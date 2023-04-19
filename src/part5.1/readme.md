# Домашнее задание «PostgreSQL Extensions»

**Преподаватель:** Николай Хащанов, Екатерина Волочаева

[SQL-запросы домашнего задания](part5.sql)

**Задание 1. Создайте подключение к удаленному облачному серверу базы HR (база данных postgres, схема hr), используя модуль postgres_fdw.**  

Напишите SQL-запрос на выборку любых данных используя 2 сторонних таблицы, соединенных с помощью JOIN.  

В качестве ответа на задание пришлите список команд, использовавшихся для настройки подключения, создания внешних таблиц, а также получившийся SQL-запрос.

```sql
create schema hr_foreign;
set search_path to hr_foreign, public;

create extension postgres_fdw;

create server slave_db
foreign data wrapper postgres_fdw
options (host '51.250.106.132', dbname 'postgres', port '19001');

create user mapping for postgres
server slave_db
options (user '*e****y', password '*e*****');

import foreign schema hr limit to (city, address)
from server slave_db into hr_foreign;
--- === (1)
select * 
from hr_foreign.address
join hr_foreign.city using(city_id)
limit 10
;
```

Результат работы запроса (1):
|city_id|address_id|full_address|postal_code|city|
|-------|----------|------------|-----------|----|
|1|1|Владимирская обл, г. Владимир, ул Кирова, д. 13Б|309777|Владимир|
|1|2|Владимирская обл, г. Владимир, ул Чайковского, д. 25А|360592|Владимир|
|2|3|Воронежская обл, г. Воронеж, ул Кирова, д. 3, кор. А|309777|Воронеж|
|3|4|Краснодарский край, г. Краснодар, ул Путевая, д. 1|383266|Краснодар|
|4|5|Москва г, ул Марксистская, д. 3|326125|Москва|
|4|6|Москва г, ул Новорязанская, д. 4|306358|Москва|
|4|7|Москва г, ул Новорязанская, д. 6|306358|Москва|
|5|8|Нижегородская обл, г. Нижний Новгород, пр-кт Гагарина, д. 136, кор. а|501961|Нижний Новгород|
|6|9|Новосибирская обл, г. Новосибирск, ул Фрунзе, д. 53/2|165754|Новосибирск|
|7|10|Приморский край, г. Владивосток, ул Нижнепортовая, д. 1|341333|Владивосток|


**Задание 2. С помощью модуля tablefunc получите из таблицы projects базы HR таблицу с данными, колонками которой будут: год, месяцы с января по декабрь, общий итог по стоимости всех проектов за год.**  

В качестве ответа на задание пришлите получившийся SQL-запрос.  
Ожидаемый результат: [letsdocode.ru...lp-5-2.png](https://letsdocode.ru/sql-main/sqlp-5-2.png)

```sql
set search_path to hr;
create extension tablefunc;

--- === (2)
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
```

Результат работы запроса (2):
|Год\Месяц|Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь|Итого|
|---------|------|-------|----|------|---|----|----|------|--------|-------|------|-------|-----|
|2018||1248809544.00||18078772.00|212402656.00|597974743.00|131515754.00|370893354.00|161434600.00|719667834.00|157036405.00|245303910.00|3863117572.00|
|2019|49269396.00|52571048.00|188510907.00|266755273.00|173232562.00|228671486.00|105716681.00|379531674.00|274681623.00|407918404.00|93794307.00|234736197.00|2455389558.00|
|2020|56114176.00|74093104.00|50976690.00||||||||||181183970.00|
|Всего|105383572.00|1375473696.00|239487597.00|284834045.00|385635218.00|826646229.00|237232435.00|750425028.00|436116223.00|1127586238.00|250830712.00|480040107.00|6499691100.00|


**Задание 3. Настройте модуль pg_stat_statements на локальном сервере PostgresSQL и выполните несколько любых SQL-запросов к базе.**  

В качестве ответа на задание пришлите скриншот со статистикой по выполненным запросам.

На сервере в `postgresql.conf` "включил" `pg_stat_statements` и перезапустил PostgreSQL:
```bash
# edit `./postgresql.conf` 
...
#
shared_preload_libraries = ‘pg_stat_statements’
...
```

```bash
systemctl restart postgresql
```


```sql
set search_path to hr;

CREATE EXTENSION pg_stat_statements;

--- === (3)
SELECT * 
FROM employee
join person p using(person_id)
join "position" p2 using(pos_id)
;

SELECT userid, dbid, queryid, query, calls, total_exec_time, min_exec_time, max_exec_time, stddev_exec_time
FROM pg_stat_statements
WHERE query LIKE '%employee%';
```


Статистика выполнения запроса (3):
|userid|dbid|queryid|query|calls|total_exec_time|min_exec_time|max_exec_time|stddev_exec_time|
|------|----|-------|-----|-----|---------------|-------------|-------------|----------------|
|10|13761|-575055565216760362|SELECT * FROM employee_salary es|2|0.531803|0.162861|0.368942|0.1030405|
|10|13761|2865105130469128819|SELECT x.* FROM hr.employee x|1|0.256715|0.256715|0.256715|0.0|
|10|13761|-5000999979659326283|SELECT * FROM employee join person p using(person_id) join "position" p2 using(pos_id)|1|5.017448|5.017448|5.017448|0.0|
