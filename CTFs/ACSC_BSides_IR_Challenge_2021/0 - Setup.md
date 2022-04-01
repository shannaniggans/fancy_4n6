# Set up & Tools I used for the ACSC BSides IR Challenge 2021
he challenge can be downloaded here along with all the details - https://www.cyber.gov.au/acsc/view-all-content/news/acsc-cyber-security-challenge.

Big thanks to the ACSC for putting this together and sharing the content.

## Setup
So I could pretend to play along I setup an instance of ctfd locally in docker for windows.
1. https://hub.docker.com/r/ctfd/ctfd
2. Ran "docker run -p 8000:8000 -it ctfd/ctfd:3.3.1-release" to download the image locally, this was the version that worked for me when i imported the config.
3. Imported the provided ctfd_config.zip to my instance.

![](Assets\2022-01-20-19-06-48.png)

## Memory Forensics
### Volatility 3
1. Installing WSL2 - https://docs.microsoft.com/en-us/windows/wsl/install
2. From a command prompt within WSL I used the volatility wheel file to download and install the latest version of volatility3: `python3 -m pip install volatility3-2.0.0-py3-none-any.whl`
    * https://github.com/volatilityfoundation/volatility3/releases
    * https://pip.pypa.io/en/latest/user_guide/installing-from-wheels
3. the binary `vol` was then available in `.local/bin/` from the installation directory

#### TrufflePig Forensics
1. Download the trial version from https://trufflepig-forensics.com/
2. Run the install wizard and setup.

## EZTools
1. I used the PowerShell script to grab all of the EZTools into a directory on my desktop - https://github.com/EricZimmerman/Get-ZimmermanTools

## Autopsy
[Autopsy Setup](https://github.com/shannaniggans/fancy_4n6/blob/main/Tooling%20setup/Autopsy.md)






