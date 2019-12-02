select  Process
              ,Resource
              ,LastUpdated
              ,LatestStage
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
) aa    
UNION ALL
select  '#*NA*#' Process
              ,'NA' Resource

              ,'1900-01-01 00:00:00.000' LastUpdated
              ,'NA'LatestStage
			  ,'NA' Duration
			  ,0.0 DurationInminutes
              , 1 StatusId  
              , 0  StatusId0
              , 0  StatusId1
			  ,'NA' Pendingruntime
			  ,0 ProcessDurationInminutes                        
ORDER BY DurationInminutes DESC