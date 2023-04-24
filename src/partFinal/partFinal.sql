set search_path to public;

do $$ declare
    tabname record;
begin
    for tabname in (select tablename 
                    from pg_tables 
                    where schemaname = current_schema()) 
loop
    execute 'drop table if exists ' || quote_ident(tabname.tablename) || ' cascade';
end loop;
end $$;
drop type if exists courier_status cascade;

-- =================================================================================
-- 1. Используя сервис https://supabase.com/
-- нужно поднять облачную базу данных PostgreSQL.

--- Создал ЛК, установил пароль

-- =================================================================================
-- 2. Для доступа к данным в базе данных должен быть создан пользователь 
-- логин: netocourier
-- пароль: NetoSQL2022
-- права: полный доступ на схему public, 
-- к information_schema и pg_catalog права только на чтение, 
-- предусмотреть доступ к иным схемам, если они нужны. 

---- действия выполняются из под пользователя postgres:
set search_path to public;
create role netocourier login password 'netosql2022';
grant usage on schema public to netocourier;
grant all privileges on schema public to netocourier;
grant usage on schema information_schema, pg_catalog to netocourier;
grant select on all tables in schema information_schema to netocourier;
grant select on all tables in schema pg_catalog to netocourier;

---- действия выполняются из под пользователя netocourier:
-- =================================================================================
-- 3. Должны быть созданы следующие отношения:
-- courier: --данные по заявкам на курьера
-- id uuid PK
-- from_place varchar --откуда
-- where_place varchar --куда
-- name varchar --название документа
-- account_id uuid FK --id контрагента
-- contact_id uuid FK --id контакта 
-- description text --описание
-- user_id uuid FK --id сотрудника отправителя
-- status enum -- статусы 'В очереди', 'Выполняется', 'Выполнено', 'Отменен'. По умолчанию 'В очереди'
-- created_date date --дата создания заявки, значение по умолчанию now()
-- 
-- account: --список контрагентов
-- id uuid PK
-- name varchar --название контрагента
-- 
-- contact: --список контактов контрагентов
-- id uuid PK
-- last_name varchar --фамилия контакта
-- first_name varchar --имя контакта
-- account_id uuid FK --id контрагента
-- 
-- user: --сотрудники
-- id uuid PK
-- last_name varchar --фамилия сотрудника
-- first_name varchar --имя сотрудника
-- dismissed boolean --уволен или нет, значение по умолчанию "нет"
-- 
drop type if exists courier_status cascade;
create type courier_status as enum ('В очереди', 'Выполняется', 'Выполнено', 'Отменен');

drop table if exists courier; --(данные по заявкам на курьера)
create table if not exists courier (
	id uuid primary key default gen_random_uuid(),
	from_place varchar(250) not null,
	where_place  varchar(250) not null,
	"name" varchar(150) not null,
	account_id uuid not null, 
	contact_id uuid not null, 
	description text,
	user_id uuid not null, 
	status courier_status not null default 'В очереди',
	created_date date not null default now()
);

drop table if exists account; -- (список контрагентов)
create table account (
	id uuid primary key default gen_random_uuid(),
	name varchar (100) not null
);

drop table if exists contact; -- (список контактов контрагентов)
create table contact (
	id uuid primary key default gen_random_uuid(),
	last_name varchar (50) not null,
	first_name varchar (50) not null,
	account_id uuid not null --references account (id)
);
drop table if exists "user"; -- (список сотрудников)
create table "user" (
	id uuid primary key default gen_random_uuid(),
	last_name varchar(50) not null,
	first_name varchar(50) not null,
	dismissed boolean default false not null
);
-- === add constraint
alter table courier
  add constraint courier_contact_id_fk foreign key (contact_id) references contact(id),
  add constraint courier_account_id_fk foreign key (account_id) references account(id),
  add constraint courier_user_id_fk foreign key (user_id) references "user"(id)
;
alter table contact
  add constraint contact_account_id_fk foreign key (account_id) references account(id)
;

-- === add comments
comment on table courier is e'реестр данных по заявкам на курьера';
comment on column courier.id is e'uuid pk';
comment on column courier.from_place is e'откуда';
comment on column courier.where_place is e'куда';
comment on column courier.name is e'название документа';
comment on column courier.account_id is e'id контрагента';
comment on column courier.contact_id is e'id контакта';
comment on column courier.description is e'описание';
comment on column courier.user_id is e'id сотрудника отправителя';
comment on column courier.status  is e'enum - статусы "в очереди", "выполняется", "выполнено", "отменен". по умолчанию "в очереди"';
comment on column courier.created_date  is e'дата создания заявки, значение по умолчанию now()';

comment on table account is e'список контрагентов';
comment on column account.id is e'uuid pk';
comment on column account.name is e'название контрагента';

comment on table contact is e'список контактов контрагентов';
comment on column contact.id is e'uuid pk';
comment on column contact.last_name is e'фамилия контакта';
comment on column contact.first_name is e'имя контакта';
comment on column contact.account_id is e'id контрагента';

comment on table "user" is e'список сотрудников';
comment on column "user".id is e'uuid pk';
comment on column "user".last_name is e'фамилия сотрудника';
comment on column "user".first_name is e'имя сотрудника';
comment on column "user".dismissed is e'уволен или нет, значение по умолчанию "нет"';

-- =================================================================================
-- 4. Использование UUID для генерации ID
--
--- На платформе SUPABASE по умолчанию включено расширение uuid—ossp, 
--- которое предоставляет функции генерации UUID - gen_random_uuid();
-- test uuid
select * from pg_extension where extname in ('uuid-ossp');
-- |oid|extname|extowner|extnamespace|extrelocatable|extversion|extconfig|extcondition|
-- |16423|uuid-ossp|10|16387|true|1.1|||

create extension if not exists "uuid-ossp";
---- extension "uuid-ossp" already exists, skipping

select gen_random_uuid();
---- |gen_random_uuid|
---- |4f8d33d7-2f0a-47af-a21a-17520118d3cd|

-- =================================================================================
-- 5. Для формирования списка значений в атрибуте status используйте create type ... as enum:
-- 
-- create type courier_status as enum ('В очереди', 'Выполняется', 'Выполнено', 'Отменен');
-- test enum
select enum_range(null::courier_status);
---- |enum_range|
---- |{"В очереди",Выполняется,Выполнено,Отменен}|
----
-- =================================================================================
-- 6. Для возможности тестирования приложения необходимо реализовать процедуру insert_test_data(value), которая принимает на вход целочисленное значение.
-- Данная процедура должна внести:
-- value * 1 строк случайных данных в отношение account.
-- value * 2 строк случайных данных в отношение contact.
-- value * 1 строк случайных данных в отношение user.
-- value * 5 строк случайных данных в отношение courier.
--- Генерация id должна быть через uuid-ossp
--- Генерация символьных полей через конструкцию SELECT repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя',1,(random()*33)::integer),(random()*10)::integer);
--- Соблюдайте длину типа varchar. Первый random получает случайный набор символов из строки, второй random дублирует количество символов полученных в substring.
--- Генерация булева типа происходит через 0 и 1 с использованием оператора random.
--- Генерацию даты и времени можно сформировать через select now() - interval '1 day' * round(random() * 1000) as timestamp;
--- Генерацию статусов можно реализовать через enum_range()
---
-- Функция Генерация символьных полей c ограничением длины поля таблицы
drop function if exists gen_string_with_limit(text,text);
create or replace function gen_string_with_limit(
  tbl_name text, tbl_column text, out rnd_str varchar
)
as $$
declare 
  column_length int4;
begin
	select character_maximum_length
	from INFORMATION_SCHEMA.columns
	where table_name = tbl_name and column_name = tbl_column
	into column_length;
	-- raise warning 'tbl - %, column %, has length %', tbl_name, tbl_column,column_length;
	select substring(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1,
		ceiling((random()*33))::int2), ceiling((random()*10))::int2), 1, coalesce(column_length,10))
	into rnd_str;
end
$$ language plpgsql;
-- проверка gen_string_with_limit();
select gen_string_with_limit('account','name');
select gen_string_with_limit('user','last_name');
select gen_string_with_limit('courier', 'from_place');
select gen_string_with_limit('courier','description');

-- Функция: Генерация булева типа;
drop function if exists gen_bool();
create or replace function gen_bool(out rnd_bool bool)
as $$
begin
	select (round(random())::int4)::bool
	into rnd_bool;
end
$$ language plpgsql;
-- проверка gen_bool();
select gen_bool();

-- Функция: Генерацию даты и времени;
drop function if exists gen_datetime();
create or replace function gen_datetime(out rnd_date date)
as $$
declare 
  column_length int4;
begin
	select now() - interval '1 day' * round(random() * 1000) timestamp
	into rnd_date;
end
$$ language plpgsql;
-- проверка gen_datetime();
select gen_datetime();

-- Функция: Генерация статусов;
drop function if exists gen_status();
create or replace function gen_status(out rnd_stat courier_status)
as $$
begin
	select (enum_range(null::courier_status))[4-floor(random() * 3.1456)]
	into rnd_stat;
end
$$ language plpgsql;
-- проверка gen_status;
select gen_status();
-- Функция: Получение случайного ID из таблицы. ID существует. 
drop function if exists get_table_row_id(varchar);
create or replace function get_table_row_id(table_name text, out rnd_id uuid)
as $$
begin
--	raise notice 'get_table_row_id - %', table_name;
	execute 'select id from '|| table_name || ' limit 1 offset floor(random()* (select count (id) from '|| table_name ||'));'
    into rnd_id;
end
$$ language plpgsql;
-- проверка get_table_row_id
select get_table_row_id('account');
select get_table_row_id('contact');
select get_table_row_id('"user"');


-- Процедура: Добавление тестовых данных сгенерированных по бизнес правилам;
-- gen_string_with_limit(table_name, table_column);
-- gen_bool();
-- gen_datetime();
-- gen_status();
-- get_table_row_id(table_name);
drop procedure if exists insert_test_data(int4);
create or replace procedure insert_test_data(loop_cnt int4 default 1)
as $$
declare
tbl text;
contact_id_var uuid; 
account_id_var uuid;
user_id_var uuid;
i int;
j int;
cnt int;
k json;
loop_table_data_test json = '[{ "tbl": "account","cnt":1 }, { "tbl": "user","cnt":1},{ "tbl": "contact","cnt":2},{ "tbl": "courier","cnt":5 }]';
begin 
	if loop_cnt <= 0
	  then raise exception 'Количество итераций должно быть больше 0';
	end if;
  for i in 1..loop_cnt loop
    --raise notice '[%]', i;
     for k in select * from json_array_elements(loop_table_data_test)
     loop
	     --raise notice 'row - (%)', k;
	    tbl = k->>'tbl'::text;
	    cnt = k->>'cnt';
	    case
		    when tbl = 'account' then
		      for j in 1..cnt loop
		        insert into account ("name") 
		        values (gen_string_with_limit('account','name'));
       		    --raise notice '[%] table - % exists', i, tbl;
		      end loop;
		    when tbl = 'user' then
		      for j in 1..cnt loop
		        insert into "user" (last_name, first_name, dismissed) 
		        values (gen_string_with_limit('user','last_name'), gen_string_with_limit('user','first_name'), gen_bool());
       		    --raise notice '[%] table - % exists', i, tbl;		       
		      end loop;
		    when tbl = 'contact' then
		      for j in 1..cnt loop
		        insert into contact (last_name, first_name, account_id) 
		        values (gen_string_with_limit('contact','last_name'), gen_string_with_limit('contact','first_name'), get_table_row_id('account'));
       		    --raise notice '[%] table - % exists', i, tbl;
		      end loop;
		    when tbl = 'courier' then
		      for j in 1..cnt loop     		 
			    contact_id_var = (get_table_row_id('contact'));
			    --raise notice 'contact_id_var[%]', contact_id_var; 
			    account_id_var = (select account_id from contact where id = contact_id_var);
			    --raise notice 'acc_id_var[%]', account_id_var; 
			    --raise notice 'user_id_var[%]', user_id_var; 
			    --raise notice '[%] table - % exists - contact % - acc % - user %', i, tbl, contact_id_var, account_id_var, get_table_row_id('"user"');
		        insert into courier (from_place, where_place, "name", account_id, contact_id, description, user_id, status, created_date) 
		        values (gen_string_with_limit('courier','from_place'), gen_string_with_limit('courier','where_place'), gen_string_with_limit('courier','name'), account_id_var, contact_id_var, gen_string_with_limit('courier','description'), get_table_row_id('"user"'), gen_status(), gen_datetime());
		      end loop;
		     
		   else
		   --raise notice '[%] table - % not exists', i, tbl;
		  end case;
     end loop;
  end loop;
end;
$$ language plpgsql;

call insert_test_data(10);

-- =================================================================================
-- 7. Необходимо реализовать процедуру erase_test_data(), 
-- которая будет удалять тестовые данные из отношений.
--
drop procedure if exists erase_test_data;
create or replace procedure erase_test_data()
as $$
begin
	truncate account, contact, courier, "user";
end;
$$ language plpgsql;
--тест
select count(*) from courier;
call erase_test_data();
select count(*) from account, contact, courier, "user";
call insert_test_data(100);

-- =================================================================================
-- 8. На бэкенде реализована функция по добавлению новой записи о заявке на курьера:
-- function add($params) --добавление новой заявки
--     {
--         $pdo = Di::pdo();
--         $from = $params["from"]; 
--         $where = $params["where"]; 
--         $name = $params["name"]; 
--         $account_id = $params["account_id"]; 
--         $contact_id = $params["contact_id"]; 
--         $description = $params["description"]; 
--         $user_id = $params["user_id"]; 
--         $stmt = $pdo->prepare('CALL add_courier (?, ?, ?, ?, ?, ?, ?)');
--         $stmt->bindParam(1, $from); --from_place
--         $stmt->bindParam(2, $where); --where_place
--         $stmt->bindParam(3, $name); --name
--         $stmt->bindParam(4, $account_id); --account_id
--         $stmt->bindParam(5, $contact_id); --contact_id
--         $stmt->bindParam(6, $description); --description
--         $stmt->bindParam(7, $user_id); --user_id
--         $stmt->execute();
--    }
-- Нужно реализовать процедуру 
-- add_courier(from_place, where_place, name, account_id, contact_id, description, user_id), 
-- которая принимает на вход вышеуказанные аргументы и вносит данные в таблицу courier
-- Важно! Последовательность значений должна быть строго соблюдена, 
-- иначе приложение работать не будет.
--
drop procedure if exists add_courier (varchar, varchar, varchar, uuid, uuid, text, uuid);
create or replace procedure add_courier(from_place varchar, where_place varchar, "name" varchar, account_id uuid, contact_id uuid, description text, user_id uuid)
as $$
begin
	if from_place is null
		then raise exception 'from_place value is null!';
	elseif where_place is null
		then raise exception 'where_place value is null!';
	elseif "name" is null
		then raise exception 'name value is null!';
	elseif account_id is null
		then raise exception 'account_id value is null!';
	elseif contact_id is null
		then raise exception 'contact_id value is null!';
	elseif user_id is null
		then raise exception 'user_id value is null!';
	else
		insert into courier (from_place, where_place, "name", account_id, contact_id, description, user_id)
		values (from_place, where_place, "name", account_id, contact_id, description, user_id);
	end if;
end;
$$ language plpgsql;
-- проверка add_courier();
select count(*) from courier;
call add_courier('2nd floor building A', 'undeground floor, Archive', gen_string_with_limit('courier', 'name'),get_table_row_id('account') , get_table_row_id('contact'), 'test', get_table_row_id('"user"'));
select count(*) from courier;

-- =================================================================================
-- 9. На бэкенде реализована функция по получению записей о заявках на курьера: 
-- static function get() --получение списка заявок
--    {
--         $pdo = Di::pdo();
--         $stmt = $pdo->prepare('SELECT * FROM get_courier()');
--         $stmt->execute();
--         $data = $stmt->fetchAll();
--         return $data;
--     }
-- Нужно реализовать функцию get_courier(), которая возвращает таблицу согласно следующей структуры:
-- id --идентификатор заявки
-- from_place --откуда
-- where_place --куда
-- name --название документа
-- account_id --идентификатор контрагента
-- account --название контрагента
-- contact_id --идентификатор контакта
-- contact --фамилия и имя контакта через пробел
-- description --описание
-- user_id --идентификатор сотрудника
-- user --фамилия и имя сотрудника через пробел
-- status --статус заявки
-- created_date --дата создания заявки
-- Сортировка результата должна быть сперва по статусу, затем по дате от большего к меньшему.
-- Важно! Если названия столбцов возвращаемой функцией таблицы 
-- будут отличаться от указанных выше, то приложение работать не будет.
drop function if exists get_courier();
create or replace function get_courier()
returns table (id uuid, from_place varchar, where_place varchar, "name" varchar, account_id uuid, account varchar, contact_id uuid, contact varchar, description text, user_id uuid, "user" varchar, status courier_status, created_date date) 
as $$
begin
  return query
  select 
    c.id,
    c.from_place,
    c.where_place,
    c.name,
    c.account_id,
    a.name,
    c.contact_id,
    concat_ws(' ', cn.last_name, cn.first_name)::varchar,
    c.description,
    c.user_id,
    concat_ws(' ', u.last_name, u.first_name)::varchar,
    c.status,
    c.created_date
  from courier c
  join account a on c.account_id = a.id
  join contact cn on c.contact_id = cn.id
  join "user" u on c.user_id = u.id
  order by c.status,
  -- status type = courier_status, поэтому сортировка выполнится по индексу списка enum;
  created_date desc;
end;
$$ language plpgsql;
--проверка get_courier()
select * from get_courier();

-- =================================================================================
-- 10. На бэкенде реализована функция по изменению статуса заявки.
-- function change_status($params) --изменение статуса заявки
--     {
--         $pdo = Di::pdo();
--         $status = $params["new_status"];
--         $id = $params["id"];
--         $stmt = $pdo->prepare('CALL change_status(?, ?)');
--         $stmt->bindParam(1, $status); --новый статус
--         $stmt->bindParam(2, $id); --идентификатор заявки
--         $stmt->execute();
--     }
-- Нужно реализовать процедуру change_status(status, id), 
-- которая будет изменять статус заявки. 
-- На вход процедура принимает новое значение статуса и 
-- значение идентификатора заявки.
drop procedure if exists change_status(courier_status, uuid);
create or replace procedure change_status(status_new courier_status, id_current uuid)
as $$
begin	
	--raise notice 'id %', id_current;
	--raise notice 'old status %', (select status from courier where id = id_current limit 1);
	if (status_new is not null or id_current is not null) and exists (select id from courier where id = id_current)
	  then update courier set status = status_new where id = id_current;
	elseif not exists (select id from courier where id = id_current)
	  then raise warning 'courier.id = % is not exists', id_current ;
	else
	  raise exception 'status % or id % is not be null', status_new, id_current;	
	end if;
    --raise notice 'new status %', (select status from courier where id = id_current limit 1);
end;
$$ language plpgsql;
--проверка change_status()
call change_status(gen_status(), 'cd55aea2-c623-465a-80dc-2214802757ea'); -- id_current is not exists;
call change_status(gen_status(), get_table_row_id('courier')); -- id_current is exists;

-- =================================================================================
-- 11. На бэкенде реализована функция получения списка сотрудников компании.
-- static function get_users() --получение списка пользователей
--    {
--         $pdo = Di::pdo();
--         $stmt = $pdo->prepare('SELECT * FROM get_users()');
--         $stmt->execute();
--         $data = $stmt->fetchAll();
--         $result = [];
--         foreach ($data as $v) {
--             $result[] = $v['user'];
--         }
--         return $result;
--     }
-- Нужно реализовать функцию get_users(), которая 
-- возвращает таблицу согласно следующей структуры:
-- user: --фамилия и имя сотрудника через пробел 
-- Сотрудник должен быть действующим! 
-- Сортировка должна быть по фамилии сотрудника.

drop function if exists get_users();
create or replace function get_users()
returns table ("user" varchar) 
as $$
begin
	return query
	select concat_ws(' ', last_name, first_name)::varchar
	from "user"
	where dismissed is false
	order by last_name;
end;
$$ language plpgsql;
-- проверка get_users()
select * from get_users();

-- =================================================================================
-- 12. На бэкенде реализована функция получения списка контрагентов.
-- static function get_accounts() --получение списка контрагентов
--     {
--         $pdo = Di::pdo();
--         $stmt = $pdo->prepare('SELECT * FROM get_accounts()');
--         $stmt->execute();
--         $data = $stmt->fetchAll();
--         $result = [];
--         foreach ($data as $v) {
--             $result[] = $v['account'];
--         }
--         return $result;
--     }
-- Нужно реализовать функцию get_accounts(), 
-- которая возвращает таблицу согласно следующей структуры:
-- account --название контрагента 
-- Сортировка должна быть по названию контрагента.
drop function if exists get_accounts();
create or replace function get_accounts()
returns table (account varchar) 
as $$
begin
	return query
	select "name"
	from account
	order by "name";
end;
$$ language plpgsql;
--проверка get_accounts()
select * from get_accounts();

-- =================================================================================
-- 13. На бэкенде реализована функция получения списка контактов.
-- function get_contacts($params) -- получение списка контактов
--     {
--         $pdo = Di::pdo();
--         $account_id = $params["account_id"]; 
--         $stmt = $pdo->prepare('SELECT * FROM get_contacts(?)');
--         $stmt->bindParam(1, $account_id); -- идентификатор контрагента
--         $stmt->execute();
--         $data = $stmt->fetchAll();
--         $result = [];
--         foreach ($data as $v) {
--             $result[] = $v['contact'];
--         }
--         return $result;
--     }
-- Нужно реализовать функцию get_contacts(account_id), 
-- которая принимает на вход идентификатор контрагента и 
-- возвращает таблицу с контактами переданного контрагента 
-- согласно следующей структуры:
-- contact -- фамилия и имя контакта через пробел 
-- Сортировка должна быть по фамилии контакта. Если в функцию вместо идентификатора контрагента передан null, нужно вернуть строку 'Выберите контрагента'.

drop function if exists get_contacts(uuid);
create or replace function get_contacts(contact_account_id uuid default null)
returns table (contact varchar)
as $$
begin
	if contact_account_id is null
		then 
			return query
			select 'Выберите контрагента'::varchar;
	else
		return query
		select concat_ws(' ', last_name, first_name)::varchar
		from contact
		where account_id = contact_account_id
		order by last_name;
	end if;
end;
$$ language plpgsql;
--проверка get_contacts()
select * from get_contacts(get_table_row_id('account'));
select * from get_contacts();

-- =================================================================================
-- 14. На бэкенде реализована функция по получению статистики о заявках на курьера: 
-- static function get_stat() --получение статистики
--     {
--         $pdo = Di::pdo();
--         $stmt = $pdo->prepare('SELECT * FROM courier_statistic');
--         $stmt->execute();
--         $data = $stmt->fetchAll();
--         return $data;
--     }
-- Нужно реализовать представление courier_statistic, со следующей структурой:
-- account_id --идентификатор контрагента
-- account --название контрагента
-- count_courier --количество заказов на курьера для каждого контрагента
-- count_complete --количество завершенных заказов для каждого контрагента
-- count_canceled --количество отмененных заказов для каждого контрагента
-- percent_relative_prev_month -- процентное изменение количества заказов текущего месяца к предыдущему месяцу для каждого контрагента, если получаете деление на 0, то в результат вывести 0.
-- count_where_place --количество мест доставки для каждого контрагента
-- count_contact --количество контактов по контрагенту, которым доставляются документы
-- cansel_user_array --массив с идентификаторами сотрудников, по которым были заказы со статусом "Отменен" для каждого контрагента
--===

drop view if exists courier_statistic;

create or replace view courier_statistic as
with cansel_user_array as (
  select account_id, array_agg(distinct case when c.status = 'Отменен'::courier_status then c.user_id end) cansel_user_array
  from courier c
  where c.status = 'Отменен'::courier_status
  group by account_id
), 
count_contact as (
  select account_id , count(distinct contact_id) count_contact
  from courier c
  group by account_id
),
count_courier as (
  select account_id, count(case when c.status = 'Выполняется'::courier_status THEN 1 END) count_courier
  from courier c
  group by account_id
),
count_complete as (
  select account_id, count(case when c.status = 'Выполнено'::courier_status THEN 1 END) count_complete
  from courier c
  group by account_id
),
count_canceled as (
  select account_id, count(case when c.status = 'Отменен'::courier_status THEN 1 END) count_canceled
  from courier c
  group by account_id
),
count_where_place as (
  select account_id, count(distinct c.where_place) count_where_place
  from courier c
  group by account_id
),
percent_relative_prev_month as (
  select  
  account_id,
  date_trunc('month', c.created_date) created_month,
  coalesce (
    (round(
      count(c.id)::numeric/lag(count(c.id)::numeric,1) over (partition by c.account_id order by date_trunc('month', c.created_date)::date)
     ,4)-1)*100 
  ,0) percent_relative_prev_month
  from courier c
  group by c.account_id, created_month
  order by account_id, created_month
)
select 
	c.account_id,
	a."name" account
	, c2.count_courier
	, c3.count_complete
	, c4.count_canceled
	, p.percent_relative_prev_month
	, c5.count_where_place
	, c6.count_contact
	, u.cansel_user_array
from courier c 
join account a on c.account_id = a.id 
left join count_courier c2 on c2.account_id = c.account_id
left join count_complete c3 on c3.account_id = c.account_id
left join count_canceled c4 on c4.account_id = c.account_id
left join percent_relative_prev_month p on p.account_id = c.account_id and p.created_month = date_trunc('month', c.created_date)::date
left join count_where_place c5 on c5.account_id = c.account_id
left join count_contact c6 on c6.account_id = c.account_id
left join cansel_user_array u on u.account_id = c.account_id
group by c.account_id , a."name", c2.count_courier, c3.count_complete, c4.count_canceled
    , p.percent_relative_prev_month, c5.count_where_place, c6.count_contact, u.cansel_user_array
order by c.account_id
;
-- проверка courier_statistic;
select * from courier_statistic;