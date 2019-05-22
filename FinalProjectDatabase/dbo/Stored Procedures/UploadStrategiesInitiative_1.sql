-- =============================================
-- Author:		MinhNN12
-- Create date: 12/20/2017 4:48:51 PM
-- Description:	UploadStrategiesInitiative
-- =============================================
CREATE PROCEDURE [dbo].[UploadStrategiesInitiative]
    @StrategyInitiative StrategyInitiativeRawDataType READONLY
    WITH RECOMPILE
AS
    BEGIN
        SET ARITHABORT ON		
        DECLARE @ResultTable TABLE
            (
             [InitiativeId] [NVARCHAR](MAX) NULL
           , [StrategyId] [NVARCHAR](MAX) NULL
           , [InitiativeName] [NVARCHAR](MAX) NULL
           , [PartnerIncharge] [NVARCHAR](MAX) NULL
           , [ImplementationStatus] [NVARCHAR](MAX) NULL
           , [ImplementationDate] [NVARCHAR](MAX) NULL
           , [Description] [NVARCHAR](MAX) NULL
		   , [FunctionId] [NVARCHAR](MAX) NULL
		   , [BusinessId] [NVARCHAR](MAX) NULL
           , [ErrorMessage] [NVARCHAR](MAX) NULL
            )
        DECLARE @TemporaryTable TABLE
            (
             [InitiativeId] [NVARCHAR](MAX) NULL
           , [StrategyId] [NVARCHAR](MAX) NULL
           , [InitiativeName] [NVARCHAR](MAX) NULL
           , [PartnerIncharge] [NVARCHAR](MAX) NULL
           , [ImplementationStatus] [NVARCHAR](MAX) NULL
           , [ImplementationDate] [NVARCHAR](MAX) NULL
           , [Description] [NVARCHAR](MAX) NULL
		   , [FunctionId] [NVARCHAR](MAX) NULL
		   , [BusinessId] [NVARCHAR](MAX) NULL
           , [CreatedDate] [DATETIME] NULL
           , [CreatedBy] [NVARCHAR](MAX) NULL
           , [UpdatedDate] [DATETIME] NULL
           , [UpdatedBy] [NVARCHAR](MAX) NULL
            )
        DECLARE @cnt INT = 0;
        WHILE @cnt < (SELECT COUNT (1) FROM @StrategyInitiative)
            BEGIN			
                BEGIN TRY
                    INSERT  @TemporaryTable
                            (InitiativeId
                           , StrategyId
                           , InitiativeName
                           , PartnerIncharge
                           , ImplementationStatus
                           , ImplementationDate
                           , Description
						   , FunctionId
						   , BusinessId
                           , CreatedDate
                           , CreatedBy
                           , UpdatedDate
                           , UpdatedBy
				            )
                            SELECT  InitiativeId
                                  , StrategyId
                                  , InitiativeName
                                  , PartnerIncharge
                                  , ImplementationStatus
                                  , ImplementationDate
                                  , Description
								  ,	FunctionId
								  ,	BusinessId
                                  , CreatedDate
                                  , CreatedBy
                                  , UpdatedDate
                                  , UpdatedBy
                            FROM    @StrategyInitiative
                            ORDER BY InitiativeId DESC
                                  OFFSET @cnt ROWS FETCH NEXT 1 ROWS ONLY
					
					DECLARE @InitiativeId NVARCHAR(MAX) = (SELECT TOP 1 InitiativeId FROM @TemporaryTable)
					--VARIABLE FOR FUNCTION
					DECLARE @PartnerIncharge			NVARCHAR(max) = (SELECT TOP 1 PartnerIncharge FROM @TemporaryTable)
					DECLARE @PartnerInchargeID			NVARCHAR(MAX) = 
						(select reverse(stuff(reverse(CONVERT(NVARCHAR(max), 
						(SELECT E.EmployeeID + ','
						FROM dbo.FnSplitString(@PartnerIncharge, ',')
						LEFT JOIN Common.dbo.Employee E ON E.EmailAddress = SplitItem FOR XML PATH(''))
						)), 1, 1, '')))
					--VARIABLE FOR FUNCTION AND BUSINESS
					DECLARE @Function					NVARCHAR(max) = (SELECT TOP 1 FunctionId FROM @TemporaryTable)
					DECLARE @FunctionIdFollowFunction	NVARCHAR(max) = @Function
					DECLARE @Business					NVARCHAR(max) = (SELECT TOP 1 BusinessId FROM @TemporaryTable)
					DECLARE @FunctionIdFollowBusiness	NVARCHAR(max) = (SELECT TOP 1 FunctionCode FROM Common.dbo.ProfitCenter WHERE ProfitCenterGroupCode = @Business)
								
					----CHECK FUNCTION
					IF ((SELECT COUNT(1) FROM Common.dbo.ProfitCenter WHERE FunctionCode = @Function) = 0 OR @FunctionIdFollowFunction IS NULL)
					BEGIN				
						INSERT @ResultTable
                                    (InitiativeId
                                   , StrategyId
                                   , InitiativeName
                                   , PartnerIncharge
                                   , ImplementationStatus
                                   , ImplementationDate
                                   , Description
                                   , FunctionId
                                   , BusinessId
                                   , ErrorMessage
                                    )                            
                                    SELECT TOP 1
                                            InitiativeId
                                          , StrategyId
                                          , InitiativeName
                                          , PartnerIncharge
                                          , ImplementationStatus
                                          , ImplementationDate
                                          , Description
										  , FunctionId
										  , BusinessId
                                          , 'Not Map Function Name Or Function Name Is Null'
                                    FROM    @TemporaryTable		
																					
					END	
					--CHECK BUSINESS
					ELSE 
					IF ((SELECT COUNT(1) FROM Common.dbo.ProfitCenter WHERE ProfitCenterGroupCode = @Business) > 0 
						AND @FunctionIdFollowBusiness IS NOT NULL 
						AND @FunctionIdFollowFunction <> @FunctionIdFollowBusiness)
					BEGIN
						INSERT @ResultTable
                                    (InitiativeId
                                   , StrategyId
                                   , InitiativeName
                                   , PartnerIncharge
                                   , ImplementationStatus
                                   , ImplementationDate
                                   , Description
                                   , FunctionId
                                   , BusinessId
                                   , ErrorMessage
                                    )                            
                                    SELECT TOP 1
                                            InitiativeId
                                          , StrategyId
                                          , InitiativeName
                                          , PartnerIncharge
                                          , ImplementationStatus
                                          , ImplementationDate
                                          , Description
										  , FunctionId
										  , BusinessId
                                          , 'Not Map Business Unit Name'
                                    FROM    @TemporaryTable
					END	
					ELSE
					BEGIN
					----CHECK BUSINESS
					
				--INSERT WHEN ID = 0
				IF @InitiativeId IS NULL OR @InitiativeId = 0
                    INSERT dbo.StrategyInitiative
                            (StrategyId
                           , InitiativeName
                           , PartnerIncharge
                           , ImplementationStatus
                           , ImplementationDate
                           , Description
                           , CreatedDate
                           , CreatedBy
                           , UpdatedDate
                           , UpdatedBy
                           , FunctionId
                           , BusinessUnitId
                            )                   
                            SELECT  TOP 1
									StrategyId
                                  , InitiativeName
                                  , @PartnerInchargeID
                                  , ImplementationStatus
                                  , ImplementationDate
                                  , Description
                                  , GETDATE()
                                  , CreatedBy
                                  , GETDATE()
                                  , UpdatedBy								  
								  , @Function
								  ,	@Business
                            FROM    @TemporaryTable
                            WHERE   InitiativeId = 0
      --              IF @@ROWCOUNT < 0
                        
						--BEGIN
				--UPDATE WHEN ID <> 0
				ELSE
                BEGIN 
                    UPDATE  dbo.StrategyInitiative
                    SET     InitiativeName = Source.InitiativeName
                          , PartnerIncharge = @PartnerInchargeID
                          , ImplementationStatus = Source.ImplementationStatus
                          , ImplementationDate = Source.ImplementationDate
                          , Description = Source.Description
						  , FunctionId = @Function
						  , BusinessUnitId = @Business
                          , UpdatedDate = GETDATE()
                          , UpdatedBy = Source.UpdatedBy
                    FROM    @TemporaryTable AS Source
                    WHERE   Source.InitiativeId <> 0
                            AND Source.InitiativeId = dbo.StrategyInitiative.InitiativeId
                    IF @@ROWCOUNT = 0
                        BEGIN
                            INSERT @ResultTable
                                    (InitiativeId
                                   , StrategyId
                                   , InitiativeName
                                   , PartnerIncharge
                                   , ImplementationStatus
                                   , ImplementationDate
                                   , Description
                                   , FunctionId
                                   , BusinessId
                                   , ErrorMessage
                                    )                            
                                    SELECT TOP 1
                                            InitiativeId
                                          , StrategyId
                                          , InitiativeName
                                          , PartnerIncharge
                                          , ImplementationStatus
                                          , ImplementationDate
                                          , Description
										  , FunctionId
										  , BusinessId
                                          , 'No Record Found'
                                    FROM    @TemporaryTable
                        END
						END 
						--END
						END	
                    DELETE  FROM @TemporaryTable
                END TRY
                BEGIN CATCH
                    INSERT @ResultTable
                                    (InitiativeId
                                   , StrategyId
                                   , InitiativeName
                                   , PartnerIncharge
                                   , ImplementationStatus
                                   , ImplementationDate
                                   , Description
                                   , FunctionId
                                   , BusinessId
                                   , ErrorMessage
                                    )                            
                                    SELECT TOP 1
                                            InitiativeId
                                          , StrategyId
                                          , InitiativeName
                                          , PartnerIncharge
                                          , ImplementationStatus
                                          , ImplementationDate
                                          , Description
										  , FunctionId
										  , BusinessId
                                          , ERROR_MESSAGE()
                                    FROM    @TemporaryTable
                END CATCH
                DELETE  FROM @TemporaryTable
                SET @cnt = @cnt + 1;				
            END;	
        SELECT  *
        FROM    @ResultTable
    END