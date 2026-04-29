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
echo "[2/6] Checking for uncommitted changes..."
if [ -z "$(git status --porcelain)" ]; then
    echo "[INFO] No local changes to commit."
    # goto push_only equivalent
    echo ""
    echo "[PUSH] Pushing to GitHub..."
    git push origin main
    if [ $? -ne 0 ]; then
        echo ""
        echo "[ERROR] Push failed! Remote might have new commits."
        echo "[INFO] Try running this script again to pull and merge."
        exit 1
    fi
    echo ""
    echo "============================================"
    echo "[SUCCESS] Blog updated and pushed to GitHub!"
    echo "============================================"
    exit 0
fi

echo ""
echo "[3/6] Stashing local changes..."
git stash push -m "Auto-stash before pull"
if [ $? -ne 0 ]; then
    echo "[WARN] Stash failed or nothing to stash, continuing..."
fi

echo ""
echo "[4/6] Pulling remote changes..."
git fetch origin main
git rebase origin/main
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Rebase failed! There might be conflicts."
    echo "[INFO] Aborting rebase..."
    git rebase --abort 2>/dev/null
    echo "[INFO] Restoring stashed changes..."
    git stash pop 2>/dev/null
    echo ""
    echo "Please resolve conflicts manually:"
    echo "  1. git pull origin main"
    echo "  2. Resolve conflicts"
    echo "  3. Run this script again"
    exit 1
fi

echo ""
echo "[5/6] Restoring stashed changes..."
git stash pop 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[WARN] Stash pop had conflicts, please resolve manually."
    exit 1
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
fi

echo ""
echo "[PUSH] Pushing to GitHub..."
git push origin main
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Push failed! Remote might have new commits."
    echo "[INFO] Try running this script again to pull and merge."
    exit 1
fi

echo ""
echo "============================================"
echo "[SUCCESS] Blog updated and pushed to GitHub!"
echo "============================================"