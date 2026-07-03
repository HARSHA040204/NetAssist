# ============================================
# NetAssist v2
# ============================================

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Downloads = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
$Folder = "$Downloads\NetAssist_$TimeStamp"

New-Item -ItemType Directory -Path $Folder -Force | Out-Null

# -----------------------------
# Helper Function
# -----------------------------
$Report = @()

function Add-Line {
    param($Name, $Value)
    $script:Report += "{0,-22}: {1}" -f $Name, $Value
}

# -----------------------------
# System Information
# -----------------------------
Add-Line "Hostname" $env:COMPUTERNAME
Add-Line "User" $env:USERNAME

$os = Get-CimInstance Win32_OperatingSystem

$uptime = (Get-Date) - $os.LastBootUpTime
$uptimeText = "{0} Days {1} Hours" -f $uptime.Days, $uptime.Hours

Add-Line "Computer Uptime" $uptimeText
Add-Line "Last Reboot" $os.LastBootUpTime

# -----------------------------
# Active Adapter
# -----------------------------
$adapter = Get-NetIPConfiguration |
Where-Object {
    $_.IPv4DefaultGateway -ne $null
} |
Select-Object -First 1

if ($adapter) {

    Add-Line "Active Adapter" $adapter.InterfaceAlias

    $netAdapter = Get-NetAdapter -Name $adapter.InterfaceAlias

    Add-Line "Network Type" $netAdapter.MediaType
    Add-Line "IPv4 Address" $adapter.IPv4Address.IPAddress
    Add-Line "Gateway" $adapter.IPv4DefaultGateway.NextHop
    Add-Line "DNS Servers" ($adapter.DNSServer.ServerAddresses -join ", ")
    Add-Line "MAC Address" $netAdapter.MacAddress
}

# -----------------------------
# WiFi SSID
# -----------------------------
try {
    $ssid = (netsh wlan show interfaces |
        Select-String "SSID" |
        Select-Object -First 1).ToString()

    $ssid = $ssid.Split(":")[1].Trim()

    if ($ssid) {
        Add-Line "WiFi SSID" $ssid
    }
}
catch {}

# -----------------------------
# Domain Joined
# -----------------------------
try {
    $cs = Get-CimInstance Win32_ComputerSystem
    Add-Line "Domain Joined" $cs.PartOfDomain

    if ($cs.PartOfDomain) {
        Add-Line "Domain" $cs.Domain
    }
}
catch {}

# -----------------------------
# Proxy Information
# -----------------------------
try {
    $proxy = Get-ItemProperty `
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    Add-Line "Proxy Enabled" $proxy.ProxyEnable
    Add-Line "Proxy Server" $proxy.ProxyServer
    Add-Line "Auto Config URL" $proxy.AutoConfigURL
}
catch {}

try {
    $winHttp = netsh winhttp show proxy | Out-String
    $winHttp = $winHttp.Trim()
    Add-Line "WinHTTP Proxy" $winHttp
}
catch {}

# -----------------------------
# Internet Test
# -----------------------------
$internet = Test-Connection google.com -Count 1 -Quiet
Add-Line "Internet" $(if($internet){"OK"}else{"Failed"})

# -----------------------------
# HTTPS Test
# -----------------------------
try {
    $https = Test-NetConnection google.com -Port 443
    Add-Line "HTTPS (443)" $(if($https.TcpTestSucceeded){"OK"}else{"Failed"})
}
catch {}

# -----------------------------
# DNS Test
# -----------------------------
try {
    Resolve-DnsName google.com -ErrorAction Stop | Out-Null
    Add-Line "DNS Resolution" "OK"
}
catch {
    Add-Line "DNS Resolution" "Failed"
}

# -----------------------------
# Public IP
# -----------------------------
try {
    $publicIp = Invoke-RestMethod "https://api.ipify.org"
    Add-Line "Public IP" $publicIp
}
catch {
    Add-Line "Public IP" "Unable to Fetch"
}

# -----------------------------
# VPN Detection
# -----------------------------
$vpn = Get-NetAdapter |
Where-Object {
    $_.InterfaceDescription -match "VPN|Cisco|AnyConnect|GlobalProtect|Pulse|Zscaler|Forti"
}

if ($vpn) {
    Add-Line "VPN Adapter" ($vpn.Name -join ", ")
}
else {
    Add-Line "VPN Adapter" "Not Connected"
}

# -----------------------------
# Zscaler Check
# -----------------------------
try {

    $z = Invoke-WebRequest `
        "https://ip.zscaler.com" `
        -UseBasicParsing

    $content = $z.Content

    if ($content -match "didn't come from a Zscaler IP") {
        Add-Line "Zscaler" "Not Connected"
    }
    else {
        Add-Line "Zscaler" "Connected"
    }
}
catch {
    Add-Line "Zscaler" "Unable to Determine"
}

# -----------------------------
# Health Analysis
# -----------------------------
$Health = @()

if ($internet) {
    $Health += "[OK] Internet Working"
}
else {
    $Health += "[FAIL] Internet Failed"
}

if ($vpn) {
    $Health += "[OK] VPN Connected"
}
else {
    $Health += "[FAIL] VPN Not Connected"
}

# -----------------------------
# Build Summary
# -----------------------------
$Summary = @"
=========================================
NETASSIST DIAGNOSTICS
=========================================
$($Report -join "`r`n")

Likely Issues:
--------------
$($Health -join "`r`n")
=========================================
"@

# -----------------------------
# Save Summary
# -----------------------------
$Summary | Out-File `
    "$Folder\Diagnostics.txt" `
    -Encoding UTF8

# -----------------------------
# Save Raw Outputs
# -----------------------------
ipconfig /all | Out-File `
    "$Folder\IpConfig.txt" `
    -Encoding UTF8

route print | Out-File `
    "$Folder\Route.txt" `
    -Encoding UTF8

arp -a | Out-File `
    "$Folder\Arp.txt" `
    -Encoding UTF8

netsh winhttp show proxy | Out-File `
    "$Folder\Proxy.txt" `
    -Encoding UTF8

try {
    Invoke-WebRequest `
        "https://ip.zscaler.com" `
        -UseBasicParsing |
        Select-Object -ExpandProperty Content |
        Out-File "$Folder\ZscalerPage.txt"
}
catch {}

# -----------------------------
# Copy to Clipboard
# -----------------------------
$Summary | Set-Clipboard

# -----------------------------
# Screenshot ip.zscaler.com
# -----------------------------

try {

    # Open ip.zscaler.com in Edge
    Start-Process "msedge.exe" "https://ip.zscaler.com"

    # Wait for page to fully load
    Start-Sleep 8

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

    $bmp = New-Object System.Drawing.Bitmap `
        $bounds.Width,
        $bounds.Height

    $graphics = [System.Drawing.Graphics]::FromImage($bmp)

    $graphics.CopyFromScreen(
        $bounds.Location,
        [System.Drawing.Point]::Empty,
        $bounds.Size
    )

    $ScreenshotPath = "$Folder\Zscaler_FullScreen.png"

    $bmp.Save(
        $ScreenshotPath,
        [System.Drawing.Imaging.ImageFormat]::Png
    )

    $graphics.Dispose()
    $bmp.Dispose()

}
catch {
    Write-Host "Unable to capture screenshot."
}

# -----------------------------
# Create ZIP
# -----------------------------
$ZipFile = "$Downloads\NetAssist_$TimeStamp.zip"

Compress-Archive `
    -Path "$Folder\*" `
    -DestinationPath $ZipFile `
    -Force

# -----------------------------
# Display
# -----------------------------
Write-Host $Summary

Write-Host ""
Write-Host "Diagnostics copied to clipboard."
Write-Host "ZIP Bundle Created:"
Write-Host $ZipFile
Write-Host ""
Write-Host "Please attach the ZIP file to Teams or Email."

# Open folder automatically
Invoke-Item $Downloads

