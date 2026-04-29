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
echo [2/6] Checking for uncommitted changes...
for /f %%i in ('git status --porcelain') do (
    set "has_changes=1"
)
if not defined has_changes (
    echo [INFO] No local changes to commit.
    goto :push_only
)

echo.
echo [3/6] Stashing local changes...
git stash push -m "Auto-stash before pull"
if errorlevel 1 (
    echo [WARN] Stash failed or nothing to stash, continuing...
)

echo.
echo [4/6] Pulling remote changes...
git fetch origin main
git rebase origin/main
if errorlevel 1 (
    echo.
    echo [ERROR] Rebase failed! There might be conflicts.
    echo [INFO] Aborting rebase...
    git rebase --abort 2>nul
    echo [INFO] Restoring stashed changes...
    git stash pop 2>nul
    echo.
    echo Please resolve conflicts manually:
    echo   1. git pull origin main
    echo   2. Resolve conflicts
    echo   3. Run this script again
    pause
    exit /b 1
)

echo.
echo [5/6] Restoring stashed changes...
git stash pop 2>nul
if errorlevel 1 (
    echo [WARN] Stash pop had conflicts, please resolve manually.
    pause
    exit /b 1
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
)

:push_only
echo.
echo [PUSH] Pushing to GitHub...
git push origin main
if errorlevel 1 (
    echo.
    echo [ERROR] Push failed! Remote might have new commits.
    echo [INFO] Try running this script again to pull and merge.
    pause
    exit /b 1
)

echo.
echo ============================================
echo [SUCCESS] Blog updated and pushed to GitHub!
echo ============================================
pause
endlocal