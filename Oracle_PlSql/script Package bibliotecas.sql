	CREATE TABLE TB_BL_AUTOR(
		cod_autor number primary key,
		nom_autor varchar(50)
	);


	CREATE TABLE TB_BL_LIBRO(
		cod_libro number primary key,
		nom_libro varchar (50),
		cod_autor number,
		CONSTRAINT fk_autor
	    FOREIGN KEY (cod_autor)  REFERENCES TB_BL_AUTOR (cod_autor) ON DELETE CASCADE
	);

	CREATE TABLE TB_BL_DEPARTAMENTO(
		cod_departamento number primary key,
		nom_departamento varchar(50)
	);

	CREATE TABLE TB_BL_CIUDAD(
		cod_ciudad number primary key,
		nom_ciudad varchar(50),
		cod_departamento number,
		CONSTRAINT fk_departamento
		FOREIGN KEY (cod_departamento) REFERENCES TB_BL_DEPARTAMENTO(cod_departamento) ON DELETE CASCADE
	);

	CREATE TABLE TB_BL_USUARIO(
		cod_usuario number primary key,
		nom_usuario varchar(50),
		cod_ciudad number,
		CONSTRAINT fk_ciudad 
		FOREIGN KEY (cod_ciudad) REFERENCES TB_BL_CIUDAD(cod_ciudad)
	);

	CREATE TABLE TB_BL_PRESTAMO(
		cod_prestamo number primary key,
		cod_libro number,
		cod_usuario number,
		fec_prestamo date,
		fec_devolucion date,
		CONSTRAINT fk_libro
	    FOREIGN KEY (cod_libro)  REFERENCES TB_BL_LIBRO (cod_libro) ON DELETE CASCADE,
	    CONSTRAINT fk_usuario
	    FOREIGN KEY (cod_usuario)  REFERENCES TB_BL_USUARIO (cod_usuario) ON DELETE CASCADE
	);

BEGIN
insert into TB_BL_AUTOR values(1,'Mario Benedetti');
insert into TB_BL_AUTOR values(2,'Mario Vargas Llosa');
insert into TB_BL_AUTOR values(3,'Paulo Coelho');

insert into TB_BL_LIBRO values(1,'La Tregua',1);
insert into TB_BL_LIBRO values(2,'Buzón de tiempo',1);
insert into TB_BL_LIBRO values(3,'La ciudad y los perros',2);
insert into TB_BL_LIBRO values(4,'La tía Julia y el escribidor',2);
insert into TB_BL_LIBRO values(5,'Las Valkirias',3);


insert into TB_BL_DEPARTAMENTO values(1,'cundinamarca');
insert into TB_BL_DEPARTAMENTO values(2,'tolima');

insert into TB_BL_CIUDAD values(1,'Bogota',1);
insert into TB_BL_CIUDAD values(2,'zipaquira',1);
insert into TB_BL_CIUDAD values(3,'ibague',2);
insert into TB_BL_CIUDAD values(4,'honda',2);

insert into TB_BL_USUARIO values(1,'Camilo Avila',1);
insert into TB_BL_USUARIO values(2,'william gonzales',2);
insert into TB_BL_USUARIO values(3,'Fabian Varela',4);
insert into TB_BL_USUARIO values(4,'Sergio Avila',1);
insert into TB_BL_USUARIO values(5,'catherine sandoval',3);



insert into TB_BL_PRESTAMO values(1,2,1,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(2,2,1,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(3,3,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(4,5,3,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(5,1,3,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(6,3,4,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(7,4,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(8,1,1,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(9,3,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(10,2,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(11,2,3,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(12,3,4,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(13,5,5,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(14,4,4,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(15,4,3,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(16,3,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(17,2,1,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(18,5,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(19,5,2,'02-27-2016',null);
insert into TB_BL_PRESTAMO values(20,5,2,'02-27-2016',null);
END;

--///////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////
--PROCEDIMIENTOS ALMACENADOS
CREATE OR REPLACE PROCEDURE imprimir(cadena varchar)
is 
begin
	dbms_output.put_line(cadena); 
end;

--CANTIDAD DE PRESTAMOS POR DEPARTAMENTO CON FOR
--Ejemplo begin SP_Cant_PrestamosXDepartamento; end;
CREATE OR REPLACE PROCEDURE SP_Cant_PrestamosXDepartamento
    IS
        CURSOR cursor_pxd
        IS
            select nom_departamento nombre, COUNT(cod_prestamo) total_prestamos
                FROM TB_BL_PRESTAMO
                INNER JOIN TB_BL_USUARIO ON TB_BL_PRESTAMO.cod_usuario = TB_BL_USUARIO.cod_usuario
                INNER JOIN TB_BL_CIUDAD ON TB_BL_CIUDAD.cod_ciudad = TB_BL_USUARIO.cod_ciudad
                INNER JOIN TB_BL_DEPARTAMENTO ON TB_BL_DEPARTAMENTO.cod_departamento = TB_BL_CIUDAD.cod_departamento
                    GROUP BY nom_departamento;
    BEGIN
        FOR registro IN cursor_pxd loop
            imprimir(registro.nombre||' --> '||registro.total_prestamos);
        end loop;
    END;




--CANTIDAD DE PRESTAMOS POR USUARIO
--Ejemplo begin SP_Cant_PrestamosXUsuario; end;
CREATE OR REPLACE PROCEDURE SP_Cant_PrestamosXUsuario
    IS
        CURSOR cursor_pxd
        IS
            select nom_usuario nombre, COUNT(cod_prestamo) total_prestamos
                FROM TB_BL_PRESTAMO
                INNER JOIN TB_BL_USUARIO ON TB_BL_PRESTAMO.cod_usuario = TB_BL_USUARIO.cod_usuario
                    GROUP BY nom_usuario;
    BEGIN
        FOR registro IN cursor_pxd loop
            imprimir(registro.nombre||' --> '||registro.total_prestamos);
        end loop;
    END;


--CANTIDAD DE PRESTAMOS DE UN AUTOR DADO
--EJEMPLO: recordar que esto devuelve un texto que debe imprimirse
-- begin imprimir(F_Cant_Prest_Autor_Dado(1)); end;
create or replace FUNCTION F_Cant_Prest_Autor_Dado(autor number)
RETURN varchar
IS
    nombre TB_BL_AUTOR.nom_autor%type;
    total_prestamos number;
BEGIN

SELECT TB_BL_AUTOR.nom_autor,COUNT(TB_BL_PRESTAMO.cod_prestamo) INTO nombre,total_prestamos
FROM TB_BL_PRESTAMO
    INNER JOIN TB_BL_LIBRO ON  TB_BL_LIBRO.cod_libro= TB_BL_PRESTAMO.cod_libro
    INNER JOIN TB_BL_AUTOR ON TB_BL_AUTOR.cod_autor= TB_BL_LIBRO.cod_autor
    WHERE TB_BL_AUTOR.cod_autor=autor
GROUP BY nom_autor;
RETURN(Nombre||' -----> '||total_prestamos);
END;


--CANTIDAD DE PRESTAMOS DE UNA CIUDAD DADA Y UN AUTOR DADO
--EJEMPLO: recordar que esto devuelve un texto que debe imprimirse
-- begin imprimir(F_Cant_Prest_Autor_Ciudad_Dada(1,1)); end;
create or replace FUNCTION F_Cant_Prest_Autor_Ciudad_Dada(autor number,ciudadp number)
RETURN varchar
IS
    nombre TB_BL_AUTOR.nom_autor%type;
    ciudad TB_BL_CIUDAD.nom_ciudad%type;
    total_prestamos number;
BEGIN

SELECT TB_BL_AUTOR.nom_autor,TB_BL_CIUDAD.nom_ciudad,COUNT(TB_BL_PRESTAMO.cod_prestamo) INTO nombre,ciudad,total_prestamos
FROM TB_BL_PRESTAMO
    INNER JOIN TB_BL_LIBRO ON  TB_BL_LIBRO.cod_libro= TB_BL_PRESTAMO.cod_libro
    INNER JOIN TB_BL_AUTOR ON TB_BL_AUTOR.cod_autor= TB_BL_LIBRO.cod_autor
    INNER JOIN TB_BL_USUARIO ON TB_BL_USUARIO.cod_usuario=TB_BL_PRESTAMO.cod_usuario
    INNER JOIN TB_BL_CIUDAD ON TB_BL_CIUDAD.cod_ciudad = TB_BL_USUARIO.cod_ciudad
    WHERE TB_BL_AUTOR.cod_autor=autor AND TB_BL_CIUDAD.cod_ciudad  = ciudadp
GROUP BY nom_autor,nom_ciudad;
RETURN(' Autor: '||Nombre||' -----> Ciudad: '||ciudad||' -----> Cant: '||total_prestamos);
END;


--CANTIDAD DE LIBROS SIN DEVOLVER
--EJEMPLO: recordar que esto devuelve un texto que debe imprimirse
-- 	begin imprimir(F_Cant_Libros_Sin_Devolver); end;
create or replace FUNCTION F_Cant_Libros_Sin_Devolver
RETURN varchar
IS
    total_prestamos number;
BEGIN

SELECT COUNT(TB_BL_PRESTAMO.cod_prestamo) INTO total_prestamos
FROM TB_BL_PRESTAMO
    WHERE TB_BL_PRESTAMO.fec_devolucion IS NULL;
RETURN(' Cant. Libros sin Devolver: '||total_prestamos);
END;


--PACKAGE /////////////////////////////////////////////////////
--PRIMERO CREAMOS LA ESPECIFICACION
CREATE OR REPLACE PACKAGE PKG_Library
IS
	PROCEDURE imprimir(cadena varchar);

	PROCEDURE SP_Cant_PrestamosXDepartamento();

	PROCEDURE SP_Cant_PrestamosXUsuario();

	FUNCTION F_Cant_Prest_Autor_Dado(autor number)
	RETURN varchar;

	FUNCTION F_Cant_Prest_Autor_Ciudad_Dada(autor number,ciudadp number)
	RETURN varchar;

	FUNCTION F_Cant_Libros_Sin_Devolver
	RETURN varchar;	

END PKG_Library


--DESPUES DEFINIMOS EL BODY DEL PACKAGE , AQUI CREAMOS LOS PROCEDIMIENTOS Y FUNCIONES A ALMACENAR EN EL PAQUETE

CREATE OR REPLACE PACKAGE BODY PKG_Library
IS
	PROCEDURE imprimir(cadena Varchar)
	IS 
		BEGIN
			dbms_output.put_line(cadena);
		END;

		--CANTIDAD DE PRESTAMOS POR DEPARTAMENTO CON FOR
	--Ejemplo begin PKG_Library.SP_Cant_PrestamosXDepartamento; end;
	PROCEDURE SP_Cant_PrestamosXDepartamento
	    IS
	        CURSOR cursor_pxd
	        IS
	            select nom_departamento nombre, COUNT(cod_prestamo) total_prestamos
	                FROM TB_BL_PRESTAMO
	                INNER JOIN TB_BL_USUARIO ON TB_BL_PRESTAMO.cod_usuario = TB_BL_USUARIO.cod_usuario
	                INNER JOIN TB_BL_CIUDAD ON TB_BL_CIUDAD.cod_ciudad = TB_BL_USUARIO.cod_ciudad
	                INNER JOIN TB_BL_DEPARTAMENTO ON TB_BL_DEPARTAMENTO.cod_departamento = TB_BL_CIUDAD.cod_departamento
	                    GROUP BY nom_departamento;
	    BEGIN
	        FOR registro IN cursor_pxd loop
	            imprimir(registro.nombre||' --> '||registro.total_prestamos);
	        end loop;
	    END;




	--CANTIDAD DE PRESTAMOS POR USUARIO
	--Ejemplo begin PKG_Library.SP_Cant_PrestamosXUsuario; end;
	PROCEDURE SP_Cant_PrestamosXUsuario
	    IS
	        CURSOR cursor_pxd
	        IS
	            select nom_usuario nombre, COUNT(cod_prestamo) total_prestamos
	                FROM TB_BL_PRESTAMO
	                INNER JOIN TB_BL_USUARIO ON TB_BL_PRESTAMO.cod_usuario = TB_BL_USUARIO.cod_usuario
	                    GROUP BY nom_usuario;
	    BEGIN
	        FOR registro IN cursor_pxd loop
	            imprimir(registro.nombre||' --> '||registro.total_prestamos);
	        end loop;
	    END;


	--CANTIDAD DE PRESTAMOS DE UN AUTOR DADO
	--EJEMPLO: recordar que esto devuelve un texto que debe imprimirse
	-- begin PKG_Library.imprimir(PKG_Library.F_Cant_Prest_Autor_Dado(1)); end;
	FUNCTION F_Cant_Prest_Autor_Dado(autor number)
	RETURN varchar
	IS
	    nombre TB_BL_AUTOR.nom_autor%type;
	    total_prestamos number;
	BEGIN

	SELECT TB_BL_AUTOR.nom_autor,COUNT(TB_BL_PRESTAMO.cod_prestamo) INTO nombre,total_prestamos
	FROM TB_BL_PRESTAMO
	    INNER JOIN TB_BL_LIBRO ON  TB_BL_LIBRO.cod_libro= TB_BL_PRESTAMO.cod_libro
	    INNER JOIN TB_BL_AUTOR ON TB_BL_AUTOR.cod_autor= TB_BL_LIBRO.cod_autor
	    WHERE TB_BL_AUTOR.cod_autor=autor
	GROUP BY nom_autor;
	RETURN(Nombre||' -----> '||total_prestamos);
	END;


	--CANTIDAD DE PRESTAMOS DE UNA CIUDAD DADA Y UN AUTOR DADO
	--EJEMPLO: recordar que esto devuelve un texto que debe imprimirse
	-- begin PKG_Library.imprimir(PKG_Library.F_Cant_Prest_Autor_Ciudad_Dada(1,1)); end;
	FUNCTION F_Cant_Prest_Autor_Ciudad_Dada(autor number,ciudadp number)
	RETURN varchar
	IS
	    nombre TB_BL_AUTOR.nom_autor%type;
	    ciudad TB_BL_CIUDAD.nom_ciudad%type;
	    total_prestamos number;
	BEGIN

	SELECT TB_BL_AUTOR.nom_autor,TB_BL_CIUDAD.nom_ciudad,COUNT(TB_BL_PRESTAMO.cod_prestamo) INTO nombre,ciudad,total_prestamos
	FROM TB_BL_PRESTAMO
	    INNER JOIN TB_BL_LIBRO ON  TB_BL_LIBRO.cod_libro= TB_BL_PRESTAMO.cod_libro
	    INNER JOIN TB_BL_AUTOR ON TB_BL_AUTOR.cod_autor= TB_BL_LIBRO.cod_autor
	    INNER JOIN TB_BL_USUARIO ON TB_BL_USUARIO.cod_usuario=TB_BL_PRESTAMO.cod_usuario
	    INNER JOIN TB_BL_CIUDAD ON TB_BL_CIUDAD.cod_ciudad = TB_BL_USUARIO.cod_ciudad
	    WHERE TB_BL_AUTOR.cod_autor=autor AND TB_BL_CIUDAD.cod_ciudad  = ciudadp
	GROUP BY nom_autor,nom_ciudad;
	RETURN(' Autor: '||Nombre||' -----> Ciudad: '||ciudad||' -----> Cant: '||total_prestamos);
	END;


	--CANTIDAD DE LIBROS SIN DEVOLVER
	--EJEMPLO: recordar que esto devuelve un texto que debe imprimirse
	--begin PKG_Library.imprimir(PKG_Library.F_Cant_Libros_Sin_Devolver); end;
	FUNCTION F_Cant_Libros_Sin_Devolver
	RETURN varchar
	IS
	    total_prestamos number;
	BEGIN

	SELECT COUNT(TB_BL_PRESTAMO.cod_prestamo) INTO total_prestamos
	FROM TB_BL_PRESTAMO
	    WHERE TB_BL_PRESTAMO.fec_devolucion IS NULL;
	RETURN(' Cant. Libros sin Devolver: '||total_prestamos);
	END;
END PKG_Library;


--AHORA MOSTRAMOS LA RESPUESTA DEL METODO SUMAR CON LA IMPRESION DE EL PAQUETE1

BEGIN
	PKG_Library.imprimir();
END;




