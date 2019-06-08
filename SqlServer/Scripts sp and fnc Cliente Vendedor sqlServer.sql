--CREATE TABLES

CREATE TABLE VENDEDOR(
	cod_vendedor integer primary key,
	nom_vendedor varchar(50)
);

CREATE TABLE CIUDAD(
	cod_ciudad integer primary key,
	nom_ciudad varchar(50)
);

CREATE TABLE F_PAGO(
	cod_f_pago integer primary key,
	nom_f_pago varchar(50)
);


alter table f_pago modify cod_f_pago primary key;
alter table VENDEDOR modify cod_vendedor primary key;
alter table CIUDAD modify cod_ciudad primary key;

CREATE TABLE CLIENTE(
    cod_cliente integer PRIMARY KEY ,
    nom_cliente varchar(50),
    cod_vendedor integer,
    cod_ciudad integer,
    cod_f_pago integer,
    CONSTRAINT fk_vendedor
    FOREIGN KEY (cod_vendedor)  REFERENCES VENDEDOR (cod_vendedor) ON DELETE CASCADE,
    CONSTRAINT fk_ciudad
    FOREIGN KEY (cod_ciudad)  REFERENCES CIUDAD (cod_ciudad) ON DELETE CASCADE,
     CONSTRAINT fk_f_pago
    FOREIGN KEY (cod_f_pago)  REFERENCES F_PAGO (cod_f_pago) ON DELETE CASCADE
);

CREATE TABLE FACTURA(
cod_factura integer primary key,
cod_cliente integer,
val_factura integer,
CONSTRAINT fk_factura
    FOREIGN KEY (cod_cliente)  REFERENCES CLIENTE (cod_cliente) ON DELETE CASCADE
);


------------------INSERTS----------------------------
 begin
 
        insert into vendedor values(1,'sandra');
        insert into vendedor values(2,'claudia');
        insert into vendedor values(3,'yamyle');
        
        insert into ciudad values(1,'Bogota');
        insert into ciudad values(2,'medellin');
        insert into ciudad values(3,'cali');
        
        insert into f_pago values(1,'credito');
        insert into f_pago values(2,'contado');
        
        insert into cliente values(1,'juan',1,3,1);
        insert into cliente values(2,'jose',2,3,1);
        insert into cliente values(3,'julio',3,2,2);
        insert into cliente values(4,'jaime',3,2,2);
        insert into cliente values(5,'jorge',2,1,1);
        
        insert into factura values(1,1,1000);
        insert into factura values(2,1,2000);
        insert into factura values(3,1,3000);
        insert into factura values(4,1,4000);
        insert into factura values(5,1,5000);
        insert into factura values(6,1,1000);
        insert into factura values(7,2,2000);
        insert into factura values(8,3,3000);
        insert into factura values(9,4,4000);
        insert into factura values(10,5,5000);
        insert into factura values(11,1,1000);
        insert into factura values(12,2,2000);
        insert into factura values(13,3,3000);
        insert into factura values(14,4,4000);
		insert into factura values(15,6,4000);
        
 end;



------------------CONSULTAS JOIN --------------------

--1) venta por vendedor
    --nombre vendedor, monto
SELECT DISTINCT VENDEDOR.nom_vendedor as "VENDEDOR",SUM(FACTURA.val_factura) as "TOTAL VENDIDO"
FROM VENDEDOR
    INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
GROUP BY VENDEDOR.cod_vendedor,VENDEDOR.nom_vendedor;


--2) Venta por Ciudad
    --Ciudad, Monto
SELECT DISTINCT CIUDAD.nom_ciudad as "CIUDAD",SUM(FACTURA.val_factura) as "TOTAL VENDIDO"
FROM CIUDAD
    INNER JOIN CLIENTE ON CLIENTE.cod_ciudad = CIUDAD.cod_ciudad
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
GROUP BY CIUDAD.cod_ciudad,CIUDAD.nom_ciudad;

--3) Venta por Vendedor y Forma
    --Nombre, Credito/Contado, Monto
SELECT VENDEDOR.nom_vendedor as "VENDEDOR",F_PAGO.nom_f_pago as "FORMATO DE PAGO",FACTURA.val_factura as "VENTA"
FROM VENDEDOR
    INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
    INNER JOIN F_PAGO ON CLIENTE.cod_f_pago = F_PAGO.cod_f_pago


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

 -- =============================================
-- Author:   William Fabian Gonzalez Cobo
-- Create date: 20/02/2015
-- Description: Procedimiento que entrega la suma de todas las ventas por vendedor
-- Ejemplo: execute spvxv;
-- =============================================
ALTER PROCEDURE SPVXV
AS
     BEGIN
         SELECT VENDEDOR.nom_vendedor,
                SUM(FACTURA.val_factura)
         FROM VENDEDOR
              INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
              INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
         GROUP BY nom_vendedor;
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