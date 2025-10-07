function Install-PreCommitHooks {
    <#
    .SYNOPSIS
    Installs and configures pre-commit hooks for code quality and consistency.
    
    .DESCRIPTION
    Sets up pre-commit framework with hooks for linting, formatting, security scanning,
    and other code quality checks. Supports multiple languages and frameworks.
    
    .PARAMETER Repository
    Path to Git repository. Defaults to current directory.
    
    .PARAMETER HookConfiguration
    Custom hook configuration. Uses defaults if not specified.
    
    .PARAMETER Language
    Primary language for hook selection. Options: 'JavaScript', 'Python', 'CSharp', 'Go', 'Mixed'
    
    .PARAMETER InstallFramework
    Install pre-commit framework if not present.
    
    .PARAMETER ShowProgress
    Display detailed progress information.
    
    .EXAMPLE
    Install-PreCommitHooks -Language JavaScript -ShowProgress
    
    .EXAMPLE
    Install-PreCommitHooks -Repository "C:\Projects\MyApp" -Language Python
    
    .OUTPUTS
    PSCustomObject with installation results
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Git repository path")]
        [string]$Repository = (Get-Location).Path,
        
        [Parameter(HelpMessage = "Hook configuration")]
        [hashtable]$HookConfiguration,
        
        [Parameter(HelpMessage = "Primary programming language")]
        [ValidateSet('JavaScript', 'Python', 'CSharp', 'Go', 'Mixed')]
        [string]$Language = 'Mixed',
        
        [Parameter(HelpMessage = "Install pre-commit framework")]
        [switch]$InstallFramework,
        
        [Parameter(HelpMessage = "Show progress")]
        [switch]$ShowProgress
    )
    
    $result = [PSCustomObject]@{
        Repository = $Repository
        Language = $Language
        FrameworkInstalled = $false
        HooksConfigured = @()
        ConfigurationFile = $null
        Success = $true
        Error = $null
    }
    
    try {
        if ($ShowProgress) { Write-Host "Installing pre-commit hooks for $Language..." -ForegroundColor Green }
        
        # Validate repository
        if (-not (Test-Path "$Repository\.git")) {
            throw "Not a Git repository: $Repository"
        }
        
        # Install pre-commit framework if needed
        if ($InstallFramework -or -not (Get-Command 'pre-commit' -ErrorAction SilentlyContinue)) {
            if ($ShowProgress) { Write-Host "  Installing pre-commit framework..." -ForegroundColor Cyan }
            
            $frameworkResult = Install-PreCommitFramework
            $result.FrameworkInstalled = $frameworkResult.Success
            
            if (-not $frameworkResult.Success) {
                throw "Failed to install pre-commit framework: $($frameworkResult.Error)"
            }
        }
        
        # Generate hook configuration
        $configPath = Join-Path $Repository '.pre-commit-config.yaml'
        
        if (-not $HookConfiguration) {
            $HookConfiguration = Get-DefaultHookConfiguration -Language $Language
        }
        
        if ($ShowProgress) { Write-Host "  Generating hook configuration..." -ForegroundColor Cyan }
        
        $configContent = ConvertTo-PreCommitConfig -Configuration $HookConfiguration
        Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        
        $result.ConfigurationFile = $configPath
        $result.HooksConfigured = $HookConfiguration.Keys
        
        # Install hooks
        if ($ShowProgress) { Write-Host "  Installing hooks..." -ForegroundColor Cyan }
        
        Push-Location $Repository
        try {
            $installOutput = & pre-commit install 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Pre-commit install failed: $installOutput"
            }
            
            if ($ShowProgress) { Write-Host "    ✓ Hooks installed successfully" -ForegroundColor Green }
        }
        finally {
            Pop-Location
        }
        
        # Run initial check
        if ($ShowProgress) { Write-Host "  Running initial hook validation..." -ForegroundColor Cyan }
        
        Push-Location $Repository
        try {
            $checkOutput = & pre-commit run --all-files 2>&1
            # Note: pre-commit may exit with non-zero on first run due to formatting changes
            if ($ShowProgress) { 
                Write-Host "    ✓ Initial validation complete" -ForegroundColor Green 
                if ($checkOutput) {
                    Write-Host "    Hook output: $checkOutput" -ForegroundColor Yellow
                }
            }
        }
        catch {
            # Non-critical - first run often has formatting issues
            if ($ShowProgress) { Write-Host "    ⚠ Initial run had formatting changes (normal)" -ForegroundColor Yellow }
        }
        finally {
            Pop-Location
        }
        
        if ($ShowProgress) { Write-Host "✓ Pre-commit hooks installation complete" -ForegroundColor Green }
    }
    catch {
        $result.Success = $false
        $result.Error = $_.Exception.Message
        if ($ShowProgress) { Write-Host "✗ Pre-commit installation failed: $($_.Exception.Message)" -ForegroundColor Red }
    }
    
    return $result
}