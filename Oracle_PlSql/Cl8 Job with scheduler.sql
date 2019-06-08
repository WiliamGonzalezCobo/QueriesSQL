CREATE table "FACTURA" (
    "COD_FACTURA" NUMBER NOT NULL,
    "VAL_FACTURA" NUMBER NOT NULL,
    constraint  "FACTURA_PK" primary key ("COD_FACTURA")
)
/

CREATE sequence "FACTURA_SEQ" 
/

CREATE trigger "BI_FACTURA"  
  before insert on "FACTURA"              
  for each row 
begin  
  if :NEW."COD_FACTURA" is null then
    select "FACTURA_SEQ".nextval into :NEW."COD_FACTURA" from dual;
  end if;
end;
/   

CREATE MATERIALIZED VIEW VISTA1M
	REFRESH ON DEMAND
		AS
			SELECT * FROM FACTURA;
			
			
SELECT * FROM VISTA1M;
SELECT * FROM FACTURA;


BEGIN
dbms_mview.refresh('VISTA1M');
END;


CREATE O REPLACE PROCEDURE REFRESH_VIEW_VISTA1M
IS
BEGIN 
	dbms_mview.refresh('VISTA1M');
END;


BEGIN
DBMS_SCHEDULER.CREATE_PROGRAM (
program_name      => 'PROG_REFRESH_VIEW_VISTA1M',
program_action     => 'REFRESH_VIEW_VISTA1M',
program_type      => 'STORED_PROCEDURE');
END;

BEGIN
dbms_scheduler.enable('PROG_REFRESH_VIEW_VISTA1M');
END;

BEGIN
DBMS_SCHEDULER.CREATE_SCHEDULE (
 schedule_name   => 'REFRESH_VERY_5_MINUTES',
 start_date    => SYSTIMESTAMP,
 repeat_interval  => 'FREQ=MINUTELY; INTERVAL=5; BYDAY=SAT,SUN',
 end_date     => SYSTIMESTAMP + INTERVAL '30' day,
 comments     => 'Every 5 minutes');
END;

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
  job_name     => 'JOB_REFRESH_VIEW_VISTA1M',
  program_name   => 'PROG_REFRESH_VIEW_VISTA1M',
  schedule_name   => 'REFRESH_VERY_5_MINUTES');
END;

BEGIN
dbms_scheduler.enable('JOB_REFRESH_VIEW_VISTA1M');
END;

select job_name, status, run_duration, cpu_used
from USER_SCHEDULER_JOB_RUN_DETAILS
where job_name = JOB_REFRESH_VIEW_VISTA1M;
		
		
		
		
		
		
		
	
	