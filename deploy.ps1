$ErrorActionPreference = "Stop"

$msg = Get-Date -Format "yyyy-MM-dd-HH-mm"

function Step($Number, $Text) {
    Write-Host ""
    Write-Host "[$Number/5] $Text" -ForegroundColor Cyan
}

function Invoke-Checked($Command, [string[]]$Arguments = @()) {
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Command $($Arguments -join ' ')"
    }
}

function Require-Command($Command) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Command"
    }
}

try {
    Require-Command "git"
    Require-Command "hugo"

    $branch = (& git branch --show-current).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to determine current git branch."
    }
    if ($branch -ne "main") {
        throw "Deploy must run from the main branch. Current branch: $branch"
    }

    Step 1 "Syncing with origin/main..."
    Invoke-Checked "git" @("pull", "--rebase", "--autostash", "origin", "main")

    Step 2 "Building Hugo site..."
    Invoke-Checked "hugo" @()

    Step 3 "Adding and committing changes..."
    Invoke-Checked "git" @("add", "-A")
    $staged = & git diff --cached --name-only
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to inspect staged changes."
    }

    if ($staged) {
        Invoke-Checked "git" @("commit", "-m", $msg)
        Write-Host "[INFO] Committed: $msg" -ForegroundColor Yellow
    } else {
        Write-Host "[INFO] No changes to commit." -ForegroundColor Yellow
    }

    Step 4 "Pushing to GitHub..."
    Invoke-Checked "git" @("push", "origin", "main")

    Step 5 "Done."
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "[SUCCESS] Blog updated and pushed to GitHub!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Read-Host "Press Enter to exit"
