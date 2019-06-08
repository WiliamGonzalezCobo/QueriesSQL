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
