$datetime = Get-Date -Format "yyyy-MM-dd-HH-mm"
$msg = $datetime

Write-Host ""
Write-Host "[1/5] Building Hugo site..." -ForegroundColor Cyan
& hugo 2>&1 | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | Out-Default
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Hugo build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[2/5] Adding and committing changes..." -ForegroundColor Cyan
& git add -A
$staged = git diff --cached --name-only 2>&1
if ($staged) {
    & git commit -m $msg *>&1 | Out-Null
    Write-Host "[INFO] Committed: $msg" -ForegroundColor Yellow
} else {
    Write-Host "[INFO] No changes to commit." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/5] Fetching remote changes..." -ForegroundColor Cyan
& git fetch origin main *>&1 | Out-Null

Write-Host ""
Write-Host "[4/5] Rebasing on remote..." -ForegroundColor Cyan
& git rebase origin/main *>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Rebase failed!" -ForegroundColor Red
    & git rebase --abort *>&1 | Out-Null
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[5/5] Pushing to GitHub..." -ForegroundColor Cyan
& git push origin main *>&1 | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | Out-Default
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Push failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "[SUCCESS] Blog updated and pushed to GitHub!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Read-Host "Press Enter to exit"