-- =============================================
-- Author: William Gonzalez
-- Create date: 20/02/2016
-- Description: Devuelve String con la totalidad vendida segun el vendedor y la forma de pago
-- Ejemplo: FVXVFP (1,1)
-- =============================================
CREATE FUNCTION FVXVFP (@VENDEDOR_DADO INT, @FORMA_DE_PAGO INT)
RETURNS VARCHAR(50)
AS
BEGIN
DECLARE
 @nombre as varchar(50),
 @total_ventas as int,
 @forma_Pago AS varchar(50);

 SELECT @nombre=VENDEDOR.nom_vendedor,
       @total_ventas=SUM(FACTURA.val_factura),
       @forma_Pago = f_pago.nom_f_pago
FROM dbo.VENDEDOR
    INNER JOIN dbo.CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN dbo.FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
    INNER JOIN dbo.F_PAGO ON F_PAGO.cod_f_pago =CLIENTE.cod_f_pago
    WHERE VENDEDOR.cod_vendedor=@VENDEDOR_DADO AND F_PAGO.cod_f_pago= @FORMA_DE_PAGO
GROUP BY VENDEDOR.nom_vendedor,F_PAGO.nom_f_pago;
RETURN(@Nombre+' -----> '+convert(varchar(50),@total_ventas)+' -----> '+@forma_Pago);

END;


-- =============================================
-- Author:  William Gonzalez
-- Create date: 20/02/2016
-- Description: devuelve el total de ventas segun el vendedor ingresado
-- Ejemplo: [FVXV] (1)
-- =============================================
ALTER FUNCTION [dbo].[FVXV] (@VENDEDOR_DADO INT)
RETURNS  VARCHAR(50) 
AS 
BEGIN
    DECLARE @nombre VARCHAR(20);
    DECLARE @total NUMERIC(18, 0);

    SELECT 
        @nombre = VENDEDOR.nom_vendedor, 
        @total = SUM(FACTURA.val_factura)
    FROM VENDEDOR
    INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
    WHERE VENDEDOR.cod_vendedor = @VENDEDOR_DADO
    GROUP BY VENDEDOR.nom_vendedor;
    RETURN(@nombre + ' -----> ' + CONVERT(VARCHAR(20), @total));
END;

GO

-- =============================================
-- Author: William Gonzalez
-- Create date: 20/02/2016
-- Description: Devuelve String con la totalidad vendida segun la forma de pago
-- Ejemplo: FVXFP (1,1)
-- =============================================
CREATE FUNCTION FVXFP
(@FORMA_DE_PAGO INT
)
RETURNS VARCHAR(50)
AS
     BEGIN
         DECLARE @total_ventas AS INT, @forma_Pago AS VARCHAR(50);
         SELECT @total_ventas = SUM(FACTURA.val_factura),
                @forma_Pago = f_pago.nom_f_pago
         FROM dbo.VENDEDOR
              INNER JOIN dbo.CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
              INNER JOIN dbo.FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
              INNER JOIN dbo.F_PAGO ON F_PAGO.cod_f_pago = CLIENTE.cod_f_pago
         WHERE F_PAGO.cod_f_pago = @FORMA_DE_PAGO
         GROUP BY VENDEDOR.nom_vendedor,
                  F_PAGO.nom_f_pago;
         RETURN(CONVERT(VARCHAR(50), @total_ventas)+' -----> '+@forma_Pago);
     END;


 -- =============================================
-- Author:  William Gonzalez
-- Create date: 20/02/2016
-- Description: devuelve el total de ventas por ciudad ingresada
-- Ejemplo: [FVXC] (1)
-- =============================================
CREATE FUNCTION FVXC
(@COD_CIUDAD_PARAM INT
)
RETURNS VARCHAR(50)
AS
     BEGIN
         DECLARE @nombre_Ciudad_Var AS VARCHAR(50), @total_ventas_var AS INT;
         SELECT @nombre_Ciudad_Var = CIUDAD.nom_ciudad,
                @total_ventas_var = SUM(FACTURA.val_factura)
         FROM CIUDAD
              INNER JOIN CLIENTE ON CLIENTE.cod_ciudad = CIUDAD.cod_ciudad
              INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
         WHERE CLIENTE.cod_ciudad = @COD_CIUDAD_PARAM
         GROUP BY CIUDAD.nom_ciudad;
         RETURN(@nombre_Ciudad_Var+' ----> '+CONVERT(VARCHAR(50), @total_ventas_var));
     END;


-- =============================================
-- Author: William Gonzalez
-- Create date: 20/02/2016
-- Description: Devuelve String con la totalidad vendida segun la forma de pago
-- Ejemplo: print dbo.FVXFP (1)
-- =============================================
CREATE FUNCTION FVXFP
(@FORMA_DE_PAGO INT
)
RETURNS VARCHAR(50)
AS
     BEGIN
         DECLARE @total_ventas AS INT, @forma_Pago AS VARCHAR(50);
         SELECT @total_ventas = SUM(FACTURA.val_factura),
                @forma_Pago = f_pago.nom_f_pago
         FROM dbo.VENDEDOR
              INNER JOIN dbo.CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
              INNER JOIN dbo.FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
              INNER JOIN dbo.F_PAGO ON F_PAGO.cod_f_pago = CLIENTE.cod_f_pago
         WHERE F_PAGO.cod_f_pago = @FORMA_DE_PAGO
         GROUP BY VENDEDOR.nom_vendedor,
                  F_PAGO.nom_f_pago;
         RETURN(CONVERT(VARCHAR(50), @total_ventas)+' -----> '+@forma_Pago);
     END;