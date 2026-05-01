#!/usr/bin/env bash
set -euo pipefail

msg="$(date "+%Y-%m-%d-%H-%M")"

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[ERROR] Missing required command: $1" >&2
        exit 1
    fi
}

step() {
    echo ""
    echo "[$1/5] $2"
}

need_cmd git
need_cmd hugo

branch="$(git branch --show-current)"
if [ "$branch" != "main" ]; then
    echo "[ERROR] Deploy must run from the main branch. Current branch: $branch" >&2
    exit 1
fi

step 1 "Syncing with origin/main..."
git pull --rebase --autostash origin main

step 2 "Building Hugo site..."
hugo

step 3 "Adding and committing changes..."
git add -A
if [ -n "$(git diff --cached --name-only)" ]; then
    git commit -m "$msg"
    echo "[INFO] Committed: $msg"
else
    echo "[INFO] No changes to commit."
fi

step 4 "Pushing to GitHub..."
git push origin main

step 5 "Done."
echo ""
echo "============================================"
echo "[SUCCESS] Blog updated and pushed to GitHub!"
echo "============================================"
