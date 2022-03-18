# Setting up CAPE for fun (and profit)
I've used CAPE and found it really really useful and wanted to set up an instance to play with and go through the process to understand how its put together.

Running CAPE in a virutalised environment isn't ideal due to the need for virtualisation in virtualisation, but for my purposes it should be ok.

For ease I'm using Hyper-V which I've enabled under Windows 11.

> CAPE Sandbox is an Open Source software for automating analysis of suspicious files. To do so it makes use of custom components that monitor the behavior of the malicious processes while running in an isolated environment.

## Install Ubuntu Desktop under Hyper-V
* Create new VM (I'll refine this section and see what works best and update)
* Test whether Generation 1 or Generation 2 works

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

### Install Python3 and pip
```
sudo apt install python3 python3-pip mongodb -y
```

### Install Pillow (9.0.1 was the latest at this time)
```
pip3 install Pillow==9.0.1
```
### The work is already done
```
wget https://raw.githubusercontent.com/doomedraven/Tools/master/Sandbox/cape2.sh
chmod a+x cape2.sh
sudo ./cape2.sh base cape

```
## Virtual Machine Creation
The virtual machines are environments in which samples are detonated.

Handy hint - https://zeltser.com/free-malware-analysis-windows-vm/#step2

```
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y
```

