# DeveloperEnvironmentTools PowerShell Module
# Professional development environment automation

# Get the path to this script's directory
$ModuleRoot = $PSScriptRoot

# Import all public functions
$PublicFunctions = Get-ChildItem -Path "$ModuleRoot\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue
foreach ($Function in $PublicFunctions) {
    try {
        . $Function.FullName
        Write-Verbose "Imported function: $($Function.BaseName)"
    }
    catch {
        Write-Error "Failed to import function $($Function.FullName): $($_.Exception.Message)"
    }
}

# Import all private functions  
$PrivateFunctions = Get-ChildItem -Path "$ModuleRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue
foreach ($Function in $PrivateFunctions) {
    try {
        . $Function.FullName
        Write-Verbose "Imported private function: $($Function.BaseName)"
    }
    catch {
        Write-Error "Failed to import private function $($Function.FullName): $($_.Exception.Message)"
    }
}

# Module variables for configuration
$Script:ModuleConfig = @{
    DefaultToolsPath = "$env:ProgramFiles\DeveloperTools"
    ConfigPath = "$env:USERPROFILE\.devenv"
    LogPath = "$env:TEMP\DeveloperEnvironmentTools.log"
    SupportedPlatforms = @('Windows', 'Linux', 'macOS')
    DefaultProfile = 'Standard'
}

# Initialize module
Write-Verbose "DeveloperEnvironmentTools module loaded successfully"
Write-Verbose "Module root: $ModuleRoot"
Write-Verbose "Public functions: $($PublicFunctions.Count)"
Write-Verbose "Private functions: $($PrivateFunctions.Count)"

# Export module members (functions are exported via manifest)
# This ensures only intended functions are available to users