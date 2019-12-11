
CREATE TYPE [dbo].[MyTypeTable] AS TABLE(
	[UniqueID] [uniqueidentifier] NOT NULL,
	[orden] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Value] [varchar](100) NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


