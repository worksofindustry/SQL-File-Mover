IF OBJECT_ID('dbo.PublicFileCopier','U') IS NOT NULL DROP TABLE dbo.PublicFileCopier
GO


CREATE TABLE dbo.PublicFileCopier(ID INT IDENTITY(1,1), [FILE] NVARCHAR(510), [Source_Directory] NVARCHAR(520),
[Target_Directory] NVARCHAR(520), [Schedule_ID] INT, [Last_Run_Time] DATETIME, [Next_Run_Time] DATETIME, [Transfer_In_Progress] BIT, 
[Last_Run_Success] BIT )
GO

IF OBJECT_ID('dbo.SchedulesForPublicFileCopier', 'U') IS NOT NULL DROP TABLE dbo.SchedulesForPublicFileCopier
GO

CREATE TABLE dbo.SchedulesForPublicFileCopier(LUID INT IDENTITY(1,1), Schedule NVARCHAR(24), [Description] NVARCHAR(50))
GO

IF Object_ID('dbo.tr_SchedulesForPublicFileCopier', 'TR') IS NOT NULL DROP Trigger tr_SchedulesForPublicFileCopier
GO

CREATE TRIGGER tr_SchedulesForPublicFileCopier ON dbo.SchedulesForPublicFileCopier
INSTEAD OF INSERT
AS

BEGIN
    DECLARE @cronexpression nvarchar(24)
    SET @cronexpression = (Select [Schedule] from inserted)
    DECLARE @count INT
    SET @count = (Select ISNULL(count(*),0) FROM dbo.CrontabSchedule(@cronexpression, GETDATE(), DATEADD(YEAR,1,GETDATE())))

    IF @count > 0
    BEGIN
    INSERT INTO dbo.SchedulesForPublicFileCopier(Schedule, [Description])
    SELECT Schedule, [Description] FROM inserted
    END

    IF @count = 0
    BEGIN
    RAISERROR ('The cron expression is not valid. You can get help from https://crontab.guru', 16, 1)
    ROLLBACK TRANSACTION
END

END
GO


--Load in some test schedules
INSERT INTO dbo.SchedulesForPublicFileCopier(Schedule, [Description])
VALUES('* * * * *','Every Minute'),('*/5 * * * *','Every Five Minutes'),
('*/10 * * * *','Every 10 Minutes'),('*/15 * * * *','Every 15 Minutes'),
('*/30 * * * *','Every 30 Minutes'), ('0 * * * *','Every Hour'),
('0 6 * * *','6 AM In the Morning'),
('0 */2 * * *','Every Two Hours'), ('0 */6 * * *','Every Six Hours'),
('0 */12 * * *','Every 12 Hours'), ('*/5 9-17 * * *','During the Work Day'),
('0 0 * * *','Every day at Midnight'), ('0 0 1 * *','At the Start of Every Month'),
('0 0 1 1 *','On January 1st at Midnight');

--load in some directories and files to move
INSERT INTO dbo.PublicFileCopier([FILE], Source_Directory, Target_Directory, Schedule_ID)
VALUES('*_201901.xlsx','\\mynetwork\public','\\publicsrvr\t\Assignments','7'),
('SomeFile.Txt','\\network\location\of\your\file','\\cluster1\public\Public\Projects\','11'), ('SomeFile2.Txt','\\network\location\of\your\file','\\cluster1\public\Public\Projects\','4'),
('some_directory,''mynetwork\public','\\shared\aws\s3');

