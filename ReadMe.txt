Finding Timestomping from Windows Event Logs

It involves altering the system’s clock or adjusting the dates of files, affecting timestamp integrity within Event Logs. This technique can disrupt the sequence of logged events, complicating incident analysis and forensics.

An attacker might change the system time before executing malicious activities, making these activities appear to have occurred at an earlier or later time than they actually did. This can mislead security solutions (SIEM, EDR) that rely on log timestamps to piece together the sequence of events and generate an alert 

Security EventID 4616
The system time was changed. This is the most reliable Event ID we will use to detect time slipping 
[Microsoft-Windows-Time-Service] EventID 52
   This event is important to monitor significant system time alterations
[Microsoft-Windows-Time-Service] EventID 261
   W32time service changed the time