# PORTX Packages Repository

This repository contains curated Windows packages for the PORTX portable development environment.

## Structure

```
releases/
└── windows-amd64/          # Windows x64 packages
    ├── 7zip/               # 7-Zip archiver
    ├── aws/                # AWS CLI
    ├── azure-cli/          # Azure CLI
    ├── docker-compose/     # Docker Compose
    ├── fzf/                # Fuzzy finder
    ├── helm/               # Kubernetes package manager
    ├── jq/                 # JSON processor
    ├── k9s/                # Kubernetes CLI
    ├── ripgrep/            # Fast text search
    └── terraform/          # Infrastructure as code
```

## Package Management

Packages are managed through the PORTX package manager:

```bash
# List available packages
portx list available

# Install a package
portx install terraform

# List installed packages
portx list installed
```

## API Integration

This repository provides REST API access via GitHub's Contents API:
- `GET /repos/damiansirbu-org/portx-packages/contents/releases/windows-amd64`

Each package directory contains versioned ZIP files following the naming convention:
`{package-name}-{version}-{architecture}.zip`
