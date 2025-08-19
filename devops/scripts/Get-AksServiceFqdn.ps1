# This script retrieves the Fully Qualified Domain Name (FQDN) for a Kubernetes service with a public IP in Azure AKS.
# It prompts for the service name (unless passed as a parameter), automatically finds its namespace, fetches the external IP, and queries Azure for the FQDN.
#
# Example usage:
#   1. Run the script in PowerShell:
#        ./Get-AksServiceFqdn.ps1 -ServiceName <your-service-name>
#      or
#        ./Get-AksServiceFqdn.ps1
#   2. Enter the Kubernetes service name when prompted (if not passed as a parameter).

param(
    [string]$ServiceName
)

if (-not $ServiceName) {
    $ServiceName = Read-Host "Enter the Kubernetes service name"
}

# Find the namespace for the service automatically
$namespace = (
    kubectl get svc --all-namespaces -o json |
    ConvertFrom-Json |
    Select-Object -ExpandProperty items |
    Where-Object { $_.metadata.name -eq $ServiceName }
).metadata.namespace

if (-not $namespace) {
    Write-Error "Service '$ServiceName' not found in any namespace."
    exit 1
}

# Get the external IP from the Kubernetes service
$ip = kubectl get svc $ServiceName -n $namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

if (-not $ip) {
    Write-Error "No external IP found for service '$ServiceName' in namespace '$namespace'."
    exit 1
}

# Query Azure for the public IP resource with that IP
$fqdn = az network public-ip list `
  --query "[?ipAddress=='$ip'].dnsSettings.fqdn" `
  --output tsv

if ([string]::IsNullOrWhiteSpace($fqdn)) {
    Write-Warning "No FQDN assigned for the public IP ($ip) associated with service '$ServiceName' in namespace '$namespace'."
}

Write-Output "FQDN: $fqdn"