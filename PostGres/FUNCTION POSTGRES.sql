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
