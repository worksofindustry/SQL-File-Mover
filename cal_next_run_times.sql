With cte AS (
SELECT P.ID, P.[FILE], P.[Source_Directory], P.[Target_Directory], PLU.[Schedule], S.Occurrence AS Next_Run_Time, 
Row_Number() OVER(PARTITION BY ID ORDER BY S.Occurrence ASC) AS R, --get most recent Next_Run_Time
ROW_NUMBER() OVER(PARTITION BY [FILE], [Schedule], Source_Directory, Target_Directory ORDER BY ID DESC) AS R2
FROM dbo.PublicFileCopier P INNER JOIN dbo.SchedulesForPublicFileCopier PLU ON P.Schedule_ID=PLU.LUID
CROSS APPLY dbo.CrontabSchedule(PLU.[Schedule], GETDATE(), DATEADD(DAY,60,GETDATE())) AS S
WHERE (Source_Directory IS NOT NULL OR Target_Directory IS NOT NULL) 
AND s.Occurrence IS NOT NULL
)
UPDATE P
SET P.Next_Run_Time = cte.Next_Run_Time
FROM dbo.PublicFileCopier AS P INNER JOIN cte ON P.ID=cte.ID
GO
Select * FROM cte WHERE R = 1 AND R2 = 1
GO