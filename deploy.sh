#!/bin/bash

datetime=$(date "+%Y-%m-%d-%H-%M")
msg="$datetime"

echo ""
echo "[1/5] Building Hugo site..."
hugo 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[ERROR] Hugo build failed!"
    exit 1
fi

echo ""
echo "[2/5] Adding and committing changes..."
git add -A
if [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
    git commit -m "$msg" 2>/dev/null
    echo "[INFO] Committed: $msg"
else
    echo "[INFO] No changes to commit."
fi

echo ""
echo "[3/5] Fetching remote changes..."
git fetch origin main 2>/dev/null

echo ""
echo "[4/5] Rebasing on remote..."
git rebase origin/main 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[ERROR] Rebase failed!"
    git rebase --abort 2>/dev/null
    exit 1
fi

echo ""
echo "[5/5] Pushing to GitHub..."
git push origin main
if [ $? -ne 0 ]; then
    echo "[ERROR] Push failed!"
    exit 1
fi

echo ""
echo "============================================"
echo "[SUCCESS] Blog updated and pushed to GitHub!"
echo "============================================"