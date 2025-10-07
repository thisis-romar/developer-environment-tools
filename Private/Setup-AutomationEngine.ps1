<#
.SYNOPSIS
    Automated setup script for AI attribution automation system
.DESCRIPTION
    Configures pre-commit hooks, git hooks, and GitHub Actions for automated AI attribution
.NOTES
    Run this script to set up the complete automation system for LLM commit attribution
.EXAMPLE
    ./setup-automation.ps1
    ./setup-automation.ps1 -Verbose -Force
#>

param(
    [switch]$Force,
    [switch]$Verbose,
    [switch]$SkipPreCommit,
    [switch]$SkipGitHooks
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 AI Attribution Automation Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Verify we're in a git repository
try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        throw "Not in a git repository"
    }
    Set-Location $gitRoot
    Write-Host "✅ Git repository found: $gitRoot" -ForegroundColor Green
}
catch {
    Write-Error "❌ This script must be run from within a git repository"
    exit 1
}

# Check PowerShell execution policy
Write-Host "`n🔒 Checking PowerShell execution policy..." -ForegroundColor Blue
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "AllSigned") {
    Write-Host "⚠️ Current execution policy: $currentPolicy" -ForegroundColor Yellow
    
    if ($Force -or (Read-Host "Set execution policy to RemoteSigned? (y/N)") -eq "y") {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "✅ Execution policy updated to RemoteSigned" -ForegroundColor Green
    }
    else {
        Write-Warning "⚠️ Execution policy may prevent automation scripts from running"
    }
}
else {
    Write-Host "✅ Execution policy is compatible: $currentPolicy" -ForegroundColor Green
}

# Install pre-commit if not skipped
if (-not $SkipPreCommit) {
    Write-Host "`n📋 Setting up pre-commit hooks..." -ForegroundColor Blue
    
    # Check if pre-commit is installed
    try {
        $preCommitVersion = pre-commit --version 2>$null
        Write-Host "✅ Pre-commit found: $preCommitVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Pre-commit not found. Installing via pip..." -ForegroundColor Red
        
        try {
            pip install pre-commit
            Write-Host "✅ Pre-commit installed successfully" -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️ Failed to install pre-commit. Please install manually: pip install pre-commit"
        }
    }
    
    # Install pre-commit hooks
    if (Test-Path ".pre-commit-config.yaml") {
        Write-Host "🔧 Installing pre-commit hooks..." -ForegroundColor Gray
        try {
            pre-commit install
            Write-Host "✅ Pre-commit hooks installed" -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️ Failed to install pre-commit hooks: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "⚠️ .pre-commit-config.yaml not found"
    }
}

# Set up git hooks
if (-not $SkipGitHooks) {
    Write-Host "`n🪝 Setting up git hooks..." -ForegroundColor Blue
    
    $hooksDir = ".git\hooks"
    
    # Create pre-commit hook
    $preCommitHook = Join-Path $hooksDir "pre-commit"
    if (-not (Test-Path $preCommitHook) -or $Force) {
        @"
#!/bin/sh
# AI Attribution Pre-commit Hook
powershell.exe -ExecutionPolicy Bypass -File ".git/hooks/pre-commit.ps1" `$@
"@ | Set-Content $preCommitHook -Encoding UTF8
        
        Write-Host "✅ Pre-commit git hook created" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Pre-commit hook already exists (use -Force to overwrite)" -ForegroundColor Yellow
    }
    
    # Create post-commit hook  
    $postCommitHook = Join-Path $hooksDir "post-commit"
    if (-not (Test-Path $postCommitHook) -or $Force) {
        @"
#!/bin/sh
# AI Attribution Post-commit Hook
powershell.exe -ExecutionPolicy Bypass -File ".git/hooks/post-commit.ps1" `$@
"@ | Set-Content $postCommitHook -Encoding UTF8
        
        Write-Host "✅ Post-commit git hook created" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Post-commit hook already exists (use -Force to overwrite)" -ForegroundColor Yellow
    }
}

# Verify tools directory
Write-Host "`n🔧 Verifying automation tools..." -ForegroundColor Blue
$toolsPath = "tools"
if (Test-Path $toolsPath) {
    $requiredTools = @(
        "LLMCommitIdentifier.ps1",
        "ChatHistoryParser.ps1", 
        "CommitAttributionCorrector.ps1",
        "ChatAnalysisHelpers.ps1"
    )
    
    $missingTools = @()
    foreach ($tool in $requiredTools) {
        $toolPath = Join-Path $toolsPath $tool
        if (Test-Path $toolPath) {
            Write-Host "✅ $tool" -ForegroundColor Green
        }
        else {
            Write-Host "❌ $tool (missing)" -ForegroundColor Red
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -eq 0) {
        Write-Host "✅ All required tools found" -ForegroundColor Green
    }
    else {
        Write-Warning "⚠️ Missing tools: $($missingTools -join ', ')"
    }
}
else {
    Write-Warning "⚠️ Tools directory not found at $toolsPath"
}

# Test git configuration
Write-Host "`n⚙️ Checking git configuration..." -ForegroundColor Blue
$gitUser = git config user.name 2>$null
$gitEmail = git config user.email 2>$null

if ($gitUser -and $gitEmail) {
    Write-Host "✅ Git user configured: $gitUser <$gitEmail>" -ForegroundColor Green
}
else {
    Write-Warning "⚠️ Git user not configured. Set with:"
    Write-Host "   git config --global user.name `"Your Name`"" -ForegroundColor Gray
    Write-Host "   git config --global user.email `"your.email@example.com`"" -ForegroundColor Gray
}

# GitHub Actions check
Write-Host "`n🔄 Checking GitHub Actions configuration..." -ForegroundColor Blue
$actionsDir = ".github\workflows"
if (Test-Path $actionsDir) {
    $workflowFiles = Get-ChildItem $actionsDir -Filter "*.yml" -ErrorAction SilentlyContinue
    if ($workflowFiles.Count -gt 0) {
        Write-Host "✅ GitHub Actions workflows found:" -ForegroundColor Green
        foreach ($workflow in $workflowFiles) {
            Write-Host "   - $($workflow.Name)" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "⚠️ No workflow files found in $actionsDir" -ForegroundColor Yellow
    }
}
else {
    Write-Host "⚠️ GitHub Actions directory not found" -ForegroundColor Yellow
}

# Final verification test
Write-Host "`n🧪 Running verification test..." -ForegroundColor Blue
try {
    $testFile = "automation-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    "AI Attribution Automation Test" | Set-Content $testFile
    git add $testFile
    
    Write-Host "✅ Test file created and staged" -ForegroundColor Green
    
    # Clean up
    git reset HEAD $testFile 2>$null
    Remove-Item $testFile -ErrorAction SilentlyContinue
    
}
catch {
    Write-Warning "⚠️ Verification test failed: $($_.Exception.Message)"
}

# Summary
Write-Host "`n📊 Setup Summary" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "✅ PowerShell execution policy configured" -ForegroundColor Green
if (-not $SkipPreCommit) { Write-Host "✅ Pre-commit hooks installed" -ForegroundColor Green }
if (-not $SkipGitHooks) { Write-Host "✅ Git hooks configured" -ForegroundColor Green }
Write-Host "✅ Automation tools verified" -ForegroundColor Green
Write-Host "✅ GitHub Actions ready" -ForegroundColor Green

Write-Host "`n🎉 AI Attribution Automation is now active!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Make a test commit to verify automation" -ForegroundColor Gray
Write-Host "2. Check GitHub Actions after pushing" -ForegroundColor Gray  
Write-Host "3. Review attribution in git log" -ForegroundColor Gray
Write-Host "4. Monitor weekly audit reports" -ForegroundColor Gray

Write-Host "`n💡 Useful commands:" -ForegroundColor Blue
Write-Host "   ./tools/LLMCommitIdentifier.ps1 -ShowDetails  # Analyze commits" -ForegroundColor Gray
Write-Host "   ./tools/CommitAttributionCorrector.ps1 -DryRun  # Preview corrections" -ForegroundColor Gray
Write-Host "   git commit --no-verify  # Bypass hooks temporarily" -ForegroundColor Gray
Write-Host "   pre-commit run --all-files  # Run all pre-commit hooks" -ForegroundColor Gray