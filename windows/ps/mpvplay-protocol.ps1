# MPV Protocol Handler PowerShell Script

# Get input parameter
param(
    [Parameter(Mandatory=$true)]
    [string]$InputUrl
)

# Function: URL decode
function UrlDecode {
    param([string]$UrlEncodedString)
    
    Add-Type -AssemblyName System.Web
    return [System.Web.HttpUtility]::UrlDecode($UrlEncodedString)
}

# Function: Process URL
function ProcessUrl {
    param([string]$Url)
    
    Write-Host "Input URL: $Url"
    
    # Handle weblink format
    if ($Url.StartsWith("mpvplay://weblink?url=") -or $Url.StartsWith("mpvplay://weblink/?url=")) {
        Write-Host "Detected weblink format"
        $Url = $Url.Replace("mpvplay://weblink?url=", "").Replace("mpvplay://weblink/?url=", "")
        Write-Host "Extracted URL: $Url"
        $Url = UrlDecode $Url
        Write-Host "URL decoded: $Url"
        return $Url
    }
    
    # Remove mpvplay:// prefix
    if ($Url -match "mpvplay://(.+)") {
        $Url = $matches[1]
        Write-Host "Removed prefix: $Url"
    }
    
    # Fix Chrome 130+ format
    if ($Url.StartsWith("http//") -or $Url.StartsWith("https//")) {
        Write-Host "Fixing Chrome 130+ format"
        $Url = $Url.Replace("http//", "http://").Replace("https//", "https://")
        Write-Host "Fixed URL: $Url"
    }
    
    return $Url
}

# Main program
try {
    # Get script directory
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $mpvPath = Join-Path $scriptPath "mpv.exe"
    
    # Check if MPV exists
    if (-not (Test-Path $mpvPath)) {
        Write-Host "Error: mpv.exe not found"
        Write-Host "Current directory: $scriptPath"
        Write-Host "Please make sure this script is in the MPV installation directory."
        exit 1
    }
    
    # Process URL
    $processedUrl = ProcessUrl $InputUrl
    Write-Host "Final URL: $processedUrl"
    
    # Start MPV with no window
    Write-Host "Starting MPV..."
    Write-Host "Command line: '$mpvPath' '$processedUrl'"
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $mpvPath
    $startInfo.Arguments = "$processedUrl"
    $startInfo.CreateNoWindow = $true
    $startInfo.UseShellExecute = $false
    $process = [System.Diagnostics.Process]::Start($startInfo)
    
    # Write logs to temp file for debugging
    $logFile = "$env:TEMP\mpvplay-protocol.log"
    Get-Content $logFile -ErrorAction SilentlyContinue
    $Host.UI.RawUI.FlushInputBuffer()
    "$(Get-Date) - Processed URL: $processedUrl" | Out-File -Append $logFile
} catch {
    $errorMessage = "Error occurred: $_"
    $errorMessage | Out-File -Append "$env:TEMP\mpvplay-protocol-error.log"
    exit 1
}
