show lc_collate;

--=== МОДУЛЬ 1. Командная строка. DCL и TCL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ HR ===========
SET search_path TO hr;

--=== Задание 2. Работа с пользователями
-- 2.1. Создайте нового пользователя MyUser, которому разрешен вход, но не задан пароль и права доступа.  
create role "MyUser" with
  login
;

-- 2.2. Задайте пользователю MyUser любой пароль сроком действия до последнего дня текущего месяца.
--   use FORMAT('text with params %I %L', param[0],..,param[n]):
--    quote_ident() == %I 
--    quote_literal() == %L

do $$
  declare
    userName text = 'MyUser';
	passwd varchar = (select md5(random()::text));
    end_of_month date = (select (date_trunc('month', now()) + interval '1 month - 1 day')::date);
  begin
   if exists (SELECT * FROM pg_catalog.pg_roles WHERE rolname = userName) then
     execute format('ALTER ROLE %I WITH PASSWORD %L VALID UNTIL %L', userName, passwd,end_of_month);
   end if;
     end;
$$ language plpgsql;

-- 2.3. Дайте пользователю MyUser права на чтение данных из двух любых таблиц восстановленной базы данных. 

grant usage on schema hr to "MyUser";
grant select on address to "MyUser";
grant select on city to "MyUser";

select * from address limit 5;

-- 2.4. Заберите право на чтение данных ранее выданных таблиц  

revoke all on all tables in schema hr from "MyUser" cascade;

-- 2.5. Удалите пользователя MyUser.  

reassign owned by "MyUser" to postgres;
drop owned by "MyUser";
drop role "MyUser";

--=== Задание 3. Работа с транзакциями =====================
-- 3.1. Начните транзакцию
begin

-- 3.2. Добавьте в таблицу projects новую запись
INSERT INTO hr.projects (project_id,"name",employees_id,amount,assigned_id,created_at)
  select max(project_id)+1 ,'ТМК (Агентский договор)','{392,969,551,448}',1024.00,516,now() from hr.projects;
 
-- 3.3. Создайте точку сохранения
savepoint sp_33;

-- 3.4. Удалите строку, добавленную в п.3.2
delete from hr.projects
where project_id in (select max(project_id)+1 from hr.projects)
;
-- 3.5. Откатитесь к точке сохранения
rollback to sp_33;

-- 3.6. Завершите транзакцию
commit;
