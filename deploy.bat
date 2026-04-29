@echo off
<<<<<<< Updated upstream
powershell -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
=======
setlocal

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
echo [3/6] Stashing unstaged changes before rebase...
git stash push -m "Auto-stash-before-rebase" 2>nul

REM Check if stash was created
git stash list | findstr "Auto-stash-before-rebase" >nul
if not errorlevel 1 (
    set stashed=1
    echo [INFO] Local changes stashed.
) else (
    set stashed=0
    echo [INFO] No unstaged changes to stash.
)

echo.
echo [4/6] Rebasing on remote...
git rebase origin/main
if errorlevel 1 (
    echo [ERROR] Rebase failed! There might be conflicts.
    echo [INFO] Aborting rebase...
    git rebase --abort
    if %stashed%==1 (
        echo [INFO] Restoring stashed changes...
        git stash pop
    )
    echo.
    echo Please resolve conflicts manually:
    echo   1. git pull origin main
    echo   2. Resolve conflicts
    echo   3. Run this script again
    pause
    exit /b 1
)

if %stashed%==1 (
    echo.
    echo [5/6] Restoring stashed changes...
    git stash pop
    git status --porcelain 2>nul | findstr "^UU" >nul
    if not errorlevel 1 (
        echo [ERROR] Conflicts detected after stash pop!
        echo Please resolve conflicts manually.
        pause
        exit /b 1
    )
    echo [INFO] Stash restored.
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
    echo [INFO] Committed: %msg%
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
>>>>>>> Stashed changes
