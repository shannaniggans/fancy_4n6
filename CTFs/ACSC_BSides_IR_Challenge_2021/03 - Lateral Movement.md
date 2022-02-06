# Section 3 - Lateral Movement
**Having found evidence of malicious activity on their web server, ALIEN are concerned about what the actor did next. Maybe they tried to move further into the network.**

# LM-1
*Shortly after dropping sample 2 on disk, the actor seems to have downloaded an interesting looking file. What process does this file relate to?*

* Going back to Splunk and looking at the IIS logs there is a get request to a file - "/dfsr-reports/health-alien_webdev-31Marc2021-0421.xml".
* Quick Google of that directory and we see its the DFS Replication Health Report for the server.
* The hint is in the flag hint of ABCD - DFS Replication (DFSR)

**Flag: DFSR**

# LM-2
*So the DMZ webserver was connected via DFSR to another host on the network. What is the hostname of the server that is linked to the DMZ webserver through DFSR?*

* Time to look at the eventlogs and there is an eventlog for the DFS Replication service - "artefacts\dmz-webpub.alien.local\C\Windows\System32\winevt\Logs"
* Opening the eventlog with my Windows 10 system gives me the following error in every event log entry - "The description for Event ID 1202 from source DFSR cannot be found. Either the component that raises this event is not installed on your local computer or the installation is corrupted. You can install or repair the component on the local computer."
* If you want to open event logs from another system, you do need to have all the service installed on the system you are opening it on. Lucky this is why we use different parsers to get us the correct information.
* Splunk offers little in the of assistance here, also showing the error message.

## EvtxExplorer - EZTools

```
PS C:\Users\fancy_4n6\Desktop\EZTools> .\EvtxExplorer\EvtxECmd.exe -f "D:\Fancy4n6\Streams\ACSC_IR_Challenge_2021\artefacts\dmz-webpub.alien.local\C\Windows\System32\winevt\Logs\DFS Replication.evtx" --csv "D:\Fancy4n6\Streams\ACSC_IR_Challenge_2021\artefacts\dmz-webpub.alien.local" --csvf dmz-webpub-dfs-evt.csv
```
* Importing the results into my tracker spreadsheet.
* Scrolling across to the column "Payload" is where we see the details of the events and where we can see the other server that is linked.
  `{"EventData":{"Data":"BB8ED29B-1961-43F1-8B61-409F6A23E435, CORP-WEBDEV, dfsrtest, corp-webdev.alien.local, corp-webdev, 10.1.1.110, 1722, The RPC server is unavailable., 5309CC5C-F501-44D2-9AA4-41E563E223AE","Binary":""}}`

**Flag: CORP-WEBDEV**

# LM-3
*DFSR? Doesn't that have something to do with moving files around? Could sample 2 have been copied onto another server? What was the filepath of the replicated folder?*

sample 2 aka core tool = App_Web_aa0aecbt.dll

* Looking in the DFSR eventlog around the timeframe of that sample being loaded to dmz-webpub we see the following directory in logs - `{"EventData":{"Data":"4BEEF345-3B6B-43B1-97A4-E74FC5E0FEAA, C:\\inetpub\\wwwroot\\alien, alien, alien_webdev, 371ED249-B35C-4613-B4ED-7CEA42E2ED92, 34B06F13-4F16-4475-9947-9F7E03181BF3","Binary":""}}`

**Flag: c:\inetpub\wwwroot\alien**

# M-1
*What was the initial DFSR replicated folder set up between the two servers?*

`{"EventData":{"Data":"BBD5FC23-18C7-4852-B43B-0A869F460447, C:\\dfsrtest, dfsrtest, dfsrtest, 5309CC5C-F501-44D2-9AA4-41E563E223AE, 037CD430-D5EE-4B2A-BC47-2A30446C443C","Binary":""}}`

**Flag: c:\dfsrtest**

# LM-4
*So sample 2 was replicated onto CORP-WEBDEV, but we don't know if the actor were aware of the DFSR setup, or if they were able to access the replicated sample. Thankfully, ALIEN have provided data from CORP-WEBDEV for us to continue the investigation. What time (UTC) did the actor test their ability to interact with the copy of sample 2 on CORP-WEBDEV?*

* Looking through the artefacts provided, we once again have some IIS logs to ingest into Splunk, so I dropped those logs into Splunk and did some searching.

```
source="W3SVC2.zip:*" host="corp-webdev" index="acsc_ir_challenge_2021" 
| sort _time
| table _time, cs_method, cs_uri_stem, c_ip, sc_status
```
* The first eventlog related is a GET request to /submit.aspx, similarly as we saw on the dmz-webpub server: `4/1/21 3:03:16.000 AM 2021-04-01 03:03:16 10.1.1.110 GET /submit.aspx - 80 - 10.1.0.80 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64;+rv:54.0)+Gecko/20100101+Firefox/54.0 - 200 0 0 1703 c_ip = 10.1.0.80host = corp-webdevsource = W3SVC2.zip:.\u_ex210401.logsourcetype = iis`

```
.\MFTECmd.exe -f "D:\Fancy4n6\Streams\ACSC_IR_Challenge_2021\artefacts\corp-webdev.alien.local\C\`$MFT" --csv "D:\Fancy4n6\Streams\ACSC_IR_Challenge_2021\artefacts\corp-webdev.alien.local\C\" --csvf corp-webdev-mft-output.csv
```
* Parsing the MFT with EZTools MFT parser we can also see the sample being compiled:
  * ParentPath: .\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\root\a056c683\f67bca3c
  * FileName: submit.aspx.cdcab7d2.compiled
  * Timestamp: 2021-04-01 03:03:16.505

**Flag: 2021-04-01 03:03:16**