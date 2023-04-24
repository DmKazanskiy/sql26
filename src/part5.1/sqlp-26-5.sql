select *
from pg_catalog.pg_available_extensions 
where installed_version is not null

create extension postgres_fdw

local 	foreign
S 		SIUD	

SIUD	S

create server pfdw 
foreign data wrapper postgres_fdw
options (host '51.250.106.132', port '19001', dbname 'workplace')

create user mapping for postgres
server pfdw
options (user 'netology', password 'NetoSQL2019')

create foreign table out_temp_pfdw (
	id int,
	val text,
	created_at timestamp default now())
server pfdw
options (schema_name 'nkh', table_name 'temp_pfdw')

drop foreign table out_temp_pfdw

select * 
from out_temp_pfdw

insert into out_temp_pfdw(id, val)
values (2, 'b')

select *
from "language" l
join out_temp_pfdw x on x.id = l.language_id

import foreign schema public limit to (payment, rental)
from server pfdw into pfdw_test

select c.customer_id, sum(amount), count(r.rental_id)
from customer c
join pfdw_test.payment p on c.customer_id = p.customer_id
join pfdw_test.rental r on r.rental_id = p.rental_id
group by c.customer_id

select *
from pg_catalog.pg_available_extensions 
where installed_version is not null

create extension file_fdw

create server file_fdw_temp
foreign data wrapper file_fdw

select * 
from customer c

CREATE foreign TABLE csv_file (
	customer_id int NOT NULL,
	store_id int2 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(50) NULL,
	address_id int2 NULL,
	activebool bool NOT NULL,
	create_date date NOT NULL,
	last_update timestamp NULL,
	active int4 NULL)
server file_fdw_temp
options (filename 'c:\1\some_csv.csv', format 'csv', delimiter ';', header 'true')

select c.customer_id, sum(amount), count(r.rental_id)
from csv_file c
join pfdw_test.payment p on c.customer_id = p.customer_id
join pfdw_test.rental r on r.rental_id = p.rental_id
group by c.customer_id

select *
from pg_catalog.pg_available_extensions 
where installed_version is not null

select *
from flights f

departure_airport 321, cn1 ... Итого
dme					50
led					10
Итого

select pg_typeof(coalesce(da, 'Итого')), pg_typeof(coalesce(ac, 'Итого')), pg_typeof(count::int)
from (
	select departure_airport da, aircraft_code ac, count(*)
	from flights 
	group by cube(1, 2)
	order by 1, 2) t

select distinct aircraft_code 
from flights 
order by 1
	
select *
from hr_for_check.crosstab($$
	select coalesce(da, 'Итого')::text, coalesce(ac, 'Итого')::text, count::int
	from (
		select departure_airport da, aircraft_code ac, count(*)
		from flights 
		group by cube(1, 2)
		order by 1, 2) t $$) as cst ("Аэропорт вылета" text, "319" int, "321" int, "733" int,
			"763" int, "773" int, "CN1" int, "CR2" int, "SU9" int, "Итого" int)

select * 
from (
	select distinct aircraft_code 
	from flights 
	order by 1) t
union all
select 'Итого'
			
select "Аэропорт вылета", coalesce("319", 0), coalesce("321", 0), coalesce("733", 0),
		coalesce("763", 0), coalesce("773", 0), coalesce("CN1", 0), coalesce("CR2", 0), 
		coalesce("SU9", 0), coalesce("Итого", 0)
from hr_for_check.crosstab($$
	select coalesce(da, 'Итого')::text, coalesce(ac, 'Итого')::text, count::int
	from (
		select departure_airport da, aircraft_code ac, count(*)
		from flights 
		group by cube(1, 2)
		order by 1, 2) t $$,
	$$select * 
	from (
		select distinct aircraft_code 
		from flights 
		order by 1) t
	union all
	select 'Итого' $$) as cst ("Аэропорт вылета" text, "319" int, "321" int, "733" int,
		"763" int, "773" int, "CN1" int, "CR2" int, "SU9" int, "Итого" int)
		
select x::text
from generate_series(1,12,1) x
order by 1

create type airport_otchet as (
	"Аэропорт вылета" text, 
	"319" int, 
	"321" int, 
	"733" int,
	"763" int, 
	"773" int, 
	"CN1" int, 
	"CR2" int, 
	"SU9" int, 
	"Итого" int	)
	
create function airport_otchet_total(text)
returns setof airport_otchet
as '$libdir/tablefunc', 'crosstab' language c stable strict

select *
from airport_otchet_total($$
	select coalesce(da, 'Итого')::text, coalesce(ac, 'Итого')::text, count::int
	from (
		select departure_airport da, aircraft_code ac, count(*)
		from flights 
		group by cube(1, 2)
		order by 1, 2) t $$)
		
create function airport_otchet_total(text, text)
returns setof airport_otchet
as '$libdir/tablefunc', 'crosstab_hash' language c stable strict

select "Аэропорт вылета", coalesce("319", 0), coalesce("321", 0), coalesce("733", 0),
		coalesce("763", 0), coalesce("773", 0), coalesce("CN1", 0), coalesce("CR2", 0), 
		coalesce("SU9", 0), coalesce("Итого", 0)
from airport_otchet_total($$
	select coalesce(da, 'Итого')::text, coalesce(ac, 'Итого')::text, count::int
	from (
		select departure_airport da, aircraft_code ac, count(*)
		from flights 
		group by cube(1, 2)
		order by 1, 2) t $$,
	$$select * 
	from (
		select distinct aircraft_code 
		from flights 
		order by 1) t
	union all
	select 'Итого' $$) 
	
	
select *
from "structure" s

explain analyze --86.14 / 0.125
with recursive r as (
	select *, 1 as level
	from "structure" 
	where unit_id = 59
	union 
	select s.*, level + 1 as level
	from r 
	join "structure" s on r.parent_id = s.unit_id)
select *
from r

explain analyze --21.71 / 0.270
select s.*, level
from hr_for_check.connectby('structure', 'parent_id', 'unit_id', '59', 0, '~') 
	as cb (parent_id int, unit_id int, level int, branch text)
join "structure" s on s.unit_id = cb.unit_id

select *
from pg_catalog.pg_available_extensions 
where installed_version is not null

create extension pg_stat_statements

select *
from pg_stat_statements pss

do $$
begin 
	for i in 1..1000000
	loop
		insert into b 
		values ('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя',
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя',
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 
		'абвгдеёжзийклмнопрстуфхцчшщьыъэюя');
	
725 007 029

select 725007029 / 1024 / 1024

	end loop;
end;
$$ language plpgsql

1000 		- 100
100 000 	- 1000
1 000 000 	- 2000
5 000 000 	- 3000
5 000 001	- 3001  1 / 66644477 / 6000000

explain 
select * from b 
order by random()

select departure_airport, a1.latitude as x, arrival_airport, a2.longitude as y, 
(acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) +cos(radians(a1.latitude))*
cos(radians(a2.latitude))*cos(radians(a1.longitude - a2.longitude)))*6371)::integer as "Расстояние", range
from 
	(select distinct departure_airport, arrival_airport, aircraft_code 
	from flights) as foo
join airports a1 on foo.departure_airport = a1.airport_code
join airports a2 on foo.arrival_airport = a2.airport_code
join aircrafts on aircrafts.aircraft_code = foo.aircraft_code
order by arrival_airport

SELECT DISTINCT f.departure_city, f.arrival_city, 
	ST_DISTANCESPHERE(ST_MAKEPOINT(a1.longitude, a1.latitude), 
		ST_MAKEPOINT(a2.longitude, a2.latitude))/1000
FROM flights_v f
JOIN airports a1 ON f.departure_airport = a1.airport_code
JOIN airports a2 ON f.arrival_airport = a2.airport_code;


SELECT ST_AREA(
	ST_TRANSFORM(
		ST_GEOMFROMTEXT('POLYGON((37.547897 55.718520, 37.549551 55.717563, 37.550541 55.718105, 
			37.548887 55.719085, 37.547897 55.718520))',4326)
	,31467)
) AS sqm;

1		2
				3
					
6			4
		

	5
	
1, 2, 3, 4, 5, 6, 1

select *
from planet_osm_polygon

CREATE TABLE cities(
	id serial PRIMARY KEY, 
	city_name varchar(100));

SELECT ADDGEOMETRYCOLUMN('cities', 'polygon', 4326, 'POLYGON', 2);

select * from cities

CREATE INDEX cities_idx ON cities USING gist(polygon);

INSERT INTO cities(city_name, polygon)
SELECT name, ST_TRANSFORM(way, 4326)
FROM planet_osm_polygon WHERE place = 'city';

select *
from cities

CREATE TABLE pubs(
	  id serial  PRIMARY KEY, 
	  pub_name varchar(150)
);

SELECT ADDGEOMETRYCOLUMN('pubs', 'point', 4326, 'POINT', 2);

CREATE INDEX pubs_idx ON pubs USING gist(point);

INSERT INTO pubs(pub_name, point)
SELECT name, ST_TRANSFORM(way, 4326)
FROM planet_osm_point
WHERE amenity = 'bar' AND name IS NOT NULL;

select * from pubs

SELECT pub_name, point, ST_GEOMFROMEWKT('SRID=4326;POINT(37.629923 55.787615)'),
  ST_DISTANCESPHERE(point, ST_GEOMFROMEWKT('SRID=4326;POINT(37.629923 55.787615)'))/1000 AS dist
FROM pubs
ORDER BY point <-> ST_GEOMFROMEWKT('SRID=4326;POINT(37.629923 55.787615 )')
LIMIT 5;


1
2
3
4
5
6
7
8
9
10

5
46
37
28
19