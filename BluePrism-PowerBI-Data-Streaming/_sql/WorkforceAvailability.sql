;with DP AS 
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
                                    ) AS VDI
                                    LEFT JOIN
                                    (SELECT resourceid AS PoolId, name AS PoolName
                                    FROM BPAResource WITH (NOLOCK)
                                    ) AS VDI_POOL ON VDI.[pool] = VDI_POOL.PoolId
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

ORDER BY ResourceGroupPool