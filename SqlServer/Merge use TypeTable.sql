CREATE PROCEDURE [dbo].[stpInvoiceLineAdditionalPropertiesUpdate]
	 @prmMyTypeTable MyTypeTable READONLY,
	 @prmUUID uniqueidentifier = null
AS
BEGIN

	declare @query nvarchar(MAX)
	declare @strNombreTabla varchar (200)	

	set @query = 'merge MyTabla as t using @prmMyTypeTable as s
					on t.[UniqueID] = s.[UniqueID] and t.[orden] = s.[orden] and t.[Name] = s.[Name]
				  when matched
					then update 
					set 
					t.[Value] = s.[Value]
				  when not matched by target
					then insert (
						[UniqueID],
						[orden],
						[Name],
						[Value])
						values (s.[UniqueID],
								s.[orden],
								s.[Name],
								s.[Value])
				  when not matched by source and t.[UniqueID] in (@prmUUID)
					then delete;					
				'

	   exec sp_executesql @query 
		   ,N'@prmMyTypeTable MyTypeTable READONLY
		   ,@prmUUID uniqueidentifier = null'
		   ,@prmMyTypeTable
		   , @prmUUID
END



GO


