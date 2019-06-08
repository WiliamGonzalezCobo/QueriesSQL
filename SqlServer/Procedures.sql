-- =============================================
-- Author:   William Fabian Gonzalez Cobo
-- Create date: 20/02/2015
-- Description: Procedimiento que entrega la suma de todas las ventas por Ciudades
-- Ejemplo: execute SPVXC;
-- =============================================
CREATE PROCEDURE SPVXC
AS
     BEGIN
         SELECT CIUDAD.nom_ciudad,
                SUM(FACTURA.val_factura)
         FROM CIUDAD
              INNER JOIN CLIENTE ON CLIENTE.cod_ciudad = CIUDAD.cod_ciudad
              INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
         GROUP BY CIUDAD.nom_ciudad;
     END;
GO


-- =============================================
-- Author:   William Fabian Gonzalez Cobo
-- Create date: 20/02/2015
-- Description: Procedimiento que entrega la suma de todas las ventas por Ciudades
-- Ejemplo: execute SPVXC;
-- =============================================
CREATE PROCEDURE SPVXC
AS
     BEGIN
         SELECT CIUDAD.nom_ciudad,
                SUM(FACTURA.val_factura)
         FROM CIUDAD
              INNER JOIN CLIENTE ON CLIENTE.cod_ciudad = CIUDAD.cod_ciudad
              INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
         GROUP BY CIUDAD.nom_ciudad;
     END;
GO

-- =============================================
-- Author:   William Fabian Gonzalez Cobo
-- Create date: 20/02/2015
-- Description: Procedimiento que entrega la suma de todas las ventas por forma de pago
-- Ejemplo: execute SPVXFP;
-- =============================================
CREATE PROCEDURE SPVXFP
AS
     BEGIN
         SELECT f_pago.nom_f_pago,
                SUM(FACTURA.val_factura)
         FROM F_PAGO
              INNER JOIN CLIENTE ON F_PAGO.cod_f_pago = CLIENTE.cod_f_pago
              INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
         GROUP BY F_PAGO.nom_f_pago;
     END;
GO


-- =============================================
-- Author:   William Fabian Gonzalez Cobo
-- Create date: 20/02/2015
-- Description: Procedimiento que entrega la suma de todas las ventas por forma de pago y vendedor
-- Ejemplo: execute SPVXVXFP;
-- =============================================
CREATE PROCEDURE SPVXVXFP
AS
     BEGIN
         SELECT VENDEDOR.nom_vendedor,
                f_pago.nom_f_pago,
                SUM(FACTURA.val_factura)
         FROM F_PAGO
              INNER JOIN CLIENTE ON F_PAGO.cod_f_pago = CLIENTE.cod_f_pago
              INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
              INNER JOIN VENDEDOR ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
         GROUP BY F_PAGO.nom_f_pago,
                  VENDEDOR.nom_vendedor;
     END;
GO