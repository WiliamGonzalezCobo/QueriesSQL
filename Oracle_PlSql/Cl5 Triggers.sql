--un disparado o desencadenador....es una porcion de 
--codigo que se ejecuta tas un evento del dml(insert update y delete)
--los triger se aplican sobre las tablas 
-- y generan dos variables de Typerow new y old 

CREATE TABLE MATERIA(
	cod_materia number primary key,
	nom_materia varchar(50)
);

CREATE TABLE ALUMNO(
	cod_alumno number primary key,
	nom_alumno varchar(50)
);

CREATE TABLE NOTAS(
	cod_materia NUMBER,
	cod_alumno NUMBER,
	valor_nota NUMBER,
	PRIMARY KEY(cod_materia,cod_alumno),
	CONSTRAINTS fk_Alumno
	FOREIGN KEY (cod_alumno) REFERENCES ALUMNO(cod_alumno) ON DELETE CASCADE,
	CONSTRAINTS fk_materia
	FOREIGN KEY (cod_materia) REFERENCES MATERIA(cod_materia) ON DELETE CASCADE
);

create table AUDI_NOTAS(
    cod_materia number,
    cod_alumno number,
    nota_vieja number,
    nota_nueva number,
    fecha_delito Date,
    ip_delito varchar(30)   
);
ALTER TABLE AUDI_NOTAS ADD tipo_auditoria char(1);


BEGIN

INSERT INTO ALUMNO VALUES(1,'EXCELENTE');
INSERT INTO ALUMNO VALUES(2,'MUY BUENO');
INSERT INTO ALUMNO VALUES(3,'TRAMPOSIN');

INSERT INTO materia VALUES(1,'BD I');
INSERT INTO materia VALUES(2,'BD II');
INSERT INTO materia VALUES(3,'BD III');

INSERT INTO NOTAS VALUES(1,1,5);
INSERT INTO NOTAS VALUES(1,2,4);
INSERT INTO NOTAS VALUES(1,3,3);
INSERT INTO NOTAS VALUES(2,1,5);
INSERT INTO NOTAS VALUES(2,2,4);
INSERT INTO NOTAS VALUES(2,3,3);
INSERT INTO NOTAS VALUES(3,1,5);
INSERT INTO NOTAS VALUES(3,2,4);
INSERT INTO NOTAS VALUES(3,3,3);

DELETE NOTAS WHERE cod_alumno=1;
UPDATE NOTAS SET valor_nota=3 WHERE cod_materia = 1 AND cod_alumno = 2;
select * from audi_notas;

END;

--trigger de update notas
create or replace trigger AU_notas
after update on notas
for each row
begin
insert into audi_notas values(
    :new.cod_materia,
    :new.cod_alumno,
    :old.valor_nota,
    :new.valor_nota,
    Sysdate,
    Sys_context('USERENV','IP_ADDRESS'),
    'UPDATE'
);
end;

	
--TRIGGER CON AFTER PARA TODOS LOS DML
--BT = BEFORE TOTAL
create or replace TRIGGER BT_NOTAS
	AFTER DELETE OR UPDATE OR INSERT ON NOTAS
	FOR EACH ROW
	BEGIN 
    IF (UPDATING) THEN
        INSERT INTO AUDI_NOTAS VALUES(
                :new.cod_materia,
                :new.cod_alumno,
                :old.valor_nota,
                :new.valor_nota,
                sysdate,
                sys_context('USERENV','IP_ADDRESS'),
                'UPDATE'
            ); 
	END IF;
	
	IF (DELETING) THEN
        INSERT INTO AUDI_NOTAS VALUES(
                :old.cod_materia,
                :old.cod_alumno,
                :old.valor_nota,
                :new.valor_nota,
                sysdate,
                sys_context('USERENV','IP_ADDRESS'),
                'DELETE'
            ); 
	END IF;
	
	IF (INSERTING) THEN
        INSERT INTO AUDI_NOTAS VALUES(
                :new.cod_materia,
                :new.cod_alumno,
                :old.valor_nota,
                :new.valor_nota,
                sysdate,
                sys_context('USERENV','IP_ADDRESS'),
                'INSERT'
            ); 
	END IF;
END;

--PRUEBO TRIGUER

INSERT INTO NOTAS 
	


--validar que el movimiento sea >= 0
--after insert en movimiento
--update en cuenta.



