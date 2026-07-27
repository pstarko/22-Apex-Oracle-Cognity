CREATE TABLE regions
   ( region_id NUMBER 
   CONSTRAINT region_id_nn NOT NULL 
   , region_name VARCHAR2(25) 
   );
CREATE UNIQUE INDEX reg_id_pk
         ON regions (region_id);
ALTER TABLE regions
         ADD ( CONSTRAINT reg_id_pk
   PRIMARY KEY (region_id)
   ) ;

REM ********************************************************************
REM Create the COUNTRIES table to hold country information for customers
REM and company locations. 
REM OE.CUSTOMERS table and HR.LOCATIONS have a foreign key to this table.
       
CREATE TABLE countries 
   ( country_id CHAR(2) 
   CONSTRAINT country_id_nn NOT NULL 
   , country_name VARCHAR2(40) 
   , region_id NUMBER 
   , CONSTRAINT country_c_id_pk 
   PRIMARY KEY (country_id) 
   ) 
   ORGANIZATION INDEX; 
ALTER TABLE countries
         ADD ( CONSTRAINT countr_reg_fk
   FOREIGN KEY (region_id)
   REFERENCES regions(region_id) 
   ) ;
REM ********************************************************************
REM Create the LOCATIONS table to hold address information for company departments.
REM HR.DEPARTMENTS has a foreign key to this table.
       
CREATE TABLE locations
   ( location_id NUMBER(4)
   , street_address VARCHAR2(40)
   , postal_code VARCHAR2(12)
   , city VARCHAR2(30)
   CONSTRAINT loc_city_nn NOT NULL
   , state_province VARCHAR2(25)
   , country_id CHAR(2)
   ) ;
CREATE UNIQUE INDEX loc_id_pk
         ON locations (location_id) ;
ALTER TABLE locations
         ADD ( CONSTRAINT loc_id_pk
   PRIMARY KEY (location_id)
   , CONSTRAINT loc_c_id_fk
   FOREIGN KEY (country_id)
   REFERENCES countries(country_id) 
   ) ;
Rem Useful for any subsequent addition of rows to locations table
Rem Starts with 3300
CREATE SEQUENCE locations_seq
   START WITH 3300
   INCREMENT BY 100
   MAXVALUE 9900
   NOCACHE
   NOCYCLE;
REM ********************************************************************
REM Create the DEPARTMENTS table to hold company department information.
REM HR.EMPLOYEES and HR.JOB_HISTORY have a foreign key to this table.
       
CREATE TABLE departments
   ( department_id NUMBER(4)
   , department_name VARCHAR2(30)
   CONSTRAINT dept_name_nn NOT NULL
   , manager_id NUMBER(6)
   , location_id NUMBER(4)
   ) ;
CREATE UNIQUE INDEX dept_id_pk
         ON departments (department_id) ;
ALTER TABLE departments
         ADD ( CONSTRAINT dept_id_pk
   PRIMARY KEY (department_id)
   , CONSTRAINT dept_loc_fk
   FOREIGN KEY (location_id)
   REFERENCES locations (location_id)
   ) ;
Rem Useful for any subsequent addition of rows to departments table
Rem Starts with 280 
CREATE SEQUENCE departments_seq
   START WITH 280
   INCREMENT BY 10
   MAXVALUE 9990
   NOCACHE
   NOCYCLE;
REM ********************************************************************
REM Create the JOBS table to hold the different names of job roles within the company.
REM HR.EMPLOYEES has a foreign key to this table.
       
CREATE TABLE jobs
   ( job_id VARCHAR2(10)
   , job_title VARCHAR2(35)
   CONSTRAINT job_title_nn NOT NULL
   , min_salary NUMBER(6)
   , max_salary NUMBER(6)
   ) ;
CREATE UNIQUE INDEX job_id_pk 
         ON jobs (job_id) ;
ALTER TABLE jobs
         ADD ( CONSTRAINT job_id_pk
   PRIMARY KEY(job_id)
   ) ;
REM ********************************************************************
REM Create the EMPLOYEES table to hold the employee personnel 
REM information for the company.
REM HR.EMPLOYEES has a self referencing foreign key to this table.
       
CREATE TABLE employees
   ( employee_id NUMBER(6)
   , first_name VARCHAR2(20)
   , last_name VARCHAR2(25)
   CONSTRAINT emp_last_name_nn NOT NULL
   , email VARCHAR2(25)
   CONSTRAINT emp_email_nn NOT NULL
   , phone_number VARCHAR2(20)
   , hire_date DATE
   CONSTRAINT emp_hire_date_nn NOT NULL
   , job_id VARCHAR2(10)
   CONSTRAINT emp_job_nn NOT NULL
   , salary NUMBER(8,2)
   , commission_pct NUMBER(2,2)
   , manager_id NUMBER(6)
   , department_id NUMBER(4)
   , CONSTRAINT emp_salary_min
   CHECK (salary > 0) 
   , CONSTRAINT emp_email_uk
   UNIQUE (email)
   ) ;
CREATE UNIQUE INDEX emp_emp_id_pk
         ON employees (employee_id) ;
       
ALTER TABLE employees
         ADD ( CONSTRAINT emp_emp_id_pk
   PRIMARY KEY (employee_id)
   , CONSTRAINT emp_dept_fk
   FOREIGN KEY (department_id)
   REFERENCES departments
   , CONSTRAINT emp_job_fk
   FOREIGN KEY (job_id)
   REFERENCES jobs (job_id)
   , CONSTRAINT emp_manager_fk
   FOREIGN KEY (manager_id)
   REFERENCES employees
   ) ;
ALTER TABLE departments
         ADD ( CONSTRAINT dept_mgr_fk
   FOREIGN KEY (manager_id)
   REFERENCES employees (employee_id)
   ) ;
       
Rem Useful for any subsequent addition of rows to employees table
REM Starts with 207 
       
CREATE SEQUENCE employees_seq
   START WITH 207
   INCREMENT BY 1
   NOCACHE
   NOCYCLE;
/*REM ********************************************************************
REM Create the JOB_HISTORY table to hold the history of jobs that 
REM employees have held in the past.
REM HR.JOBS, HR_DEPARTMENTS, and HR.EMPLOYEES have a foreign key to this table.
       
CREATE TABLE job_history
   ( employee_id NUMBER(6)
   CONSTRAINT jhist_employee_nn NOT NULL
   , start_date DATE
   CONSTRAINT jhist_start_date_nn NOT NULL
   , end_date DATE
   CONSTRAINT jhist_end_date_nn NOT NULL
   , job_id VARCHAR2(10)
   CONSTRAINT jhist_job_nn NOT NULL
   , department_id NUMBER(4)
   , CONSTRAINT jhist_date_interval
   CHECK (end_date > start_date)
   ) ;
CREATE UNIQUE INDEX jhist_emp_id_st_date_pk 
         ON job_history (employee_id, start_date) ;
ALTER TABLE job_history
         ADD ( CONSTRAINT jhist_emp_id_st_date_pk
   PRIMARY KEY (employee_id, start_date)
   , CONSTRAINT jhist_job_fk
   FOREIGN KEY (job_id)
   REFERENCES jobs
   , CONSTRAINT jhist_emp_fk
   FOREIGN KEY (employee_id)
   REFERENCES employees
   , CONSTRAINT jhist_dept_fk
   FOREIGN KEY (department_id)
   REFERENCES departments
   ) ;*/
REM ********************************************************************
REM Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
REM departments, jobs, countries, and locations table to provide details
REM about employees.
       
CREATE OR REPLACE VIEW emp_details_view
   (employee_id,
   job_id,
   manager_id,
   department_id,
   location_id,
   country_id,
   first_name,
   last_name,
   salary,
   commission_pct,
   department_name,
   job_title,
   city,
   state_province,
   country_name,
   region_name)
   AS SELECT
   e.employee_id, 
   e.job_id, 
   e.manager_id, 
   e.department_id,
   d.location_id,
   l.country_id,
   e.first_name,
   e.last_name,
   e.salary,
   e.commission_pct,
   d.department_name,
   j.job_title,
   l.city,
   l.state_province,
   c.country_name,
   r.region_name
   FROM
   employees e,
   departments d,
   jobs j,
   locations l,
   countries c,
   regions r
   WHERE e.department_id = d.department_id
   AND d.location_id = l.location_id
   AND l.country_id = c.country_id
   AND c.region_id = r.region_id
   AND j.job_id = e.job_id 
   WITH READ ONLY;
 
COMMIT;
ALTER SESSION SET NLS_LANGUAGE=American; 
REM ***************************insert data into the REGIONS table
INSERT INTO regions VALUES 
   ( 1
   , 'Europe' 
   );
INSERT INTO regions VALUES 
   ( 2
   , 'Americas' 
   );
INSERT INTO regions VALUES 
   ( 3
   , 'Asia' 
   );
INSERT INTO regions VALUES 
   ( 4
   , 'Middle East and Africa' 
   );
REM ***************************insert data into the COUNTRIES table
INSERT INTO countries VALUES 
   ( 'IT'
   , 'Italy'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'JP'
   , 'Japan'
   , 3 
   );
INSERT INTO countries VALUES 
   ( 'US'
   , 'United States of America'
   , 2 
   );
INSERT INTO countries VALUES 
   ( 'CA'
   , 'Canada'
   , 2 
   );
INSERT INTO countries VALUES 
   ( 'CN'
   , 'China'
   , 3 
   );
INSERT INTO countries VALUES 
   ( 'IN'
   , 'India'
   , 3 
   );
INSERT INTO countries VALUES 
   ( 'AU'
   , 'Australia'
   , 3 
   );
INSERT INTO countries VALUES 
   ( 'ZW'
   , 'Zimbabwe'
   , 4 
   );
INSERT INTO countries VALUES 
   ( 'SG'
   , 'Singapore'
   , 3 
   );
INSERT INTO countries VALUES 
   ( 'UK'
   , 'United Kingdom'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'FR'
   , 'France'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'DE'
   , 'Germany'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'ZM'
   , 'Zambia'
   , 4 
   );
INSERT INTO countries VALUES 
   ( 'EG'
   , 'Egypt'
   , 4 
   );
INSERT INTO countries VALUES 
   ( 'BR'
   , 'Brazil'
   , 2 
   );
INSERT INTO countries VALUES 
   ( 'CH'
   , 'Switzerland'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'NL'
   , 'Netherlands'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'MX'
   , 'Mexico'
   , 2 
   );
INSERT INTO countries VALUES 
   ( 'KW'
   , 'Kuwait'
   , 4 
   );
INSERT INTO countries VALUES 
   ( 'IL'
   , 'Israel'
   , 4 
   );
INSERT INTO countries VALUES 
   ( 'DK'
   , 'Denmark'
   , 1 
   );
INSERT INTO countries VALUES 
   ( 'HK'
   , 'HongKong'
   , 3 
   );
INSERT INTO countries VALUES 
   ( 'NG'
   , 'Nigeria'
   , 4 
   );
INSERT INTO countries VALUES 
   ( 'AR'
   , 'Argentina'
   , 2 
   );
INSERT INTO countries VALUES 
   ( 'BE'
   , 'Belgium'
   , 1 
   );
       
REM ***************************insert data into the LOCATIONS table       
INSERT INTO locations VALUES 
   ( 1000 
   , '1297 Via Cola di Rie'
   , '00989'
   , 'Roma'
   , NULL
   , 'IT'
   );
INSERT INTO locations VALUES 
   ( 1100 
   , '93091 Calle della Testa'
   , '10934'
   , 'Venice'
   , NULL
   , 'IT'
   );
INSERT INTO locations VALUES 
   ( 1200 
   , '2017 Shinjuku-ku'
   , '1689'
   , 'Tokyo'
   , 'Tokyo Prefecture'
   , 'JP'
   );
INSERT INTO locations VALUES 
   ( 1300 
   , '9450 Kamiya-cho'
   , '6823'
   , 'Hiroshima'
   , NULL
   , 'JP'
   );
INSERT INTO locations VALUES 
   ( 1400 
   , '2014 Jabberwocky Rd'
   , '26192'
   , 'Southlake'
   , 'Texas'
   , 'US'
   );
INSERT INTO locations VALUES 
   ( 1500 
   , '2011 Interiors Blvd'
   , '99236'
   , 'South San Francisco'
   , 'California'
   , 'US'
   );
INSERT INTO locations VALUES 
   ( 1600 
   , '2007 Zagora St'
   , '50090'
   , 'South Brunswick'
   , 'New Jersey'
   , 'US'
   );
INSERT INTO locations VALUES 
   ( 1700 
   , '2004 Charade Rd'
   , '98199'
   , 'Seattle'
   , 'Washington'
   , 'US'
   );
INSERT INTO locations VALUES 
   ( 1800 
   , '147 Spadina Ave'
   , 'M5V 2L7'
   , 'Toronto'
   , 'Ontario'
   , 'CA'
   );
INSERT INTO locations VALUES 
   ( 1900 
   , '6092 Boxwood St'
   , 'YSW 9T2'
   , 'Whitehorse'
   , 'Yukon'
   , 'CA'
   );
INSERT INTO locations VALUES 
   ( 2000 
   , '40-5-12 Laogianggen'
   , '190518'
   , 'Beijing'
   , NULL
   , 'CN'
   );
INSERT INTO locations VALUES 
   ( 2100 
   , '1298 Vileparle (E)'
   , '490231'
   , 'Bombay'
   , 'Maharashtra'
   , 'IN'
   );
INSERT INTO locations VALUES 
   ( 2200 
   , '12-98 Victoria Street'
   , '2901'
   , 'Sydney'
   , 'New South Wales'
   , 'AU'
   );
INSERT INTO locations VALUES 
   ( 2300 
   , '198 Clementi North'
   , '540198'
   , 'Singapore'
   , NULL
   , 'SG'
   );
INSERT INTO locations VALUES 
   ( 2400 
   , '8204 Arthur St'
   , NULL
   , 'London'
   , NULL
   , 'UK'
   );
INSERT INTO locations VALUES 
   ( 2500 
   , 'Magdalen Centre, The Oxford Science Park'
   , 'OX9 9ZB'
   , 'Oxford'
   , 'Oxford'
   , 'UK'
   );
INSERT INTO locations VALUES 
   ( 2600 
   , '9702 Chester Road'
   , '09629850293'
   , 'Stretford'
   , 'Manchester'
   , 'UK'
   );
INSERT INTO locations VALUES 
   ( 2700 
   , 'Schwanthalerstr. 7031'
   , '80925'
   , 'Munich'
   , 'Bavaria'
   , 'DE'
   );
INSERT INTO locations VALUES 
   ( 2800 
   , 'Rua Frei Caneca 1360 '
   , '01307-002'
   , 'Sao Paulo'
   , 'Sao Paulo'
   , 'BR'
   );
INSERT INTO locations VALUES 
   ( 2900 
   , '20 Rue des Corps-Saints'
   , '1730'
   , 'Geneva'
   , 'Geneve'
   , 'CH'
   );
INSERT INTO locations VALUES 
   ( 3000 
   , 'Murtenstrasse 921'
   , '3095'
   , 'Bern'
   , 'BE'
   , 'CH'
   );
INSERT INTO locations VALUES 
   ( 3100 
   , 'Pieter Breughelstraat 837'
   , '3029SK'
   , 'Utrecht'
   , 'Utrecht'
   , 'NL'
   );
INSERT INTO locations VALUES 
   ( 3200 
   , 'Mariano Escobedo 9991'
   , '11932'
   , 'Mexico City'
   , 'Distrito Federal,'
   , 'MX'
   );
       
REM ****************************insert data into the DEPARTMENTS table
REM disable integrity constraint to EMPLOYEES to load data
ALTER TABLE departments 
   DISABLE CONSTRAINT dept_mgr_fk;
INSERT INTO departments VALUES 
   ( 10
   , 'Administration'
   , 200
   , 1700
   );
INSERT INTO departments VALUES 
   ( 20
   , 'Marketing'
   , 201
   , 1800
   );
   
   INSERT INTO departments VALUES 
   ( 30
   , 'Purchasing'
   , 114
   , 1700
   );
   
   INSERT INTO departments VALUES 
   ( 40
   , 'Human Resources'
   , 203
   , 2400
   );
INSERT INTO departments VALUES 
   ( 50
   , 'Shipping'
   , 121
   , 1500
   );
   
   INSERT INTO departments VALUES 
   ( 60 
   , 'IT'
   , 103
   , 1400
   );
   
   INSERT INTO departments VALUES 
   ( 70 
   , 'Public Relations'
   , 204
   , 2700
   );
   
   INSERT INTO departments VALUES 
   ( 80 
   , 'Sales'
   , 145
   , 2500
   );
   
   INSERT INTO departments VALUES 
   ( 90 
   , 'Executive'
   , 100
   , 1700
   );
INSERT INTO departments VALUES 
   ( 100 
   , 'Finance'
   , 108
   , 1700
   );
   
   INSERT INTO departments VALUES 
   ( 110 
   , 'Accounting'
   , 205
   , 1700
   );
INSERT INTO departments VALUES 
   ( 120 
   , 'Treasury'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 130 
   , 'Corporate Tax'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 140 
   , 'Control And Credit'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 150 
   , 'Shareholder Services'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 160 
   , 'Benefits'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 170 
   , 'Manufacturing'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 180 
   , 'Construction'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 190 
   , 'Contracting'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 200 
   , 'Operations'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 210 
   , 'IT Support'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 220 
   , 'NOC'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 230 
   , 'IT Helpdesk'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 240 
   , 'Government Sales'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 250 
   , 'Retail Sales'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 260 
   , 'Recruiting'
   , NULL
   , 1700
   );
INSERT INTO departments VALUES 
   ( 270 
   , 'Payroll'
   , NULL
   , 1700
   );
       
REM ***************************insert data into the JOBS table
INSERT INTO jobs VALUES 
   ( 'AD_PRES'
   , 'President'
   , 20000
   , 40000
   );
   INSERT INTO jobs VALUES 
   ( 'AD_VP'
   , 'Administration Vice President'
   , 15000
   , 30000
   );
INSERT INTO jobs VALUES 
   ( 'AD_ASST'
   , 'Administration Assistant'
   , 3000
   , 6000
   );
INSERT INTO jobs VALUES 
   ( 'FI_MGR'
   , 'Finance Manager'
   , 8200
   , 16000
   );
INSERT INTO jobs VALUES 
   ( 'FI_ACCOUNT'
   , 'Accountant'
   , 4200
   , 9000
   );
INSERT INTO jobs VALUES 
   ( 'AC_MGR'
   , 'Accounting Manager'
   , 8200
   , 16000
   );
INSERT INTO jobs VALUES 
   ( 'AC_ACCOUNT'
   , 'Public Accountant'
   , 4200
   , 9000
   );
   INSERT INTO jobs VALUES 
   ( 'SA_MAN'
   , 'Sales Manager'
   , 10000
   , 20000
   );
INSERT INTO jobs VALUES 
   ( 'SA_REP'
   , 'Sales Representative'
   , 6000
   , 12000
   );
INSERT INTO jobs VALUES 
   ( 'PU_MAN'
   , 'Purchasing Manager'
   , 8000
   , 15000
   );
INSERT INTO jobs VALUES 
   ( 'PU_CLERK'
   , 'Purchasing Clerk'
   , 2500
   , 5500
   );
INSERT INTO jobs VALUES 
   ( 'ST_MAN'
   , 'Stock Manager'
   , 5500
   , 8500
   );
   INSERT INTO jobs VALUES 
   ( 'ST_CLERK'
   , 'Stock Clerk'
   , 2000
   , 5000
   );
INSERT INTO jobs VALUES 
   ( 'SH_CLERK'
   , 'Shipping Clerk'
   , 2500
   , 5500
   );
INSERT INTO jobs VALUES 
   ( 'IT_PROG'
   , 'Programmer'
   , 4000
   , 10000
   );
INSERT INTO jobs VALUES 
   ( 'MK_MAN'
   , 'Marketing Manager'
   , 9000
   , 15000
   );
INSERT INTO jobs VALUES 
   ( 'MK_REP'
   , 'Marketing Representative'
   , 4000
   , 9000
   );
INSERT INTO jobs VALUES 
   ( 'HR_REP'
   , 'Human Resources Representative'
   , 4000
   , 9000
   );
INSERT INTO jobs VALUES 
   ( 'PR_REP'
   , 'Public Relations Representative'
   , 4500
   , 10500
   );
       
REM ***************************insert data into the EMPLOYEES table
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('100','Steven','King','SKING','1.515.555.0100',to_date('13/06/17','RR/MM/DD'),'AD_PRES','24000',null,null,'90');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('101','Neena','Yang','NYANG','1.515.555.0101',to_date('15/09/21','RR/MM/DD'),'AD_VP','17000',null,'100','90');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('102','Lex','Garcia','LGARCIA','1.515.555.0102',to_date('11/01/13','RR/MM/DD'),'AD_VP','17000',null,'100','90');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('103','Alexander','James','AJAMES','1.590.555.0103',to_date('16/01/03','RR/MM/DD'),'IT_PROG','9000',null,'102','60');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('104','Bruce','Miller','BMILLER','1.590.555.0104',to_date('17/05/21','RR/MM/DD'),'IT_PROG','6000',null,'103','60');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('105','David','Williams','DWILLIAMS','1.590.555.0105',to_date('15/06/25','RR/MM/DD'),'IT_PROG','4800',null,'103','60');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('106','Valli','Jackson','VJACKSON','1.590.555.0106',to_date('16/02/05','RR/MM/DD'),'IT_PROG','4800',null,'103','60');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('107','Diana','Nguyen','DNGUYEN','1.590.555.0107',to_date('17/02/07','RR/MM/DD'),'IT_PROG','4200',null,'103','60');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('108','Nancy','Gruenberg','NGRUENBE','1.515.555.0108',to_date('12/08/17','RR/MM/DD'),'FI_MGR','12008',null,'101','100');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('109','Daniel','Faviet','DFAVIET','1.515.555.0109',to_date('12/08/16','RR/MM/DD'),'FI_ACCOUNT','9000',null,'108','100');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('110','John','Chen','JCHEN','1.515.555.0110',to_date('15/09/28','RR/MM/DD'),'FI_ACCOUNT','8200',null,'108','100');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('111','Ismael','Sciarra','ISCIARRA','1.515.555.0111',to_date('15/09/30','RR/MM/DD'),'FI_ACCOUNT','7700',null,'108','100');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('112','Jose Manuel','Urman','JMURMAN','1.515.555.0112',to_date('16/03/07','RR/MM/DD'),'FI_ACCOUNT','7800',null,'108','100');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('113','Luis','Popp','LPOPP','1.515.555.0113',to_date('17/12/07','RR/MM/DD'),'FI_ACCOUNT','6900',null,'108','100');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('114','Den','Li','DLI','1.515.555.0114',to_date('12/12/07','RR/MM/DD'),'PU_MAN','11000',null,'100','30');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('115','Alexander','Khoo','AKHOO','1.515.555.0115',to_date('13/05/18','RR/MM/DD'),'PU_CLERK','3100',null,'114','30');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('116','Shelli','Baida','SBAIDA','1.515.555.0116',to_date('15/12/24','RR/MM/DD'),'PU_CLERK','2900',null,'114','30');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('117','Sigal','Tobias','STOBIAS','1.515.555.0117',to_date('15/07/24','RR/MM/DD'),'PU_CLERK','2800',null,'114','30');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('118','Guy','Himuro','GHIMURO','1.515.555.0118',to_date('16/11/15','RR/MM/DD'),'PU_CLERK','2600',null,'114','30');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('119','Karen','Colmenares','KCOLMENA','1.515.555.0119',to_date('17/08/10','RR/MM/DD'),'PU_CLERK','2500',null,'114','30');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('120','Matthew','Weiss','MWEISS','1.650.555.0120',to_date('14/07/18','RR/MM/DD'),'ST_MAN','8000',null,'100','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('121','Adam','Fripp','AFRIPP','1.650.555.0121',to_date('15/04/10','RR/MM/DD'),'ST_MAN','8200',null,'100','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('122','Payam','Kaufling','PKAUFLIN','1.650.555.0122',to_date('13/05/01','RR/MM/DD'),'ST_MAN','7900',null,'100','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('123','Shanta','Vollman','SVOLLMAN','1.650.555.0123',to_date('15/10/10','RR/MM/DD'),'ST_MAN','6500',null,'100','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('124','Kevin','Mourgos','KMOURGOS','1.650.555.0124',to_date('17/11/16','RR/MM/DD'),'ST_MAN','5800',null,'100','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('125','Julia','Nayer','JNAYER','1.650.555.0125',to_date('15/07/16','RR/MM/DD'),'ST_CLERK','3200',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('126','Irene','Mikkilineni','IMIKKILI','1.650.555.0126',to_date('16/09/28','RR/MM/DD'),'ST_CLERK','2700',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('127','James','Landry','JLANDRY','1.650.555.0127',to_date('17/01/14','RR/MM/DD'),'ST_CLERK','2400',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('128','Steven','Markle','SMARKLE','1.650.555.0128',to_date('18/03/08','RR/MM/DD'),'ST_CLERK','2200',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('129','Laura','Bissot','LBISSOT','1.650.555.0129',to_date('15/08/20','RR/MM/DD'),'ST_CLERK','3300',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('130','Mozhe','Atkinson','MATKINSO','1.650.555.0130',to_date('15/10/30','RR/MM/DD'),'ST_CLERK','2800',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('131','James','Marlow','JAMRLOW','1.650.555.0131',to_date('15/02/16','RR/MM/DD'),'ST_CLERK','2500',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('132','TJ','Olson','TJOLSON','1.650.555.0132',to_date('17/04/10','RR/MM/DD'),'ST_CLERK','2100',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('133','Jason','Mallin','JMALLIN','1.650.555.0133',to_date('14/06/14','RR/MM/DD'),'ST_CLERK','3300',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('134','Michael','Rogers','MROGERS','1.650.555.0134',to_date('16/08/26','RR/MM/DD'),'ST_CLERK','2900',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('135','Ki','Gee','KGEE','1.650.555.0135',to_date('17/12/12','RR/MM/DD'),'ST_CLERK','2400',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('136','Hazel','Philtanker','HPHILTAN','1.650.555.0136',to_date('18/02/06','RR/MM/DD'),'ST_CLERK','2200',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('137','Renske','Ladwig','RLADWIG','1.650.555.0137',to_date('13/07/14','RR/MM/DD'),'ST_CLERK','3600',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('138','Stephen','Stiles','SSTILES','1.650.555.0138',to_date('15/10/26','RR/MM/DD'),'ST_CLERK','3200',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('139','John','Seo','JSEO','1.650.555.0139',to_date('16/02/12','RR/MM/DD'),'ST_CLERK','2700',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('140','Joshua','Patel','JPATEL','1.650.555.0140',to_date('16/04/06','RR/MM/DD'),'ST_CLERK','2500',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('141','Trenna','Rajs','TRAJS','1.650.555.0141',to_date('13/10/17','RR/MM/DD'),'ST_CLERK','3500',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('142','Curtis','Davies','CDAVIES','1.650.555.0142',to_date('15/01/29','RR/MM/DD'),'ST_CLERK','3100',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('143','Randall','Matos','RMATOS','1.650.555.0143',to_date('16/03/15','RR/MM/DD'),'ST_CLERK','2600',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('144','Peter','Vargas','PVARGAS','1.650.555.0144',to_date('16/07/09','RR/MM/DD'),'ST_CLERK','2500',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('145','John','Singh','JSINGH','44.1632.960000',to_date('14/10/01','RR/MM/DD'),'SA_MAN','14000','0,4','100','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('146','Karen','Partners','KPARTNER','44.1632.960001',to_date('15/01/05','RR/MM/DD'),'SA_MAN','13500','0,3','100','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('147','Alberto','Errazuriz','AERRAZUR','44.1632.960002',to_date('15/03/10','RR/MM/DD'),'SA_MAN','12000','0,3','100','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('148','Gerald','Cambrault','GCAMBRAU','44.1632.960003',to_date('17/10/15','RR/MM/DD'),'SA_MAN','11000','0,3','100','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('149','Eleni','Zlotkey','EZLOTKEY','44.1632.960004',to_date('18/01/29','RR/MM/DD'),'SA_MAN','10500','0,2','100','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('150','Sean','Tucker','STUCKER','44.1632.960005',to_date('15/01/30','RR/MM/DD'),'SA_REP','10000','0,3','145','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('151','David','Bernstein','DBERNSTE','44.1632.960006',to_date('15/03/24','RR/MM/DD'),'SA_REP','9500','0,25','145','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('152','Peter','Hall','PHALL','44.1632.960007',to_date('15/08/20','RR/MM/DD'),'SA_REP','9000','0,25','145','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('153','Christopher','Olsen','COLSEN','44.1632.960008',to_date('16/03/30','RR/MM/DD'),'SA_REP','8000','0,2','145','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('154','Nanette','Cambrault','NCAMBRAU','44.1632.960009',to_date('16/12/09','RR/MM/DD'),'SA_REP','7500','0,2','145','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('155','Oliver','Tuvault','OTUVAULT','44.1632.960010',to_date('17/11/23','RR/MM/DD'),'SA_REP','7000','0,15','145','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('156','Janette','King','JKING','44.1632.960011',to_date('14/01/30','RR/MM/DD'),'SA_REP','10000','0,35','146','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('157','Patrick','Sully','PSULLY','44.1632.960012',to_date('14/03/04','RR/MM/DD'),'SA_REP','9500','0,35','146','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('158','Allan','McEwen','AMCEWEN','44.1632.960013',to_date('14/08/01','RR/MM/DD'),'SA_REP','9000','0,35','146','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('159','Lindsey','Smith','LSMITH','44.1632.960014',to_date('15/03/10','RR/MM/DD'),'SA_REP','8000','0,3','146','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('160','Louise','Doran','LDORAN','44.1632.960015',to_date('15/12/15','RR/MM/DD'),'SA_REP','7500','0,3','146','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('161','Sarath','Sewall','SSEWALL','44.1632.960016',to_date('16/11/03','RR/MM/DD'),'SA_REP','7000','0,25','146','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('162','Clara','Vishney','CVISHNEY','44.1632.960017',to_date('15/11/11','RR/MM/DD'),'SA_REP','10500','0,25','147','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('163','Danielle','Greene','DGREENE','44.1632.960018',to_date('17/03/19','RR/MM/DD'),'SA_REP','9500','0,15','147','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('164','Mattea','Marvins','MMARVINS','44.1632.960019',to_date('18/01/24','RR/MM/DD'),'SA_REP','7200','0,1','147','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('165','David','Lee','DLEE','44.1632.960020',to_date('18/02/23','RR/MM/DD'),'SA_REP','6800','0,1','147','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('166','Sundar','Ande','SANDE','44.1632.960021',to_date('18/03/24','RR/MM/DD'),'SA_REP','6400','0,1','147','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('167','Amit','Banda','ABANDA','44.1632.960022',to_date('18/04/21','RR/MM/DD'),'SA_REP','6200','0,1','147','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('168','Lisa','Ozer','LOZER','44.1632.960023',to_date('15/03/11','RR/MM/DD'),'SA_REP','11500','0,25','148','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('169','Harrison','Bloom','HBLOOM','44.1632.960024',to_date('16/03/23','RR/MM/DD'),'SA_REP','10000','0,2','148','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('170','Tayler','Fox','TFOX','44.1632.960025',to_date('16/01/24','RR/MM/DD'),'SA_REP','9600','0,2','148','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('171','William','Smith','WSMITH','44.1632.960026',to_date('17/02/23','RR/MM/DD'),'SA_REP','7400','0,15','148','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('172','Elizabeth','Bates','EBATES','44.1632.960027',to_date('17/03/24','RR/MM/DD'),'SA_REP','7300','0,15','148','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('173','Sundita','Kumar','SKUMAR','44.1632.960028',to_date('18/04/21','RR/MM/DD'),'SA_REP','6100','0,1','148','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('174','Ellen','Abel','EABEL','44.1632.960029',to_date('14/05/11','RR/MM/DD'),'SA_REP','11000','0,3','149','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('175','Alyssa','Hutton','AHUTTON','44.1632.960030',to_date('15/03/19','RR/MM/DD'),'SA_REP','8800','0,25','149','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('176','Jonathon','Taylor','JTAYLOR','44.1632.960031',to_date('16/03/24','RR/MM/DD'),'SA_REP','8600','0,2','149','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('177','Jack','Livingston','JLIVINGS','44.1632.960032',to_date('16/04/23','RR/MM/DD'),'SA_REP','8400','0,2','149','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('178','Kimberely','Grant','KGRANT','44.1632.960033',to_date('17/05/24','RR/MM/DD'),'SA_REP','7000','0,15','149',null);
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('179','Charles','Johnson','CJOHNSON','44.1632.960034',to_date('18/01/04','RR/MM/DD'),'SA_REP','6200','0,1','149','80');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('180','Winston','Taylor','WTAYLOR','1.650.555.0145',to_date('16/01/24','RR/MM/DD'),'SH_CLERK','3200',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('181','Jean','Fleaur','JFLEAUR','1.650.555.0146',to_date('16/02/23','RR/MM/DD'),'SH_CLERK','3100',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('182','Martha','Sullivan','MSULLIVA','1.650.555.0147',to_date('17/06/21','RR/MM/DD'),'SH_CLERK','2500',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('183','Girard','Geoni','GGEONI','1.650.555.0148',to_date('18/02/03','RR/MM/DD'),'SH_CLERK','2800',null,'120','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('184','Nandita','Sarchand','NSARCHAN','1.650.555.0149',to_date('14/01/27','RR/MM/DD'),'SH_CLERK','4200',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('185','Alexis','Bull','ABULL','1.650.555.0150',to_date('15/02/20','RR/MM/DD'),'SH_CLERK','4100',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('186','Julia','Dellinger','JDELLING','1.650.555.0151',to_date('16/06/24','RR/MM/DD'),'SH_CLERK','3400',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('187','Anthony','Cabrio','ACABRIO','1.650.555.0152',to_date('17/02/07','RR/MM/DD'),'SH_CLERK','3000',null,'121','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('188','Kelly','Chung','KCHUNG','1.650.555.0153',to_date('15/06/14','RR/MM/DD'),'SH_CLERK','3800',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('189','Jennifer','Dilly','JDILLY','1.650.555.0154',to_date('15/08/13','RR/MM/DD'),'SH_CLERK','3600',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('190','Timothy','Venzl','TVENZL','1.650.555.0155',to_date('16/07/11','RR/MM/DD'),'SH_CLERK','2900',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('191','Randall','Perkins','RPERKINS','1.650.555.0156',to_date('17/12/19','RR/MM/DD'),'SH_CLERK','2500',null,'122','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('192','Sarah','Bell','SBELL','1.650.555.0157',to_date('14/02/04','RR/MM/DD'),'SH_CLERK','4000',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('193','Britney','Everett','BEVERETT','1.650.555.0158',to_date('15/03/03','RR/MM/DD'),'SH_CLERK','3900',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('194','Samuel','McLeod','SMCLEOD','1.650.555.0159',to_date('16/07/01','RR/MM/DD'),'SH_CLERK','3200',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('195','Vance','Jones','VJONES','1.650.555.0160',to_date('17/03/17','RR/MM/DD'),'SH_CLERK','2800',null,'123','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('196','Alana','Walsh','AWALSH','1.650.555.0161',to_date('16/04/24','RR/MM/DD'),'SH_CLERK','3100',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('197','Kevin','Feeney','KFEENEY','1.650.555.0162',to_date('16/05/23','RR/MM/DD'),'SH_CLERK','3000',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('198','Donald','OConnell','DOCONNEL','1.650.555.0163',to_date('17/06/21','RR/MM/DD'),'SH_CLERK','2600',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('199','Douglas','Grant','DGRANT','1.650.555.0164',to_date('18/01/13','RR/MM/DD'),'SH_CLERK','2600',null,'124','50');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('200','Jennifer','Whalen','JWHALEN','1.515.555.0165',to_date('13/09/17','RR/MM/DD'),'AD_ASST','4400',null,'101','10');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('201','Michael','Martinez','MMARTINE','1.515.555.0166',to_date('14/02/17','RR/MM/DD'),'MK_MAN','13000',null,'100','20');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('202','Pat','Davis','PDAVIS','1.603.555.0167',to_date('15/08/17','RR/MM/DD'),'MK_REP','6000',null,'201','20');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('203','Susan','Jacobs','SJACOBS','1.515.555.0168',to_date('12/06/07','RR/MM/DD'),'HR_REP','6500',null,'101','40');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('204','Hermann','Brown','HBROWN','1.515.555.0169',to_date('12/06/07','RR/MM/DD'),'PR_REP','10000',null,'101','70');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('205','Shelley','Higgins','SHIGGINS','1.515.555.0170',to_date('12/06/07','RR/MM/DD'),'AC_MGR','12008',null,'101','110');
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values ('206','William','Gietz','WGIETZ','1.515.555.0171',to_date('12/06/07','RR/MM/DD'),'AC_ACCOUNT','8300',null,'205','110');

 /*  
REM ********* insert data into the JOB_HISTORY table
       
INSERT INTO job_history
         VALUES (102
   , TO_DATE('13-JAN-1993', 'dd-MON-yyyy')
   , TO_DATE('24-JUL-1998', 'dd-MON-yyyy')
   , 'IT_PROG'
   , 60);
INSERT INTO job_history
         VALUES (101
   , TO_DATE('21-SEP-1989', 'dd-MON-yyyy')
   , TO_DATE('27-OCT-1993', 'dd-MON-yyyy')
   , 'AC_ACCOUNT'
   , 110);
INSERT INTO job_history
         VALUES (101
   , TO_DATE('28-OCT-1993', 'dd-MON-yyyy')
   , TO_DATE('15-MAR-1997', 'dd-MON-yyyy')
   , 'AC_MGR'
   , 110);
INSERT INTO job_history
         VALUES (201
   , TO_DATE('17-FEB-1996', 'dd-MON-yyyy')
   , TO_DATE('19-DEC-1999', 'dd-MON-yyyy')
   , 'MK_REP'
   , 20);
INSERT INTO job_history
         VALUES (114
   , TO_DATE('24-MAR-1998', 'dd-MON-yyyy')
   , TO_DATE('31-DEC-1999', 'dd-MON-yyyy')
   , 'ST_CLERK'
   , 50
   );
INSERT INTO job_history
         VALUES (122
   , TO_DATE('01-JAN-1999', 'dd-MON-yyyy')
   , TO_DATE('31-DEC-1999', 'dd-MON-yyyy')
   , 'ST_CLERK'
   , 50
   );
INSERT INTO job_history
         VALUES (200
   , TO_DATE('17-SEP-1987', 'dd-MON-yyyy')
   , TO_DATE('17-JUN-1993', 'dd-MON-yyyy')
   , 'AD_ASST'
   , 90
   );
INSERT INTO job_history
         VALUES (176
   , TO_DATE('24-MAR-1998', 'dd-MON-yyyy')
   , TO_DATE('31-DEC-1998', 'dd-MON-yyyy')
   , 'SA_REP'
   , 80
   );
INSERT INTO job_history
         VALUES (176
   , TO_DATE('01-JAN-1999', 'dd-MON-yyyy')
   , TO_DATE('31-DEC-1999', 'dd-MON-yyyy')
   , 'SA_MAN'
   , 80
   );
INSERT INTO job_history
         VALUES (200
   , TO_DATE('01-JUL-1994', 'dd-MON-yyyy')
   , TO_DATE('31-DEC-1998', 'dd-MON-yyyy')
   , 'AC_ACCOUNT'
   , 90
   );*/
REM enable integrity constraint to DEPARTMENTS
ALTER TABLE departments 
   ENABLE CONSTRAINT dept_mgr_fk;
COMMIT;
CREATE INDEX emp_department_ix
   ON employees (department_id);
CREATE INDEX emp_job_ix
   ON employees (job_id);
CREATE INDEX emp_manager_ix
   ON employees (manager_id);
CREATE INDEX emp_name_ix
   ON employees (last_name, first_name);
CREATE INDEX dept_location_ix
   ON departments (location_id);
CREATE INDEX jhist_job_ix
   ON job_history (job_id);
CREATE INDEX jhist_employee_ix
   ON job_history (employee_id);
CREATE INDEX jhist_department_ix
   ON job_history (department_id);
CREATE INDEX loc_city_ix
   ON locations (city);
CREATE INDEX loc_state_province_ix 
   ON locations (state_province);
CREATE INDEX loc_country_ix
   ON locations (country_id);
COMMIT;
REM procedure and statement trigger to allow dmls during business hours:
         CREATE OR REPLACE PROCEDURE secure_dml
         IS
         BEGIN
   IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
   OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
   RAISE_APPLICATION_ERROR (-20205, 
   'You may only make changes during normal office hours');
   END IF;
   END secure_dml;
   /
CREATE OR REPLACE TRIGGER secure_employees
   BEFORE INSERT OR UPDATE OR DELETE ON employees
   BEGIN
   secure_dml;
   END secure_employees;
   /
/*ALTER TRIGGER secure_employees DISABLE;
REM **************************************************************************
REM procedure to add a row to the JOB_HISTORY table and row trigger 
REM to call the procedure when data is updated in the job_id or 
REM department_id columns in the EMPLOYEES table:
CREATE OR REPLACE PROCEDURE add_job_history
   ( p_emp_id job_history.employee_id%type
   , p_start_date job_history.start_date%type
   , p_end_date job_history.end_date%type
   , p_job_id job_history.job_id%type
   , p_department_id job_history.department_id%type 
   )
   IS
   BEGIN
   INSERT INTO job_history (employee_id, start_date, end_date, 
   job_id, department_id)
   VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
   END add_job_history;
   /
CREATE OR REPLACE TRIGGER update_job_history
   AFTER UPDATE OF job_id, department_id ON employees
   FOR EACH ROW
   BEGIN
   add_job_history(:old.employee_id, :old.hire_date, sysdate, 
   :old.job_id, :old.department_id);
   END;
   /
   */
COMMIT;
COMMENT ON TABLE regions 
         IS 'Regions table that contains region numbers and names. Contains 4 rows; references with the Countries table.';
COMMENT ON COLUMN regions.region_id
         IS 'Primary key of regions table.';
COMMENT ON COLUMN regions.region_name
         IS 'Names of regions. Locations are in the countries of these regions.';
COMMENT ON TABLE locations
         IS 'Locations table that contains specific address of a specific office,
         warehouse, and/or production site of a company. Does not store addresses /
         locations of customers. Contains 23 rows; references with the
         departments and countries tables. ';
COMMENT ON COLUMN locations.location_id
         IS 'Primary key of locations table';
COMMENT ON COLUMN locations.street_address
         IS 'Street address of an office, warehouse, or production site of a company.
         Contains building number and street name';
COMMENT ON COLUMN locations.postal_code
         IS 'Postal code of the location of an office, warehouse, or production site 
         of a company. ';
COMMENT ON COLUMN locations.city
         IS 'A not null column that shows city where an office, warehouse, or 
         production site of a company is located. ';
COMMENT ON COLUMN locations.state_province
         IS 'State or Province where an office, warehouse, or production site of a 
         company is located.';
COMMENT ON COLUMN locations.country_id
         IS 'Country where an office, warehouse, or production site of a company is
         located. Foreign key to country_id column of the countries table.';
       
REM *********************************************
COMMENT ON TABLE departments
         IS 'Departments table that shows details of departments where employees 
         work. Contains 27 rows; references with locations, employees, and job_history tables.';
COMMENT ON COLUMN departments.department_id
         IS 'Primary key column of departments table.';
COMMENT ON COLUMN departments.department_name
         IS 'A not null column that shows name of a department. Administration, 
         Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public 
         Relations, Sales, Finance, and Accounting. ';
COMMENT ON COLUMN departments.manager_id
         IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.';
COMMENT ON COLUMN departments.location_id
         IS 'Location id where a department is located. Foreign key to location_id column of locations table.';
       
/*REM *********************************************
COMMENT ON TABLE job_history
         IS 'Table that stores job history of the employees. If an employee 
         changes departments within the job or changes jobs within the department, 
         new rows get inserted into this table with old job information of the 
         employee. Contains a complex primary key: employee_id+start_date.
         Contains 25 rows. References with jobs, employees, and departments tables.';
COMMENT ON COLUMN job_history.employee_id
         IS 'A not null column in the complex primary key employee_id+start_date.
         Foreign key to employee_id column of the employee table';
COMMENT ON COLUMN job_history.start_date
         IS 'A not null column in the complex primary key employee_id+start_date. 
         Must be less than the end_date of the job_history table. (enforced by 
         constraint jhist_date_interval)';
COMMENT ON COLUMN job_history.end_date
         IS 'Last day of the employee in this job role. A not null column. Must be 
         greater than the start_date of the job_history table. 
         (enforced by constraint jhist_date_interval)';
COMMENT ON COLUMN job_history.job_id
         IS 'Job role in which the employee worked in the past; foreign key to 
         job_id column in the jobs table. A not null column.';
COMMENT ON COLUMN job_history.department_id
         IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';
   */    
REM *********************************************
COMMENT ON TABLE countries
         IS 'country table. Contains 25 rows. References with locations table.';
COMMENT ON COLUMN countries.country_id
         IS 'Primary key of countries table.';
COMMENT ON COLUMN countries.country_name
         IS 'Country name';
COMMENT ON COLUMN countries.region_id
         IS 'Region ID for the country. Foreign key to region_id column in the departments table.';
REM *********************************************
COMMENT ON TABLE jobs
         IS 'jobs table with job titles and salary ranges. Contains 19 rows.
         References with employees and job_history table.';
COMMENT ON COLUMN jobs.job_id
         IS 'Primary key of jobs table.';
COMMENT ON COLUMN jobs.job_title
         IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';
COMMENT ON COLUMN jobs.min_salary
         IS 'Minimum salary for a job title.';
COMMENT ON COLUMN jobs.max_salary
         IS 'Maximum salary for a job title';
REM *********************************************
COMMENT ON TABLE employees
         IS 'employees table. Contains 107 rows. References with departments, 
         jobs, job_history tables. Contains a self reference.';
COMMENT ON COLUMN employees.employee_id
         IS 'Primary key of employees table.';
COMMENT ON COLUMN employees.first_name
         IS 'First name of the employee. A not null column.';
COMMENT ON COLUMN employees.last_name
         IS 'Last name of the employee. A not null column.';
COMMENT ON COLUMN employees.email
         IS 'Email id of the employee';
COMMENT ON COLUMN employees.phone_number
         IS 'Phone number of the employee; includes country code and area code';
COMMENT ON COLUMN employees.hire_date
         IS 'Date when the employee started on this job. A not null column.';
COMMENT ON COLUMN employees.job_id
         IS 'Current job of the employee; foreign key to job_id column of the 
         jobs table. A not null column.';
COMMENT ON COLUMN employees.salary
         IS 'Monthly salary of the employee. Must be greater 
         than zero (enforced by constraint emp_salary_min)';
COMMENT ON COLUMN employees.commission_pct
         IS 'Commission percentage of the employee; Only employees in sales 
         department elgible for commission percentage';
COMMENT ON COLUMN employees.manager_id
         IS 'Manager id of the employee; has same domain as manager_id in 
         departments table. Foreign key to employee_id column of employees table.
         (useful for reflexive joins and CONNECT BY query)';
COMMENT ON COLUMN employees.department_id
         IS 'Department id where employee works; foreign key to department_id 
         column of the departments table';
COMMIT;
 