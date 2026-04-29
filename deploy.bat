@echo off
setlocal EnableDelayedExpansion

for /f "tokens=1-6 delims=/:. " %%a in ("%date% %time%") do (
    set "datetime=%%a-%%b-%%c-%%d-%%e"
)
set "msg=%datetime%"

echo.
echo [1/6] Building Hugo site...
hugo
if errorlevel 1 (
    echo [ERROR] Hugo build failed!
    pause
    exit /b 1
)

echo.
echo [2/6] Fetching remote changes...
git fetch origin main
if errorlevel 1 (
    echo [WARN] Fetch failed, continuing...
)

echo.
echo [3/6] Checking for local changes to stash...
git diff --quiet HEAD
if errorlevel 1 (
    echo [INFO] Stashing local changes...
    git stash push -m "Auto-stash before rebase"
    set "stashed=1"
) else (
    echo [INFO] No local changes to stash.
    set "stashed=0"
)

echo.
echo [4/6] Rebasing on remote...
git rebase origin/main
if errorlevel 1 (
    echo.
    echo [ERROR] Rebase failed! There might be conflicts.
    echo [INFO] Aborting rebase...
    git rebase --abort 2>nul
    if "!stashed!"=="1" (
        echo [INFO] Restoring stashed changes...
        git stash pop 2>nul
    )
    echo.
    echo Please resolve conflicts manually:
    echo   1. git pull origin main
    echo   2. Resolve conflicts
    echo   3. Run this script again
    pause
    exit /b 1
)

if "!stashed!"=="1" (
    echo.
    echo [5/6] Restoring stashed changes...
    git stash pop 2>nul
    if errorlevel 1 (
        git status --porcelain | findstr "^UU" >nul
        if errorlevel 1 (
            echo [INFO] Stash pop completed.
        ) else (
            echo [ERROR] Conflicts detected after stash pop!
            echo Please resolve conflicts manually.
            pause
            exit /b 1
        )
    )
) else (
    echo.
    echo [5/6] No stash to restore.
)

echo.
echo [6/6] Adding and committing changes...
git add -A

git diff --quiet --cached
if errorlevel 1 (
    git commit -m "%msg%"
    if errorlevel 1 (
        echo [ERROR] Git commit failed!
        pause
        exit /b 1
    )
    echo [INFO] Committed: %msg%
) else (
    echo [INFO] No changes to commit.
)

echo.
echo [PUSH] Pushing to GitHub...
git push origin main
if errorlevel 1 (
    echo.
    echo [ERROR] Push failed! Remote might have new commits.
    echo [INFO] Try running this script again.
    pause
    exit /b 1
)

echo.
echo ============================================
echo [SUCCESS] Blog updated and pushed to GitHub!
echo ============================================
pause