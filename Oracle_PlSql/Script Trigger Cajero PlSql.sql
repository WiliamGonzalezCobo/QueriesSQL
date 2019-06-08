--Script Cajero

	CREATE TABLE TB_CJ_T_MOVIMIENTO(
		cod_t_movimiento number primary key,
		nom_t_movimiento varchar(50)
	);

	CREATE TABLE TB_CJ_CUENTA(
		cod_cuenta number primary key,
		nom_cuenta varchar(50),
		sal_cuenta number
	);

	CREATE TABLE TB_CJ_MOVIMIENTO(
		cod_movimiento number primary key,
		cod_cuenta number,
		cod_t_movimiento number,
		fecha_movimiento date,
		valor_movimiento number,
		CONSTRAINT fk_T_Movimiento
	    FOREIGN KEY (cod_t_movimiento) REFERENCES TB_CJ_T_MOVIMIENTO (cod_t_movimiento) ON DELETE CASCADE,
    	CONSTRAINT fk_Cuenta
	    FOREIGN KEY (cod_cuenta)  REFERENCES TB_CJ_CUENTA (cod_cuenta) ON DELETE CASCADE
	);


select * from TB_CJ_MOVIMIENTO;
select * from TB_CJ_CUENTA;
SELECT * FROM TB_CJ_T_MOVIMIENTO;

UPDATE TB_CJ_CUENTA set sal_cuenta =0;
	BEGIN
		insert into TB_CJ_CUENTA values(1,'Claudia',0);
		insert into TB_CJ_CUENTA values(2,'Paola',0);
		insert into TB_CJ_CUENTA values(3,'Carolina',0);
		insert into TB_CJ_CUENTA values(4,'Natalia',0);

		insert into TB_CJ_T_MOVIMIENTO values(1,'Consignacion');
		insert into TB_CJ_T_MOVIMIENTO values(2,'Retiro');
		insert into TB_CJ_T_MOVIMIENTO values(3,'Consulta');

		--PROBANDO TRIGER CON DIFERENTES INSERT A LA TABLA TODO OK
		insert into TB_CJ_MOVIMIENTO values(1,1,1,'04-04-2015',-1000000);
		insert into TB_CJ_MOVIMIENTO values(2,2,2,'04-04-2015',3000000);	
		insert into TB_CJ_MOVIMIENTO values(3,3,1,'04-04-2015',2000000);
		insert into TB_CJ_MOVIMIENTO values(4,1,1,'04-04-2015',2000000);
		insert into TB_CJ_MOVIMIENTO values(5,2,1,'04-04-2015',-2000000);
		insert into TB_CJ_MOVIMIENTO values(6,3,1,'04-04-2015',3000000);
		insert into TB_CJ_MOVIMIENTO values(7,3,2,'04-04-2015',-4000000);
		insert into TB_CJ_MOVIMIENTO values(8,1,2,'04-04-2015',-3000000);		
		insert into TB_CJ_MOVIMIENTO values(9,2,2,'04-04-2015',2000000);	
		insert into TB_CJ_MOVIMIENTO values(10,3,2,'04-04-2015',4000000);	
		insert into TB_CJ_MOVIMIENTO values(11,2,2,'04-04-2015',5000000);	
		insert into TB_CJ_MOVIMIENTO values(12,1,2,'04-04-2015',1000000);				


	END;


	--trigger de Cajero Electronico NO TIENE ERRORES FALTA PROBARLO JAJAJA
create or replace TRIGGER AI_TB_CJ_MOVIMIENTO
	AFTER INSERT ON TB_CJ_MOVIMIENTO
	FOR EACH ROW
	DECLARE
	saldoParm TB_CJ_CUENTA.sal_cuenta%type;
	BEGIN
		SELECT sal_cuenta INTO saldoParm
					FROM TB_CJ_CUENTA 
					WHERE cod_cuenta=:NEW.cod_cuenta;

		
		IF(:NEW.cod_t_movimiento = 1) THEN
			IF(:NEW.valor_movimiento > 0) THEN
				UPDATE TB_CJ_CUENTA
				SET sal_cuenta = sal_cuenta+:NEW.valor_movimiento
				WHERE cod_cuenta = :NEW.cod_cuenta;
			ELSE
				imprimir('la Transaccion de Consignacion debe ser mayor a 0');
			END IF;
		END IF;
		
		IF(:NEW.cod_t_movimiento = 2) THEN
            IF(:NEW.valor_movimiento > 0)THEN
                IF(:NEW.valor_movimiento <= saldoParm) THEN
                    UPDATE TB_CJ_CUENTA
                    SET sal_cuenta = sal_cuenta - :NEW.valor_movimiento
                    WHERE cod_cuenta = :NEW.cod_cuenta;
                ELSE
                    imprimir('Retiro: Saldo insuficiente.');	
                END IF;
            ELSE
                imprimir('Retiro: se indico un valor errado');
            END IF;
		END IF;
		
		IF(:NEW.cod_t_movimiento = 3) THEN
			-- CONCATENAR SALDO
			imprimir('Su saldo es: '||saldoParm);
		END IF;

	END;






    SELECT cod_cuenta cuenta, SUM(valor_movimiento) saldoReal 
    	FROM TB_CJ_MOVIMIENTO
    	where valor_movimiento >= 0 and cod_t_movimiento = 1
    	GROUP BY cod_cuenta;
   	

   	--Consignaciones 
   	SELECT cod_cuenta cuenta, SUM(valor_movimiento) saldoReal 
    	FROM TB_CJ_MOVIMIENTO
    	where valor_movimiento >= 0 and cod_t_movimiento = 1
    	GROUP BY cod_cuenta;

	--Retiros
	SELECT cod_cuenta cuenta, SUM(valor_movimiento) saldoReal 
    	FROM TB_CJ_MOVIMIENTO
    	where valor_movimiento >= 0 and cod_t_movimiento = 2
    	GROUP BY cod_cuenta;



--- CREO UNA TABLA  IGUAL A LA MANEJADA EN EL TRIGGER E INSERTO LOS VALORES DE MI TABLA MOVIMIENTO.

CREATE TABLE TB_CJ_MOVIMIENTO_TEMP(
		cod_movimiento number primary key,
		cod_cuenta number,
		cod_t_movimiento number,
		fecha_movimiento date,
		valor_movimiento number,
		CONSTRAINT fk_T_MovimientoTemp
	    FOREIGN KEY (cod_t_movimiento) REFERENCES TB_CJ_T_MOVIMIENTO (cod_t_movimiento) ON DELETE CASCADE,
    	CONSTRAINT fk_CuentaTemp
	    FOREIGN KEY (cod_cuenta)  REFERENCES TB_CJ_CUENTA (cod_cuenta) ON DELETE CASCADE
	);

--- LE CREO EL MISMO TRIGUER A MI TABLA SECUNDARIA

create or replace TRIGGER AI_TB_CJ_MOVIMIENTO_TEMP
	AFTER INSERT ON TB_CJ_MOVIMIENTO_TEMP
	FOR EACH ROW
	DECLARE
	saldoParm TB_CJ_CUENTA.sal_cuenta%type;
	BEGIN
		SELECT sal_cuenta INTO saldoParm
					FROM TB_CJ_CUENTA 
					WHERE cod_cuenta=:NEW.cod_cuenta;

		
		IF(:NEW.cod_t_movimiento = 1) THEN
			IF(:NEW.valor_movimiento > 0) THEN
				UPDATE TB_CJ_CUENTA
				SET sal_cuenta = sal_cuenta+:NEW.valor_movimiento
				WHERE cod_cuenta = :NEW.cod_cuenta;
			ELSE
				imprimir('la Transaccion de Consignacion debe ser mayor a 0');
			END IF;
		END IF;
		
		IF(:NEW.cod_t_movimiento = 2) THEN
            IF(:NEW.valor_movimiento > 0)THEN
                IF(:NEW.valor_movimiento <= saldoParm) THEN
                    UPDATE TB_CJ_CUENTA
                    SET sal_cuenta = sal_cuenta - :NEW.valor_movimiento
                    WHERE cod_cuenta = :NEW.cod_cuenta;
                ELSE
                    imprimir('Retiro: Saldo insuficiente.');	
                END IF;
            ELSE
                imprimir('Retiro: se indico un valor errado');
            END IF;
		END IF;
		
		IF(:NEW.cod_t_movimiento = 3) THEN
			-- CONCATENAR SALDO
			imprimir('Su saldo es: '||saldoParm);
		END IF;

	END;

--PROCEMIENTO QUE RECUPERA EL SALDO DE MIS CUENTAS
CREATE OR REPLACE PROCEDURE RECUPERAR_SALDOS
is 
begin
DELETE TB_CJ_MOVIMIENTO_TEMP;
	INSERT INTO TB_CJ_MOVIMIENTO_TEMP (cod_movimiento,cod_cuenta,cod_t_movimiento,fecha_movimiento,valor_movimiento)
SELECT cod_movimiento,
		cod_cuenta,
		cod_t_movimiento,
		fecha_movimiento,
		valor_movimiento
FROM
TB_CJ_MOVIMIENTO;
end;


select * from TB_CJ_MOVIMIENTO;
select * from TB_CJ_CUENTA;
SELECT * FROM TB_CJ_T_MOVIMIENTO;
UPDATE TB_CJ_CUENTA set sal_cuenta =0;

begin 
RECUPERAR_SALDOS;
end;

