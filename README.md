# Developer Environment Tools

Professional PowerShell module for development environment setup, automation, and git workflow configuration.

## Overview

Developer Environment Tools provides comprehensive capabilities for automating development environment setup, configuring git workflows, and managing development toolchains across projects and teams.

## Features

- **Automated Environment Setup**: Complete development environment configuration
- **Git Workflow Automation**: Pre-commit hooks, git hooks, and workflow automation
- **Multi-Platform Support**: Windows, macOS, and Linux compatibility
- **Team Standardization**: Consistent development environments across team members
- **CI/CD Integration**: GitHub Actions and workflow automation
- **Extensible Configuration**: Customizable setup profiles and configurations

## Quick Start

### Installation

```powershell
# Install from PowerShell Gallery (recommended)
Install-Module DeveloperEnvironmentTools

# Or clone directly for development
git clone https://github.com/thisis-romar/developer-environment-tools.git
Import-Module .\DeveloperEnvironmentTools.psd1
```

### Basic Usage

```powershell
# Complete environment setup
Invoke-DevelopmentEnvironmentSetup

# Git workflow automation only
Initialize-GitWorkflowAutomation

# Pre-commit hooks setup
Install-PreCommitHooks
```

## Core Components

### Environment Setup Engine
- Automated tool installation and configuration
- Development dependency management
- Environment variable configuration
- Cross-platform compatibility

### Git Workflow Automation
- Pre-commit hook installation and management
- Custom git hooks configuration
- Commit message standardization
- Branch protection and workflow rules

### Configuration Management
- Team configuration profiles
- Project-specific setup templates
- Environment standardization
- Configuration validation and testing

## Use Cases

### Individual Developers
- **Quick Setup**: Get productive development environment in minutes
- **Consistency**: Maintain consistent tooling across projects
- **Best Practices**: Automated enforcement of coding standards

### Development Teams
- **Standardization**: Ensure all team members have identical environments
- **Onboarding**: Streamline new developer setup process
- **Quality Gates**: Automated code quality enforcement

### DevOps Teams
- **CI/CD Integration**: Seamless integration with automation pipelines
- **Environment Management**: Consistent environments from dev to production
- **Compliance**: Automated compliance and security policy enforcement

## Advanced Features

### Multi-Project Setup
```powershell
# Setup multiple projects with shared configuration
Initialize-MultiProjectEnvironment -Projects @("api", "frontend", "mobile")
```

### Custom Profiles
```powershell
# Create and use custom setup profiles
New-EnvironmentProfile -Name "NodeJS-React" -Tools @("node", "yarn", "prettier")
Invoke-DevelopmentEnvironmentSetup -Profile "NodeJS-React"
```

### Team Configuration
```powershell
# Apply team-wide settings
Import-TeamConfiguration -ConfigUrl "https://company.com/dev-config.json"
```

## Requirements

- **PowerShell**: 5.1 or later (PowerShell Core 6+ recommended)
- **Git**: Version 2.20 or later
- **Permissions**: Administrative privileges for system-level tool installation
- **Internet**: For downloading tools and dependencies

## Architecture

```
DeveloperEnvironmentTools/
├── DeveloperEnvironmentTools.psd1    # Module manifest
├── DeveloperEnvironmentTools.psm1    # Main module file
├── Public/                           # Public functions
│   ├── Invoke-DevelopmentEnvironmentSetup.ps1
│   ├── Initialize-GitWorkflowAutomation.ps1
│   ├── Install-PreCommitHooks.ps1
│   └── Test-EnvironmentConfiguration.ps1
├── Private/                          # Internal functions
│   ├── Install-DevelopmentTools.ps1
│   ├── Configure-GitHooks.ps1
│   ├── Setup-PreCommitFramework.ps1
│   └── Validate-Environment.ps1
├── Templates/                        # Configuration templates
│   ├── .pre-commit-config.yaml
│   ├── .gitignore
│   └── setup-profiles.json
├── docs/                            # Documentation
│   ├── API.md
│   └── Configuration.md
├── examples/                        # Usage examples
│   ├── basic-setup.ps1
│   └── team-configuration.ps1
└── tests/                          # Unit tests
    └── DeveloperEnvironmentTools.Tests.ps1
```

## Supported Tools and Frameworks

### Languages and Runtimes
- Node.js and npm/yarn
- Python and pip/conda
- .NET Core and .NET Framework
- Java and Maven/Gradle
- Go and Go modules
- Rust and Cargo

### Development Tools
- VS Code and extensions
- Git and Git LFS
- Docker and Docker Compose
- PowerShell Core
- Windows Subsystem for Linux (WSL)

### Quality and Testing Tools
- ESLint, Prettier, StyleCop
- Jest, pytest, xUnit
- SonarQube integration
- Code coverage tools

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```powershell
# Clone the repository
git clone https://github.com/thisis-romar/developer-environment-tools.git
cd developer-environment-tools

# Import for development
Import-Module .\DeveloperEnvironmentTools.psd1 -Force

# Run tests
Invoke-Pester -Path .\tests\
```

## Related Projects

- **[AI Attribution Tools](https://github.com/thisis-romar/ai-attribution-tools)**: AI-assisted commit attribution analysis
- **[Chat Analysis Tools](https://github.com/thisis-romar/chat-analysis-tools)**: VS Code chat history analysis

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/thisis-romar/developer-environment-tools/issues)
- **Documentation**: [docs/](docs/) folder
- **Examples**: [examples/](examples/) folder

---

**Professional development environment automation for modern software teams.**