select 111

select sum(amount)
from payment 
where payment_date::date between '15.07.2005' and '01.08.2005'
group by customer_id

create function foo(start_date date, end_date date, out res numeric) as $$
begin
	select sum(amount)
	from payment 
	where payment_date::date between start_date and end_date into res;
end;
$$ language plpgsql

select foo('01.07.2005', '01.08.2005')

select foo('01.07.2005', null)

select foo('01.08.2005', '01.07.2005')

if / when

create or replace function foo(start_date date, end_date date, out res numeric) as $$
begin
	if start_date is null 
		then start_date = (select min(payment_date::date) from payment);
	elsif end_date is null 
		then end_date = (select max(payment_date::date) from payment);
	elseif end_date < start_date
		then raise exception 'Дата окончания не может быть меньше даты начала';
	end if;
	select sum(amount)
	from payment 
	where payment_date::date between start_date and end_date into res;
end;
$$ language plpgsql

select foo('01.07.2005', null)

select foo(null, '01.07.2005')

select foo('01.08.2005', '01.07.2005')

SQL Error [P0001]: ОШИБКА: Дата окончания не может быть меньше даты начала

create or replace function foo(start_date date, end_date date) returns numeric as $$
declare res numeric;
begin
	if start_date is null 
		then start_date = (select min(payment_date::date) from payment);
	elsif end_date is null 
		then end_date = (select max(payment_date::date) from payment);
	elseif end_date < start_date
		then raise exception 'Дата окончания не может быть меньше даты начала';
	end if;
	select sum(amount)
	from payment 
	where payment_date::date between start_date and end_date into res;
	return res;
end;
$$ language plpgsql

create or replace function foo(start_date date, end_date date, cust_id int) returns numeric as $$
declare res numeric;
begin
	if start_date is null 
		then start_date = (select min(payment_date::date) from payment);
	elsif end_date is null 
		then end_date = (select max(payment_date::date) from payment);
	elseif end_date < start_date
		then raise exception 'Дата окончания не может быть меньше даты начала';
	end if;
	select sum(amount)
	from payment 
	where payment_date::date between start_date and end_date and customer_id = cust_id into res;
	return res;
end;
$$ language plpgsql

drop function foo(date, date, int)

drop function foo

select foo('01.07.2005', '01.08.2005')

select foo('01.07.2005', '01.08.2005', 3)

create or replace function foo1(title_ text) returns text as $$
begin
	case 
		when title_ in (select title from film) then return 'да';
		else return 'нет';
	end case;
end;
$$ language plpgsql

select foo1('ACADEMY DINOSAUR')

select * from film f

ACADEMY DINOSAUR
ACE GOLDFINGER
ADAPTATION HOLES
AFFAIR PREJUDICE
AFRICAN EGG

create or replace function foo1(title_ text) returns text as $$
begin
	case title_
		when 'ACADEMY DINOSAUR' then return 'да';
		when 'ACE GOLDFINGER' then return 'да';
		when 'ADAPTATION HOLES' then return 'да';
		when 'AFFAIR PREJUDICE' then return 'да';
		when 'AFRICAN EGG' then return 'да';
		else return 'нет';
	end case;
end;
$$ language plpgsql

for 
loop
foreach
while

create or replace function foo2(in_amount numeric, out c_name text, out s_amount numeric, out c_film int) 
	returns setof record as $$
declare i record;
begin
	for i in (select customer_id from payment group by customer_id having sum(amount) > in_amount)
	loop
		select concat(c.last_name, ' ', c.first_name), sum(p.amount), count(inv.film_id)
		from customer c
		join payment p on p.customer_id = c.customer_id
		join rental r on r.rental_id = p.rental_id
		join inventory inv on r.inventory_id = inv.inventory_id
		where c.customer_id = i.customer_id
		group by c.customer_id into c_name, s_amount, c_film;
		return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo2(190)

create or replace function foo2(in_amount numeric) returns table(c_name text, s_amount numeric, c_film int) as $$
declare i record;
begin
	for i in (select customer_id from payment group by customer_id having sum(amount) > in_amount)
	loop
		select concat(c.last_name, ' ', c.first_name), sum(p.amount), count(inv.film_id)
		from customer c
		join payment p on p.customer_id = c.customer_id
		join rental r on r.rental_id = p.rental_id
		join inventory inv on r.inventory_id = inv.inventory_id
		where c.customer_id = i.customer_id
		group by c.customer_id into c_name, s_amount, c_film;
		return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo2(200)

create or replace function foo3(in_amount numeric) returns table(c_name text, s_amount numeric, c_film int) as $$
declare i record;
begin
	return query
		select concat(c.last_name, ' ', c.first_name)::text, sum(p.amount)::numeric, count(inv.film_id)::int
		from customer c
		join payment p on p.customer_id = c.customer_id
		join rental r on r.rental_id = p.rental_id
		join inventory inv on r.inventory_id = inv.inventory_id
		group by c.customer_id
		having sum(amount) > in_amount;	
end;
$$ language plpgsql

select *
from foo3(180)

create or replace function foo4() returns table(y int) as $$
declare i record;
begin
	for i in 1..10
	loop	
		y = 0;
		y = y + i;
	return next;
	end loop;	
end;
$$ language plpgsql
	
create or replace function foo4() returns table(y int) as $$
declare i record; 
begin
	for i in reverse 10..1
	loop	
		y = 0;
		y = i;
	return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo4()
	
create or replace function foo5(x int) returns table(y int) as $$
declare i int = 0; 
begin
	while i <= x
	loop
		y = i;
		i = i + 1;
	return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo5(10)

create or replace function foo5(x int) returns table(y int) as $$
declare i int = 0; 
begin
	loop
		y = i;
		i = i + 1;
		exit when i > x;
	return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo5(10)

create or replace function foo5(x int) returns table(y int) as $$
declare i int = 0; 
begin
	loop
		y = i;
		i = i + 1;
		continue when i > x;
	return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo5(10)

create or replace function foo6(x text[]) returns table(y text) as $$
declare i text; 
begin
	foreach i in array x
	loop
		y = i;
	return next;
	end loop;	
end;
$$ language plpgsql

select *
from foo6((select special_features from film where film_id = 14))

create or replace function foo7(start_date date, end_date date) returns setof rental as $$
begin
	return query 
		select *
		from rental 
		where rental_date::date between start_date and end_date;
end;
$$ language plpgsql

select * from foo7('01.07.2005', '01.08.2005')

create role test_foo with login 

select * from pg_catalog.pg_roles pr

select (date_trunc('month', current_date) + interval '1 month' - interval '1d')::date

alter role test_foo valid until (select date_trunc('month', current_date) + interval '1 month' - interval '1d')

do $$
declare x date = (select (date_trunc('month', current_date) + interval '1 month' - interval '1d')::date);
	y text = 'test_foo';
begin
	execute 'alter role ' || quote_ident(y) || ' valid until ' || quote_literal(x);
end;
$$ language plpgsql

select quote_literal(), quote_ident(), quote_nullable()

alter role "test_foo" valid until '2023-03-31';

do '
declare x date = (select (date_trunc(''month'', current_date) + interval ''1 month'' - interval ''1d'')::date);
	y text = ''test_foo'';
begin
	execute ''alter role '' || quote_ident(y) || '' valid until '' || quote_literal(x);
end;
' language plpgsql

create table a (
	id int,
	val text)
	
create table b (
	id int,
	val text,
	val_a text)
	
create trigger a_test
before insert or update on a 
for each row execute procedure foo_t()

create or replace function foo_t() returns trigger as $$
begin
	insert into b (val_a)
	values (new.val);
	return new;
end;
$$ language plpgsql

insert into a 
values (1, 'a')

update a 
set val = 'b'
where id = 1

delete from b

select * from a

select * from b

drop trigger a_test on a

create or replace function foo_t() returns trigger as $$
begin
	if tg_op = 'INSERT' then 
		insert into b (val)
		values (new.val);
	elseif tg_op = 'UPDATE' then 
		insert into b (id, val)
		values (old.id, old.val);
	end if;
	return new;
end;
$$ language plpgsql

create trigger a_test
after insert or update on a 
for each row execute procedure foo_t()

SQL Error [54001]: ОШИБКА: превышен предел глубины стека

tab1	tg1 -> foo1
tab2 	tg2 -> foo1
tab3 	tg3 -> foo1
tab4 	tg4 -> foo1
tab5 	tg5 -> foo1

tab_itogo

foo1() returns trigger 
if tg_table_name = 'tab1' then ->
if tg_level

CREATE TABLE summary_report (
	customer_id int2 NOT NULL,
	customer_fio varchar(150) NOT NULL,
	sum_amount numeric(10,2) NOT NULL,
	count_rents int NOT NULL,
	last_payment timestamp NOT NULL)
	
CREATE OR REPLACE FUNCTION summary_report_foo() RETURNS trigger AS $$
DECLARE cust_fio varchar(150) = (
	SELECT CONCAT(last_name, ' ', first_name) 
	FROM customer 
	WHERE customer_id = NEW.customer_id);
	sum_a numeric(10,2) = (SELECT SUM(amount) FROM payment WHERE customer_id = NEW.customer_id);
	count_r int = (SELECT COUNT(*) FROM rental WHERE customer_id = NEW.customer_id);
	last_p timestamp = NEW.payment_date;	
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.customer_id NOT IN (SELECT customer_id FROM summary_report)
		THEN INSERT INTO summary_report (customer_id, customer_fio, sum_amount, count_rents, last_payment)
		VALUES (NEW.customer_id, cust_fio, sum_a, count_r, last_p);
	ELSEIF TG_OP = 'DELETE' AND OLD.customer_id NOT IN (SELECT customer_id FROM customer)
			THEN DELETE FROM summary_report WHERE customer_id = OLD.customer_id;
	ELSEIF TG_OP = 'INSERT' OR TG_OP = 'UPDATE'
		THEN UPDATE summary_report 
			SET sum_amount = sum_a, count_rents = count_r, last_payment = last_p 
			WHERE customer_id = NEW.customer_id;
	ELSEIF TG_OP = 'DELETE'
	THEN UPDATE summary_report 
		SET sum_amount = sum_a, count_rents = count_r, last_payment = last_p 
		WHERE customer_id = OLD.customer_id;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER summary_report_trigger 
AFTER INSERT OR UPDATE OR DELETE ON payment 
FOR EACH ROW EXECUTE PROCEDURE summary_report_foo();

explain analyze
SELECT CONCAT(last_name, ' ', first_name) 
FROM customer 
WHERE customer_id = null

create trigger b 
after insert on table a

create trigger a 
before insert on table a

tg1 before foo1 -> I tg2 before foo2 -> I tg3 after U -> foo3

create or replace function foo(start_date date, end_date date, out res numeric) as $$
declare x text = 'a';
begin
	raise exception '%', pg_typeof(x);
	insert into a (id, val)
	values (x, 2::int);
	if start_date is null 
		then start_date = (select min(payment_date::date) from payment);
	elsif end_date is null 
		then end_date = (select max(payment_date::date) from payment);
	elseif end_date < start_date
		then raise exception 'Дата окончания не может быть меньше даты начала';
	end if;
	select sum(amount)
	from payment 
	where payment_date::date between start_date and end_date into res;	
end;
$$ language plpgsql

select * from foo('01.07.2005', '01.08.2005')

select * from a

SQL Error [42601]: ОШИБКА: в запросе нет назначения для данных результата
  Подсказка: Если вам нужно отбросить результаты SELECT, используйте PERFORM.
  Где: функция PL/pgSQL foo(date,date), строка 10, оператор SQL-оператор
  
SQL Error [22P02]: ОШИБКА: неверный синтаксис для типа integer: "a"

try (логику) catch (ловим ошибку) - не существует

SQL Error [42804]: ОШИБКА: столбец "id" имеет тип integer, а выражение - text

ddl_command_start CREATE, ALTER, DROP, SECURITY LABEL, COMMENT, GRANT и REVOKE
ddl_command_end CREATE, ALTER, DROP, SECURITY LABEL, COMMENT, GRANT и REVOKE
table_rewrite ALTER TABLE и ALTER TYPE
sql_drop

TG_EVENT 
TG_TAG

CREATE TABLE ddl_audit (
	id SERIAL PRIMARY KEY,
	command_type VARCHAR(64) NOT NULL,
	schema_name VARCHAR(64) NOT NULL,
	object_name VARCHAR(64) NOT NULL,
	user_name VARCHAR(64) NOT NULL DEFAULT CURRENT_USER,
	created_at TIMESTAMP NOT NULL DEFAULT NOW())
	
CREATE OR REPLACE FUNCTION ddl_command_audit() RETURNS event_trigger AS $$
DECLARE i record;
BEGIN
	IF TG_EVENT = 'ddl_command_end' THEN
		FOR i IN SELECT * FROM pg_event_trigger_ddl_commands() WHERE object_type = 'table'
		LOOP
			INSERT INTO ddl_audit (command_type, schema_name, object_name)
		    VALUES (tg_tag, (SELECT SPLIT_PART(i.object_identity, '.', 1)), (SELECT SPLIT_PART(i.object_identity, '.', 2)));
		END LOOP;
	ELSEIF TG_EVENT = 'sql_drop' THEN
   		FOR i IN SELECT * FROM pg_event_trigger_dropped_objects() WHERE object_type = 'table'
	    LOOP
			INSERT INTO ddl_audit (command_type, schema_name, object_name)
			VALUES(tg_tag, (SELECT SPLIT_PART(i.object_identity, '.', 1)), (SELECT SPLIT_PART(i.object_identity, '.', 2)));
	    END LOOP;
   END IF;
END; $$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER ddl_command_audit ON ddl_command_end
EXECUTE FUNCTION ddl_command_audit();

CREATE EVENT TRIGGER ddl_command_audit_drop ON sql_drop
EXECUTE FUNCTION ddl_command_audit();

ddl_command_end
classid	oid	OID каталога, к которому относится объект
objid	oid	OID самого объекта
objsubid	integer	Идентификатор подобъекта (например, номер для столбца)
command_tag	text	Тег команды
object_type	text	Тип объекта
schema_name	text	Имя схемы, к которой относится объект; если объект не относится ни к какой схеме — NULL. 
В кавычки имя не заключается.
object_identity	text	Текстовое представление идентификатора объекта, включающее схему. При необходимости 
компоненты этого идентификатора заключаются в кавычки.
in_extension	boolean	True, если команда является частью скрипта расширения
command	pg_ddl_command	Полное представление команды, во внутреннем формате. Его нельзя вывести непосредственно, 
но можно передать другим функциям, чтобы получить различные сведения о команде.

sql_drop
classid	oid	OID каталога, к которому относился объект
objid	oid	OID самого объекта
objsubid	integer	Идентификатор подобъекта (например, номер для столбца)
original	boolean	True, если это один из корневых удаляемых объектов
normal	boolean	True, если к этому объекту в графе зависимостей привело отношение обычной зависимости
is_temporary	boolean	True, если объект был временным
object_type	text	Тип объекта
schema_name	text	Имя схемы, к которой относился объект; если объект не относился ни к какой схеме — NULL. 
В кавычки имя не заключается.
object_name	text	Имя объекта, если сочетание схемы и имени позволяет уникально идентифицировать объект; в 
противном случае — NULL. Имя не заключается в кавычки и не дополняется именем схемы.
object_identity	text	Текстовое представление идентификатора объекта, включающее схему. При необходимости 
компоненты этого идентификатора заключаются в кавычки.
address_names	text[]	Массив, который в сочетании с object_type и массивом address_args можно передать функции 
pg_get_object_address, чтобы воссоздать адрес объекта на удалённом сервере, содержащем одноимённый объект того же рода.
address_args	text[]	Дополнение к массиву address_names

select * from ddl_audit

drop table a

create table c ()

alter table c add column id int

drop role test_foo

function 									procedure
обязательно возвращают что-то				ничего не возвращают
											call
работает в 1 транзакции						управляют транзакциями

CREATE TABLE table_a (
	id serial PRIMARY KEY,
	val int NOT NULL);

INSERT INTO table_a (val)
VALUES (11), (12), (13);

CREATE TABLE table_b (
	id serial PRIMARY KEY,
	val int NOT NULL,
	created_at timestamp DEFAULT now());

CREATE FUNCTION f1() RETURNS void AS $$
	BEGIN
		FOR i IN 1..10
		LOOP 
			IF i%2 = 0 
				THEN 
					INSERT INTO table_b(val)
					VALUES (i);
			END IF;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION f2() RETURNS void AS $$
	DECLARE i record;
	BEGIN
		PERFORM f1();
		FOR i IN 
			SELECT val FROM table_a
		LOOP 
			INSERT INTO table_b(val)
			VALUES (i.val);
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE or replace FUNCTION f3() RETURNS void AS $$
	BEGIN
		PERFORM f2();
	END;
$$ LANGUAGE plpgsql;

Tb SELECT f3(); f3() -> f2() -> f1() Tc

SQL Error [42601]: ОШИБКА: в запросе нет назначения для данных результата
  Подсказка: Если вам нужно отбросить результаты SELECT, используйте PERFORM.
  Где: функция PL/pgSQL f3(), строка 3, оператор SQL-оператор
  
select * from table_b

CREATE PROCEDURE p1() AS $$
	BEGIN
		FOR i IN 1..10
		LOOP 
			INSERT INTO table_b(val)
			VALUES (i);
			IF i%2 = 0 
				THEN COMMIT; 
			ELSE 
				ROLLBACK;
			END IF;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE PROCEDURE p2() AS $$
	DECLARE i record;
	BEGIN
		CALL p1();
		FOR i IN 
			SELECT val FROM table_a
		LOOP 
			INSERT INTO table_b(val)
			VALUES (i.val);
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE PROCEDURE p3() AS $$
	BEGIN
		CALL p2();
	END;
$$ LANGUAGE plpgsql;

CALL p3();

SELECT * FROM table_b;

delete from table_b

do$$
	begin
		commit
		rollback		
	end;
$$LANGUAGE plpgsql;

Задание 1. Напишите функцию, которая принимает на вход название должности (например, стажер), а также даты периода поиска,
и возвращает количество вакансий, опубликованных по этой должности в заданный период.

Задание 2. Напишите триггер, срабатывающий тогда, когда в таблицу position добавляется значение grade, которого нет 
в таблице-справочнике grade_salary. Триггер должен возвращать предупреждение пользователю о несуществующем значении grade.

Задание 3. Создайте таблицу employee_salary_history с полями:
emp_id - id сотрудника
salary_old - последнее значение salary (если не найдено, то 0)
salary_new - новое значение salary
difference - разница между новым и старым значением salary
last_update - текущая дата и время
Напишите триггерную функцию, которая срабатывает при добавлении новой записи о сотруднике или при обновлении 
значения salary в таблице employee_salary, и заполняет таблицу employee_salary_history данными.

Задание 4. Напишите процедуру, которая содержит в себе транзакцию на вставку данных в таблицу employee_salary. 
Входными параметрами являются поля таблицы employee_salary.

