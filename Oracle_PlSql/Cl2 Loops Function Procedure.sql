--bucle loop el programa siempre ingresa por lo menos una vez.
--la condicion  la tiene dentro para finalizarla o salir

--los primeros 50 numeros pares 
DECLARE
x number:=1;
begin 
	loop
		dbms_output.put_line(2*x);
		x:=x+1;
		if(x>50) then
			exit;
		end if;
	end loop;
end;

--bucle while
--los primeros 50 numeros inpares en revez

DECLARE
x number := :dato;
begin
	while (x>=1) loop
	dbms_output.put_line(2*x-1);
	x:=x-1;
	end loop;
end;

--BUCLE FOR

--primeros n numeros impares
DECLARE
n number :=:dato;
begin
	for x in 1..n loop
		dbms_output.put_line(2*x-1);
	end loop;
end;

--primeros n numeros impares en sentido contrario
DECLARE
n number :=:dato;
begin
	for x in REVERSE 1..n loop
		dbms_output.put_line(2*x-1);
	end loop;
end;

--factorial de numero n

DECLARE
numero number :=:numero;
aux number :=1;
begin
	for dato in 1..numero loop
		aux:=aux*dato;
end loop;
dbms_output.put_line(aux);
end;

--repeticion
DECLARE
repeticion number:=:repeticion;
begin
for x in 1.. repeticion loop
	for y in 1.. x loop
	dbms_output.put_line(x);
	end loop;
end loop;
end;


--PROCEDIMIENTOS ALMACENADOS
CREATE OR REPLACE PROCEDURE imprimir(cadena varchar)
is 
begin
	dbms_output.put_line(cadena); 
end;

CREATE OR REPLACE PROCEDURE sumar(num1 number,num2 number)
is
	--Aqui podemos declarar nuestras variables
	begin
		imprimir(num1 +num2);
	end;

--FUNCIONES
CREATE OR REPLACE FUNCTION elevar2(x number)
return number	
is 
	begin 
		return (x*x);
	end;

--usar las funciones y los procedimientos
DECLARE
c number;
begin
	c:=elevar2(:n);
	imprimir(c);
end;


CREATE OR REPLACE FUNCTION ffactorial(n number)
return number
	is
	begin
		if (n = 0) then
			return 1;
		else
			return n*ffactorial(n-1);
		end if;

	end;

--USAMOS LA FUNCION ffactorial e imprimimos con el procedimiento imprimir
DECLARE
x number :=:xconsola;
begin
	imprimir(ffactorial(x));
end;


--FUNCION FIBONACHI
CREATE OR REPLACE FUNCTION fibonacci(n number)
return number
is

begin
	if (n=0)or (n=1) then
		return 1;
	else
		return fibonacci(n-2)+fibonacci(n-1);
	end if;
end;





