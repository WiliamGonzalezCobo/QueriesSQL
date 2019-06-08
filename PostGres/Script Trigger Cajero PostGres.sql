Script Cajero PostGres

CREATE TABLE TB_CJ_T_MOVIMIENTO(
		cod_t_movimiento integer primary key,
		nom_t_movimiento varchar(50)
	);

	CREATE TABLE TB_CJ_CUENTA(
		cod_cuenta integer primary key,
		nom_cuenta varchar(50),
		sal_cuenta integer
	);

	CREATE TABLE TB_CJ_MOVIMIENTO(
		cod_movimiento integer primary key,
		cod_cuenta integer,
		cod_t_movimiento integer,
		fecha_movimiento date,
		valor_movimiento integer,
		CONSTRAINT fk_T_Movimiento
	    FOREIGN KEY (cod_t_movimiento) REFERENCES TB_CJ_T_MOVIMIENTO (cod_t_movimiento) ON DELETE CASCADE,
    	CONSTRAINT fk_Cuenta
	    FOREIGN KEY (cod_cuenta)  REFERENCES TB_CJ_CUENTA (cod_cuenta) ON DELETE CASCADE
	);


select * from TB_CJ_MOVIMIENTO;
select * from TB_CJ_CUENTA;

	BEGIN
		insert into TB_CJ_CUENTA values(1,'Claudia',0);
		insert into TB_CJ_CUENTA values(2,'Paola',0);
		insert into TB_CJ_CUENTA values(3,'Carolina',0);
		insert into TB_CJ_CUENTA values(4,'Natalia',0);

		insert into TB_CJ_T_MOVIMIENTO values(1,'Consignacion');
		insert into TB_CJ_T_MOVIMIENTO values(2,'Retiro');
		insert into TB_CJ_T_MOVIMIENTO values(3,'Consulta');

		--PROBANDO TRIGER CON DIFERENTES INSERT A LA TABLA TODO OK
		insert into TB_CJ_MOVIMIENTO values(1,1,1,'04-04-2015',10000);
		insert into TB_CJ_MOVIMIENTO values(2,1,2,'04-04-2015',5000);	
		insert into TB_CJ_MOVIMIENTO values(3,1,2,'04-04-2015',-5000);
		insert into TB_CJ_MOVIMIENTO values(7,1,3,'04-04-2015',5000);
		insert into TB_CJ_MOVIMIENTO values(11,1,1,'04-04-2015',0);
		insert into TB_CJ_MOVIMIENTO values(12,2,1,'04-04-2015',5000);
		insert into TB_CJ_MOVIMIENTO values(13,2,2,'04-04-2015',2365);
		insert into TB_CJ_MOVIMIENTO values(14,2,3,'04-04-2015',0);		
		insert into TB_CJ_MOVIMIENTO values(15,1,1,'04-04-2015',10000);	
		insert into TB_CJ_MOVIMIENTO values(16,1,2,'04-04-2015',-7000);	
		insert into TB_CJ_MOVIMIENTO values(17,1,1,'04-04-2015',-7000);	
		insert into TB_CJ_MOVIMIENTO values(18,1,2,'04-04-2015',7000);				


	END;
--PRIMERO DEFINIMOS LA FUNCION QUE SE EJECUTARA EN EL TRIGGER.

	--esta funcion protegera mis datos en un triguer de before
CREATE OR REPLACE FUNCTION proteger_datos() RETURNS TRIGGER AS $proteger_datos$
  DECLARE
  BEGIN
   
   --
   -- Esta funcion es usada para proteger datos en un tabla 
   -- No se permitira el borrado de filas si la usamos
   -- en un disparador de tipo BEFORE / row-level
   --

   RETURN NULL;
  END;
$proteger_datos$ LANGUAGE plpgsql;

--ESTA FUNCION REALIZA EL UPDATE DE LOS SALDOS DE LA CUENTA DEPENDIENDO DE LA TRANSACCION
 CREATE OR REPLACE FUNCTION SP_AI_TB_CJ_MOVIMIENTO() RETURNS TRIGGER AS $SP_AI_TB_CJ_MOVIMIENTO$
  DECLARE
  saldoParm TB_CJ_CUENTA.sal_cuenta%type;
  BEGIN
  		SELECT sal_cuenta INTO saldoParm
					FROM TB_CJ_CUENTA 
					WHERE cod_cuenta=NEW.cod_cuenta;

		
		IF(NEW.cod_t_movimiento = 1) THEN
			IF(NEW.valor_movimiento > 0) THEN
				UPDATE TB_CJ_CUENTA
				SET sal_cuenta = sal_cuenta+NEW.valor_movimiento
				WHERE cod_cuenta = NEW.cod_cuenta;
			ELSE
			raise notice 'la Transaccion de Consignacion debe ser mayor a 0: %', NEW.valor_movimiento;
			END IF;
		END IF;
		
		IF(NEW.cod_t_movimiento = 2) THEN
            IF(NEW.valor_movimiento > 0)THEN
                IF(NEW.valor_movimiento <= saldoParm) THEN
                    UPDATE TB_CJ_CUENTA
                    SET sal_cuenta = sal_cuenta - NEW.valor_movimiento
                    WHERE cod_cuenta = NEW.cod_cuenta;
                ELSE
                raise notice 'Retiro: Saldo insuficiente: %', NEW.valor_movimiento;
                 
                END IF;
            ELSE
            raise notice 'Retiro: se indico un valor errado: %', NEW.valor_movimiento;

            END IF;
		END IF;
		
		IF(NEW.cod_t_movimiento = 3) THEN
			-- CONCATENAR SALDO
			raise notice 'Su saldo es: %',saldoParm;
			
		END IF;
		RETURN NEW;
  END;
$SP_AI_TB_CJ_MOVIMIENTO$ LANGUAGE plpgsql;

--Ahora creamos el trigger que invocara mi funcionon 
CREATE TRIGGER AI_TB_CJ_MOVIMIENTO
	AFTER INSERT ON TB_CJ_MOVIMIENTO
	FOR EACH ROW
	EXECUTE PROCEDURE SP_AI_TB_CJ_MOVIMIENTO();




