# MPV Protocol Handler Registration Script
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
    # Get script directory
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $mpvPath = Join-Path $scriptPath "mpv.exe"
    $handlerPath = Join-Path $scriptPath "mpvplay-protocol.ps1"
    
    # Check if required files exist
    if (-not (Test-Path $mpvPath)) {
        Write-Host "Error: mpv.exe not found"
        Write-Host "Current directory: $scriptPath"
        Write-Host "Please make sure this script is in the MPV installation directory."
        Read-Host "Press Enter to continue..."
        exit 1
    }
    
    if (-not (Test-Path $handlerPath)) {
        Write-Host "Error: mpvplay-protocol.ps1 not found"
        Write-Host "Current directory: $scriptPath"
        Write-Host "Please make sure mpvplay-protocol.ps1 is in the same directory."
        Read-Host "Press Enter to continue..."
        exit 1
    }
    
    Write-Host "Registering mpvplay:// protocol handler..."
    
    # Register protocol
    $registryPath = "HKLM:\SOFTWARE\Classes\mpvplay"
    
    # Create main key
    New-Item -Path $registryPath -Force | Out-Null
    Set-ItemProperty -Path $registryPath -Name "(Default)" -Value "URL:mpvplay Protocol"
    Set-ItemProperty -Path $registryPath -Name "URL Protocol" -Value ""
    
    # Create DefaultIcon
    New-Item -Path "$registryPath\DefaultIcon" -Force | Out-Null
    Set-ItemProperty -Path "$registryPath\DefaultIcon" -Name "(Default)" -Value "`"$mpvPath`",0"
    
    # Create shell\open\command
    New-Item -Path "$registryPath\shell\open\command" -Force | Out-Null
    $commandValue = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -NoProfile -File `"$handlerPath`" `"%1`""
    Set-ItemProperty -Path "$registryPath\shell\open\command" -Name "(Default)" -Value $commandValue
    
    Write-Host "Registration complete!"
    Write-Host "You can now use the following URL formats:"
    Write-Host "  mpvplay://http://example.com/video.mp4"
    Write-Host "  mpvplay://weblink?url=http://example.com/video.mp4"
    Write-Host "  mpvplay://http//example.com/video.mp4 (Chrome 130+)"
    
} catch {
    Write-Host "Error occurred: $_"
} finally {
    Read-Host "Press Enter to continue..."
}
