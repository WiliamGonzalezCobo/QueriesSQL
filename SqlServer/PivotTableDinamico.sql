


--Nombre :[CP_RequerimientosByEntidadRpt]  
--Descripción : Reporte de las solicitudes atendidas por segmento en un rango de fechas  
--Parámetros :  
--    @dFechaIncial date - Fecha Inicial  
--    @dFechaFinal date - Fecha Final  
--    @iEmpresaID int - ID de la entidad  
--    @vchinentidades varchar(200) - ID's serparadas por comas de las entidades a presentar en el reporte las demás  quedan como 'OTRAS ENTIDADES'  
  
--Historia:  
--Versión  Fecha   Cambio    Autor     Descripción  
--1.0.000  03/01/2017  C18588    Dilver Valencia   Creación  
--1.0.001  28/05/2019  C?????    William Gonzalez   modificacion dinamica de empresa  
--Ejemplos
-- CP_RequerimientosByEntidadRpt '05/23/2018','05/25/2019',null,''
-- CP_RequerimientosByEntidadRpt '05/23/2018','05/25/2019',null,'1,86,91'
-- CP_RequerimientosByEntidadRpt '05/23/2019','05/25/2019',null,'1'
-- CP_RequerimientosByEntidadRpt '05/23/2019','05/25/2019',null,'91'

ALTER PROCEDURE dbo.CP_RequerimientosByEntidadRpt(@dFechaIncial date , 
                                                  @dFechaFinal date , 
                                                  @iEmpresaID int , 
                                                  @vchinentidades varchar(200))
AS
BEGIN  
    --SET NOCOUNT ON;  
  
    --Inicialización de Parámetros Begin  
    IF @iEmpresaID = 0
        BEGIN
            SET @iEmpresaID = NULL;
        END;  
    --Inicialización de Parámetros End  
    DECLARE
       @sqlQuery nvarchar(1000) = '' , 
       @columnas varchar(1000) = '' , 
       @alias varchar(1000) = '',
       @aliasPv varchar(1000) = '';

    BEGIN TRY


        SELECT b.vchEmpresa , 
               a.iEntidad , 
               c.vchEntidad , 
               ISNULL(COUNT(biSolicitudId) , 0)iCantidad INTO #Alltemp
          FROM
               dbo.CT_Solicitudes a JOIN dbo.CT_Empresa b
               ON a.iEmpresaId = b.iEmpresaId
                                    JOIN ct_entidades c
               ON a.iEntidad = c.iEntidad
          WHERE iEstado = 1
            AND CONVERT(date , dtFechaRta) >= CONVERT(date , @dFechaIncial)
            AND CONVERT(date , dtFechaRta) <= CONVERT(date , @dFechaFinal)
            AND a.iEmpresaId = ISNULL(@iEmpresaID , a.iEmpresaId)
          GROUP BY a.iEmpresaId , 
                   b.vchEmpresa , 
                   a.iEntidad , 
                   c.vchEntidad;
                   
        --Columnas Dinamicas
        SET @columnas = (SELECT STUFF((
                                       SELECT DISTINCT ', [' + vchEmpresa + ']'
                                         FROM #Alltemp
                                         FOR XML PATH('')) , 1 , 2 , ''));
        --Alias Dinamicos
        SET @alias = (SELECT STUFF((
                                    SELECT DISTINCT ', [' + vchEmpresa + '] [iCantidad' + vchEmpresa + ']'
                                      FROM #Alltemp
                                      FOR XML PATH('')) , 1 , 2 , ''));
                                      
        --Alias pivot Dinamicos
        SET @aliasPv = (SELECT STUFF((
                                    SELECT DISTINCT ', [iCantidad' + vchEmpresa + ']'
                                      FROM #Alltemp
                                      FOR XML PATH('')) , 1 , 2 , ''));

        IF @vchinentidades = ''
            BEGIN  
                --Pivot de los resultados Dinamicos 
                SET @sqlQuery = 'SELECT iEntidad , vchEntidad ,' + @alias + 'FROM #Alltemp PIVOT(SUM(iCantidad)FOR vchEmpresa IN(' + @columnas + '))AS PivotTab;';
                
            END;
        ELSE
            BEGIN
            SET @sqlQuery = 'SELECT iEntidad , 
				vchEntidad ,' + @alias + ' INTO #PivotTemp FROM #Alltemp PIVOT(SUM(iCantidad)FOR vchEmpresa IN(' + @columnas + '))AS PivotTable;
				SELECT  iEntidad , 
					   vchEntidad , ' + @aliasPv + '
				FROM
				  #PivotTemp a JOIN dbo.FN_Split(''' + @vchinentidades + ''')u
				  ON a.iEntidad = u.iRadicado
				  UNION ALL
					SELECT 0 , 
				 ''OTRAS ENTIDADES'' ,' + @aliasPv + '
				  FROM
				  #PivotTemp a LEFT JOIN dbo.FN_Split(''' + @vchinentidades + ''')u
				  ON a.iEntidad = u.iRadicado
				  WHERE u.iRadicado IS NULL;
				DROP TABLE #PivotTemp;';
            END;
	   EXECUTE sp_executesql @sqlQuery;
        DROP TABLE #Alltemp;
    END TRY
    BEGIN CATCH
        DECLARE
           @vchMensajeError varchar(max);
        DECLARE
           @iNumeroError int;
        DECLARE
           @iErrorSeverity int;

        SET @vchMensajeError = ERROR_MESSAGE();
        SET @iNumeroError = ERROR_NUMBER();
        SET @iErrorSeverity = ERROR_SEVERITY();

        IF @iErrorSeverity < 11
            BEGIN
                SET @iErrorSeverity = 11;
            END;
        IF @iNumeroError > 255
            BEGIN
                SET @iNumeroError = -1;
            END;
        RAISERROR(@vchMensajeError , @iErrorSeverity , @iNumeroError);
    END CATCH;
    SET NOCOUNT OFF;
END;  
  
  
  