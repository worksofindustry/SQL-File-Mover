CREATE ASSEMBLY [NCrontabSQL] FROM 'C:\SQLServer\NcrontabSQL.dll'
WITH PERMISSION_SET = UNSAFE;
GO

CREATE FUNCTION dbo.CrontabSchedule( @Expression NVARCHAR(100), @Start DATETIME, @End DATETIME) 
RETURNS TABLE ( [Occurrence] DATETIME) AS     
            --assembly name  --namespace.<public class>  --return value 
EXTERNAL NAME [NCrontabSQL].[NCrontab.SqlCrontab].      [GetOccurrences] 
GO
