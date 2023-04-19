-- === Задание 1. Создайте подключение к удаленному облачному серверу базы HR 
-- (база данных postgres, схема hr), используя модуль postgres_fdw.

-- drop schema hr_foreign  cascade; 
create schema hr_foreign;
set search_path to hr_foreign, public;

-- =======
--drop extension if exists postgres_fdw cascade;
create extension postgres_fdw;

-- test
select * from pg_extension;
-- =======
--drop server if exists slave_db cascade;
create server slave_db
foreign data wrapper postgres_fdw
options (host '51.250.106.132', dbname 'postgres', port '19001');
-- test
select * from pg_foreign_server;

-- =======
create user mapping for postgres
server slave_db
options (user '**', password '**');
--test
select * from pg_user_mapping;

-- =======
import foreign schema hr limit to (city, address)
from server slave_db into hr_foreign;

-- =======
select * 
from hr_foreign.address
join hr_foreign.city using(city_id)
limit 10
;


-- Задание 2. С помощью модуля tablefunc получите из таблицы projects базы HR таблицу с данными, 
-- колонками которой будут: 
-- год, месяцы с января по декабрь, 
-- общий итог по стоимости всех проектов за год.
set search_path to hr;
create extension tablefunc;

select *
from crosstab (
	$$ 
	select
	  coalesce(year_created::text, 'Всего'),
	  coalesce(month_created, 13),
	  sum_total
	from (
	  select
	    extract('year' from created_at)::numeric as year_created,
		extract('month' from created_at)::numeric as month_created,
		sum(amount) as sum_total
	  from projects
	  group by cube(year_created, month_created)
	  order by year_created, month_created
	) dataset 
	$$,
	$$ 
	(select month_created from pg_catalog.generate_series(1, 13) month_created)
	$$
)
as ct(
    "Год\Месяц" text, "Январь" numeric, "Февраль" numeric, "Март" numeric,
	"Апрель" numeric, "Май" numeric, "Июнь" numeric,
	"Июль" numeric, "Август" numeric, "Сентябрь" numeric,
	"Октябрь" numeric, "Ноябрь" numeric, "Декабрь" numeric, "Итого" numeric
);

-- Задание 3. Настройте модуль pg_stat_statements на локальном сервере PostgresSQL и выполните несколько любых SQL-запросов к базе.
set search_path to hr;
create extension pg_stat_statements;

select * 
from employee
join person p using(person_id)
join "position" p2 using(pos_id)
;

select userid, dbid, queryid, query, calls, total_exec_time, min_exec_time, max_exec_time, stddev_exec_time
from pg_stat_statements
where query like '%employee%';
