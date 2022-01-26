## 1 - Getting Started
### GS-0
Press submit on this one to continue.
### GS-1
How many hosts have we received data from?

* Easy one, just count the number of zip files provided as they named by host.

Flag = 9

### GS-2
What is the MD5 hash of the memory image provided?

* Multiple ways that this can be done, simple enough in Windows to use PowerShell.
  ```Get-FileHash memory.raw -Algorithm MD5 | Format-List```

Flag: 20b25f76cc1839c2e7759a69a82bf664

### GS-3
What time was this image taken?
#### Volatility



#### TrufflePig Forensics




Flag = TBA

### GS-4
What website management platform are ALIEN using for their public facing website?
