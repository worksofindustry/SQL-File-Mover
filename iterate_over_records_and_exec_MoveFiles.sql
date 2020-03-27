--Cursor Params
DECLARE @ID INT
DECLARE @s1 NVARCHAR(250)
DECLARE @s2 NVARCHAR(250)
DECLARE @s3 NVARCHAR(250)

DECLARE cur CURSOR FAST_FORWARD LOCAL FOR 

		Select ID, 
		CASE WHEN CHARINDEX(' ', RTRIM(LTRIM([FILE]))) = 0 OR CHARINDEX(' ', RTRIM(LTRIM([FILE]))) IS NULL THEN RTRIM(LTRIM([FILE]))
		ELSE '''''' + [FILE] + '''''' END as s1,
		
		CASE 
		WHEN 
		CHARINDEX(' ', CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))), 1) <>'\' THEN Source_Directory ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))),1)) END) = 0 
		OR
		CHARINDEX(' ', CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))), 1) <>'\' THEN Source_Directory	ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))),1)) END) IS NULL
		THEN
		CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))), 1) <>'\' THEN Source_Directory	ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))),1)) END
		ELSE
		'''''' + CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))), 1) <>'\' THEN Source_Directory	ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Source_Directory))),1)) END + ''''''
		END
		as s2,

		CASE 
		WHEN 
		CHARINDEX(' ', CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))), 1) <>'\' THEN Target_Directory ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))),1)) END) = 0 
		OR
		CHARINDEX(' ', CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))), 1) <>'\' THEN Target_Directory	ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))),1)) END) IS NULL
		THEN
		CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))), 1) <>'\' THEN Target_Directory	ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))),1)) END
		ELSE
		'''''' + CASE WHEN LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))), 1) <>'\' THEN Target_Directory	ELSE REVERSE(LEFT(REVERSE(LTRIM(RTRIM(Target_Directory))),1)) END + ''''''
		END + ' '''
	
		as s3
		
				
		FROM dbo.PublicFileCopier
		WHERE (Transfer_In_Progress IS NULL OR Transfer_In_Progress = 0) --don't move any files in progress
		AND LTRIM(RTRIM([FILE]))<>'' --don't want user to enter an empty file or directory
		AND Next_Run_Time BETWEEN DATEADD(MINUTE,-1,GETDATE()) AND DATEADD(MINUTE,2,GETDATE())

OPEN cur
		
		FETCH NEXT FROM cur INTO @ID, @s1, @s2, @s3

			WHILE @@FETCH_STATUS = 0

		BEGIN

				BEGIN TRY

					UPDATE dbo.PublicFileCopier SET Transfer_In_Progress = 1 WHERE ID=@ID ;
					
					DECLARE @SQL NVARCHAR(2000)
					SET @SQL = 'xp_cmdshell	''cd \ && CMD /s /c powershell C:\MoveFiles.ps1 -file ' + @s1 + ' -source_dir ' + @s2 + ' -target_dir ' + @s3 
							
					EXECUTE sp_executesql @sql
														
					UPDATE dbo.PublicFileCopier SET Transfer_In_Progress = 0, Last_Run_Time = GETDATE(), Last_Run_Success=1 WHERE ID = @ID

				END TRY

				BEGIN CATCH

					UPDATE dbo.PublicFileCopier SET Last_Run_Success = 0, Transfer_In_Progress = 0, Last_Run_Time = GETDATE() WHERE ID=@ID

					SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() AS ErrorSeverity, ERROR_STATE() AS ErrorState,
					ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine,	ERROR_MESSAGE() AS ErrorMessage
					
				END CATCH

			FETCH NEXT FROM cur INTO @ID, @s1, @s2, @s3

		END

CLOSE cur
DEALLOCATE cur
;
