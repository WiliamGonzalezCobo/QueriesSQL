CREATE TABLE TB_FACTURA(
		cod_factura integer primary key,
		nameFactura varchar(50),
		int_value integer
	);

INSERT INTO TB_FACTURA VALUES(1,"FACT 1",1000000);
INSERT INTO TB_FACTURA VALUES(2,"FACT 2",2000000);	



CREATE OR REPLACE FUNCTION SP_ListFacturas(
		OUT idFac TB_FACTURA.cod_factura%type,
		OUT nombreFac TB_FACTURA.nameFactura%type,
		OUT int_value TB_FACTURA.int_value%type) 
RETURNS setof record AS $$
BEGIN	
	return query SELECT * FROM TB_FACTURA;
RETURN;
END;
$$ LANGUAGE PLPGSQL;


SELECT * FROM SP_ListFacturas();