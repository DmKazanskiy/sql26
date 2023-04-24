select *
from pg_catalog.pg_replication_slots prs

select *
from pg_catalog.pg_publication pp

drop publication insert_only

create table a (
	id serial primary key,
	val text)

create publication pub_26 for table a, b, c

create publication pub_26 for all tables

create publication pub_26 for table a where (id > 100)

create publication pub_26 for table a with (publicsh = 'insert')

create publication pub_26 for table a (val)

create publication pub_26 for table a

insert into a (val)
values ('b')

select * from a

create publication pub_27 for table payment

create table b (
	id serial primary key,
	val text)
	
create publication pub_28 for table b

insert into b (val)
values ('aaaaaaaa')

select * from b

create table a (
	id serial primary key,
	val text)

create schema "dvd-rental"	

set search_path to "dvd-rental"	
	
create subscription sub_26
connection 'host=localhost port=5435 user=postgres password=123 dbname=postgres'
publication pub_26 with (copy_data = false)

select * from a

CREATE TABLE payment (
	payment_id serial4 NOT NULL,
	customer_id int2 NOT NULL,
	staff_id int2 NOT NULL,
	rental_id int4 NOT NULL,
	amount numeric(5, 2) NOT NULL,
	payment_date timestamp NOT NULL);
	
create subscription sub_27
connection 'host=localhost port=5435 user=postgres password=123 dbname=postgres'
publication pub_27 with (copy_data = true)

select * from payment

create table b (
	id serial primary key,
	val text)
	
create subscription sub_28
connection 'host=localhost port=5435 user=postgres password=123 dbname=postgres'
publication pub_28 

select * from b

insert into b (val)
values ('щщщщ')

select *
from pg_catalog.pg_replication_slots prs

select * from pg_catalog.pg_subscription ps

delete from b where id = 3

select distinct date_trunc('month', payment_date) 
from payment 

CREATE TABLE payment_05_2005 
(CHECK (DATE_TRUNC('month', payment_date) = '01.05.2005')) INHERITS (payment);

CREATE TABLE payment_06_2005 
(CHECK (DATE_TRUNC('month', payment_date) = '01.06.2005')) INHERITS (payment);

CREATE TABLE payment_07_2005 
(CHECK (DATE_TRUNC('month', payment_date) = '01.07.2005')) INHERITS (payment);

CREATE TABLE payment_08_2005 
(CHECK (DATE_TRUNC('month', payment_date) = '01.08.2005')) INHERITS (payment);

CREATE INDEX payment_05_2005_date_idx ON payment_05_2005 (CAST(payment_date as date));

CREATE INDEX payment_06_2005_date_idx ON payment_06_2005 (CAST(payment_date as date));

CREATE INDEX payment_07_2005_date_idx ON payment_07_2005 (CAST(payment_date as date));

CREATE INDEX payment_08_2005_date_idx ON payment_08_2005 (CAST(payment_date as date));

CREATE INDEX payment_date_idx ON payment (CAST(payment_date as date));

CREATE RULE payment_insert_05_2005 AS ON INSERT TO payment 
WHERE (DATE_TRUNC('month', payment_date) = '01.05.2005')
DO INSTEAD INSERT INTO payment_05_2005 VALUES (new.*);

CREATE RULE payment_insert_06_2005 AS ON INSERT TO payment 
WHERE (DATE_TRUNC('month', payment_date) = '01.06.2005')
DO INSTEAD INSERT INTO payment_06_2005 VALUES (new.*);

CREATE RULE payment_insert_07_2005 AS ON INSERT TO payment 
WHERE (DATE_TRUNC('month', payment_date) = '01.07.2005')
DO INSTEAD INSERT INTO payment_07_2005 VALUES (new.*);

CREATE RULE payment_insert_08_2005 AS ON INSERT TO payment 
WHERE (DATE_TRUNC('month', payment_date) = '01.08.2005')
DO INSTEAD INSERT INTO payment_08_2005 VALUES (new.*);

explain analyze
select *
from payment 
where payment_date::date = '01.08.2005'

WITH cte AS (  
	DELETE FROM ONLY payment      
	WHERE DATE_TRUNC('month', payment_date) = '01.05.2005' RETURNING *)
INSERT INTO payment_05_2005   
SELECT * FROM cte;

WITH cte AS (  
	DELETE FROM ONLY payment      
	WHERE DATE_TRUNC('month', payment_date) = '01.06.2005' RETURNING *)
INSERT INTO payment_06_2005   
SELECT * FROM cte;

WITH cte AS (  
	DELETE FROM ONLY payment      
	WHERE DATE_TRUNC('month', payment_date) = '01.07.2005' RETURNING *)
INSERT INTO payment_07_2005   
SELECT * FROM cte;

WITH cte AS (  
	DELETE FROM ONLY payment      
	WHERE DATE_TRUNC('month', payment_date) = '01.08.2005' RETURNING *)
INSERT INTO payment_08_2005   
SELECT * FROM cte;

explain analyze --97.85 / 0.164
select *
from payment 
where payment_date::date = '01.08.2005'

explain analyze --61.55 / 0.127
select *
from payment_08_2005 
where payment_date::date = '01.08.2005'

select *
from only payment 

CREATE RULE payment_update_05_2005 AS ON UPDATE TO payment 
WHERE (DATE_TRUNC('month', old.payment_date) = '01.05.2005' 
	AND DATE_TRUNC('month', new.payment_date) != '01.05.2005')
DO INSTEAD (INSERT INTO payment VALUES (new.*); 
	DELETE FROM payment_05_2005 WHERE payment_id = new.payment_id);
	
CREATE RULE payment_update_06_2005 AS ON UPDATE TO payment 
WHERE (DATE_TRUNC('month', old.payment_date) = '01.06.2005' 
	AND DATE_TRUNC('month', new.payment_date) != '01.06.2005')
DO INSTEAD (INSERT INTO payment VALUES (new.*); 
	DELETE FROM payment_06_2005 WHERE payment_id = new.payment_id);
	
CREATE RULE payment_update_07_2005 AS ON UPDATE TO payment 
WHERE (DATE_TRUNC('month', old.payment_date) = '01.07.2005' 
	AND DATE_TRUNC('month', new.payment_date) != '01.07.2005')
DO INSTEAD (INSERT INTO payment VALUES (new.*); 
	DELETE FROM payment_07_2005 WHERE payment_id = new.payment_id);
	
CREATE RULE payment_update_08_2005 AS ON UPDATE TO payment 
WHERE (DATE_TRUNC('month', old.payment_date) = '01.08.2005' 
	AND DATE_TRUNC('month', new.payment_date) != '01.08.2005')
DO INSTEAD (INSERT INTO payment VALUES (new.*); 
	DELETE FROM payment_08_2005 WHERE payment_id = new.payment_id);
	
select *
from payment p
order by payment_id

1	1	1	76	2.99	2005-05-25 11:30:37

select *
from payment_05_2005 p

update payment
set payment_date = '2005-07-25 11:30:37'
where payment_id = 1

select *
from payment_07_2005 p

drop rule payment_update_08_2005 on payment

CREATE TRIGGER payment_insert_tg
BEFORE INSERT ON payment
FOR EACH ROW EXECUTE FUNCTION payment_insert_tg();

CREATE OR REPLACE FUNCTION payment_insert_tg() RETURNS TRIGGER AS $$
BEGIN
	IF DATE_TRUNC('month', new.payment_date) = '01.05.2005' THEN    
		INSERT INTO payment_05_2005 VALUES (new.*);
	ELSIF DATE_TRUNC('month', new.payment_date) = '01.06.2005' THEN  
		INSERT INTO payment_06_2005 VALUES (new.*);
	ELSIF DATE_TRUNC('month', new.payment_date) = '01.07.2005' THEN  
		INSERT INTO payment_07_2005 VALUES (new.*);
	ELSIF DATE_TRUNC('month', new.payment_date) = '01.08.2005' THEN  
		INSERT INTO payment_08_2005 VALUES (new.*);
	ELSE RAISE EXCEPTION 'Отсутствует партиция';
	END IF;
	RETURN NULL;
END; $$ LANGUAGE plpgsql;

create temporary table pay as (
select * from payment p)

truncate payment

insert into payment
select * from pay

SQL Error [P0001]: ОШИБКА: Отсутствует партиция

CREATE OR REPLACE FUNCTION payment_insert_tg() RETURNS TRIGGER AS $$
DECLARE new_month date; new_month_part text; partition_table_name text;
begin
	new_month = DATE_TRUNC('month', new.payment_date)::date;
	new_month_part = CONCAT(SPLIT_PART(new_month::text, '-', 2), '_', SPLIT_PART(new_month::text, '-', 1));
	partition_table_name = FORMAT('payment_%s', new_month_part);
	IF (TO_REGCLASS(partition_table_name) IS NULL) then
		EXECUTE FORMAT(
			'CREATE TABLE %I ('
			'  CHECK (DATE_TRUNC(''month'', payment_date) = %L)'
			') INHERITS (payment);'
			, partition_table_name, new_month);
		EXECUTE FORMAT(
			'CREATE INDEX %1$s_date_idx ON %1$I (CAST(payment_date as date));'
			, partition_table_name);
		EXECUTE FORMAT(
			'CREATE TRIGGER %1$s_update_tg '
			'BEFORE UPDATE ON %1$I '
			'FOR EACH ROW EXECUTE FUNCTION payment_insert_tg();'
			,partition_table_name);
		END IF;
		EXECUTE FORMAT('INSERT INTO %I VALUES ($1.*)', partition_table_name) USING NEW;
	RETURN NULL;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION payment_update_tg() RETURNS TRIGGER AS $$
DECLARE new_month date; new_month_part text; partition_table_name text;
	old_month date; old_month_part text; old_partition_table_name text;
begin
	new_month = DATE_TRUNC('month', new.payment_date)::date;
	new_month_part = CONCAT(SPLIT_PART(new_month::text, '-', 2), '_', SPLIT_PART(new_month::text, '-', 1));
	partition_table_name = FORMAT('payment_%s', new_month_part);
	old_month = DATE_TRUNC('month', old.payment_date)::date;
	old_month_part = CONCAT(SPLIT_PART(old_month::text, '-', 2), '_', SPLIT_PART(old_month::text, '-', 1));
	old_partition_table_name = FORMAT('payment_%s', old_month_part);
	if DATE_TRUNC('month', new.payment_date) != DATE_TRUNC('month', old.payment_date) then
		EXECUTE FORMAT('INSERT INTO %I VALUES ($1.*)', partition_table_name) USING NEW;
		EXECUTE 'delete from ' || quote_ident(old_partition_table_name) || ' where payment_id = ' ||
		quote_literal(old.payment_id);
	end if;
	return null;
END; $$ LANGUAGE plpgsql;



%s - просто подставляем значение
%I - подставляем значение в ""
%L - подставляем значение в ''

'2005-07-25 11:30:37'

select to_char('2005-07-25 11:30:37'::timestamp, 'mm_yyyy')

select DATE_TRUNC('month', '2005-07-25 11:30:37'::timestamp)::date --2005-07-01

select CONCAT(SPLIT_PART((DATE_TRUNC('month', '2005-07-25 11:30:37'::timestamp)::date)::text, '-', 2), 
	'_', SPLIT_PART((DATE_TRUNC('month', '2005-07-25 11:30:37'::timestamp)::date)::text, '-', 1)) --07_2005
	
select FORMAT('payment_%s', to_char('2005-07-25 11:30:37'::timestamp, 'mm_yyyy')) -- payment_07_2005

select TO_REGCLASS('rentalfghfghfghfg')

select * from payment_02_2006

CREATE TRIGGER payment_02_2006_update_tg
BEFORE UPDATE ON payment_02_2006
FOR EACH ROW EXECUTE FUNCTION payment_update_tg();

drop trigger payment_02_2006_update_tg on payment_02_2006

select *
from payment_05_2005

2005-05-25 11:30:37

update payment
set payment_date = '2005-07-25 11:30:37'
where payment_id = 1

select * from payment_07_2005

delete from payment_07_2005
where payment_id = 1

create database payment_2005

create database payment_2006

explain analyze --359.74 / 1.5
select *
from payment 
where payment_date::date = '01.08.2005'

CREATE INDEX payment_date_idx ON payment (CAST(payment_date as date));

explain analyze --118.29 / 0.178
select *
from payment 
where payment_date::date = '01.08.2005'

select *
from pg_catalog.pg_available_extensions pae
where installed_version is not null

create extension postgres_fdw

CREATE SERVER payment_2005_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5435', dbname 'payment_2005');

CREATE USER MAPPING FOR postgres
SERVER payment_2005_server
OPTIONS (user 'postgres', password '123');

CREATE SERVER payment_2006_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5435', dbname 'payment_2006');

CREATE USER MAPPING FOR postgres
SERVER payment_2006_server
OPTIONS (user 'postgres', password '123');

CREATE FOREIGN TABLE payment_2005 (
	payment_id int NOT NULL,
	customer_id int2 NOT NULL,
	staff_id int2 NOT NULL,
	rental_id int NOT NULL,
	amount numeric(5, 2) NOT NULL,
	payment_date timestamp NOT NULL) 
INHERITS (payment)
SERVER payment_2005_server
OPTIONS (schema_name 'public', table_name 'payment');

CREATE FOREIGN TABLE payment_2006 (
	payment_id int NOT NULL,
	customer_id int2 NOT NULL,
	staff_id int2 NOT NULL,
	rental_id int NOT NULL,
	amount numeric(5, 2) NOT NULL,
	payment_date timestamp NOT NULL) 
INHERITS (payment)
SERVER payment_2006_server
OPTIONS (schema_name 'public', table_name 'payment');


CREATE OR REPLACE FUNCTION payment_insert_tg() RETURNS TRIGGER AS $$
BEGIN
	IF DATE_PART('year', new.payment_date) = 2005 THEN    
		INSERT INTO payment_2005 VALUES (new.*);
	ELSIF DATE_PART('year', new.payment_date) = 2006 THEN  
		INSERT INTO payment_2006 VALUES (new.*);
	ELSE RAISE EXCEPTION 'Отсутствует партиция';
	END IF;
	RETURN NULL;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER payment_insert_tg    
BEFORE INSERT ON payment
FOR EACH ROW EXECUTE FUNCTION payment_insert_tg();

