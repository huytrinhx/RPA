Dear reader,

Please read this document carefully as it outlines the organization of the key deliverables of project. Successful implementation of these codes requires a sufficient understanding of the following topics:
- Robotics Process Automation (RPA) and its database schema (RPA tool used in this project is BluePrism. Hence, these queries will require adaptation if you choose to implement on other vendors like Automation Anywhere or UIPath)
- Basic understanding of PowerShell syntax
- Intermediate understanding of PowerBI (especially connecting to streaming datasets feature and its requirements)

There are 4 main folders in this project:

_doc: Contains Word document that outline the architectural designs of the platform that houses this solution, along with instructions in the deployments that connect different pieces together

_pbix: Contains 4 different PowerBI files for 4 different dashboards that each corresponds to unique challenges of monitoring RPA platform at scale

_powershell: Contains a powershell file that execute 4 SQL queries in the _sql folder and push the data to PowerBI Data Gateway in the cloud server

_sql: Contains the 4 SQL queries that return the data in the format ready to be visualized by PowerBI without the need for calculation or filtering   


Under each solution name are the descriptions of the unique challenges we address in this solution sets:


WorkForceAvailability: displays the status (Working, Idle, Logged Out, Offline) of a VDI and the resource group it belongs to. This gives manager quick alert to take actions on (reboot, login, or escalate further) 

RunningStages: displays the current stage of the running sessions and how long it has been staying at the current stage. This gives manager insights whether the current stage are in trouble and causing the VDI to freeze or not.   

ScheduleStatus: displays schedule status based on schedule properties (start time of the day, interval, interval length) together with the actual last session run. Together, it gives insights into whether the scheduler has functioned correctly and whether there are any missing schedule firing.   

Moving4HourTerminationCount: displays termination counts group by each processes in the last 4 hour. This gives manager quick alert on troublesome processes that may need scheduler turned off and a configurator to look at     









