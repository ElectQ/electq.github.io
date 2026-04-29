#!/bin/bash

datetime=$(date "+%Y-%m-%d-%H-%M")
msg="$datetime"

echo ""
echo "[1/6] Building Hugo site..."
hugo
if [ $? -ne 0 ]; then
    echo "[ERROR] Hugo build failed!"
    exit 1
fi

echo ""
echo "[2/6] Fetching remote changes..."
git fetch origin main
if [ $? -ne 0 ]; then
    echo "[WARN] Fetch failed, continuing..."
fi

echo ""
echo "[3/6] Checking for local changes to stash..."
if [ -n "$(git diff HEAD --name-only)" ]; then
    echo "[INFO] Stashing local changes..."
    git stash push -m "Auto-stash before rebase"
    stashed=1
else
    echo "[INFO] No local changes to stash."
    stashed=0
fi

echo ""
echo "[4/6] Rebasing on remote..."
git rebase origin/main
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Rebase failed! There might be conflicts."
    echo "[INFO] Aborting rebase..."
    git rebase --abort 2>/dev/null
    if [ "$stashed" -eq 1 ]; then
        echo "[INFO] Restoring stashed changes..."
        git stash pop 2>/dev/null
    fi
    echo ""
    echo "Please resolve conflicts manually:"
    echo "  1. git pull origin main"
    echo "  2. Resolve conflicts"
    echo "  3. Run this script again"
    exit 1
fi

if [ "$stashed" -eq 1 ]; then
    echo ""
    echo "[5/6] Restoring stashed changes..."
    git stash pop 2>/dev/null
    if [ $? -ne 0 ]; then
        if git status --porcelain | grep -q "^UU"; then
            echo "[ERROR] Conflicts detected after stash pop!"
            echo "Please resolve conflicts manually."
            exit 1
        else
            echo "[INFO] Stash pop completed."
        fi
    fi
else
    echo ""
    echo "[5/6] No stash to restore."
fi

echo ""
echo "[6/6] Adding and committing changes..."
git add -A

if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "$msg"
    if [ $? -ne 0 ]; then
        echo "[ERROR] Git commit failed!"
        exit 1
    fi
    echo "[INFO] Committed: $msg"
else
    echo "[INFO] No changes to commit."
fi

echo ""
echo "[PUSH] Pushing to GitHub..."
git push origin main
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Push failed! Remote might have new commits."
    echo "[INFO] Try running this script again."
    exit 1
fi

echo ""
echo "============================================"
echo "[SUCCESS] Blog updated and pushed to GitHub!"
echo "============================================"