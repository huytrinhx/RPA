SELECT ScheduleName ,  
	StartResource,
	StartResourceStatus,
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
                            WHEN (Datediff(mi, dateadd(mi, 5,instancetime) , nextstarted)/triggerperiod)-1 <= 0 OR StartResourceStatus = 'Working' THEN 0
                            ELSE (Datediff(mi, dateadd(mi, 5,instancetime), nextstarted)        /triggerperiod)-1
                     END 
              WHEN convertedunit='Minutes' 
              AND    CONVERT(VARCHAR(10), getdate(), 121) + ' ' + RIGHT(nextstarted, 7) > CONVERT(VARCHAR(10), getdate(), 121) + ' ' + endpoint THEN 0
              WHEN convertedunit='Hours' 
              AND    CONVERT(VARCHAR(10), getdate(), 121) + ' ' + RIGHT(nextstarted, 7) <= CONVERT(VARCHAR(10), getdate(), 121) + ' ' + endpoint
              AND    CONVERT(VARCHAR(11), nextstarted, 121) = CONVERT(VARCHAR(11), instancetime, 121) THEN
                     CASE 
                            WHEN ( 
                                          Datediff(hour, dateadd(mi, 5,instancetime), nextstarted)/triggerperiod)-1 <=0 OR StartResourceStatus = 'Working' THEN 0
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
					 StartResourceStatus,
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
								   StartResourceStatus,
                                   initialtaskid, 
                                   startdate, 
                                   CASE 
                                          WHEN convertedunit='Minutes' 
                                          AND    getdate() BETWEEN CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' ' +startpoint)) AND    CONVERT(datetime, CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)
                                          AND    dateadd(mi, triggerperiod, getdate()) < (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint) THEN
										                                                   CONVERT(varchar,dateadd(mi, ceiling((datediff(ss, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint)), getdate())/(1.0*triggerperiod*60))) * triggerperiod, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))), 100) 
                                          WHEN convertedunit='Minutes' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))) >0 THEN
                                                 CONVERT(varchar,CONVERT(datetime, CONVERT (varchar(10), getdate(), 101) + ' ' + startpoint), 100)
                                          WHEN convertedunit='Minutes' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint))) <0 
                                          OR     ( 
                                                        dateadd(mi, triggerperiod, getdate()) > (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)) THEN CONVERT(varchar,CONVERT(datetime, CONVERT (varchar(10), dateadd(dd, 1, getdate()), 101) + ' ' + startpoint), 100)
                                          WHEN convertedunit='Hours' 
                                          AND    getdate() BETWEEN CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' ' +startpoint)) AND    CONVERT(datetime, CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)
                                          AND    dateadd(hh, triggerperiod, getdate()) < (CONVERT(varchar(10), getdate(), 121) + ' '+ convertedendpoint)
                                          THEN CONVERT(varchar,dateadd(hour, ceiling((datediff(ss, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint)), getdate())/(1.0*triggerperiod*3600))) * triggerperiod, CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))), 100) 
                                          WHEN convertedunit='Hours' 
                                          AND    datediff(ss, getdate(), CONVERT(datetime,(CONVERT(varchar(10), getdate(), 121) + ' '+ startpoint))) >0 THEN 
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
                                             SELECT     s.NAME AS schedulename , 
                                                        instancetime , 
                                                        initialtaskid ,
							       ts.resourcename AS StartResource,
								rs.DisplayStatus AS StartResourceStatus,
                                                       startdate, 
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
											 LEFT JOIN bparesource rs WITH (nolock)
											 ON        ts.resourcename = rs.name
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
		 '#*NA*#'              StartResourceStatus ,
         '1900-01-01 00:00:00' nextstarted , 
         '1900-01-01 00:00:00' instancetime , 
         0                     triggerperiod , 
         '#*NA*#'              convertedunit , 
         '#*NA*#'              startpoint , 
         '#*NA*#'              endpoint , 
         -1                    riskscore , 
         '#*NA*#'              schedulestatus 

ORDER BY 
		RiskScore DESC,
		nextstarted DESC, 
              schedulename