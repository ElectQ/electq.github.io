#!/bin/bash

datetime=$(date "+%Y-%m-%d-%H-%M")
msg="$datetime"

echo ""
echo "[1/6] Building Hugo site..."
hugo 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[ERROR] Hugo build failed!"
    exit 1
fi

echo ""
echo "[2/6] Fetching remote changes..."
git fetch origin main 2>/dev/null

echo ""
echo "[3/6] Stashing local changes..."
git stash 2>/dev/null

echo ""
echo "[4/6] Rebasing on remote..."
git rebase origin/main 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[ERROR] Rebase failed!"
    git rebase --abort 2>/dev/null
    git stash pop 2>/dev/null
    exit 1
fi

echo ""
echo "[5/6] Restoring stashed changes..."
git stash pop 2>/dev/null

echo ""
echo "[6/6] Adding and committing changes..."
git add -A
if [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
    git commit -m "$msg" 2>/dev/null
    echo "[INFO] Committed: $msg"
else
    echo "[INFO] No changes to commit."
fi

echo ""
echo "[PUSH] Pushing to GitHub..."
git push origin main
if [ $? -ne 0 ]; then
    echo "[ERROR] Push failed!"
    exit 1
fi

echo ""
echo "============================================"
echo "[SUCCESS] Blog updated and pushed to GitHub!"
echo "============================================"