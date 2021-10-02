SELECT count(SessionNumber)SessionNumber, ProcessName, RunningResourceName
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

       SELECT 0 as SessionNumber, '#NA' as ProcessName, '#NA' as RunningResourceName, '1900-01-01 00:00:00.000' as StartDatetime, '1900-01-01 00:00:00.000' as EndDatetime
       ,'NoData' as Description, 'NoData' as Result, '1900-01-01 00:00:00.000' as lastupdated

)tsessions
GROUP BY ProcessName,RunningResourceName
ORDER BY SessionNumber DESC