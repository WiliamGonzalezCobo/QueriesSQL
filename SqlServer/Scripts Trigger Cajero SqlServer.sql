--SCRIPT CAJERO SQL SERVER

CREATE TABLE TB_CJ_T_MOVIMIENTO(
		cod_t_movimiento integer primary key identity(1,1),
		nom_t_movimiento varchar(50)
	);

	CREATE TABLE TB_CJ_CUENTA(
		cod_cuenta integer primary key identity (1,1),
		nom_cuenta varchar(50),
		sal_cuenta integer
	);

	CREATE TABLE TB_CJ_MOVIMIENTO(
		cod_movimiento integer primary key identity (1,1),
		cod_cuenta integer,
		cod_t_movimiento integer,
		fecha_movimiento date,
		valor_movimiento integer,
		CONSTRAINT fk_T_Movimiento
	    FOREIGN KEY (cod_t_movimiento) REFERENCES TB_CJ_T_MOVIMIENTO (cod_t_movimiento) ON DELETE CASCADE,
    	CONSTRAINT fk_Cuenta
	    FOREIGN KEY (cod_cuenta)  REFERENCES TB_CJ_CUENTA (cod_cuenta) ON DELETE CASCADE
	);

		insert into TB_CJ_CUENTA values('Claudia',0);
		insert into TB_CJ_CUENTA values('Paola',0);
		insert into TB_CJ_CUENTA values('Carolina',0);
		insert into TB_CJ_CUENTA values('Natalia',0);

		insert into TB_CJ_T_MOVIMIENTO values('Consignacion');
		insert into TB_CJ_T_MOVIMIENTO values('Retiro');
		insert into TB_CJ_T_MOVIMIENTO values('Consulta');

		--consulto los datos insertados	

		select * from TB_CJ_MOVIMIENTO;
		select * from TB_CJ_T_MOVIMIENTO;
		select * from TB_CJ_CUENTA;

		--PROBANDO TRIGER CON DIFERENTES INSERT A LA TABLA TODO OK
		insert into TB_CJ_MOVIMIENTO values(1,1,'04-04-2015',10000);
		insert into TB_CJ_MOVIMIENTO values(1,2,'04-04-2015',5000);	
		insert into TB_CJ_MOVIMIENTO values(1,2,'04-04-2015',-5000);
		insert into TB_CJ_MOVIMIENTO values(1,3,'04-04-2015',5000);
		insert into TB_CJ_MOVIMIENTO values(1,1,'04-04-2015',0);
		insert into TB_CJ_MOVIMIENTO values(2,1,'04-04-2015',5000);
		insert into TB_CJ_MOVIMIENTO values(2,2,'04-04-2015',2365);
		insert into TB_CJ_MOVIMIENTO values(2,3,'04-04-2015',0);		
		insert into TB_CJ_MOVIMIENTO values(1,1,'04-04-2015',10000);	
		insert into TB_CJ_MOVIMIENTO values(1,2,'04-04-2015',-7000);	
		insert into TB_CJ_MOVIMIENTO values(1,1,'04-04-2015',-7000);	
		insert into TB_CJ_MOVIMIENTO values(1,2,'04-04-2015',7000);	

--TRIGGER CAJERO
use DB_CAJERO
go
CREATE TRIGGER AI_TB_CJ_MOVIMIENTO ON TB_CJ_MOVIMIENTO
AFTER INSERT AS 
BEGIN
DECLARE @saldoV INTEGER = 0,
		@cod_cuenta INTEGER = 0,
		@cod_t_movimiento INTEGER = 0,
		@valor_movimiento INTEGER =0;



	--Capturamos los valores insertados
	SELECT 
		@cod_cuenta = INSERTED.cod_cuenta,
		@cod_t_movimiento = INSERTED.cod_t_movimiento,
		@valor_movimiento = INSERTED.valor_movimiento
	from INSERTED 

 	SELECT @saldoV = sal_cuenta
		FROM TB_CJ_CUENTA 
		WHERE cod_cuenta = @cod_cuenta;


		
		IF(@cod_t_movimiento = 1)
		BEGIN
			IF(@valor_movimiento > 0)
			BEGIN
				UPDATE TB_CJ_CUENTA
				SET sal_cuenta = @saldoV+@valor_movimiento
				WHERE cod_cuenta = @cod_cuenta;
			END
			ELSE
			BEGIN
				PRINT('la Transaccion de Consignacion debe ser mayor a 0');
			END
		END
		
		IF(@cod_t_movimiento = 2)
        BEGIN
            IF(@valor_movimiento > 0)
            BEGIN
                IF(@valor_movimiento <= @saldoV) 
                BEGIN    
                    UPDATE TB_CJ_CUENTA
                    SET sal_cuenta = @saldoV - @valor_movimiento
                    WHERE cod_cuenta = @cod_cuenta;
				END
                ELSE
				BEGIN
                    PRINT('Retiro: Saldo insuficiente.');	
                END
            END
            ELSE
            BEGIN
                PRINT('Retiro: se indico un valor errado');
            END
		END
		
		IF(@cod_t_movimiento = 3)
		BEGIN
			-- CONCATENAR SALDO
			PRINT('Su saldo es: '+CONVERT(VARCHAR(50),@saldoV));
		END
		
END
GO



