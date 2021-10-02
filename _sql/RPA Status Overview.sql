SELECT * FROM (
    SELECT [ident]
      ,[id]
      ,[queueid]
      ,[keyvalue]
      ,[status]
      ,[attempt]
      ,[exceptionreason]
      ,[worktime]
      ,[prevworktime]
      ,[attemptworktime]
      ,[state]
      ,DATEADD(hour, -4, [loaded])   as loaded
      ,DATEADD(hour, -4, [lastupdated]) as lastupdated
      ,[encryptid]
  FROM [BPVWorkQueueItem] as Q WITH (NOLOCK)
  WHERE [attempt] = (Select Max(attempt) from [BPVWorkQueueItem] as AT WITH (NOLOCK)  where AT.id = Q.id ) and
        [lastupdated] > = DATEADD(day, -90, GETDATE())) quitem
  LEFT JOIN
        (Select [queueitemident]
        ,concat_tag = STUFF((
          Select N';' + [tag] from [BPViewWorkQueueItemTag] WITH (NOLOCK)
          where [queueitemident] = itag.queueitemident order by [queueitemident] desc
          for XML PATH(''), Type).value(N'.[1]', N'nvarchar(max)'), 1, 1, N'')
      FROM [BPViewWorkQueueItemTag] as itag WITH (NOLOCK)
      Group by [queueitemident]) qutg
on
quitem.ident = qutg.queueitemident
  LEFT JOIN
  (Select [id] as qid ,[name] as queuename 
  From [BPAWorkQueue]) Q
on
quitem.queueid = Q.qid
Order by [lastupdated] desc
