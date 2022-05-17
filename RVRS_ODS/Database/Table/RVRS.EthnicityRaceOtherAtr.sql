--drop table [RVRS].[EthnicityRaceOtherAtr]
--sp_help '[RVRS].[EthnicityRaceOtherAtr]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[EthnicityRaceOtherAtr]') )
	BEGIN 
		CREATE TABLE [RVRS].[EthnicityRaceOtherAtr] (  
		   [EthnicityRaceOtherAtrId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the		  
		   [IsHispanic] VARCHAR(8) NULL ,   --IS_HISPANIC
		   [IsSpecificHispanic] VARCHAR(8) NULL,  --IS_SPECIFIC_HISPANIC
		   [IsOtherHispanic] VARCHAR(8) NULL,  --IS_OTHER_HISPANIC
		   [AppearDeathCertificate] VARCHAR(128),   -- CERT_RACE_SPECIFY
		   [HispanicCodeLiteral] VARCHAR(8) NULL ,   --DETHNIC5C
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_EthnicityRaceOtherAtrCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_EthnicityRaceOtherAtrId] PRIMARY KEY CLUSTERED 
		(
			[EthnicityRaceOtherAtrId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 