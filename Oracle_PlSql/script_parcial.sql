CREATE TABLE  "CANDIDATO" 
   (	"COD_CANDIDATO" NUMBER, 
	"NOM_CANDIDATO" VARCHAR2(40), 
	 CONSTRAINT "CANDIDATO_PK" PRIMARY KEY ("COD_CANDIDATO") ENABLE
   )
/
CREATE TABLE  "DEPARTAMENTO" 
   (	"COD_DEPARTAMENTO" NUMBER, 
	"NOM_DEPARTAMENTO" VARCHAR2(30), 
	 CONSTRAINT "DEPARTAMENTO_PK" PRIMARY KEY ("COD_DEPARTAMENTO") ENABLE
   )
/
CREATE TABLE  "CIUDAD" 
   (	"COD_CIUDAD" NUMBER, 
	"NOM_CIUDAD" VARCHAR2(40), 
	"COD_DEPARTAMENTO" NUMBER, 
	 CONSTRAINT "CIUDAD_PK" PRIMARY KEY ("COD_CIUDAD") ENABLE, 
	 CONSTRAINT "CIUDAD_FK" FOREIGN KEY ("COD_DEPARTAMENTO")
	  REFERENCES  "DEPARTAMENTO" ("COD_DEPARTAMENTO") ENABLE
   )
/
CREATE TABLE  "FORMULARIO" 
   (	"COD_FORMULARIO" NUMBER, 
	"COD_CIUDAD" NUMBER, 
	 CONSTRAINT "FORMULARIO_PK" PRIMARY KEY ("COD_FORMULARIO") ENABLE, 
	 CONSTRAINT "FORMULARIO_FK" FOREIGN KEY ("COD_CIUDAD")
	  REFERENCES  "CIUDAD" ("COD_CIUDAD") ENABLE
   )
/
CREATE TABLE  "VOTACION" 
   (	"COD_FORMULARIO" NUMBER, 
	"COD_CANDIDATO" NUMBER, 
	"CANTIDAD_VOTOS" NUMBER, 
	 CONSTRAINT "VOTACION_PK" PRIMARY KEY ("COD_FORMULARIO", "COD_CANDIDATO") ENABLE, 
	 CONSTRAINT "VOTACION_FK" FOREIGN KEY ("COD_FORMULARIO")
	  REFERENCES  "FORMULARIO" ("COD_FORMULARIO") ENABLE, 
	 CONSTRAINT "VOTACION_FK2" FOREIGN KEY ("COD_CANDIDATO")
	  REFERENCES  "CANDIDATO" ("COD_CANDIDATO") ENABLE
   )
/
CREATE UNIQUE INDEX  "CANDIDATO_PK" ON  "CANDIDATO" ("COD_CANDIDATO")
/
CREATE UNIQUE INDEX  "CIUDAD_PK" ON  "CIUDAD" ("COD_CIUDAD")
/
CREATE UNIQUE INDEX  "DEPARTAMENTO_PK" ON  "DEPARTAMENTO" ("COD_DEPARTAMENTO")
/
CREATE UNIQUE INDEX  "FORMULARIO_PK" ON  "FORMULARIO" ("COD_FORMULARIO")
/
CREATE UNIQUE INDEX  "VOTACION_PK" ON  "VOTACION" ("COD_FORMULARIO", "COD_CANDIDATO")
/

----a.	Un procedimiento que muestre la cantidad de votos de un candidato dado por departamento
CREATE OR REPLACE PROCEDURE spCantidadVotosxDepartamento(CANDIDATO_DADO NUMBER)
    IS
        CURSOR cursor_vxd
        IS
            SELECT CANDIDATO.NOM_CANDIDATO nombre_candidato,DEPARTAMENTO.NOM_DEPARTAMENTO nombre_departamento,SUM(VOTACION.CANTIDAD_VOTOS) cantidad_votos
				FROM CANDIDATO
				    INNER JOIN VOTACION ON CANDIDATO.COD_CANDIDATO = VOTACION.COD_CANDIDATO
				    INNER JOIN FORMULARIO ON FORMULARIO.COD_FORMULARIO = VOTACION.COD_FORMULARIO 
				    INNER JOIN CIUDAD ON CIUDAD.COD_CIUDAD = FORMULARIO.COD_CIUDAD
				    INNER JOIN DEPARTAMENTO ON  DEPARTAMENTO.COD_DEPARTAMENTO = CIUDAD.COD_DEPARTAMENTO
				    WHERE CANDIDATO.COD_CANDIDATO = CANDIDATO_DADO
				GROUP BY CANDIDATO.NOM_CANDIDATO,DEPARTAMENTO.NOM_DEPARTAMENTO;	
    BEGIN
        FOR registro IN cursor_vxd loop
            imprimir(registro.nombre_candidato||' --> '||registro.nombre_departamento||' --> '||registro.cantidad_votos);
        end loop;
    END;

----b.	Una función que muestre la cantidad de votos de un candidato dado y una ciudad dada--

CREATE OR REPLACE FUNCTION FVotosxCandidatoxCiudad(CANDIDATO_DADO number, CIUDAD_DADO number)
RETURN varchar
IS
	nombre_candidato CANDIDATO.NOM_CANDIDATO%type;
	nombre_ciudad CIUDAD.NOM_CIUDAD%type;
    cant_votos VOTACION.CANTIDAD_VOTOS%type;
BEGIN

SELECT CANDIDATO.NOM_CANDIDATO,CIUDAD.NOM_CIUDAD,SUM(VOTACION.CANTIDAD_VOTOS) INTO nombre_candidato,nombre_ciudad,cant_votos
FROM CANDIDATO
    INNER JOIN VOTACION ON CANDIDATO.COD_CANDIDATO = VOTACION.COD_CANDIDATO
    INNER JOIN FORMULARIO ON FORMULARIO.COD_FORMULARIO = VOTACION.COD_FORMULARIO 
    INNER JOIN CIUDAD ON CIUDAD.COD_CIUDAD = FORMULARIO.COD_CIUDAD
    WHERE CANDIDATO.COD_CANDIDATO=CANDIDATO_DADO AND CIUDAD.COD_CIUDAD= CIUDAD_DADO
GROUP BY CANDIDATO.NOM_CANDIDATO,CIUDAD.NOM_CIUDAD;	
RETURN(nombre_candidato||' -----> '||nombre_ciudad||' -----> '||cant_votos);
END;

--c.	Un procedimiento almacenado que muestre la cantidad de votos por candidato
CREATE OR REPLACE PROCEDURE spCantidadVotosxCandidato
    IS
        CURSOR cursor_vxc
        IS
            SELECT CANDIDATO.NOM_CANDIDATO nombre_candidato,SUM(VOTACION.CANTIDAD_VOTOS) cantidad_votos
				FROM CANDIDATO
				    INNER JOIN VOTACION ON CANDIDATO.COD_CANDIDATO = VOTACION.COD_CANDIDATO
				GROUP BY CANDIDATO.NOM_CANDIDATO;	
    BEGIN
        FOR registro IN cursor_vxc loop
            imprimir(registro.nombre_candidato||' --> '||registro.cantidad_votos);
        end loop;
    END;


--Empaqueto todo
--definicion
CREATE OR REPLACE PACKAGE paqueteParcial
IS
	PROCEDURE imprimir(cadena varchar);
	PROCEDURE spCantidadVotosxDepartamento(CANDIDATO_DADO NUMBER);
	FUNCTION FVotosxCandidatoxCiudad(CANDIDATO_DADO number, CIUDAD_DADO number)
	RETURN varchar;
	PROCEDURE spCantidadVotosxCandidato;

END paqueteParcial

--cuerpo

CREATE OR REPLACE PACKAGE BODY paqueteParcial
IS
		--perimite imprimir en pantalla 
	PROCEDURE imprimir(cadena varchar)
		is 
		begin
			dbms_output.put_line(cadena); 
		end;
		
		----a.	Un procedimiento que muestre la cantidad de votos de un candidato dado por departamento
	PROCEDURE spCantidadVotosxDepartamento(CANDIDATO_DADO NUMBER)
	    IS
	        CURSOR cursor_vxd
	        IS
	            SELECT CANDIDATO.NOM_CANDIDATO nombre_candidato,DEPARTAMENTO.NOM_DEPARTAMENTO nombre_departamento,SUM(VOTACION.CANTIDAD_VOTOS) cantidad_votos
					FROM CANDIDATO
					    INNER JOIN VOTACION ON CANDIDATO.COD_CANDIDATO = VOTACION.COD_CANDIDATO
					    INNER JOIN FORMULARIO ON FORMULARIO.COD_FORMULARIO = VOTACION.COD_FORMULARIO 
					    INNER JOIN CIUDAD ON CIUDAD.COD_CIUDAD = FORMULARIO.COD_CIUDAD
					    INNER JOIN DEPARTAMENTO ON  DEPARTAMENTO.COD_DEPARTAMENTO = CIUDAD.COD_DEPARTAMENTO
					    WHERE CANDIDATO.COD_CANDIDATO = CANDIDATO_DADO
					GROUP BY CANDIDATO.NOM_CANDIDATO,DEPARTAMENTO.NOM_DEPARTAMENTO;	
	    BEGIN
	        FOR registro IN cursor_vxd loop
	            imprimir(registro.nombre_candidato||' --> '||registro.nombre_departamento||' --> '||registro.cantidad_votos);
	        end loop;
	    END;

	----b.	Una función que muestre la cantidad de votos de un candidato dado y una ciudad dada--

	FUNCTION FVotosxCandidatoxCiudad(CANDIDATO_DADO number, CIUDAD_DADO number)
	RETURN varchar
	IS
		nombre_candidato CANDIDATO.NOM_CANDIDATO%type;
		nombre_ciudad CIUDAD.NOM_CIUDAD%type;
	    cant_votos VOTACION.CANTIDAD_VOTOS%type;
	BEGIN

	SELECT CANDIDATO.NOM_CANDIDATO,CIUDAD.NOM_CIUDAD,SUM(VOTACION.CANTIDAD_VOTOS) INTO nombre_candidato,nombre_ciudad,cant_votos
	FROM CANDIDATO
	    INNER JOIN VOTACION ON CANDIDATO.COD_CANDIDATO = VOTACION.COD_CANDIDATO
	    INNER JOIN FORMULARIO ON FORMULARIO.COD_FORMULARIO = VOTACION.COD_FORMULARIO 
	    INNER JOIN CIUDAD ON CIUDAD.COD_CIUDAD = FORMULARIO.COD_CIUDAD
	    WHERE CANDIDATO.COD_CANDIDATO=CANDIDATO_DADO AND CIUDAD.COD_CIUDAD= CIUDAD_DADO
	GROUP BY CANDIDATO.NOM_CANDIDATO,CIUDAD.NOM_CIUDAD;	
	RETURN(nombre_candidato||' -----> '||nombre_ciudad||' -----> '||cant_votos);
	END;

	--c.	Un procedimiento almacenado que muestre la cantidad de votos por candidato
	PROCEDURE spCantidadVotosxCandidato
	    IS
	        CURSOR cursor_vxc
	        IS
	            SELECT CANDIDATO.NOM_CANDIDATO nombre_candidato,SUM(VOTACION.CANTIDAD_VOTOS) cantidad_votos
					FROM CANDIDATO
					    INNER JOIN VOTACION ON CANDIDATO.COD_CANDIDATO = VOTACION.COD_CANDIDATO
					GROUP BY CANDIDATO.NOM_CANDIDATO;	
	    BEGIN
	        FOR registro IN cursor_vxc loop
	            imprimir(registro.nombre_candidato||' --> '||registro.cantidad_votos);
	        end loop;
	    END;
END paqueteParcial;



---validaciones

begin 
paqueteParcial.imprimir(FVotosxCandidatoxCiudad(1,1));
end;

begin 
paqueteParcial.spCantidadVotosxCandidato();
end;

begin 
paqueteParcial.spCantidadVotosxDepartamento(1);
end;




------CREATE OR REPLACE TRIGGER AU_votacion
create or replace trigger AU_votacion
	BEFORE DELETE OR UPDATE OR INSERT ON votacion
	FOR EACH ROW
	BEGIN
		IF UPDATING THEN
		INSERT INTO AUDI_votacion VALUES(
				:old.cod_formulario,
	            :new.cod_formulario,
				:old.cod_candidato,
				:new.cod_candidato,
	            :new.cantidad_votos,
	            :old.cantidad_votos,
				Sys_context('USERENV','IP_ADDRESS'),
	            Sys_context('USERENV','CURRENT_SCHEMA'),
	            Sys_context('USERENV','SESSION_USER'),
	            'UPDATE'
			); 
		END IF;

		IF DELETING THEN
		INSERT INTO AUDI_votacion VALUES(
				:old.cod_formulario,
	            :new.cod_formulario,
				:old.cod_candidato,
				:new.cod_candidato,
	            :new.cantidad_votos,
	            :old.cantidad_votos,
				Sys_context('USERENV','IP_ADDRESS'),
	            Sys_context('USERENV','CURRENT_SCHEMA'),
	            Sys_context('USERENV','SESSION_USER'),
	            'DELETE'
			); 
		END IF;
		
		IF INSERTING THEN
		INSERT INTO AUDI_votacion VALUES(
				:new.cod_formulario,
	            :new.cod_formulario,
				:new.cod_candidato,
				:new.cod_candidato,
	            :new.cantidad_votos,
	            :new.cantidad_votos,
				Sys_context('USERENV','IP_ADDRESS'),
	            Sys_context('USERENV','CURRENT_SCHEMA'),
	            Sys_context('USERENV','SESSION_USER'),
	            'INSERT'
			); 
		END IF;
	END;


--prueba insert en auditoria
INSERT INTO AUDI_votacion VALUES(1,1,1,1,1,1,
	sys_context('USERENV','IP_ADDRESS'),
	sys_context('USERENV','CURRENT_SCHEMA'),
	sys_context('USERENV','SESSION_USER'),
	'UPDATE'
	); 



select * from audi_votacion;
begin delete votacion where cod_candidato = 10; end;
begin  update votacion set cantidad_votos = 3000 where cod_candidato=1; end;
---- tabla de auditoria

create table audi_votacion(
    cod_formulario_viejo number,
    cod_formulario_nuevo number,
    cod_candidato_viejo number,
    cod_candidato_nuevo number,
    cantidad_votos_vieja number,
    cantidad_votos_nueva number,
    ip_delito varchar(30),
    esquema_delito varchar(30),
    usuario_criminal varchar(30),
    action varchar(30)
);


----PSGRESSSS


CREATE TABLE  CANDIDATO 
   (COD_CANDIDATO INTEGER PRIMARY KEY, 
	NOM_CANDIDATO VARCHAR(40)
   );

CREATE TABLE  "DEPARTAMENTO" 
   (	"COD_DEPARTAMENTO" INTEGER PRIMARY KEY, 
	"NOM_DEPARTAMENTO" VARCHAR(30)
   );

CREATE TABLE  "CIUDAD" 
   (	"COD_CIUDAD" INTEGER PRIMARY KEY, 
	"NOM_CIUDAD" VARCHAR(40), 
	"COD_DEPARTAMENTO" INTEGER, 
	 CONSTRAINT "CIUDAD_FK" FOREIGN KEY ("COD_DEPARTAMENTO")
	  REFERENCES  "DEPARTAMENTO" ("COD_DEPARTAMENTO")
   );

CREATE TABLE  "FORMULARIO" 
   (	"COD_FORMULARIO" INTEGER PRIMARY KEY, 
	"COD_CIUDAD" INTEGER,  
	 CONSTRAINT "FORMULARIO_FK" FOREIGN KEY ("COD_CIUDAD")
	  REFERENCES  "CIUDAD" ("COD_CIUDAD")
   );

CREATE TABLE  "VOTACION" 
   (	"COD_FORMULARIO" INTEGER, 
	"COD_CANDIDATO" INTEGER, 
	"CANTIDAD_VOTOS" INTEGER, 
	 PRIMARY KEY(COD_FORMULARIO,COD_CANDIDATO), 
	 CONSTRAINT "VOTACION_FK" FOREIGN KEY ("COD_FORMULARIO")
	  REFERENCES  "FORMULARIO" ("COD_FORMULARIO"), 
	 CONSTRAINT "VOTACION_FK2" FOREIGN KEY ("COD_CANDIDATO")
	  REFERENCES  "CANDIDATO" ("COD_CANDIDATO")
   );