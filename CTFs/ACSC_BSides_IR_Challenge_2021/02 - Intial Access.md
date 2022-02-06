# IA-1
*The actor seems to have initially failed to install themselves on the web server. What IP address did their malicious wizardry come from?*
* You can get Splunk Enterprise on a free trial license for non commercial use - https://www.splunk.com/en_us/download/get-started-with-your-free-trial.html which is handy to have for these things and to play and learn Splunk on.
* You can upload a zip file of all the provided IIS log files to Splunk and I created an index for the challenge.
1. Started by removing the local IP of 10.1.0.80 from the results
   ```
   index="acsc_ir_challenge_2021"
   | sort _time
   | where NOT c_ip="10.1.0.80"
   ```
2. In general, GET requests are what we'll see for normal traffic to a website, so i filtered on POST requests to see what came back.
   ```
	index="acsc_ir_challenge_2021"
	| sort _time
	| where NOT c_ip="10.1.0.80"
	| where cs_method="POST"
   ```
3. Traffic originating from 13.54.35.87 sticks out in the listing with multiple POST requests to /Telerik.Web.UI.WebResource.axd. So ill filter on that IP now.
   ```
   index="acsc_ir_challenge_2021"
   | sort _time
   | where c_ip="13.54.35.87"
   ```
4. there was a clue in the question so the following event was the one related:

	```
	2021-04-01 02:35:41 10.1.0.80 GET /Install/InstallWizard.aspx __VIEWSTATE=&culture=en-US&executeinstall 80 - 13.54.35.87 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64;+rv:54.0)+Gecko/20100101+Firefox/54.0 - 404 0 0 42
	```

Their malicious 'wizardry' that failed (404 status)

**Flag: 13.54.35.87**

# IA-2
*It looks like the actor eventually succeeded in gaining access using a combination of multiple well-documented CVEs. Which of these is the most recent?*

* The first indication in the log files that they were successful in gain access (status 500) is the log entry:
	```
	2021-04-01 02:49:08 10.1.0.80 POST /Telerik.Web.UI.WebResource.axd type=rau 80 - 13.54.35.87 python-urllib3/1.26.2 - 500 0 0 52
	c_ip = 13.54.35.87host = dmz-webpubsource = u_ex210401.logsourcetype = iis
	```
* Googling `/Telerik.Web.UI.WebResource.axd` and CVE makes it pretty clear that there are a few CVEs bouncing about, but they have asked for the most recent. Coincidentally an advisory was put out by the ACSC in 2020 that has the interesting details in it - https://www.cyber.gov.au/acsc/view-all-content/advisories/advisory-2020-004-remote-code-execution-vulnerability-being-actively-exploited-vulnerable-versions-telerik-ui-sophisticated-actors

**Flag: CVE-2019-18935**

* on a side note and maybe for later, the advisory talked about evidence of the exploit in application event logs, so I jumped in to the eventlogs to correlate.
  ![](2022-01-21-15-45-20.png)

**IOCs from the advisory**

|Item|Info|
|----|----|
|Advisories and CVEs | CVE-2019-18935, ACSC 2020-004 & ACSC 2019-126|
|Review web server request logs|<ul><li> `POST /Telerik.Web.UI.WebResource.axd type=rau 443 – 192.0.2.1 - - 500 0 0 457`</li><li> These POST requests may be larger in size than legitimate requests due to the malicious actor uploading malicious files for the purposes of uploading a reverse shell binary.</li></ul>|
|Review Windows event logs| <ul><li>Event ID: 1309<li>Source: ASP.NET <version_number><li>Message: Contains the following strings in addition to other error message content:</li><ul><li>An unhandled exception has occurred.<br>`Unable to cast object of type ‘System.Configuration.Install.AssemblyInstaller’ to type ‘Telerik.Web.UI.IAsyncUploadConfiguration`</li></ul></ul><ul><li>Organisations should review the application event logs on vulnerable or previously vulnerable hosts for indications of Telerik exploitation. This analysis can be combined looking for associated HTTP 500 responses as identified above.</li></ul>

# IA-3
*What was the filename of the first file created by the actor to test that their exploit worked? (We'll refer to this test file as sample 1)*
* Given we are looking for a file created I wanted to parse the MFT and look for files created on the file system, corresponding to the timeline from the IIS log analysis: around 2021-04-01 02:50 UTC
* EZTools - MFTECmd.exe will do the trick to parse the $MFT file provided in the artefacts folder (root of C drive). I'll run this from a PowerShell window.
  * `C:\Users\fancy_4n6\Desktop\EZTools\MFTECmd.exe --csv "c:\temp\out" --csvf dmz-webpub-mft-c.csv`
  * Open the CSV, you might need to set the format for the date/time columns. I set the format for columns T -> AA as yyyy-mm-dd hh:mm:ss.000 - NOTE: ensuring that you have the milliseconds represented will stop any rounding which will change your answers.
  * I then set a filter on the top row and sorted by column T "Created0x10"
  * Looking at around 2021-04-01, something immediately caught my eye in Column F ".\Windows\Temp and two files 1617245542.475716.dll (2021-04-01 02:52:10) and 1617245455.5314393.dll (2021-04-01 02:50:43) created after we know the attacker was able to successfully exploit the CVE. We are looking for the first file filename.

**Flag: 1617245455.5314393.dll**

I didn't do this next part on stream as it wasn't specifically called out as required for a challenge, but during a normal investigation I'd likely do some OSINT on these files names. The files are no longer on disk, or we don't have copies of that folder, so it will just be based on what I know so far.

|File Name|Location|Size|MD5|Created Date on C|Info|
|-|-|-|-|-|-|
|1617245455.5314393.dll|C:\Windows\Temp|91648| |2021-04-01 02:50:43| |
|1617245542.475716.dll|C:\Windows\Temp|118784| |2021-04-01 02:52:10| |

It is a long shot and in this instance I came back with nothing from Google + VirusTotal.

# IA-4
*After calling home, the actor finally succeeded in dropping their core tool, sample 2.What time (UTC) was this tool first used?*

If you saw me on stream they will know this one was a little annoying to get the exact right date/time they were after. Doing a CTF varies from an investigation, though in the end we got there:
* From the MFT we know that the attacker dropped some files starting at 2021-04-01 02:50:43, when we look below those entries there are a few more curious entries that look like updates being pushed to the site.

|Date Time|Artefact|Info|
|-|-|-|
|2021-04-01 02:24:30|IIS Logs|First time we see 13.54.35.87 in the logs|
|2021-04-01 02:46:33|IIS Logs|First time we see 13.54.35.87 POST to /Telerik.Web.UI.WebResource.axd|
|2021-04-01 02:50:43|MFT|C:\Windows\Temp\1617245455.5314393.dll|
|2021-04-01 02:52:10|MFT|C:\Windows\Temp\1617245542.475716.dll|
|2021-04-01 02:55:29|IIS Logs|First time we see 13.54.35.87 GET to /submit.aspx|
|2021-04-01 02:55:30|MFT|.\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\root\a056c683\f67bca3c\App_Web_aa0aecbt.dll|
|2021-04-01 02:55:30|MFT|.\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\root\a056c683\f67bca3c\submit.aspx.cdcab7d2.compiled|
|2021-04-01 02:55:30|MFT|.\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\root\a056c683\f67bca3c\App_Web_aa0aecbt.dll|

Correlating the logs we can expect that the attacker was able to use their tool via submit.aspx so the correct date time they are after relates to the time in the IIS logs and the attacker action and the first use.

**Flag:2021-04-01 02:55:29**

## Memory and TrufflePig Forensics
Wanted to have a look at network connections and things going on related to this IP address in memory and found the following netconns:
![](Assets\2022-01-21-16-11-07.png)
![](Assets\2022-01-29-04-15-17.png)

Will be looking at those further I'm sure in subsequent challenges.










