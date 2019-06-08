--vistas
-- se puede modificar la vista y esta a su vez modifica la tabla original
-- se puede crear una vista de otra vista


--simples y compuestas


CREATE VIEW vistaf
	as
		select cod_factura, cod_cliente from factura;





UPDATE  VISTAF
	SET cod_cliente = 5
	WHERE cod_factura=3;
	--vistas materializadas ocupan espacion en base de datos.


-- se pueden restringir los registros que se afecten con DML
CREATE VIEW VISTAF3
	as	
		SELECT * FROM  factura
		where cod_cliente	 = 5
		with check option;


CREATE VIEW VISTAF3
	as	
		SELECT * FROM  factura
		where cod_cliente	 = 5
		with read only;


--tabla
CREATE TABLE  "EMPLEADO" 
   (	"COD_EMPLEADO" NUMBER NOT NULL ENABLE, 
	"NOM_EMPLEADO" VARCHAR2(50) NOT NULL ENABLE, 
	"TEL_EMPLEADO" VARCHAR2(50) NOT NULL ENABLE, 
	"FEC_NACIMIENTO" DATE NOT NULL ENABLE, 
	"SAL_EMPLEADO" NUMBER NOT NULL ENABLE, 
	 CONSTRAINT "EMPLEADO_PK" PRIMARY KEY ("COD_EMPLEADO") ENABLE
   ) ;

-- creamos vista
CREATE OR REPLACE FORCE VIEW  "VISTAE" ("COD_EMPLEADO", "NOM_EMPLEADO", "SAL_EMPLEADO") AS 
  select cod_empleado,nom_empleado,sal_empleado from EMPLEADO;​

---se actualiza la tabla a la cual hace referencia la vista
UPDATE vistae
set sal_empleado=2345678
where cod_empleado=2;

--se inserta en la tabla en la tabla referenciada en la vista, ojo si la tabla no tiene secuencia en 
--el campo de primary key, se debe garantizar que se inserta el campo 
InSERT INTO vistae values (null,'Julio',3799999)



--EJEMPLO 2

CREATE OR REPLACE FORCE VIEW  "VISTA2" ("NOM_EMPLEADO", "SAL_EMPLEADO") AS 
  select nom_empleado,sal_empleado
from EMPLEADO;​

update vista2
set nom_empleado = 'ledicita'
where nom_empleado='leidy';


--Ejemplo Sinonimos

CREATE OR REPLACE FORCE VIEW  "VISTA78" ("COD_EMPRESA", "NOM_EMPRESA", "NOM_GERENTE", "INGRESOS_EMPRESA", "UTILIDADES_EMPRESA") AS 
  select "COD_EMPRESA","NOM_EMPRESA","NOM_GERENTE","INGRESOS_EMPRESA","UTILIDADES_EMPRESA" from empresa;​

create  synonym "OVEJAS"
for "VISTA78"

select * from "OVEJAS";


--VISTAS MATERIALIZADAS.

CREATE MATERIALIZED VIEW VISTA1M
	REFRESH ON DEMAND
		AS
			SELECT * FROM FACTURA;
			
			
SELECT * FROM VISTA1M;
SELECT * FROM FACTURA;


BEGIN
dbms_mview.refresh('VISTA1M');
END;


CREATE O REPLACE PROCEDURE REFRESH_VIEW_VISTA1M
IS
BEGIN 
	dbms_mview.refresh('VISTA1M');
END;




