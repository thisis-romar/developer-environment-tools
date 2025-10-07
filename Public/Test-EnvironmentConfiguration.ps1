function Test-EnvironmentConfiguration {
    <#
    .SYNOPSIS
    Tests and validates development environment configuration and tool installations.
    
    .DESCRIPTION
    Performs comprehensive validation of development environment including tool versions,
    configurations, Git setup, and environment variables. Provides detailed reporting
    of any issues or missing components.
    
    .PARAMETER Tools
    Specific tools to validate. If not specified, tests all common development tools.
    
    .PARAMETER ConfigurationTests
    Additional configuration tests to perform.
    
    .PARAMETER ShowDetails
    Display detailed test results and recommendations.
    
    .PARAMETER ExportReport
    Export validation report to specified file path.
    
    .EXAMPLE
    Test-EnvironmentConfiguration -ShowDetails
    
    .EXAMPLE
    Test-EnvironmentConfiguration -Tools @("git", "node", "docker") -ExportReport "validation-report.json"
    
    .OUTPUTS
    PSCustomObject with validation results
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Specific tools to validate")]
        [string[]]$Tools,
        
        [Parameter(HelpMessage = "Configuration tests to perform")]
        [string[]]$ConfigurationTests,
        
        [Parameter(HelpMessage = "Show detailed results")]
        [switch]$ShowDetails,
        
        [Parameter(HelpMessage = "Export report path")]
        [string]$ExportReport
    )
    
    $result = [PSCustomObject]@{
        TestDate = Get-Date
        Platform = [Environment]::OSVersion.Platform
        ToolTests = @()
        ConfigurationTests = @()
        EnvironmentTests = @()
        Warnings = @()
        Errors = @()
        Success = $true
        Score = 0
        Recommendations = @()
    }
    
    try {
        if ($ShowDetails) { Write-Host "Validating development environment..." -ForegroundColor Green }
        
        # Default tools to test if none specified
        if (-not $Tools) {
            $Tools = @('git', 'node', 'npm', 'python', 'pip', 'docker', 'code')
        }
        
        # Test tool installations
        if ($ShowDetails) { Write-Host "`nTesting tool installations:" -ForegroundColor Yellow }
        
        $passedTests = 0
        $totalTests = $Tools.Count
        
        foreach ($tool in $Tools) {
            $toolTest = Test-ToolInstallation -ToolName $tool
            $result.ToolTests += $toolTest
            
            if ($toolTest.Installed) {
                $passedTests++
                if ($ShowDetails) { 
                    Write-Host "  ✓ $tool ($($toolTest.Version))" -ForegroundColor Green 
                }
            }
            else {
                $result.Errors += "Tool not found: $tool"
                if ($ShowDetails) { 
                    Write-Host "  ✗ $tool (not found)" -ForegroundColor Red 
                }
                $result.Recommendations += "Install $tool for development workflow"
            }
            
            # Check for version warnings
            if ($toolTest.Installed -and $toolTest.UpdateAvailable) {
                $result.Warnings += "$tool update available: $($toolTest.LatestVersion)"
                $result.Recommendations += "Update $tool to latest version: $($toolTest.LatestVersion)"
            }
        }
        
        # Test Git configuration
        if ($ShowDetails) { Write-Host "`nTesting Git configuration:" -ForegroundColor Yellow }
        
        $gitConfigTests = @(
            @{ Name = 'user.name'; Required = $true },
            @{ Name = 'user.email'; Required = $true },
            @{ Name = 'core.autocrlf'; Required = $false },
            @{ Name = 'init.defaultBranch'; Required = $false }
        )
        
        foreach ($configTest in $gitConfigTests) {
            $configValue = & git config --get $configTest.Name 2>$null
            
            $testResult = [PSCustomObject]@{
                Name = $configTest.Name
                Value = $configValue
                Configured = -not [string]::IsNullOrEmpty($configValue)
                Required = $configTest.Required
            }
            
            $result.ConfigurationTests += $testResult
            
            if ($testResult.Configured) {
                if ($ShowDetails) { 
                    Write-Host "  ✓ $($testResult.Name): $($testResult.Value)" -ForegroundColor Green 
                }
            }
            else {
                if ($testResult.Required) {
                    $result.Errors += "Required Git config missing: $($testResult.Name)"
                    if ($ShowDetails) { 
                        Write-Host "  ✗ $($testResult.Name) (required)" -ForegroundColor Red 
                    }
                    $result.Recommendations += "Configure Git $($testResult.Name): git config --global $($testResult.Name) 'your-value'"
                }
                else {
                    $result.Warnings += "Optional Git config missing: $($testResult.Name)"
                    if ($ShowDetails) { 
                        Write-Host "  ⚠ $($testResult.Name) (optional)" -ForegroundColor Yellow 
                    }
                }
            }
        }
        
        # Test environment variables
        if ($ShowDetails) { Write-Host "`nTesting environment variables:" -ForegroundColor Yellow }
        
        $envTests = @(
            @{ Name = 'PATH'; Required = $true },
            @{ Name = 'HOME'; Required = $false },
            @{ Name = 'USERPROFILE'; Required = $false }
        )
        
        foreach ($envTest in $envTests) {
            $envValue = [Environment]::GetEnvironmentVariable($envTest.Name)
            
            $testResult = [PSCustomObject]@{
                Name = $envTest.Name
                Configured = -not [string]::IsNullOrEmpty($envValue)
                Required = $envTest.Required
            }
            
            $result.EnvironmentTests += $testResult
            
            if ($testResult.Configured) {
                if ($ShowDetails) { 
                    Write-Host "  ✓ $($testResult.Name)" -ForegroundColor Green 
                }
            }
            else {
                if ($testResult.Required) {
                    $result.Errors += "Required environment variable missing: $($testResult.Name)"
                }
                else {
                    $result.Warnings += "Optional environment variable missing: $($testResult.Name)"
                }
            }
        }
        
        # Calculate score
        $result.Score = [math]::Round(($passedTests / $totalTests) * 100, 1)
        
        # Determine overall success
        $result.Success = $result.Errors.Count -eq 0
        
        # Display summary
        if ($ShowDetails) {
            Write-Host "`n" + "="*50 -ForegroundColor Yellow
            Write-Host "Environment Validation Summary" -ForegroundColor Yellow
            Write-Host "="*50 -ForegroundColor Yellow
            Write-Host "Score: $($result.Score)%" -ForegroundColor White
            Write-Host "Tools Passed: $passedTests/$totalTests" -ForegroundColor White
            Write-Host "Errors: $($result.Errors.Count)" -ForegroundColor $(if($result.Errors.Count -eq 0){'Green'}else{'Red'})
            Write-Host "Warnings: $($result.Warnings.Count)" -ForegroundColor $(if($result.Warnings.Count -eq 0){'Green'}else{'Yellow'})
            
            if ($result.Recommendations.Count -gt 0) {
                Write-Host "`nRecommendations:" -ForegroundColor Cyan
                $result.Recommendations | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
            }
            
            $statusColor = switch ($result.Score) {
                {$_ -ge 90} { 'Green' }
                {$_ -ge 70} { 'Yellow' }
                default { 'Red' }
            }
            
            $statusMessage = switch ($result.Score) {
                {$_ -ge 90} { "Excellent - Environment is well configured" }
                {$_ -ge 70} { "Good - Minor improvements recommended" }
                default { "Needs Attention - Several issues need resolution" }
            }
            
            Write-Host "`nStatus: $statusMessage" -ForegroundColor $statusColor
        }
        
        # Export report if requested
        if ($ExportReport) {
            $result | ConvertTo-Json -Depth 3 | Set-Content -Path $ExportReport -Encoding UTF8
            if ($ShowDetails) { 
                Write-Host "`nReport exported to: $ExportReport" -ForegroundColor Cyan 
            }
        }
    }
    catch {
        $result.Success = $false
        $result.Errors += "Validation exception: $($_.Exception.Message)"
        if ($ShowDetails) { 
            Write-Host "Environment validation failed: $($_.Exception.Message)" -ForegroundColor Red 
        }
    }
    
    return $result
}