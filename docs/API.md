# Developer Environment Tools - API Reference

## Public Functions

### Invoke-DevelopmentEnvironmentSetup
Automates complete development environment setup with tools, configurations, and workflows.

**Syntax:**
```powershell
Invoke-DevelopmentEnvironmentSetup 
    [-Profile] <String>
    [-Tools] <String[]>
    [-ConfigurationPath] <String>
    [-SkipGitSetup]
    [-SkipToolInstallation] 
    [-TeamConfiguration] <String>
    [-ShowProgress]
    [-WhatIf]
```

**Parameters:**
- `Profile`: Setup profile ('Standard', 'NodeJS', 'Python', 'DotNet', 'Full', 'Custom')
- `Tools`: Specific tools to install
- `ConfigurationPath`: Path to custom configuration file
- `SkipGitSetup`: Skip Git workflow setup
- `SkipToolInstallation`: Skip tool installation
- `TeamConfiguration`: Team configuration URL or path
- `ShowProgress`: Display detailed progress
- `WhatIf`: Show what would be done without executing

**Returns:** PSCustomObject with setup results

### Initialize-GitWorkflowAutomation
Initializes Git workflow automation including hooks, templates, and workflow rules.

**Syntax:**
```powershell
Initialize-GitWorkflowAutomation
    [-Repository] <String>
    [-HookTypes] <String[]>
    [-Configuration] <Object>
    [-ShowProgress]
```

**Parameters:**
- `Repository`: Git repository path (default: current directory)
- `HookTypes`: Git hook types to install (default: pre-commit, commit-msg, pre-push)
- `Configuration`: Configuration object
- `ShowProgress`: Display progress information

**Returns:** PSCustomObject with automation results

### Install-PreCommitHooks
Installs and configures pre-commit hooks for code quality and consistency.

**Syntax:**
```powershell
Install-PreCommitHooks
    [-Repository] <String>
    [-HookConfiguration] <Hashtable>
    [-Language] <String>
    [-InstallFramework]
    [-ShowProgress]
```

**Parameters:**
- `Repository`: Git repository path (default: current directory)
- `HookConfiguration`: Custom hook configuration
- `Language`: Primary language ('JavaScript', 'Python', 'CSharp', 'Go', 'Mixed')
- `InstallFramework`: Install pre-commit framework if not present
- `ShowProgress`: Display progress information

**Returns:** PSCustomObject with installation results

### Test-EnvironmentConfiguration
Tests and validates development environment configuration and tool installations.

**Syntax:**
```powershell
Test-EnvironmentConfiguration
    [-Tools] <String[]>
    [-ConfigurationTests] <String[]>
    [-ShowDetails]
    [-ExportReport] <String>
```

**Parameters:**
- `Tools`: Specific tools to validate
- `ConfigurationTests`: Additional configuration tests
- `ShowDetails`: Display detailed test results
- `ExportReport`: Export validation report to file

**Returns:** PSCustomObject with validation results

### New-EnvironmentProfile
Creates a new custom environment setup profile.

**Syntax:**
```powershell
New-EnvironmentProfile
    [-Name] <String>
    [-Tools] <String[]>
    [-Configurations] <Hashtable>
    [-Description] <String>
    [-SaveToFile] <String>
```

**Parameters:**
- `Name`: Profile name
- `Tools`: Tools to include in profile
- `Configurations`: Configuration settings
- `Description`: Profile description
- `SaveToFile`: Save profile to file path

### Import-TeamConfiguration
Imports team configuration settings from URL or file.

**Syntax:**
```powershell
Import-TeamConfiguration
    [-ConfigUrl] <String>
    [-ConfigPath] <String>
    [-ApplyImmediately]
    [-Validate]
```

**Parameters:**
- `ConfigUrl`: Configuration URL
- `ConfigPath`: Local configuration file path
- `ApplyImmediately`: Apply configuration immediately
- `Validate`: Validate configuration before import

### Initialize-MultiProjectEnvironment
Initializes environment setup for multiple projects with shared configuration.

**Syntax:**
```powershell
Initialize-MultiProjectEnvironment
    [-Projects] <String[]>
    [-SharedConfiguration] <Hashtable>
    [-WorkspaceRoot] <String>
    [-ShowProgress]
```

**Parameters:**
- `Projects`: Array of project names or paths
- `SharedConfiguration`: Shared configuration settings
- `WorkspaceRoot`: Root directory for projects
- `ShowProgress`: Display progress information

## Return Objects

### Setup Results Object
```powershell
@{
    Profile = String
    Platform = String
    StartTime = DateTime
    EndTime = DateTime
    Duration = TimeSpan
    InstalledTools = String[]
    ConfigurationsApplied = String[]
    GitSetupComplete = Boolean
    Errors = String[]
    Success = Boolean
}
```

### Validation Results Object
```powershell
@{
    TestDate = DateTime
    Platform = String
    ToolTests = Object[]
    ConfigurationTests = Object[]
    EnvironmentTests = Object[]
    Warnings = String[]
    Errors = String[]
    Success = Boolean
    Score = Double
    Recommendations = String[]
}
```

### Tool Test Object
```powershell
@{
    ToolName = String
    Installed = Boolean
    Version = String
    Path = String
    UpdateAvailable = Boolean
    LatestVersion = String
}
```

## Configuration Schema

### Profile Configuration
```json
{
  "name": "ProfileName",
  "description": "Profile description",
  "platform": "Windows|Linux|macOS|Any",
  "tools": [
    {
      "name": "toolname",
      "version": "latest|specific-version",
      "required": true|false,
      "installer": "chocolatey|winget|brew|apt|manual",
      "postInstall": ["command1", "command2"]
    }
  ],
  "configurations": [
    {
      "name": "ConfigName",
      "type": "git|environment|file",
      "settings": {}
    }
  ],
  "hooks": {
    "preCommit": ["hook1", "hook2"],
    "commitMsg": ["hook1"],
    "prePush": ["hook1"]
  }
}
```

### Team Configuration
```json
{
  "organization": "CompanyName",
  "standards": {
    "gitConfig": {
      "user.name": "required",
      "user.email": "required",
      "core.autocrlf": "true",
      "pull.rebase": "false"
    },
    "requiredTools": ["git", "node", "docker"],
    "codingStandards": {
      "javascript": {
        "linter": "eslint",
        "formatter": "prettier"
      }
    }
  },
  "hooks": {
    "preCommit": ["eslint", "prettier", "test"],
    "prePush": ["build", "test"]
  }
}
```

## Error Handling

All functions implement comprehensive error handling with:
- Structured error objects
- Detailed error messages
- Correlation IDs for debugging
- Non-terminating errors where appropriate
- Rollback capabilities for failed operations

## Examples

### Basic Environment Setup
```powershell
# Standard setup with progress display
$result = Invoke-DevelopmentEnvironmentSetup -ShowProgress

# Check results
if ($result.Success) {
    Write-Host "Setup completed successfully!"
    Write-Host "Installed tools: $($result.InstalledTools -join ', ')"
} else {
    Write-Host "Setup failed with errors:"
    $result.Errors | ForEach-Object { Write-Host "  - $_" }
}
```

### Custom Profile Setup
```powershell
# Create custom profile
New-EnvironmentProfile -Name "ReactDev" -Tools @("node", "yarn", "code") -Description "React development environment"

# Use custom profile
Invoke-DevelopmentEnvironmentSetup -Profile "ReactDev" -ShowProgress
```

### Team Configuration
```powershell
# Import team settings
Import-TeamConfiguration -ConfigUrl "https://company.com/dev-standards.json" -ApplyImmediately

# Setup with team configuration
Invoke-DevelopmentEnvironmentSetup -TeamConfiguration "https://company.com/dev-standards.json"
```

### Environment Validation
```powershell
# Comprehensive validation
$validation = Test-EnvironmentConfiguration -ShowDetails -ExportReport "validation-report.json"

# Check specific tools
$toolValidation = Test-EnvironmentConfiguration -Tools @("git", "node", "docker") -ShowDetails
```

### Multi-Project Setup
```powershell
# Setup workspace for multiple projects
Initialize-MultiProjectEnvironment -Projects @("api", "frontend", "mobile") -WorkspaceRoot "C:\Projects" -ShowProgress
```