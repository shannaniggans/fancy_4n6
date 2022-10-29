###########################################
#
# DFIR VM Installation Script
#
# To execute this script:
#   1) Open powershell window as administrator
#   2) Allow script execution by running command "Set-ExecutionPolicy Unrestricted"
#   3) Execute the script by running ".\install.ps1"
#
###########################################

# Check to make sure script is run as administrator - nabbed from https://github.com/mandiant/flare-vm/blob/master/install.ps1
Write-Host "[*] Checking if script is running as administrator ..."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERR] Please run this script as administrator`n" -ForegroundColor Red
    Read-Host  "Press any key to continue"
    exit
}

# First we'll set our timezone to UTC
Write-Host "[*] Setting the time to UTC ..."
Set-TimeZone -Id "UTC" -Verbose

# We'll install Boxstarter and chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force

# Get user credentials for autologin during reboots
Write-Host "[*] Getting user credentials ..."
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting" -Value $True
if ([string]::IsNullOrEmpty($password)) {
    $cred = Get-Credential $env:username
}
else {
    $spasswd = ConvertTo-SecureString -String $password -AsPlainText -Force
    $cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $env:username, $spasswd
}

# lets update windows to the latest and then disable auto updates.
Write-Host "[*] Updating Windows to the latest, restarting and disabling automatic updates"
Install-WindowsUpdate -AcceptEula

# Create a directory to add our Tools & create a short cut on the desktop
Write-Host "[*] Creating a directory on the Desktop to add our Tools ..."
New-Item ${Env:UserProfile}\"Desktop\DFIR\Tools" -ItemType Directory #Where we'll drop our toolset
New-Item ${Env:UserProfile}\"Desktop\DFIR\Tools\EZTools" -ItemType Directory #specifically adding for EZTools

# Display hidden files, folder drives and protected OS files with modifiers
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar

# Download our toolset from choco community
choco install virtualbox-guest-additions-guest.install -y
choco install wsl -y
choco install notepadplusplus -y
choco install autopsy -y
choco install autopsy --version=4.19.0 --side-by-side -y
choco install git -y
# choco install timelineexplorer -y 

# Install EZ Tools
curl https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1 -o "${Env:UserProfile}\Desktop\DFIR\Tools\EZTools\Get-ZimmermanTools.ps1"
start-process powershell ${Env:UserProfile}\Desktop\DFIR\Tools\EZTools\Get-ZimmermanTools.ps1 -Dest "${Env:UserProfile}\Desktop\DFIR\Tools\EZTools\" -NoNewWindow

# set the Windows Update service to "disabled"
sc.exe config wuauserv start=disabled
# double check it's REALLY disabled - Start value should be 0x4
Write-Host "[*] Checking its really disabled ..."
REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start
