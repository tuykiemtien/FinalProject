CREATE PROCEDURE [dbo].[GetStrategieByDashboardId]
	@DashboardId INT
AS
BEGIN
	SELECT TOP 1
		StrategyId,
		DashletId,
		StrategyName,
		EmployeeName AS SponsoringPartner,
		StrategyStatus,
		EntailDescription,
		DisplayConfiguration,
		HighlightUpdates,
		AdditionalRequirement,
		DecisionRquired,
		CreatedDate,
		st.CreatedBy,
		UpdatedDate,
		UpdatedBy,
		Area
	FROM dbo.Strategies st
	LEFT JOIN Common.dbo.Employee ON EmployeeID = SponsoringPartner
	JOIN dbo.Dashlet dl ON dl.Id = st.DashletId
	JOIN dbo.Dashboard db ON db.Id = dl.DashboardId
	WHERE db.Id = @DashboardId

END
GO

