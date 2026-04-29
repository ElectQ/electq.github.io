@echo off
setlocal EnableDelayedExpansion

REM Get datetime format YYYY-MM-DD-HH-MM
for /f %%i in ('wmic os get LocalDateTime ^| find "."') do set dt=%%i
set msg=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%-%dt:~8,2%-%dt:~10,2%

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

echo.
echo [3/6] Rebasing on remote...
git rebase origin/main
if errorlevel 1 (
    echo [ERROR] Rebase failed! There might be conflicts.
    echo [INFO] Aborting rebase...
    git rebase --abort
    echo Please resolve conflicts manually:
    echo   1. git pull origin main
    echo   2. Resolve conflicts
    echo   3. Run this script again
    pause
    exit /b 1
)

echo.
echo [4/6] Checking stash...
git stash list | findstr "Auto-stash" >nul
if not errorlevel 1 (
    echo [INFO] Restoring stashed changes...
    git stash pop
    git status --porcelain | findstr "^UU" >nul
    if not errorlevel 1 (
        echo [ERROR] Conflicts detected after stash pop!
        echo Please resolve conflicts manually.
        pause
        exit /b 1
    )
) else (
    echo [INFO] No stash to restore.
)

echo.
echo [5/6] Adding and committing changes...
git add -A

git diff --quiet --cached
if errorlevel 1 (
    git commit -m "!msg!"
    echo [INFO] Committed: !msg!
) else (
    echo [INFO] No changes to commit.
)

echo.
echo [PUSH] Pushing to GitHub...
git push origin main
if errorlevel 1 (
    echo [ERROR] Push failed! Try running again.
    pause
    exit /b 1
)

echo.
echo ============================================
echo [SUCCESS] Blog updated and pushed to GitHub!
echo ============================================
pause