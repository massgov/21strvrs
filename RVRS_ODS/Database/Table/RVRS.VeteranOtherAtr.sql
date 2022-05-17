--drop table [RVRS].[VeteranOtherAtr]
--sp_help '[RVRS].[VeteranOtherAtr]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[VeteranOtherAtr]') )
	BEGIN 
		CREATE TABLE [RVRS].[VeteranOtherAtr] (  
		   [VeteranOtherAtrId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the		  
		   [DimArmedId] INT NOT NULL CONSTRAINT [df_VeteranOtherAtrDimArmedId] DEFAULT (0), --ARMED?
		   [VeteranEntries] DECIMAL(2,0) NOT NULL, --VET_ENTRIES
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_VeteranOtherAtrCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_VeteranOtherAtrId] PRIMARY KEY CLUSTERED 
		(
			[VeteranOtherAtrId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 