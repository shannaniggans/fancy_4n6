# IA-1
The actor seems to have initially failed to install themselves on the web server. What IP address did their malicious wizardry come from?


# IA-2
It looks like the actor eventually succeeded in gaining access using a combination of multiple well-documented CVEs. Which of these is the most recent?


# IA-3
What was the filename of the first file created by the actor to test that their exploit worked? (We'll refer to this test file as sample 1)
Flag format - filename.ext


# IA-4
After calling home, the actor finally succeeded in dropping their core tool, sample 2.What time (UTC) was this tool first used?



Something for later
![](2022-01-21-16-11-07.png)



https://www.cyber.gov.au/acsc/view-all-content/advisories/advisory-2020-004-remote-code-execution-vulnerability-being-actively-exploited-vulnerable-versions-telerik-ui-sophisticated-actors

4/1/21
1:49:08.000 PM	
2021-04-01 02:49:08 10.1.0.80 POST /Telerik.Web.UI.WebResource.axd type=rau 80 - 13.54.35.87 python-urllib3/1.26.2 - 500 0 0 52
c_ip = 13.54.35.87host = dmz-webpubsource = u_ex210401.logsourcetype = iis

Flag = 13.54.35.87

Initial Access - 2

	4/1/21
1:46:33.000 PM	
2021-04-01 02:46:33 10.1.0.80 GET /Telerik.Web.UI.WebResource.axd type=rau 80 - 13.54.35.87 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64;+rv:54.0)+Gecko/20100101+Firefox/54.0 - 200 0 0 11
c_ip = 13.54.35.87host = dmz-webpubsource = u_ex210401.logsourcetype = iis
CVE-2019-18935

![](2022-01-21-15-45-20.png)



next time - Install volatility in WSL2
parse MFT - Autopsy and EZTools
