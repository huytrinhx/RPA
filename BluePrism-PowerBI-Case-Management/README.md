# PowerBI_CaseManagement_For_BluePrism


Please read this document carefully as it outlines the organization of the key deliverables of project. Successful implementation of these codes requires a sufficient understanding of the following topics:

- Robotics Process Automation (RPA) and its database schema (RPA tool used in this project is BluePrism. Hence, these queries will require adaptation if you choose to implement on other vendors like Automation Anywhere or UIPath)

- Advanced understanding of PowerBI (especially topics such as row-level security, M Query Languages, filtering)



There are 5 main folders in this project:

_doc: Contains Word document that outline the business requirements, UI design and business context. It also keeps artifacts of technical implementation from Power BI file as appendix for easy reference.

_pbix: Contains the finished solution with 90 days of data on it for users to have an understanding of the interactions between visualizations (Due to large file constraint, this file is not uploaded. Please email author if needed)

_Mcustomfunction: Contains separate documentation of all custom functions implemented for this solution. This is for reference only as the funcions are already implemented within powerbi file

_sql: Contains separate storage of the SQL query passed to PowerBI for the center table in the solution. This is for reference only as the funcions are already implemented within powerbi file

_xlsx: Contains the custom schema mapping that bridge the gaps between Blue Prism provided tables. It also keeps the records of users and their group for row-level security implementation.

