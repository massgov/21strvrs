--drop table [RVRS].[DimAddressTypeInternal]
--sp_help '[RVRS].[DimAddressTypeInternal]'
--select * from [RVRS].[DimAddressTypeInternal]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DimAddressTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimAddressTypeInternal](
			[DimAddressTypeInternalId] [int] NOT NULL IDENTITY (1,1),
			[AddressTypeInternalDesc] [varchar](128) NOT NULL,
			[Void] [TINYINT] NOT NULL,
		 CONSTRAINT [pk_DimAddressTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimAddressTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


