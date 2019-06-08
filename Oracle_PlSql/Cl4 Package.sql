--CREAR PAQUETE 

--PRIMERO CREAMOS LA ESPECIFICACION
CREATE OR REPLACE PACKAGE paquete1
IS
	PROCEDURE imprimir(cadena varchar);

	FUNCTION sumar(n1 number, n2 number)
	return number;

END paquete1


--DESPUES DEFINIMOS EL BODY DEL PACKAGE , AQUI CREAMOS LOS PROCEDIMIENTOS Y FUNCIONES A ALMACENAR EN EL PAQUETE

CREATE OR REPLACE PACKAGE BODY paquete1
IS
	PROCEDURE imprimir(cadena Varchar)
	IS 
		BEGIN
			dbms_output.put_line(cadena);
		END;

	FUNCTION sumar(n1 number, n2 number)
	return number
	IS
	BEGIN
		return (n1+n2);
	END;
END paquete1;

--AHORA MOSTRAMOS LA RESPUESTA DEL METODO SUMAR CON LA IMPRESION DE EL PAQUETE1

BEGIN
	paquete1.imprimir(paquete1.sumar(3,-8));
END;