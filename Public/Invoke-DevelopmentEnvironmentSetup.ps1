function Invoke-DevelopmentEnvironmentSetup {
    <#
    .SYNOPSIS
    Automates complete development environment setup with tools, configurations, and workflows.
    
    .DESCRIPTION
    The Invoke-DevelopmentEnvironmentSetup function provides comprehensive automation for setting up
    development environments including tool installation, configuration management, git workflow
    setup, and team standardization. Supports multiple platforms and customizable profiles.
    
    .PARAMETER Profile
    The setup profile to use. Options: 'Standard', 'NodeJS', 'Python', 'DotNet', 'Full', 'Custom'
    Default: 'Standard'
    
    .PARAMETER Tools
    Specific tools to install. If not specified, uses profile defaults.
    
    .PARAMETER ConfigurationPath
    Path to custom configuration file. If not specified, uses built-in configurations.
    
    .PARAMETER SkipGitSetup
    Switch to skip Git workflow and hooks setup.
    
    .PARAMETER SkipToolInstallation
    Switch to skip tool installation (configuration only).
    
    .PARAMETER TeamConfiguration
    URL or path to team configuration file for standardized setup.
    
    .PARAMETER ShowProgress
    Switch to display detailed progress information during setup.
    
    .PARAMETER WhatIf
    Switch to show what would be installed without actually doing it.
    
    .EXAMPLE
    Invoke-DevelopmentEnvironmentSetup
    
    Performs standard development environment setup with default tools and configurations.
    
    .EXAMPLE
    Invoke-DevelopmentEnvironmentSetup -Profile "NodeJS" -ShowProgress
    
    Sets up Node.js development environment with progress display.
    
    .EXAMPLE
    Invoke-DevelopmentEnvironmentSetup -Tools @("git", "vscode", "docker") -WhatIf
    
    Shows what would be installed for specified tools without actually installing.
    
    .EXAMPLE
    Invoke-DevelopmentEnvironmentSetup -TeamConfiguration "https://company.com/dev-config.json"
    
    Sets up environment using team configuration from remote URL.
    
    .OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns setup results including installed tools, configurations applied, and any errors.
    
    .NOTES
    Requires administrative privileges for system-level tool installation.
    Supports Windows, macOS, and Linux platforms.
    Creates backup of existing configurations before making changes.
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(HelpMessage = "Setup profile to use")]
        [ValidateSet('Standard', 'NodeJS', 'Python', 'DotNet', 'Full', 'Custom')]
        [string]$Profile = 'Standard',
        
        [Parameter(HelpMessage = "Specific tools to install")]
        [string[]]$Tools,
        
        [Parameter(HelpMessage = "Path to custom configuration file")]
        [string]$ConfigurationPath,
        
        [Parameter(HelpMessage = "Skip Git workflow setup")]
        [switch]$SkipGitSetup,
        
        [Parameter(HelpMessage = "Skip tool installation")]
        [switch]$SkipToolInstallation,
        
        [Parameter(HelpMessage = "Team configuration URL or path")]
        [string]$TeamConfiguration,
        
        [Parameter(HelpMessage = "Show detailed progress")]
        [switch]$ShowProgress,
        
        [Parameter(HelpMessage = "Show what would be done")]
        [switch]$WhatIf
    )
    
    begin {
        Write-Verbose "Starting development environment setup"
        Write-Verbose "Profile: $Profile"
        Write-Verbose "Platform: $([Environment]::OSVersion.Platform)"
        
        # Initialize results object
        $SetupResults = [PSCustomObject]@{
            Profile = $Profile
            Platform = [Environment]::OSVersion.Platform
            StartTime = Get-Date
            InstalledTools = @()
            ConfigurationsApplied = @()
            GitSetupComplete = $false
            Errors = @()
            Success = $true
        }
        
        # Validate permissions
        if (-not $SkipToolInstallation -and -not $WhatIf) {
            if (-not (Test-AdminPrivileges)) {
                $errorMessage = "Administrative privileges required for tool installation. Run PowerShell as Administrator or use -SkipToolInstallation."
                $SetupResults.Errors += $errorMessage
                $SetupResults.Success = $false
                Write-Error $errorMessage
                return $SetupResults
            }
        }
    }
    
    process {
        try {
            # Load configuration
            if ($ShowProgress) { Write-Host "Loading configuration..." -ForegroundColor Green }
            $config = Get-SetupConfiguration -Profile $Profile -ConfigurationPath $ConfigurationPath -TeamConfiguration $TeamConfiguration
            
            # Determine tools to install
            $toolsToInstall = if ($Tools) { $Tools } else { $config.Tools }
            
            if ($ShowProgress) {
                Write-Host "Setup Configuration:" -ForegroundColor Yellow
                Write-Host "  Profile: $($config.Profile)" -ForegroundColor White
                Write-Host "  Tools: $($toolsToInstall -join ', ')" -ForegroundColor White
                Write-Host "  Platform: $($config.Platform)" -ForegroundColor White
            }
            
            # Install tools
            if (-not $SkipToolInstallation) {
                if ($ShowProgress) { Write-Host "`nInstalling development tools..." -ForegroundColor Green }
                
                foreach ($tool in $toolsToInstall) {
                    if ($ShowProgress) { Write-Host "  Installing $tool..." -ForegroundColor Cyan }
                    
                    if ($WhatIf) {
                        Write-Host "    [WHATIF] Would install: $tool" -ForegroundColor Magenta
                        $SetupResults.InstalledTools += "[WHATIF] $tool"
                    }
                    else {
                        try {
                            $installResult = Install-DevelopmentTool -ToolName $tool -Configuration $config
                            if ($installResult.Success) {
                                $SetupResults.InstalledTools += $tool
                                if ($ShowProgress) { Write-Host "    ✓ $tool installed successfully" -ForegroundColor Green }
                            }
                            else {
                                $SetupResults.Errors += "Failed to install $tool: $($installResult.Error)"
                                if ($ShowProgress) { Write-Host "    ✗ $tool installation failed" -ForegroundColor Red }
                            }
                        }
                        catch {
                            $SetupResults.Errors += "Exception installing $tool: $($_.Exception.Message)"
                            if ($ShowProgress) { Write-Host "    ✗ $tool installation exception: $($_.Exception.Message)" -ForegroundColor Red }
                        }
                    }
                }
            }
            
            # Apply configurations
            if ($ShowProgress) { Write-Host "`nApplying configurations..." -ForegroundColor Green }
            
            foreach ($configItem in $config.Configurations) {
                if ($ShowProgress) { Write-Host "  Applying $($configItem.Name)..." -ForegroundColor Cyan }
                
                if ($WhatIf) {
                    Write-Host "    [WHATIF] Would apply: $($configItem.Name)" -ForegroundColor Magenta
                    $SetupResults.ConfigurationsApplied += "[WHATIF] $($configItem.Name)"
                }
                else {
                    try {
                        $applyResult = Apply-Configuration -Configuration $configItem
                        if ($applyResult.Success) {
                            $SetupResults.ConfigurationsApplied += $configItem.Name
                            if ($ShowProgress) { Write-Host "    ✓ $($configItem.Name) applied successfully" -ForegroundColor Green }
                        }
                        else {
                            $SetupResults.Errors += "Failed to apply $($configItem.Name): $($applyResult.Error)"
                            if ($ShowProgress) { Write-Host "    ✗ $($configItem.Name) application failed" -ForegroundColor Red }
                        }
                    }
                    catch {
                        $SetupResults.Errors += "Exception applying $($configItem.Name): $($_.Exception.Message)"
                        if ($ShowProgress) { Write-Host "    ✗ $($configItem.Name) application exception: $($_.Exception.Message)" -ForegroundColor Red }
                    }
                }
            }
            
            # Setup Git workflow
            if (-not $SkipGitSetup) {
                if ($ShowProgress) { Write-Host "`nSetting up Git workflow..." -ForegroundColor Green }
                
                if ($WhatIf) {
                    Write-Host "  [WHATIF] Would setup Git workflow and hooks" -ForegroundColor Magenta
                    $SetupResults.GitSetupComplete = $true
                }
                else {
                    try {
                        $gitResult = Initialize-GitWorkflowAutomation -Configuration $config -ShowProgress:$ShowProgress
                        $SetupResults.GitSetupComplete = $gitResult.Success
                        if (-not $gitResult.Success) {
                            $SetupResults.Errors += "Git setup failed: $($gitResult.Error)"
                        }
                    }
                    catch {
                        $SetupResults.Errors += "Git setup exception: $($_.Exception.Message)"
                        if ($ShowProgress) { Write-Host "  ✗ Git setup exception: $($_.Exception.Message)" -ForegroundColor Red }
                    }
                }
            }
            
            # Validate installation
            if (-not $WhatIf -and $ShowProgress) {
                Write-Host "`nValidating installation..." -ForegroundColor Green
                $validationResult = Test-EnvironmentConfiguration -Tools $SetupResults.InstalledTools
                if ($validationResult.Success) {
                    Write-Host "  ✓ Environment validation passed" -ForegroundColor Green
                }
                else {
                    Write-Host "  ⚠ Environment validation warnings: $($validationResult.Warnings -join ', ')" -ForegroundColor Yellow
                }
            }
            
        }
        catch {
            $SetupResults.Errors += "Setup exception: $($_.Exception.Message)"
            $SetupResults.Success = $false
            Write-Error "Development environment setup failed: $($_.Exception.Message)"
        }
    }
    
    end {
        $SetupResults.EndTime = Get-Date
        $SetupResults.Duration = $SetupResults.EndTime - $SetupResults.StartTime
        
        if ($ShowProgress) {
            Write-Host "`n" + "="*60 -ForegroundColor Yellow
            Write-Host "Development Environment Setup Complete" -ForegroundColor Yellow
            Write-Host "="*60 -ForegroundColor Yellow
            Write-Host "Profile: $($SetupResults.Profile)" -ForegroundColor White
            Write-Host "Duration: $($SetupResults.Duration.ToString('mm\:ss'))" -ForegroundColor White
            Write-Host "Tools Installed: $($SetupResults.InstalledTools.Count)" -ForegroundColor White
            Write-Host "Configurations Applied: $($SetupResults.ConfigurationsApplied.Count)" -ForegroundColor White
            Write-Host "Git Setup: $(if($SetupResults.GitSetupComplete){'✓ Complete'}else{'✗ Failed'})" -ForegroundColor White
            
            if ($SetupResults.Errors.Count -gt 0) {
                Write-Host "`nErrors ($($SetupResults.Errors.Count)):" -ForegroundColor Red
                $SetupResults.Errors | ForEach-Object { Write-Host "  • $_" -ForegroundColor Red }
                $SetupResults.Success = $false
            }
            
            if ($SetupResults.Success) {
                Write-Host "`n✓ Setup completed successfully!" -ForegroundColor Green
            }
            else {
                Write-Host "`n⚠ Setup completed with errors. See details above." -ForegroundColor Yellow
            }
        }
        
        return $SetupResults
    }
}