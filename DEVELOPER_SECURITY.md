# Developer Security Guide

This project implements a **DevSecOps** pipeline to ensure high security and compliance. This guide outlines how to use the local security tools.

## 1. Prerequisites
To run security scans locally, you need the following tools installed (Windows):

```powershell
# Install using WinGet
winget install Anchore.Syft
winget install Anchore.Grype
winget install AquaSecurity.Trivy
winget install Gitleaks.Gitleaks
```

Python requirements:
```powershell
pip install bandit hadolint-py
```

## 2. Automated Pipeline
The [GitHub Actions Workflow](.github/workflows/ci.yml) automatically runs on every push to the `main` branch:

1.  **Secret Scan**: Gitleaks checks for hardcoded credentials.
2.  **SAST**: Bandit checks your Python logic for security flaws.
3.  **Container Lint**: Hadolint checks the `Dockerfile`.
4.  **SCA (Vulnerabilities)**: Trivy scans the final Docker image.
5.  **SBOM**: syft generates a CycloneDX SBOM.

## 3. Local Commands
To run a full security check before pushing, run:
```powershell
./scripts/security_check.ps1
```

Or run individual commands:

### Generate & Scan SBOM
```powershell
# Generate
syft . -o cyclonedx-json=sbom.json
# Analyze (Vulnerabilities)
trivy sbom sbom.json
```

### Scan Container Image
Make sure you build the image first:
```powershell
docker build -t projectglassbox-app .
trivy image projectglassbox-app
```

---

> [!IMPORTANT]
> **Never commit secrets**. If a scan fails on a secret, delete it from your code and use environment variables (in `.env`) instead.
