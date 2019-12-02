Dear reader,

Please read this document carefully as it outlines the organization of the key deliverables of project. Successful implementation of these codes requires a sufficient understanding of the following topics:
- Robotics Process Automation (RPA) and its database schema (RPA tool used in this project is BluePrism. Hence, these queries will require adaptation if you choose to implement on other vendors like Automation Anywhere or UIPath)
- Basic understanding of PowerShell syntax
- Intermediate understanding of PowerBI (especially connecting to streaming datasets feature and its requirements)

There are 4 main folders in this project:

_doc: Contains Word document that outline the architectural designs of the platform that houses this solution, along with instructions in the deployments that connect different pieces together
_pbix: Contains 4 different PowerBI files for 4 different dashboards that each corresponds to unique challenges of monitoring RPA platform at scale
_powershell: Contains a powershell file that execute 4 SQL queries in the _sql folder and push the data to PowerBI Data Gateway in the cloud server
_sql: Contains the 4 SQL queries that return the data in the format ready to be visualized by PowerBI without the need for calculation or filtering.


Under each solution name are the descriptions of the unique challenges we face in monitoring RPA platform at scale:

    WorkForceAvailability:

    RunningStages:

    ScheduleStatus:

    Moving4HourTerminationCount:









