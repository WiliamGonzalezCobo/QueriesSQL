-- Recuperar saldos de la cuenta de Cajero

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

