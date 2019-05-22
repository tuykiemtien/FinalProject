CREATE PROCEDURE [dbo].[GetCreateDataAccess] 
	@AppCode nvarchar(250),
	@EmployeeId nvarchar(50),
	@DatasetId int

AS
BEGIN

     CREATE TABLE #TempTable (
          ID int,
          AppCode nvarchar(255),
          DatasetId int,
		  Condition Nvarchar(1024),
          [Create] int,
          [UserGroup] int,
          [UserGroupName] nvarchar(255),
          [Query] nvarchar(2048),
          [IsUserInGroup] int
     )

     INSERT INTO #TempTable
          SELECT
               DAC.Id,
               DAC.AppCode,
               DAC.DatasetId,
			   UG.FunctionBUProfitCenter,
               DAC.[Create],
               UG.[UserGroup],
               UG.[UserGroupName],
               CONCAT('', 'SELECT @CNT = COUNT(EMPLOYEEID) FROM COMMON.DBO.EMPLOYEE WHERE EMPLOYEEID =''', @EmployeeId, '''', '  AND  ', UG.[Condition]),
               0
          FROM DashletAccessControl DAC
          LEFT JOIN UserGroup UG
               ON DAC.[UserGroup/UserId] = UG.UserGroup
          WHERE AppCode = @AppCode AND [Create] = 1 AND UG.UserGroup IS NOT NULL AND DatasetId = @DatasetId

     DECLARE @LoopCounter int,
             @MaxId int


     SELECT
          @LoopCounter = MIN(id),
          @MaxId = MAX(Id)
     FROM #TempTable

     WHILE (@LoopCounter IS NOT NULL
          AND @LoopCounter <= @MaxId)
     BEGIN

          DECLARE @count int
          DECLARE @sqlCommand nvarchar(1000)

          DECLARE @counts int
          DECLARE @query nvarchar(2048) = (SELECT TOP 1
               [Query]
          FROM #TempTable
          WHERE ID = CONVERT(nvarchar(255), @LoopCounter));
          SET @query = CONVERT(nvarchar(2048), @query)

          EXECUTE sp_executesql @query,
                                N'@cnt int OUTPUT',
                                @cnt = @counts OUTPUT
          UPDATE #TempTable
          SET IsUserInGroup =
                             CASE
                                  WHEN @counts > 0 THEN 1
                                  ELSE 0
                             END
          WHERE ID = CONVERT(nvarchar(255), @LoopCounter)

          SET @LoopCounter = @LoopCounter + 1

     END


	 SELECT
          MAX([Create]) AS AccessControl
     FROM #TempTable
     WHERE ISUSERINGROUP = 1
     GROUP BY DatasetId,
              AppCode
END