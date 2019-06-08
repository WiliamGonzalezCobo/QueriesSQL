--CREATE TABLES

CREATE TABLE VENDEDOR(
	cod_vendedor number primary key,
	nom_vendedor varchar(50)
);

CREATE TABLE CIUDAD(
	cod_ciudad number primary key,
	nom_ciudad varchar(50)
);

CREATE TABLE F_PAGO(
	cod_f_pago number primary key,
	nom_f_pago varchar(50)
);


alter table f_pago modify cod_f_pago primary key;
alter table VENDEDOR modify cod_vendedor primary key;
alter table CIUDAD modify cod_ciudad primary key;

CREATE TABLE CLIENTE(
    cod_cliente number PRIMARY KEY ,
    nom_cliente varchar(50),
    cod_vendedor number,
    cod_ciudad number,
    cod_f_pago number,
    CONSTRAINT fk_vendedor
    FOREIGN KEY (cod_vendedor)  REFERENCES VENDEDOR (cod_vendedor) ON DELETE CASCADE,
    CONSTRAINT fk_ciudad
    FOREIGN KEY (cod_ciudad)  REFERENCES CIUDAD (cod_ciudad) ON DELETE CASCADE,
     CONSTRAINT fk_f_pago
    FOREIGN KEY (cod_f_pago)  REFERENCES F_PAGO (cod_f_pago) ON DELETE CASCADE
);

CREATE TABLE FACTURA(
cod_factura number primary key,
cod_cliente number,
val_factura number,
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
CREATE OR REPLACE FUNCTION FVXV3(VENDEDOR_DADO number)
RETURN varchar
IS
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




--BUSCAR TOTAL VENTAS POR VENDEDOR Y FORMA DE PAGO
CREATE OR REPLACE FUNCTION FVXVFP(VENDEDOR_DADO number, FORMA_DE_PAGO number)
RETURN varchar
IS
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

--USAR CURSOR EXPLICITO EN PROCEDIMIENTO

--TOTAL VENTA POR VENDEDOR
CREATE OR REPLACE PROCEDURE VXVLOOP
    IS
        CURSOR cursor_vxv
        IS
            select nom_vendedor nombre, SUM(val_factura) total_ventas
                FROM    
                    VENDEDOR,CLIENTE,FACTURA
                WHERE 
                    VENDEDOR.cod_vendedor=CLIENTE.cod_vendedor AND
                    CLIENTE.cod_cliente= FACTURA.cod_cliente 
                    GROUP BY nom_vendedor;
        registro cursor_vxv%rowtype;
    BEGIN
        OPEN cursor_vxv;
        loop
            FETCH cursor_vxv INTO registro;
            EXIT WHEN cursor_vxv% NOTFOUND;
            imprimir(registro.nombre||' --> '||registro.total_ventas);
        end loop;
    END;

--USAR CURSOR EXPLICITO EN PROCEDIMIENTO

--TOTAL VENTA POR VENDEDOR Y TOTALIZA
CREATE OR REPLACE PROCEDURE VXVLOOP2
    IS
        CURSOR cursor_vxv
        IS
            select nom_vendedor nombre, SUM(val_factura) total_ventas
                FROM    
                    VENDEDOR,CLIENTE,FACTURA
                WHERE 
                    VENDEDOR.cod_vendedor=CLIENTE.cod_vendedor AND
                    CLIENTE.cod_cliente= FACTURA.cod_cliente 
                    GROUP BY ROLLUP(nom_vendedor);
        registro cursor_vxv%rowtype;
    BEGIN
        OPEN cursor_vxv;
        loop
            FETCH cursor_vxv INTO registro;
            EXIT WHEN cursor_vxv% NOTFOUND;
            imprimir(registro.nombre||' --> '||registro.total_ventas);
        end loop;
    END;

--TOTAL VENTA POR VENDEDOR Y TOTALIZA con while
CREATE OR REPLACE PROCEDURE VXVWHILE
    IS
        CURSOR cursor_vxv
        IS
            select nom_vendedor nombre, SUM(val_factura) total_ventas
                FROM    
                    VENDEDOR,CLIENTE,FACTURA
                WHERE 
                    VENDEDOR.cod_vendedor=CLIENTE.cod_vendedor AND
                    CLIENTE.cod_cliente= FACTURA.cod_cliente 
                    GROUP BY ROLLUP(nom_vendedor);
        registro cursor_vxv%rowtype;
    BEGIN
        OPEN cursor_vxv;
        FETCH cursor_vxv INTO registro;
        WHILE(cursor_vxv%FOUND) loop
            imprimir(registro.nombre||' --> '||registro.total_ventas);
            FETCH cursor_vxv INTO registro;
        end loop;
    END;

--TOTAL VENTA POR VENDEDOR Y TOTALIZA CON FOR
CREATE OR REPLACE PROCEDURE VXVFOR
    IS
        CURSOR cursor_vxv
        IS
            select nom_vendedor nombre, SUM(val_factura) total_ventas
                FROM    
                    VENDEDOR,CLIENTE,FACTURA
                WHERE 
                    VENDEDOR.cod_vendedor=CLIENTE.cod_vendedor AND
                    CLIENTE.cod_cliente= FACTURA.cod_cliente 
                    GROUP BY ROLLUP(nom_vendedor);
        --registro cursor_vxv%rowtype;  --no lo necesita
    BEGIN
        FOR registro IN cursor_vxv loop
            imprimir(registro.nombre||' --> '||registro.total_ventas);
        end loop;
    END;


