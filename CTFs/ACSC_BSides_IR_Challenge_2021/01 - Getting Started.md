## 1 - Getting Started
### GS-0
Press submit on this one to continue.
### GS-1
*How many hosts have we received data from?*

* Easy one, just count the number of zip files provided as they named by host.

**Flag = 9**

### GS-2
*What is the MD5 hash of the memory image provided?*

* Multiple ways that this can be done, simple enough in Windows to use PowerShell.

  ```Get-FileHash memory.raw -Algorithm MD5 | Format-List```

**Flag: 20b25f76cc1839c2e7759a69a82bf664**

### GS-3
*What time was this image taken?*
I want to use a few different tools to get the answers and test out some new tools along the way, so I've started here.

#### Volatility
* Installed Volatility3 in WSL2
  
  ```./vol -f "/mnt/c/temp/memory.raw" windows.info```

gave us:

``` 
layer_name      0 WindowsIntel32e
memory_layer    1 FileLayer
KdVersionBlock  0xf80732ea1f08
Major/Minor     15.17763
MachineType     34404
KeNumberProcessors      2
SystemTime      2021-04-06 01:56:57
NtSystemRoot    C:\Windows
NtProductType   NtProductServer
NtMajorVersion  10
NtMinorVersion  0
PE MajorOperatingSystemVersion  10
PE MinorOperatingSystemVersion  0
PE Machine      34404
PE TimeDateStamp        Mon Nov 22 08:46:06 2010
```

#### TrufflePig Forensics
 * Couldn't see where I could find this information in TPF

**Flag: 2021-04-06 01:56:57**

### GS-4
*What website management platform are ALIEN using for their public facing website?*
* Just looked at the web log files and googled the cs_uri_stem `/Install/InstallWizard.aspx __VIEWSTATE=&culture=en-US&executeinstall` to see what came back.

* https://www.exploit-db.com/raw/39777
* https://msadiqm.blogspot.com/2017/11/dotnetnuke-070400-administration.html

Became obvious then.

**Flag: DotNetNuke**