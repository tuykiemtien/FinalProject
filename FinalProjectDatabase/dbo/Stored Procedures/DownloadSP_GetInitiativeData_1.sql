-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DownloadSP_GetInitiativeData]
	-- Add the parameters for the stored procedure here
	@filterClause NVARCHAR(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	BEGIN TRANSACTION
	Declare @sql  NVARCHAR(Max);

	SET @sql  = '
		SELECT 
			i.StrategyId AS [Strategy ID], 
			s.StrategyName AS [Strategy Name],
			i.InitiativeId AS [Initiative ID],
			i.InitiativeName AS [Initiative Name],
			 CASE 
				WHEN i.ImplementationStatus = 1 THEN ''GOOD PROGRESS''
				WHEN i.ImplementationStatus = 2 THEN ''MODERATE PROGRESS'' 
				ELSE ''LOW PROGRESS''
			 END AS [Status],
			 CONCAT(MONTH(i.ImplementationDate) , ''/'' , YEAR(i.ImplementationDate)) AS [Implementation Date],
			 i.Description
			 ,(select reverse(stuff(reverse(CONVERT(NVARCHAR(max), 
				(SELECT E.EmployeeName + '',''
				FROM dbo.FnSplitString(i.PartnerIncharge, '','')
				LEFT JOIN Common.dbo.Employee AS E ON E.EmployeeID = SplitItem FOR XML PATH(''''))
				)), 1, 1, '''')))	AS [Partner In Charge],
			(select reverse(stuff(reverse(CONVERT(NVARCHAR(max), 
				(SELECT E.EmailAddress + '',''
				FROM dbo.FnSplitString(i.PartnerIncharge, '','')
				LEFT JOIN Common.dbo.Employee AS E ON E.EmployeeID = SplitItem FOR XML PATH(''''))
				)), 1, 1, '''')))	AS [Email ID],
			f.FunctionCode AS [Function ID],
			b.ProfitCenterGroupCode AS [Business Unit ID]
		FROM dbo.StrategyInitiative i
		JOIN dbo.Strategies s ON s.StrategyId = i.StrategyId
		LEFT JOIN (SELECT DISTINCT FunctionCode FROM Common.dbo.ProfitCenter) f ON f.FunctionCode = i.FunctionId
		LEFT JOIN (SELECT DISTINCT ProfitCenterGroupCode FROM Common.dbo.ProfitCenter) b ON b.ProfitCenterGroupCode = i.BusinessUnitId
		WHERE ' + @filterClause  
	print(@sql)
	Exec(@sql)
	COMMIT TRANSACTION -- Insert statements for procedure here
	
END