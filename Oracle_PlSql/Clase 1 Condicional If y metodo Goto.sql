DECLARE


--De esta manera solicitamos el valor en una caja de texto
x number := :valorpepito;

BEGIN
dbms_output.put_line('Bienvenidos Fukl');
dbms_output.put_line('El valor de la variable ingresado en el imput es: '|| x);

--Asignacion den Plsql, se hace como en C
x := 666;
dbms_output.put_line('El valor de la variable es: '|| x);

--CONDICIONAL IF

-- HAY TRES FORMAS DE USAR LA CONDICIONAL IF
	--FORMA 
	x:=:recojaDato;
	IF(x=3) THEN
	dbms_output.put_line('ES IGUAL A 3');
	END IF;

	--FORMA CON ELSE
	x:=:recojaDato2;
	IF(x>7) THEN
	dbms_output.put_line('ES MAYOR A 7');
	--PLSQL REALIZA CAST AUTOMATICO
	dbms_output.put_line(3+4);

	ELSE
	dbms_output.put_line('ES MENOR O IGUAL A 7');
	END IF;

	--soy el proceso 1
	--FORMA CON IF ANIDADO

	--FORMA CON IF ANIDADO

	--x:=7;
	IF(x>7) THEN
		goto proceso3;
	ELSIF(x<7) THEN
		goto proceso2;
	ELSE
		goto proceso1;
	END IF;

	<<proceso1>>
		dbms_output.put_line('soy el proceso 1');
	<<proceso2>>
		dbms_output.put_line('soy el proceso 2');
	<<proceso3>>
		dbms_output.put_line('soy el proceso 3');
END;

---CREAR TABLA

CREATE TABLE AMIGOS
(
cod_amigo number NOT NULL PRIMARY KEY,
nom_amigo varchar(30),
tel_amigo varchar(20),
correo_amigo varchar(30) 
);

INSERT INTO AMIGOS values(1,'william','313285656','william@prueba.com');

--CURSOS IMPLICITO

DECLARE
--declaracion de una variablede tipo Type
nombre AMIGOS.nom_amigo%type;

BEGIN
	select nom_amigo into nombre
	from AMIGOS
	where cod_amigo = 1;
	dbms_output.put_line(nombre);

END;

--declaracion de una variable de tipo Row
DECLARE
REGISTRO AMIGOS%rowtype;
BEGIN
	SELECT * INTO REGISTRO
	FROM AMIGOS
	WHERE cod_amigo =1;
	dbms_output.put_line(REGISTRO.nom_amigo||'--'||REGISTRO.correo_amigo);
END;


