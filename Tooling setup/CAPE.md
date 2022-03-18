# Setting up CAPE for fun (and profit)
I've used CAPE and found it really really useful and wanted to set up an instance to play with and go through the process to understand how its put together.

Running CAPE in a virutalised environment isn't ideal due to the need for virtualisation in virtualisation, but for my purposes it should be ok.

For ease I'm using Hyper-V which I've enabled under Windows 11.

## Install Ubuntu 
* Used the "Quick create" function to set up a new instance of Ubuntu 20.04.

### Enable nested virtualisation
Running PowerShell terminal as admin

```
PS C:\WINDOWS\system32> Get-VM

Name                       State   CPUUsage(%) MemoryAssigned(M) Uptime             Status             Version
----                       -----   ----------- ----------------- ------             ------             -------
CAPE                       Off     0           0                 00:00:00           Operating normally 11.0
```
* Ensure the VM is stopped

```
Stop-VM -Name 'CAPE'
```
* Now that the state of your VM is set to ‘Off’, you can enable nested virtualization. The only way to enable it is using PowerShell. 

```
Set-VMProcessor -VMName 'CAPE' -ExposeVirtualizationExtensions $True
```
That should do it.

## Get Ubuntu set up and install CAPE
Start the CAPE VM and Connect.

Make sure Ubuntu is up to date.
```
sudo apt update
sudo apt upgrade -y
```