# DevSecOps Helper Script for Local Scanning

# 1. Ensure WinGet tools are in the path for this session
$env:Path += ";$env:LocalAppData\Microsoft\WinGet\Links"

Write-Host "`n--- 1. Secret Scanning (Gitleaks) ---" -ForegroundColor Cyan
gitleaks detect --verbose --redact --config .gitleaks.toml

Write-Host "`n--- 2. Python Security Analysis (Bandit) ---" -ForegroundColor Cyan
bandit -r app/

Write-Host "`n--- 3. SBOM Generation (Syft) ---" -ForegroundColor Cyan
syft . -o cyclonedx-json=sbom.json --quiet
Write-Host "Generated sbom.json"

Write-Host "`n--- 4. Vulnerability Scanning (Trivy) ---" -ForegroundColor Cyan
# Scan the system dependencies
trivy fs . --severity CRITICAL,HIGH --quiet
# Scan the SBOM file specifically
trivy sbom sbom.json --severity CRITICAL,HIGH --quiet

Write-Host "`n--- 5. Docker Best Practices (Hadolint) ---" -ForegroundColor Cyan
docker run --rm -i hadolint/hadolint < Dockerfile

Write-Host "`nSecurity Check Complete!" -ForegroundColor Green
