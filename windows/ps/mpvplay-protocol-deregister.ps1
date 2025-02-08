# MPV Protocol Handler Deregistration Script
# This script requires administrator privileges

# Check for administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Error: This script requires administrator privileges."
    Write-Host "Please right-click the script and select 'Run as Administrator'."
    Read-Host "Press Enter to continue..."
    exit 1
}

try {
    Write-Host "Removing mpvplay:// protocol handler..."
    
    # Remove registry key
    $registryPath = "HKLM:\SOFTWARE\Classes\mpvplay"
    if (Test-Path $registryPath) {
        Remove-Item -Path $registryPath -Recurse -Force
        Write-Host "Registry key removed."
    } else {
        Write-Host "Registry key does not exist, nothing to remove."
    }
    
    Write-Host "Deregistration complete!"
    
} catch {
    Write-Host "Error occurred: $_"
} finally {
    Read-Host "Press Enter to continue..."
}
