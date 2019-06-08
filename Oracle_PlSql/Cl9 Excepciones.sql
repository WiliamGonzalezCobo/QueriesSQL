CREATE table "PAISES" (
    "COD_PAIS"   NUMBER NOT NULL,
    "NOM_PAIS"   VARCHAR2(50) NOT NULL,
    "CON_PAIS"   VARCHAR2(50) NOT NULL,
    constraint  "PAISES_PK" primary key ("COD_PAIS")
)
/

CREATE sequence "PAISES_SEQ" 
/

CREATE trigger "BI_PAISES"  
  before insert on "PAISES"              
  for each row 
begin  
  if :NEW."COD_PAIS" is null then
    select "PAISES_SEQ".nextval into :NEW."COD_PAIS" from dual;
  end if;
end;
/   

alter table "PAISES" add
constraint "PAISES_UK1" 
unique ("NOM_PAIS","CON_PAIS")
/   


/*  Insertar excepción. */
BEGIN
  INSERT INTO Paises VALUES (5, 'Ecuador', 'América');
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('Llave duplicada');
END;

/*  Generar excepciones.  */
DECLARE
  VALOR_NEGATIVO EXCEPTION;
BEGIN
  FOR VALOR IN REVERSE -4..10 LOOP
    DBMS_OUTPUT.PUT_LINE(VALOR);
    IF VALOR < 0 THEN
      RAISE VALOR_NEGATIVO;
    END IF;
  END LOOP;
EXCEPTION
  WHEN VALOR_NEGATIVO THEN
    DBMS_OUTPUT.PUT_LINE('El valor no puede ser negativo.');
END;


/*de esta manera  podemos ver los errores segun el numero DESDE -1 A -20000*/
DECLARE
mensaje VARCHAR2(255);
BEGIN
mensaje := SQLERRM(:numero);
DBMS_OUTPUT.put_line(mensaje);
END;