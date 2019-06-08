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



--USAR CURSON IMPLICITO EN FUNCIONES

--NOTA: LOS CURSORES IMPLICITOS SOLO GESTIONAN 1 REGISTRO O UN VALOR POR LO TANTO ES MUY USADO EN FUNCIONES QUE SOLO PUDEN RETORNAR UN VALOR, 
--EN CAMBIO LOS EXPLICITOS PUEDEN 
--GESTIORNAR N REGISTROS(FILAS) ES MUY POTENTE Y SE USA EN PROCEDIMIENTOS POR QUE ESTOS PUEDEN DEVOLVER MUCHOS REGISTROS

--BUSCAR TOTAL VENTAS POR VENDEDOR
CREATE FUNCTION FVXV(VENDEDOR_DADO integer)
RETURNS varchar(50)AS $$
DECLARE
    nombre VENDEDOR.nom_vendedor%type;
    total_ventas    FACTURA.val_factura%type;
BEGIN
SELECT VENDEDOR.nom_vendedor,SUM(FACTURA.val_factura) INTO nombre,total_ventas
FROM VENDEDOR
    INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
    WHERE VENDEDOR.cod_vendedor=VENDEDOR_DADO
GROUP BY VENDEDOR.nom_vendedor;
RETURN(Nombre||' -----> '||total_ventas);
END;
$$LANGUAGE plpgsql;




--BUSCAR TOTAL VENTAS POR VENDEDOR Y FORMA DE PAGO
CREATE FUNCTION FVXVFP(VENDEDOR_DADO integer, FORMA_DE_PAGO integer)
RETURNS varchar (50) AS $$
DECLARE
    nombre VENDEDOR.nom_vendedor%type;
    total_ventas    FACTURA.val_factura%type;
    forma_Pago f_pago.nom_f_pago%type;
BEGIN
SELECT VENDEDOR.nom_vendedor,SUM(FACTURA.val_factura),f_pago.nom_f_pago INTO nombre,total_ventas,forma_Pago
FROM VENDEDOR
    INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
    INNER JOIN F_PAGO ON F_PAGO.cod_f_pago =CLIENTE.cod_f_pago
    WHERE VENDEDOR.cod_vendedor=VENDEDOR_DADO AND F_PAGO.cod_f_pago= FORMA_DE_PAGO
GROUP BY VENDEDOR.nom_vendedor,F_PAGO.nom_f_pago;
RETURN(Nombre||' -----> '||total_ventas||' -----> '||forma_Pago);
END;
$$LANGUAGE PLPGSQL; 	

--BUSCAR TOTAL VENTAS POR FORMA DE PAGO
CREATE FUNCTION FVXVFP(FORMA_DE_PAGO integer)
RETURNS varchar (50) AS $$
DECLARE
    total_ventas    FACTURA.val_factura%type;
    forma_Pago f_pago.nom_f_pago%type;
BEGIN
SELECT SUM(FACTURA.val_factura),f_pago.nom_f_pago INTO total_ventas,forma_Pago
FROM VENDEDOR
    INNER JOIN CLIENTE ON CLIENTE.cod_vendedor = VENDEDOR.cod_vendedor
    INNER JOIN FACTURA ON FACTURA.cod_cliente = CLIENTE.cod_cliente
    INNER JOIN F_PAGO ON F_PAGO.cod_f_pago =CLIENTE.cod_f_pago
    WHERE F_PAGO.cod_f_pago= FORMA_DE_PAGO
GROUP BY F_PAGO.nom_f_pago;
RETURN(forma_Pago||' -----> '||total_ventas);
END;
$$LANGUAGE PLPGSQL; 	

--BUSCAR TOTAL VENTAS POR CIUDAD
DROP FUNCTION FVXC(INTEGER);

CREATE FUNCTION FVXC(COD_CIUDAD_PARAM integer)
RETURNS VARCHAR(50) AS $$
DECLARE
	nombre_Ciudad_Var CIUDAD.nom_ciudad%type;
	total_ventas_var FACTURA.val_factura%type; 
BEGIN
SELECT CIUDAD.nom_ciudad,SUM(FACTURA.val_factura) INTO nombre_Ciudad_Var,total_ventas_var
FROM CIUDAD
INNER JOIN CLIENTE ON CLIENTE.cod_ciudad=CIUDAD.cod_ciudad
INNER JOIN FACTURA ON FACTURA.cod_cliente=CLIENTE.cod_cliente
WHERE CLIENTE.cod_ciudad=COD_CIUDAD_PARAM
GROUP BY CIUDAD.nom_ciudad;
RETURN (nombre_Ciudad_Var||' ----> '||total_ventas_var);
END;
$$ LANGUAGE PLPGSQL;






--FORMA DE IMPLEMENTAR UN PROCEDIMIENTO ALMACENADO EN POSTGRES VENTAS POR VENDEDOR
DROP FUNCTION SPVXV();

CREATE OR REPLACE FUNCTION SPVXV(
		OUT vendedor_var VENDEDOR.nom_vendedor%type,
		OUT total_ventas bigint) 
RETURNS setof record AS $$
BEGIN	
	return query select VENDEDOR.nom_vendedor,sum(FACTURA.val_factura)
				FROM VENDEDOR
				INNER JOIN CLIENTE ON CLIENTE.cod_vendedor=VENDEDOR.cod_vendedor
				INNER JOIN FACTURA ON FACTURA.cod_cliente=CLIENTE.cod_cliente
				GROUP BY nom_vendedor;
RETURN;
END;
$$ LANGUAGE PLPGSQL;



 --FORMA DE IMPLEMENTAR UN PROCEDIMIENTO ALMACENADO EN POSTGRES VENTAS POR CIUDAD
DROP FUNCTION SPVXC();

CREATE OR REPLACE FUNCTION SPVXC(
		OUT ciudad_var CIUDAD.nom_ciudad%type,
		OUT total_ventas bigint) 
RETURNS setof record AS $$
BEGIN	
	return query select CIUDAD.nom_ciudad,sum(FACTURA.val_factura)
					FROM CIUDAD
						INNER JOIN CLIENTE ON CLIENTE.cod_ciudad=CIUDAD.cod_ciudad
						INNER JOIN FACTURA ON FACTURA.cod_cliente=CLIENTE.cod_cliente
					GROUP BY CIUDAD.nom_ciudad;
RETURN;
END;
$$ LANGUAGE PLPGSQL;


 --FORMA DE IMPLEMENTAR UN PROCEDIMIENTO ALMACENADO EN POSTGRES VENTAS POR FORMA DE PAGO
DROP FUNCTION SPVXFP();

CREATE OR REPLACE FUNCTION SPVXFP(
		OUT f_pago_var F_PAGO.nom_f_pago%type,
		OUT total_ventas bigint) 
RETURNS setof record AS $$
BEGIN	
	return query SELECT f_pago.nom_f_pago,SUM(FACTURA.val_factura)
FROM F_PAGO
	INNER JOIN CLIENTE ON F_PAGO.cod_f_pago =CLIENTE.cod_f_pago
	INNER JOIN FACTURA ON FACTURA.cod_cliente=CLIENTE.cod_cliente
GROUP BY F_PAGO.nom_f_pago;
RETURN;
END;
$$ LANGUAGE PLPGSQL;


 --FORMA DE IMPLEMENTAR UN PROCEDIMIENTO ALMACENADO EN POSTGRES VENTAS POR VENDEDOR Y FORMA DE PAGO
DROP FUNCTION SPVXVXFP();

CREATE OR REPLACE FUNCTION SPVXVXFP(
		OUT vendedor_var VENDEDOR.nom_vendedor%type,
		OUT f_pago_var F_PAGO.nom_f_pago%type,
		OUT total_ventas bigint) 
RETURNS setof record AS $$
BEGIN	
	return query SELECT VENDEDOR.nom_vendedor,f_pago.nom_f_pago,SUM(FACTURA.val_factura)
FROM F_PAGO
	INNER JOIN CLIENTE ON F_PAGO.cod_f_pago =CLIENTE.cod_f_pago
	INNER JOIN FACTURA ON FACTURA.cod_cliente=CLIENTE.cod_cliente
	INNER JOIN VENDEDOR ON CLIENTE.cod_vendedor=VENDEDOR.cod_vendedor
GROUP BY F_PAGO.nom_f_pago, VENDEDOR.nom_vendedor;
RETURN;
END;
$$ LANGUAGE PLPGSQL;

--Select de Validaciones de Funciones y procedimientos
--funciones
SELECT * FROM VENDEDOR;
SELECT * FROM FVXV(1);
SELECT * FROM FVXV(2);
SELECT * FROM FVXV(3);

SELECT * FROM CLIENTE;
SELECT * FROM FVXVFP(2,1);

SELECT * FROM FVXFP(1);
SELECT * FROM FVXFP(2);

SELECT * FROM CIUDAD;

SELECT * FROM FVXC(1);
SELECT * FROM FVXC(2);
SELECT * FROM FVXC(3);
--Store Procedures

SELECT * FROM SPVXV();
SELECT * FROM SPVXC();
SELECT * FROM SPVXFP();
SELECT * FROM SPVXVXFP();


