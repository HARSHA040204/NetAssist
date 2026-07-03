# NetAssist

**One-Click Network Diagnostics Collection Tool for Support and Network Engineers**

NetAssist is a PowerShell-based diagnostic utility that collects essential system and network information during troubleshooting sessions. It helps support engineers gather the information they need quickly, reducing back-and-forth communication with end users.

The tool runs entirely on the user's machine and generates a diagnostics bundle that can be shared with the support team.

---

## Features

* System information collection

  * Hostname
  * Logged-in user
  * System uptime
  * Last reboot time

* Network diagnostics

  * Active network adapter detection
  * IPv4 address
  * Default gateway
  * DNS servers
  * MAC address
  * Wi-Fi SSID (if applicable)

* Connectivity checks

  * Internet connectivity test
  * HTTPS (Port 443) connectivity test
  * DNS resolution test

* Environment information

  * Proxy configuration
  * WinHTTP proxy settings
  * Public IP address
  * Domain joined status
  * VPN adapter detection
  * Zscaler connectivity detection

* Troubleshooting utilities

  * Clipboard-ready diagnostics summary
  * Full-screen capture of `ip.zscaler.com`
  * Collection of raw networking command outputs
  * Automatic ZIP bundle generation

---

## Why NetAssist?

During troubleshooting calls, engineers often ask users to provide:

* `ipconfig /all`
* Proxy settings
* Public IP information
* `ip.zscaler.com` screenshots
* DNS and connectivity information

NetAssist consolidates these checks into a single script, helping reduce troubleshooting time and improving information gathering consistency.

---

## Requirements

* Windows 10 or Windows 11
* PowerShell 5.1 or later
* No administrator privileges required

---

## Usage

### Option 1 – Download and Run

Clone the repository:

```powershell
git clone https://github.com/HARSHA040204/NetAssist.git
```

Run:

```powershell
.\netassist.ps1
```

---

### Option 2 – Run Directly from GitHub

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/HARSHA040204/NetAssist/main/netassist.ps1 | iex"
```

---

## Generated Artifacts

NetAssist creates a diagnostics folder and a compressed ZIP bundle containing:

* Diagnostics summary
* Network configuration information
* Routing information
* ARP table
* Proxy configuration
* Zscaler screenshot
* Additional troubleshooting artifacts

---

## Security & Privacy

* No data is transmitted externally by NetAssist.
* All diagnostics are generated locally on the user's machine.
* Users can review the collected information before sharing it with support personnel.

---

## Use Cases

* Network troubleshooting calls
* VPN connectivity issues
* Zscaler troubleshooting
* Internet connectivity investigations
* Support ticket information gathering
* Remote diagnostics collection

---

## Future Enhancements

* Optional internal application connectivity tests
* Additional browser and proxy diagnostics
* Enhanced VPN detection
* HTML report generation
* Custom company-specific diagnostic modules

---

## Author

**D. Veera Harsha Vardhan Reddy**

GitHub: https://github.com/HARSHA040204
