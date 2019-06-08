-- SEQUENCE 

--creaccion de secuencias autoincrementable ciclicos y demas.

CREATE SEQUENCE secuenciaF
	MINVALUE 2
	MAXVALUE 20
	START WITH 8
	INCREMENT BY 2
	ORDER;

--se debe inicializar la secuencia.
SELECT secuenciaF.nextval FROM dual;

-- si no se a inicializado currval no funciona.
SELECT secuenciaF.currval from dual;

