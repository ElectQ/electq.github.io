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

echo ""
echo "[3/6] Rebasing on remote..."
git rebase origin/main
if [ $? -ne 0 ]; then
    echo "[ERROR] Rebase failed! There might be conflicts."
    echo "[INFO] Aborting rebase..."
    git rebase --abort
    echo ""
    echo "Please resolve conflicts manually:"
    echo "  1. git pull origin main"
    echo "  2. Resolve conflicts"
    echo "  3. Run this script again"
    exit 1
fi

echo ""
echo "[4/6] Checking stash..."
if git stash list | grep -q "Auto-stash"; then
    echo "[INFO] Restoring stashed changes..."
    git stash pop
    if git status --porcelain | grep -q "^UU"; then
        echo "[ERROR] Conflicts detected after stash pop!"
        echo "Please resolve conflicts manually."
        exit 1
    fi
else
    echo "[INFO] No stash to restore."
fi

echo ""
echo "[5/6] Adding and committing changes..."
git add -A

if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "$msg"
    echo "[INFO] Committed: $msg"
else
    echo "[INFO] No changes to commit."
fi

echo ""
echo "[PUSH] Pushing to GitHub..."
git push origin main
if [ $? -ne 0 ]; then
    echo "[ERROR] Push failed! Try running again."
    exit 1
fi

echo ""
echo "============================================"
echo "[SUCCESS] Blog updated and pushed to GitHub!"
echo "============================================"