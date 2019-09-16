
Import-Module MicrosoftPowerBIMgmt
Import-Module MicrosoftPowerBIMgmt.Profile


<#
Created By: Rajesh R Nair
Created on: 12-Mar-2019
Purpose: This Power shell script will read the data from SQL Server with the query provided 
and execute the same to refresh the dataset mentioned in the endpoint of the streaming dataset
This applicable for Use Case 1, Use Case 2, Use Case 3 and Use Case 4
#>


<#
Read the Server Details form the .ini file. the file will be kept outside the script to control the Server details configurable

#>
$filepath = "D:\BluePrism\QA\Control.ini"
$Logfileu1 = "D:\BluePrism\QA\Logs\BluePrismUsecase1log.log"
$Logfileu2 = "D:\BluePrism\QA\Logs\BluePrismUsecase2log.log"
$Logfileu3 = "D:\BluePrism\QA\Logs\BluePrismUsecase3log.log"
$Logfileu4 = "D:\BluePrism\QA\Logs\BluePrismUsecase4log.log"

$ControlParameters = Get-Content $filepath 

# Read User Id password and password converted to secure string
$UserId = $ControlParameters[5].Substring($ControlParameters[5].IndexOf("=") + 1)
$Password = Get-Content D:\BluePrism\QA\Secure\password.txt | ConvertTo-SecureString -Key (Get-Content D:\BluePrism\QA\Secure\aes.key)
$credential = New-Object System.Management.Automation.PsCredential($UserId,$Password)


#Login with the credentials

Connect-PowerBIServiceAccount -Credential $credential

#Get the SQL Server sepcific details from ini
$SqlServer = $ControlParameters[0].Substring($ControlParameters[0].IndexOf("=") +1)
$SqlDatabase = $ControlParameters[1].Substring($ControlParameters[1].IndexOf("=") +1 )
$Useridsql = $ControlParameters[2].Substring($ControlParameters[2].IndexOf("=") +1 )
$Passwordsql = $ControlParameters[3].Substring($ControlParameters[3].IndexOf("=") +1 )
$Interval = $ControlParameters[4].Substring($ControlParameters[4].IndexOf("=") +1 )
#form Connection string




#$SqlConnectionString = 'Data Source={0};Initial Catalog={1};Integrated Security=SSPI' -f $SqlServer, $SqlDatabase;
$SqlConnectionString = 'Data Source={0};Initial Catalog={1};User ID={2};password={3}' -f $SqlServer, $SqlDatabase, $Useridsql, $Passwordsql ;



#Set the connection    
$SqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $SqlConnectionString;
$SqlConnection.Open();            

#Append Log file
function LogWrite
{
   Param ([string]$Logfile,[string]$logstring)

   Add-content $Logfile -value $logstring
}

#Write to New Log file
function LogWriteStart
{
   Param ([string]$Logfile,[string]$logstring)
   
   
  set-content $Logfile -value $logstring
}


function UseCase1refresh()
{
    


    Try
    {
    
        #Query to refresh the dataset
        
        $SqlQueryu1 = ";with DP AS 
                    (Select 'Idle' AS DisplayStatus
                            UNION ALL Select 'Logged Out' AS DisplayStatus
                            UNION ALL Select 'Missing' AS DisplayStatus
                            UNION ALL Select 'Offline' AS DisplayStatus
                            UNION ALL Select 'Private' AS DisplayStatus
                            UNION ALL Select 'Working' AS DisplayStatus
                    )
                    Select   VDI.Name,VDI.Status,DP.DisplayStatus,VDI.ResourceGroupPool
                    from DP
                    Left Join (
                                SELECT VDI.name AS Name, VDI.status AS Status,VDI.DisplayStatus,CASE 
                                WHEN GROUP_RESOURCE.groupname = 'Default' THEN VDI_POOL.PoolName
                                ELSE GROUP_RESOURCE.groupname
                                END AS ResourceGroupPool
                                FROM (SELECT [resourceid]
                                            ,[name]
                                            ,[status]
                                            ,[processesrunning]
                                            ,[actionsrunning]
                                            ,[lastupdated]
                                            ,[AttributeID]
                                            ,[pool]
                                            ,[DisplayStatus]
                                    FROM BPAResource WITH (NOLOCK)
                                    WHERE AttributeID = 0) AS VDI
                                    LEFT JOIN
                                    (SELECT resourceid AS PoolId, name AS PoolName
                                    FROM BPAResource WITH (NOLOCK)
                                    WHERE AttributeID = 8) AS VDI_POOL ON VDI.[pool] = VDI_POOL.PoolId
                                    LEFT JOIN (SELECT [id],
                                         [groupname]       
                                    FROM [BPVGroupedResources] WITH (NOLOCK)) GROUP_RESOURCE ON VDI.resourceid = GROUP_RESOURCE.id
                                    WHERE 
                                    (GROUP_RESOURCE.groupname = 'Default' AND VDI_POOL.PoolId IS NOT NULL)
                                    OR
                                    (GROUP_RESOURCE.groupname <> 'Default')) VDI ON DP.DisplayStatus=VDI.DisplayStatus
                                                              WHERE VDI.ResourceGroupPool <> '__UnGrouped and UnPooled VDIs'
                                                            
UNION ALL
SELECT '#*NA*#' as Name, '#*NA*#' as Status, '#*NA*#' as DisplayStatus, '#*NA*#' as ResourceGroupPool
ORDER BY ResourceGroupPool";

            #Set the query
            $SqlCommandu1 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu1.CommandText = $SqlQueryu1;
            
            
            $SqlCommandu1.Connection = $SqlConnection;
        
        
            #Open and execute the query
            #$SqlConnection.Open();
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru1 = New-Object System.Data.SqlClient.SqlDataAdapter;
            
            $SqlAdapteru1.SelectCommand = $SqlCommandu1;
            
            $DataSetu1 = New-Object System.Data.DataSet;

            $recrodsu1 = $SqlAdapteru1.Fill($DataSetu1);
           
          $NameValue = $DataSetu1.Tables[0].Rows[0].ItemArray[0]
          
          
            $SqlDatau1= ($DataSetu1.Tables[0] | select $DataSetu1.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
            
            if ($NameValue -eq "#*NA*#" -and $recrodsu1 -eq 1)
            {
            
            $SqlDatau1 = "[" + $SqlDatau1 + "]"
            }
            
            
            


            #QA
            $endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/74757163-c116-40bd-a7da-57b1eee36631/rows?key=DDpTzKjKNcG5wdSiWEAmSbN6cdWhzDBAlM30RRKlHqt1evRQIHHbV%2Bp45AnluK4StRDYnKa3cfDKziKcDjATTQ%3D%3D"

            #actual
            #$endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/4e363e09-7a32-4579-bf96-e98da193d4a4/rows?key=ebc6KHPiGxqBm43K%2Ftx6nJ4gTn9%2FAw2jhaDj3EU%2FaJpEPZB5ef%2FNPx9yF1V1tMR0nYSOF6xTLBcROQ1wHeo9cA%3D%3D"

            #working
            #$endpointu1  = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/ea585ac0-95c3-4b8d-876d-c51b2c61bb4e/rows?key=XG6X5nGbEoQgKNO5v0XdyvuQknhldEGIo0PwVjxHZqxcC71mTGGlRuboDZZG34I3zk6qqYc4RzgCnYmjSxyNrg%3D%3D"

                       
            Remove-PowerBIRow -Datasetid 74757163-c116-40bd-a7da-57b1eee36631 -TableName RealTimeData
            #working
            #Remove-PowerBIRow -Datasetid ea585ac0-95c3-4b8d-876d-c51b2c61bb4e -TableName RealTimeData

            $Starttime = Get-Date
            LogWrite $Logfileu1 "Event: Refresh starts eventDate: $Starttime"

            Invoke-RestMethod -Method Post -Uri "$endpointu1" -Body ($SqlDatau1)
            $Starttime = Get-Date
            LogWrite $Logfileu1 "Event: Refresh ends eventDate: $Starttime"

            #sleep for 10 Sec
            #Start-Sleep $Interval         

            $SqlAdapteru1.Dispose();        
            $SqlCommandu1.Dispose();
            [System.GC]::Collect();
            


                                      
    
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu1 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu1 "Error Message: $ErrorMessage"
        [System.GC]::Collect();
   

    }

}






<#Trigger Use case 3 #>

function UseCase3Refresh()
{

    Try
    {
        $Starttime = Get-Date

        


         
           
            #Query to refresh the dataset

            $SqlQueryu3 = "select  Process
              ,Resource
              --,startdatetime
              ,LastUpdated
              ,LatestStage
			  --,Duration1 duration1
			  ,Duration
			  ,case when DurationInminutes<0 then 0 else DurationInminutes end DurationInminutes
              , StatusId  
              , case when StatusId = 0 then 1 else 0 end StatusId0
              , case when StatusId = 1 then 1 else 0 end StatusId1
			  ,Pendingruntime
			  ,ProcessDurationInminutes
			  from
			  (
select   Process
              ,Resource
              --,startdatetime
              ,LastUpdated
              ,LatestStage
			  ,Duration duration1
                       ,CASE WHEN DATEDIFF(SECOND,isnull([lastupdated],[startdatetime]),getdate()) > 0  
                        THEN Duration
                        ELSE '00:00:00' 
                        END AS Duration
              ,cast(substring(Duration,1,2) AS int)*60+
         cast(substring(Duration,4,2) AS int)+ 
         cast(substring(Duration,7,2) AS int)/60.0 AS DurationInminutes,
         StatusId,
		 Pendingruntime,
         cast(substring(Pendingruntime,1,2) AS int)*60+
         cast(substring(Pendingruntime,4,2) AS int)+ 
         cast(substring(Pendingruntime,7,2) AS int)/60.0 AS ProcessDurationInminutes
FROM
(
       SELECT [processname] As Process
                                ,[runningresourcename] AS Resource
                                ,[startdatetime] AS startdatetime
                                ,[lastupdated] AS LastUpdated
                                ,[laststage]  AS LatestStage
                                ,CASE WHEN lastupdated is null
                                                       THEN RIGHT('0' + CAST(DATEDIFF(SECOND, [startdatetime], GETDATE()) / 3600 AS VARCHAR),2) + ':' +
                                                                RIGHT('0' + CAST((DATEDIFF(SECOND,[startdatetime], GETDATE()) % 3600)/60 AS VARCHAR),2) + ':' +
                                                                RIGHT('0' + CAST(DATEDIFF(SECOND, [startdatetime], GETDATE()) % 60 AS VARCHAR),2) 
                                                        ELSE
                                                                RIGHT('0' + CAST(DATEDIFF(SECOND, [lastupdated], GETDATE()) / 3600 AS VARCHAR),2) + ':' +
                                                                RIGHT('0' + CAST((DATEDIFF(SECOND,[lastupdated], GETDATE()) % 3600)/60 AS VARCHAR),2) + ':' +
                                                                RIGHT('0' + CAST(DATEDIFF(SECOND, [lastupdated], GETDATE()) % 60 AS VARCHAR),2) 
                                                        END AS Duration ,
                                                        statusid AS StatusId  ,
								RIGHT('0' + CAST(DATEDIFF(SECOND, [startdatetime], GETDATE()) / 3600 AS VARCHAR),2) + ':' +
                                                                RIGHT('0' + CAST((DATEDIFF(SECOND,[startdatetime], GETDATE()) % 3600)/60 AS VARCHAR),2) + ':' +
                                                                RIGHT('0' + CAST(DATEDIFF(SECOND, [startdatetime], GETDATE()) % 60 AS VARCHAR),2) AS Pendingruntime                                                    
       FROM [BPVSessionInfo] with (nolock) 
       WHERE statusid in( '1','0')
)a  
--where DATEDIFF(SECOND,isnull([lastupdated],[startdatetime]),getdate()) < 0  
--where process='U-P-S2C-05-Ariba-Create Ariba Sourcing Projects-Process 05'
) aa    
UNION ALL
select  '#*NA*#' Process
              ,'NA' Resource
              --,startdatetime
              ,'1900-01-01 00:00:00.000' LastUpdated
              ,'NA'LatestStage
			  --,Duration1 duration1
			  ,'NA' Duration
			  ,0.0 DurationInminutes
              , 1 StatusId  
              , 0  StatusId0
              , 0  StatusId1
			  ,'NA' Pendingruntime
			  ,0 ProcessDurationInminutes                        
ORDER BY DurationInminutes DESC";

           #Set the query
            $SqlCommandu3 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu3.CommandText = $SqlQueryu3;

            $SqlCommandu3.Connection = $SqlConnection;
                
            #Open and execute the query
            #$SqlConnection.Open();

            #This connection end point to be replaced for each report
           # $endpointu3 ="https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/b9e5ac8f-44aa-4408-961b-b133214b708b/rows?key=t23XD%2F985k1RRypo3kEWUMFrm37D40IoMXCk%2FNWtUZ3Q2096RvXcZW7wekFAR3pb%2BIAdvmBnMyjnDg6MwKpEtQ%3D%3D";

            $endpointu3 ="https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/2b1d05c9-cf72-4ff4-bfbc-6eba4d255b16/rows?key=4fe%2BvhtNH8CqlkD8g00nQFGg%2F6%2FDv42Lfa83gfqbGT5Ds0ZJtoKBL%2FR86tBqUx6T8UlAdB1VOhfsZIStRCq%2FtA%3D%3D";

            $Starttime = Get-Date
            LogWrite $Logfileu3 "Event: Refresh starts eventDate: $Starttime"
            
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru3 = New-Object System.Data.SqlClient.SqlDataAdapter;
            $SqlAdapteru3.SelectCommand = $SqlCommandu3;
            $DataSetu3 = New-Object System.Data.DataSet;
            $recrodsu3 = $SqlAdapteru3.Fill($DataSetu3);
         
            #Convert the dataset to Jason
           # $SqlDatau3= ($DataSetu3.Tables[0] | select $DataSetu3.Tables[0].Columns.ColumnName ) | ConvertTo-Json


           $Process = $DataSetu3.Tables[0].Rows[0].ItemArray[0]
          
            $SqlDatau3= ($DataSetu3.Tables[0] | select $DataSetu3.Tables[0].Columns.ColumnName ) | ConvertTo-Json
           
             
            if ($Process -eq "#*NA*#" -and $recrodsu3 -eq 1)
            {
            
            $SqlDatau3 = "[" + $SqlDatau3 + "]"
            }
            
            
            
            

            Remove-PowerBIRow -Datasetid 2b1d05c9-cf72-4ff4-bfbc-6eba4d255b16 -TableName RealTimeData
            #echo "Refresh"
            
            Invoke-RestMethod -Method Post -Uri "$endpointu3" -Body ($SqlDatau3)
            
            $Starttime = Get-Date
            LogWrite $Logfileu3 "Event: Refresh ends eventDate: $Starttime"

            #sleep for 10 Sec
           # Start-Sleep $Interval         

            $SqlAdapteru3.Dispose();        
            $SqlCommandu3.Dispose();
            #$SqlConnection.Close();   
            #$SqlConnection.Dispose();   
            [System.GC]::Collect();
                                                  
    }
           
    
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu3 "Event: Logging Error Catch Block eventDate1: $Starttime"
        LogWrite $Logfileu3 "Error Message: $ErrorMessage"
        #$SqlAdapteru3.Dispose();        
        #$SqlCommandu3.Dispose();
        #$SqlConnection.Close();   
        #$SqlConnection.Dispose();   
        [System.GC]::Collect();
        #Break
    }
}





function UseCase4refresh()
{
    


    Try
    {
    
        #Query to refresh the dataset
        
        $SqlQueryu4 = "SELECT count(SessionNumber)SessionNumber, ProcessName, RunningResourceName
FROM
(
       Select  TERMINATED_SESSIONS.sessionnumber As SessionNumber, TERMINATED_SESSIONS.processname As ProcessName, TERMINATED_SESSIONS.runningresourcename as RunningResourceName, convert(varchar(30),TERMINATED_SESSIONS.startdatetime,121) as StartDatetime,
              convert(varchar(30),TERMINATED_SESSIONS.enddatetime,121) as EndDatetime,  
              ST.[description] as Description,
              (SELECT '[STAGE: ' + SL.stagename + ' | RESULT: ' + CONVERT(VARCHAR(255), SL.result) + '];  '
              FROM [dbo].[BPASessionLog_NonUnicode] SL with (nolock)
              WHERE SL.sessionnumber = TERMINATED_SESSIONS.sessionnumber
                     AND SL.result LIKE '%ERROR%'
              FOR XML PATH(''))AS Result ,lastupdated 
       From
    (
              SELECT [sessionnumber]
        ,[processname]
        ,[runningresourcename]
        ,[startdatetime]
        ,[starttimezoneoffset]
        ,[enddatetime]
        ,[endtimezoneoffset]
        ,[lastupdated]
        ,[statusid]
              FROM [dbo].[BPVSessionInfo] with (nolock) 
              Where 
        DATEDIFF(HOUR, [lastupdated], GETDATE()) <= 4
        AND 
              (statusid = 2 OR statusid = 3) 
        And lastupdated In (Select Max(lastupdated) From [dbo].[BPVSessionInfo] WITH (NOLOCK) Group by sessionid)
    ) AS TERMINATED_SESSIONS
       JOIN BPAStatus ST WITH (NOLOCK) ON TERMINATED_SESSIONS.statusid = ST.statusid

       UNION ALL

       SELECT 0 as SessionNumber, '#*NA*#' as ProcessName, '#*NA*#' as RunningResourceName, '1900-01-01 00:00:00.000' as StartDatetime, '1900-01-01 00:00:00.000' as EndDatetime
       ,'NoData' as Description, 'NoData' as Result, '1900-01-01 00:00:00.000' as lastupdated

)tsessions
GROUP BY ProcessName,RunningResourceName
ORDER BY SessionNumber DESC"

            #Set the query
            $SqlCommandu4 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu4.CommandText = $SqlQueryu4;
            
            
            $SqlCommandu4.Connection = $SqlConnection;
        
        
            #Open and execute the query
            #$SqlConnection.Open();
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru4 = New-Object System.Data.SqlClient.SqlDataAdapter;
            
            $SqlAdapteru4.SelectCommand = $SqlCommandu4;
            
            $DataSetu4 = New-Object System.Data.DataSet;

            $recrodsu4 = $SqlAdapteru4.Fill($DataSetu4);
            
            $ProcessName = $DataSetu4.Tables[0].Rows[0].ItemArray[1]

         
            #Convert the dataset to Jason
            $SqlDatau4= ($DataSetu4.Tables[0] | select $DataSetu4.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
            
             if ($ProcessName -eq "#*NA*#" -and $recrodsu4 -eq 1)
            {
            
            $SqlDatau4 = "[" + $SqlDatau4 + "]"
            }


            


            #QA
            $endpointu4 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/a8f7e381-60c4-471f-8f0b-a5ce3ae4e29e/rows?key=RL7uPMU4n84SptqnQXjcgyut%2FQ10J8Ncx2ery%2Bf6wc6rkf7bYMREaJ2hrIJj16wtrYqgbjci3LQ3IuTgntlOUw%3D%3D"

            #actual
            #$endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/4e363e09-7a32-4579-bf96-e98da193d4a4/rows?key=ebc6KHPiGxqBm43K%2Ftx6nJ4gTn9%2FAw2jhaDj3EU%2FaJpEPZB5ef%2FNPx9yF1V1tMR0nYSOF6xTLBcROQ1wHeo9cA%3D%3D"

            #working
            #$endpointu1  = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/ea585ac0-95c3-4b8d-876d-c51b2c61bb4e/rows?key=XG6X5nGbEoQgKNO5v0XdyvuQknhldEGIo0PwVjxHZqxcC71mTGGlRuboDZZG34I3zk6qqYc4RzgCnYmjSxyNrg%3D%3D"

                       
            Remove-PowerBIRow -Datasetid a8f7e381-60c4-471f-8f0b-a5ce3ae4e29e -TableName RealTimeData
            #working
            #Remove-PowerBIRow -Datasetid ea585ac0-95c3-4b8d-876d-c51b2c61bb4e -TableName RealTimeData

            $Starttime = Get-Date
            LogWrite $Logfileu4 "Event: Refresh starts eventDate: $Starttime"

            Invoke-RestMethod -Method Post -Uri "$endpointu4" -Body ($SqlDatau4)
            $Starttime = Get-Date
            LogWrite $Logfileu4 "Event: Refresh ends eventDate: $Starttime"

                  

            $SqlAdapteru4.Dispose();        
            $SqlCommandu4.Dispose();
            #$SqlConnection.Close();   
            #$SqlConnection.Dispose();   
            [System.GC]::Collect();
            


                                      
    
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu4 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu4 "Error Message: $ErrorMessage"
        #$SqlAdapteru4.Dispose();  
        #$SqlCommandu4.Dispose();
        #$SqlConnection.Close();   
        #$SqlConnection.Dispose(); 
        [System.GC]::Collect();
        #Break

    }

}



function UseCase2refresh()
{
    


    Try
    {
    
        #Query to refresh the dataset
        
        $SqlQueryu2 = "SELECT ScheduleName ,  StartResource,
	   NextStarted , 
       InstanceTime , 
       TriggerPeriod , 
       ConvertedUnit , 
       StartPoint , 
       EndPoint , 
          CASE 
              WHEN convertedunit='Minutes' 
              AND    CONVERT(VARCHAR(10), getdate(), 121) + ' ' + RIGHT(nextstarted, 7) <= CONVERT(VARCHAR(10), getdate(), 121) + ' ' + endpoint
              AND    CONVERT(VARCHAR(11), nextstarted, 121) = CONVERT(VARCHAR(11), instancetime, 121) THEN
                     CASE 
                            WHEN ( 
                                          Datediff(mi, dateadd(mi, 5,instancetime) , nextstarted)/triggerperiod)-1 <= 0 THEN 0
                            ELSE (Datediff(mi, dateadd(mi, 5,instancetime), nextstarted)        /triggerperiod)-1
                     END 
              WHEN convertedunit='Minutes' 
              AND    CONVERT(VARCHAR(10), getdate(), 121) + ' ' + RIGHT(nextstarted, 7) > CONVERT(VARCHAR(10), getdate(), 121) + ' ' + endpoint THEN 0
              WHEN convertedunit='Hours' 
              AND    CONVERT(VARCHAR(10), getdate(), 121) + ' ' + RIGHT(nextstarted, 7) <= CONVERT(VARCHAR(10), getdate(), 121) + ' ' + endpoint
              AND    CONVERT(VARCHAR(11), nextstarted, 121) = CONVERT(VARCHAR(11), instancetime, 121) THEN
                     CASE 
                            WHEN ( 
                                          Datediff(hour, dateadd(mi, 5,instancetime), nextstarted)/triggerperiod)-1 <=0 THEN 0
                            ELSE (Datediff(hour, dateadd(mi, 5,instancetime), nextstarted)        /triggerperiod)-1
                     END 
              WHEN convertedunit='Hours' 
              AND    CONVERT(VARCHAR(10), getdate(), 121) + ' ' + RIGHT(nextstarted, 7) > CONVERT(VARCHAR(10), getdate(), 121) + ' ' + endpoint THEN 0
              ELSE 0 
       END RiskScore , 
       CASE 
              WHEN initialtaskid= 0 or nextstarted is null THEN 'TURNED OFF'
       END ScheduleStatus 
FROM   ( 
              SELECT schedulename,
					 StartResource,
                     next nextstarted , 
                     instancetime , 
                     triggerperiod , 
                     initialtaskid , 
                     startdate , 
                     convertedunit , 
                     startpoint , 
                     endpoint 
              FROM   ( 
                            SELECT a.schedulename,
								   StartResource,
                                   initialtaskid, 
                                   startdate, 
                                   CASE 
                                          WHEN convertedunit='Minutes' 
                                          AND    getdate() BETWEEN CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' ' +startpoint)) AND    CONVERT(datetime, CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)
                                          AND    dateadd(mi, triggerperiod, getdate()) < (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint) THEN -- CONVERTedUnit='Minutes'  and   datediff(ss,convert(datetime,(convert(varchar(10),getdate(),121) + ' '+ StartPoint)),getdate())>=0 and datediff(ss,convert(datetime,(convert(varchar(10),getdate(),121) + ' '+ CONVERTedENDPoint)),getdate())<0  then 
                                                 CONVERT(varchar,dateadd(mi, ceiling((datediff(ss, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint)), getdate())/(1.0*triggerperiod*60))) * triggerperiod, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))), 100) 
                                          WHEN convertedunit='Minutes' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))) >0 THEN --  and datediff(ss,getdate(),convert(varchar(10),getdate(),121) + ' '+ CONVERTedENDPoint) >0 THEN
                                                 CONVERT(varchar,CONVERT(datetime, CONVERT (varchar(10), getdate(), 101) + ' ' + startpoint), 100)
                                          WHEN convertedunit='Minutes' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint))) <0 
                                          OR     ( 
                                                        dateadd(mi, triggerperiod, getdate()) > (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)) THEN CONVERT(varchar,CONVERT(datetime, CONVERT (varchar(10), dateadd(dd, 1, getdate()), 101) + ' ' + startpoint), 100)
                                          WHEN convertedunit='Hours' 
                                          AND    getdate() BETWEEN CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' ' +startpoint)) AND    CONVERT(datetime, CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)
                                          AND    dateadd(hh, triggerperiod, getdate()) < (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint) --and   datediff(ss,convert(datetime,(convert(varchar(10),getdate(),121) + ' '+ StartPoint)),getdate())>=0 and datediff(ss,convert(datetime,(convert(varchar(10),getdate(),121) + ' '+ CONVERTedENDPoint)),getdate())<0  --and dateadd(hh,triggerperiod,getdate()) < (convert(varchar(10),getdate(),121) + ' '+ CONVERTedENDPoint)
                                          THEN CONVERT(varchar,dateadd(hour, ceiling((datediff(ss, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint)), getdate())/(1.0*triggerperiod*3600))) * triggerperiod, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))), 100) 
                                          WHEN convertedunit='Hours' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))) >0 THEN --  and datediff(ss,getdate(),convert(varchar(10),getdate(),121) + ' '+ CONVERTedENDPoint) >0 THEN
                                                 CONVERT(varchar,CONVERT(datetime, CONVERT (varchar(10), getdate(), 101) + ' ' + startpoint), 100)
                                          WHEN convertedunit='Hours' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint))) <0 
                                          OR     ( 
                                                        dateadd(hh, triggerperiod, getdate()) > (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)) THEN CONVERT(varchar,CONVERT(datetime, CONVERT (varchar(10), dateadd(dd, 1, getdate()), 101) + ' ' + startpoint), 100)
                                          WHEN convertedunit='Days' 
                                          AND    datediff(ss, CONVERT(datetime,(CONVERT(varchar(10), getdate(),121) + ' '+ right(convert(varchar(30),startdate,121),12))), getdate()) >0 THEN CONVERT(varchar(30), dateadd(day, 1, CONVERT(datetime,(CONVERT(varchar(10), getdate(),121) + ' '+ right(convert(varchar(30),startdate,121),12)))), 100) 
                                          WHEN convertedunit='Days' 
                                          AND    datediff(ss, CONVERT(datetime,(CONVERT(varchar(10), getdate(),121) + ' '+ right(convert(varchar(30),startdate,121),12))), getdate()) <=0 THEN CONVERT(varchar(20), CONVERT(datetime,(CONVERT(varchar(10), getdate(),121) + ' '+ right(convert(varchar(30),startdate,121),12))), 100) 
                                         
                                                                       WHEN convertedunit='Weeks' 
                                          AND    datepart(dw, startdate)= datepart(dw, getdate())
                                          AND    ( 
                                                        CONVERT(varchar(10), getdate(), 121) + ' ' + RIGHT(CONVERT(varchar(30), startdate, 121), 12)) > getdate() THEN CONVERT(varchar,dateadd(ww, datediff(ww, startdate, getdate()), startdate), 100)
                                          WHEN convertedunit='Weeks' 
                                          AND    datepart(dw, startdate)= datepart(dw, getdate())
                                          AND    ( 
                                                        CONVERT(varchar(10), getdate(), 121) + ' ' + RIGHT(CONVERT(varchar(30), startdate, 121), 12)) <= getdate() THEN CONVERT(varchar,dateadd(ww, datediff(ww, startdate, getdate())+1, startdate), 100)
                                          WHEN convertedunit='Weeks' 
                                          AND    datepart(dw, startdate)> datepart(dw, getdate()) THEN CONVERT(varchar,dateadd(ww, datediff(ww, startdate, getdate()), startdate), 100)
                                          WHEN convertedunit='Weeks' 
                                          AND    datepart(dw, startdate)< datepart(dw, getdate()) THEN CONVERT(varchar,dateadd(ww, datediff(ww, startdate, getdate())+1, startdate), 100)
                                          
                                                                       
                                                                     WHEN convertedunit='BiWeeks' 
                                          AND    datepart(dw, startdate)= datepart(dw, getdate())
                                          AND    ( 
                                                        CONVERT(varchar(10), getdate(), 121) + ' ' + RIGHT(CONVERT(varchar(30), startdate, 121), 12)) > getdate() THEN CONVERT(varchar,dateadd(ww, (datediff(dd, startdate, getdate())/14.0)*2, startdate), 100)
                                          WHEN convertedunit='BiWeeks' 
                                          AND    datepart(dw, startdate)= datepart(dw, getdate())
                                          AND    ( 
                                                        CONVERT(varchar(10), getdate(), 121) + ' ' + RIGHT(CONVERT(varchar(30), startdate, 121), 12)) <= getdate() THEN CONVERT(varchar,dateadd(ww, ((datediff(dd, startdate, getdate())/14.0)*2)+2, startdate), 100)
                                          WHEN convertedunit='BiWeeks' 
                                          AND    datepart(dw, startdate)> datepart(dw, getdate()) THEN CONVERT(varchar,dateadd(ww, ((datediff(dd, startdate, getdate())/14.0)*2)+1, startdate), 100)
                                                                                                                
                                                                       WHEN convertedunit='BiWeeks' 
                                          AND    datepart(dw, startdate)< datepart(dw, getdate()) THEN CONVERT(varchar,dateadd(ww, ((datediff(dd, startdate, getdate())/14.0)*2)+2, startdate), 100)
                                                                                                                
                                          WHEN convertedunit='Months' 
                                          AND    dateadd(mm, datediff(mm, startdate, getdate()), startdate) >= getdate() THEN CONVERT(varchar,dateadd(mm, datediff(mm, startdate, getdate()), startdate), 100)
                                          WHEN convertedunit='Months' 
                                          AND    dateadd(mm, datediff(mm, startdate, getdate()), startdate) < getdate() THEN CONVERT(varchar,dateadd(mm, datediff(mm, startdate, getdate())+1, startdate), 100)
                                   END                                                     next ,
                                   CONVERT(varchar,cast(instancetime AS datetime), 100) AS instancetime ,
                                   triggerperiod , 
                                   convertedunit , 
                                   CONVERT(varchar(8), cast(startpoint AS time), 100) AS startpoint ,
                                   convertedendpoint                                  AS endpoint
                            FROM   ( 
                                             SELECT    s.NAME AS schedulename , 
                                                       instancetime , 
                                                       initialtaskid ,
													   ts.resourcename AS StartResource,
                                                       startdate , 
                                                       endpoint , 
                                                       CONVERT(varchar,RIGHT('0' + cast(st.startpoint / 3600 AS varchar), 2) + ':' + RIGHT('0' + cast((st.startpoint / 60) % 60 AS varchar), 2) + ':' + RIGHT('0' + cast(st.startpoint % 60 AS varchar), 2), 112)             AS startpoint ,
                                                       CONVERT(varchar(7), cast(RIGHT('0' + cast(st.endpoint / 3600 AS varchar), 2) + ':' + RIGHT('0' + cast((st.endpoint / 60) % 60 AS varchar), 2) + ':' + RIGHT('0' + cast(st.endpoint % 60 AS varchar), 2) AS time), 100) AS convertedendpoint ,
                                                       CASE st.unittype 
                                                                 WHEN 1 THEN 'Hours' 
                                                                 WHEN 2 THEN 'Days' 
                                                                 WHEN 3 THEN 'Weeks' 
                                                                 WHEN 4 THEN 'Months' 
                                                                 WHEN 5 THEN 'Biweeks' 
                                                                 WHEN 6 THEN 'Minutes' 
                                                                 ELSE '' 
                                                       END         AS convertedunit , 
                                                       st.[period] AS triggerperiod 
                                             FROM      bpaschedule s WITH (nolock) 
                                             LEFT JOIN bpascheduletrigger st WITH (nolock) 
                                             ON        s.id = st.scheduleid 
											 LEFT JOIN bpatasksession ts WITH (nolock)
											 ON        s.initialtaskid = ts.taskid
                                             LEFT JOIN bpaschedulelog sl WITH (nolock) 
                                             ON        s.id = sl.scheduleid 
                                             AND       sl.heartbeat = 
                                                       ( 
                                                              SELECT max(sl2.heartbeat) 
                                                              FROM   bpaschedulelog sl2 WITH (nolock)
                                                              WHERE  sl2.scheduleid = sl.scheduleid)
                                             WHERE     s.NAME IS NOT NULL 
                                             AND       s.retired = 0 
                                             AND       st.priority = 0 
                                             AND       ( 
                                                                 st.enddate IS NULL 
                                                      OR        st.enddate > getdate()) )a)aa)aaa

UNION ALL 
SELECT   '#*NA*#'              schedulename ,
		 '#*NA*#'              StartResource ,
         '1900-01-01 00:00:00' nextstarted , 
         '1900-01-01 00:00:00' instancetime , 
         0                     triggerperiod , 
         '#*NA*#'              convertedunit , 
         '#*NA*#'              startpoint , 
         '#*NA*#'              endpoint , 
         -1                    riskscore , 
         '#*NA*#'              schedulestatus 
ORDER BY nextstarted DESC, 
         schedulename";

            #Set the query
            $SqlCommandu2 = New-Object -TypeName System.Data.SqlClient.SqlCommand;
            $SqlCommandu2.CommandText = $SqlQueryu2;
            
            
            $SqlCommandu2.Connection = $SqlConnection;
        
        
            #Open and execute the query
            #$SqlConnection.Open();
            # Return the dataset and fill it in Dataset      
            $SqlAdapteru2 = New-Object System.Data.SqlClient.SqlDataAdapter;
            
            $SqlAdapteru2.SelectCommand = $SqlCommandu2;
            
            $DataSetu2 = New-Object System.Data.DataSet;

            $recrodsu2 = $SqlAdapteru2.Fill($DataSetu2);
           
          $ScheduleName = $DataSetu2.Tables[0].Rows[0].ItemArray[0]
          
          
            $SqlDatau2= ($DataSetu2.Tables[0] | select $DataSetu2.Tables[0].Columns.ColumnName ) | ConvertTo-Json
            
            
            if ($ScheduleName -eq "#*NA*#" -and $recrodsu2 -eq 1)
            {
            
            $SqlDatau2 = "[" + $SqlDatau2 + "]"
            }
            
                       


            #QA
   
            $endpointu2 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/a615fa98-f1a0-4e60-9177-08bfec9a873e/rows?key=%2BsWOUVqYpclpLV0i4tFnudJxhz5PX%2B6Lu5DCrNRGonpMG2SDYeNdmrJdPO9uP6jWjN4BUM5SXbqThs1CbxpiRQ%3D%3D"

            #actual
            #$endpointu1 = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/4e363e09-7a32-4579-bf96-e98da193d4a4/rows?key=ebc6KHPiGxqBm43K%2Ftx6nJ4gTn9%2FAw2jhaDj3EU%2FaJpEPZB5ef%2FNPx9yF1V1tMR0nYSOF6xTLBcROQ1wHeo9cA%3D%3D"

            #working
            #$endpointu1  = "https://api.powerbi.com/beta/ca56a4a5-e300-406a-98ff-7e36a0baac5b/datasets/ea585ac0-95c3-4b8d-876d-c51b2c61bb4e/rows?key=XG6X5nGbEoQgKNO5v0XdyvuQknhldEGIo0PwVjxHZqxcC71mTGGlRuboDZZG34I3zk6qqYc4RzgCnYmjSxyNrg%3D%3D"

                       
            Remove-PowerBIRow -Datasetid a615fa98-f1a0-4e60-9177-08bfec9a873e -TableName RealTimeData
            #working
            #Remove-PowerBIRow -Datasetid ea585ac0-95c3-4b8d-876d-c51b2c61bb4e -TableName RealTimeData

            $Starttime = Get-Date
            LogWrite $Logfileu2 "Event: Refresh starts eventDate: $Starttime"

            Invoke-RestMethod -Method Post -Uri "$endpointu2" -Body ($SqlDatau2)
            $Starttime = Get-Date
            LogWrite $Logfileu2 "Event: Refresh ends eventDate: $Starttime"

            #sleep for 10 Sec
            #Start-Sleep $Interval         

            $SqlAdapteru2.Dispose();        
            $SqlCommandu2.Dispose();
            #$SqlConnection.Close();   
            #$SqlConnection.Dispose();   
            [System.GC]::Collect();
            


                                      
    
    }
    Catch 
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $Starttime = Get-Date
        LogWrite $Logfileu2 "Event: Logging Error Catch Block eventDate: $Starttime"
        LogWrite $Logfileu2 "Error Message: $ErrorMessage"
        #$SqlAdapteru1.Dispose();  
        #$SqlCommandu1.Dispose();
        #$SqlConnection.Close();   
        #$SqlConnection.Dispose(); 
        [System.GC]::Collect();
       # Break

    }

}






<#Block to trigger Use cases #>
$n=1
$Count = 1
DO
{    

    $Starttime = Get-Date
    if ($n -eq 1)
    {
    LogWriteStart $Logfileu1 "Event: Logging started Start Time: $Starttime";
    }
    UseCase1Refresh;   

    $Starttime = Get-Date

    if ($n -eq 1)
    {
    LogWriteStart $Logfileu3 "Event: Logging started Start Time: $Starttime"
    }

    UseCase3Refresh;

    $Starttime = Get-Date

    if ($n -eq 1)
    {
    LogWriteStart $Logfileu4 "Event: Logging started Start Time: $Starttime"
    }

    UseCase4Refresh;

    $Starttime = Get-Date

    if ($n -eq 1)
    {
    LogWriteStart $Logfileu2 "Event: Logging started Start Time: $Starttime"
    }

    UseCase2Refresh;


    $n=0
    #17280
    if ($Count -eq 17280)
    {
    
        if (Test-Path $Logfileu1) 
        {
            Remove-Item $Logfileu1
        }
        if (Test-Path $Logfileu3) 
        {
            Remove-Item $Logfileu3
        }
        if (Test-Path $Logfileu4) 
        {
            Remove-Item $Logfileu4
        }
        if (Test-Path $Logfileu2) 
        {
            Remove-Item $Logfileu2
        }
      $n = 1
      $Count = 1
    }
    

    $Count++
    

     #sleep for 10 Sec $Interval 
     Start-Sleep $Interval   

} While(1 -eq 1)

$SqlConnection.Close();  
$SqlConnection.Dispose();  
