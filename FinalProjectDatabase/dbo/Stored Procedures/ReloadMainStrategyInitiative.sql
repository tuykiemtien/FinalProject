CREATE PROCEDURE [dbo].[ReloadMainStrategyInitiative]
	@Id INT,	-- StrategyId
	@IsMain BIT = 1,
	@FilterInitiativeId INT = 0
AS
BEGIN
	IF(@IsMain = 1 AND (@FilterInitiativeId != 0 OR @Id != 0))
		BEGIN
			SELECT 
				SI.InitiativeId,
				SI.StrategyId,
				SI.InitiativeName,
				SI.PartnerIncharge,
				SI.ImplementationDate,
				SI.[Description],
				SI.CreatedDate,
				SI.CreatedBy,
				SI.UpdatedDate,
				SI.UpdatedBy,
				SI.FunctionId,
				SI.BusinessUnitId,
				SI.ActiveFlag,
				(SELECT SUM(IAD.ProjectedRevenue) FROM InitiativeActivities IA,StrategyInitiative STI, [dbo].[InitiativeActivityDetail] IAD WHERE IA.InitiativeID = STI.InitiativeId AND SI.InitiativeId = STI.ParentId AND IA.[ActivitiesId] = IAD.[ActivitiesId]) ProjectedRevenue,
				(SELECT SUM(IAD.InvestmentOutlay) FROM InitiativeActivities IA,StrategyInitiative STI, [dbo].[InitiativeActivityDetail] IAD WHERE IA.InitiativeID = STI.InitiativeId AND SI.InitiativeId = STI.ParentId AND IA.[ActivitiesId] = IAD.[ActivitiesId]) InvestmentOutlay
			FROM dbo.StrategyMainInitiative SI 
			WHERE ActiveFlag = 1 
			  AND InitiativeId = @Id
		END
	ELSE
		BEGIN
			SELECT 
				SI.InitiativeId,
				SI.StrategyId,
				SI.InitiativeName,
				SI.PartnerIncharge,
				SI.ImplementationDate,
				SI.[Description],
				SI.CreatedDate,
				SI.CreatedBy,
				SI.UpdatedDate,
				SI.UpdatedBy,
				SI.FunctionId,
				SI.BusinessUnitId,
				SI.ActiveFlag,
				(SELECT SUM(IAD.ProjectedRevenue) FROM InitiativeActivities IA,StrategyInitiative STI, [dbo].[InitiativeActivityDetail] IAD WHERE IA.InitiativeID = STI.InitiativeId AND SI.InitiativeId = STI.ParentId AND IA.[ActivitiesId] = IAD.[ActivitiesId] AND STI.InitiativeId = @FilterInitiativeId) ProjectedRevenue,
				(SELECT SUM(IAD.InvestmentOutlay) FROM InitiativeActivities IA,StrategyInitiative STI, [dbo].[InitiativeActivityDetail] IAD WHERE IA.InitiativeID = STI.InitiativeId AND SI.InitiativeId = STI.ParentId AND IA.[ActivitiesId] = IAD.[ActivitiesId] AND STI.InitiativeId = @FilterInitiativeId) InvestmentOutlay
			FROM dbo.StrategyMainInitiative SI 
			WHERE ActiveFlag = 1 
			  AND InitiativeId = @Id
		END
	
END