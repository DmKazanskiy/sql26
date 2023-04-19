
drop schema if exists flowers_delivery_db cascade;
create schema flowers_delivery_db;
set search_path to flowers_delivery_db;

-- drop table if exists cities cascade;
create table if not exists cities (
	city_id serial primary key,
	city varchar(50) not null
);
-- drop table if exists addresses cascade;
create table if not exists addresses (
	address_id serial primary key,
	zipcode varchar(10),
	address varchar(50) not null,
	city_id int4 not null,
	address_str varchar generated always as (address || ' ' || zipcode) stored not null
);

-- drop table if exists partners cascade;
create table partners (
	partner_id int4 primary key,
	partner_name varchar,
	address_id int4,
	phone varchar,
	company_details varchar,
	created timestamp default current_timestamp
);
-- drop table if exists prices cascade;
create table prices (
	price_id int4 primary key,
	product_id int4,
	price_netto numeric (20,2) default 0.00,
	price_brutto numeric (20,2) default 0.00,
	date_changed date,
	created timestamp default current_timestamp
);

-- drop table if exists stores cascade;
create table stores (
	store_id int4 primary key,
	address_id int4,
	capacity numeric,
	created timestamp default current_timestamp
);

-- drop table if exists  cascade;
create table customers (
	customer_id int4 primary key,
	address_id int4,
	nickname varchar,
	phone varchar,
	created timestamp default current_timestamp
);

-- drop table if exists  cascade;
create table staff (
	staff_id int4 primary key,
	staff_address varchar,
	staff_nickname varchar,
	staff_phone varchar,
	staff_position varchar,
	staff_salary numeric,
	created timestamp default current_timestamp
);

-- drop table if exists  cascade;
create table products (
	product_id int4 primary key,
	partner_id int4 not null,	
	product_type varchar,
	created timestamp default current_timestamp
);
-- drop table if exists supplies cascade;
create table supplies (
	supply_id int4 primary key,
	partner_id int4 not null,	
	store_id int4,	
	capacity numeric,
	date_delivery date,
	best_before int4,
	created timestamp default current_timestamp
);

--=== Замечание 20230418 (2)
--- аналогично в таблице поставок, может быть поставлено несколько товаров в одной поставке одним поставщиком
--- Исправил - добавил таблицу связей Товары в Поставках
-- drop table if exists  cascade;
create table products_supplies (
	products_supplies_id int4 primary key,
	product_id int4 not null,
	supply_id int4 not null,
	quantity int4 default 0,
	capacity numeric  
);

-- drop table if exists cities cascade;
create table if not exists products_stores (
  product_store_id int4 primary key,
	product_id int4 not null,
	store_id int4 not null,
    quantity int4 default 0	
);

-- drop table if exists  cascade;
create table sources_sale (
	source_id int4 primary key,
	source_sale_name varchar,
	created timestamp default current_timestamp
);

create type status_enum as enum ('created', 'queue', 'accepted', 'delivered', 'canceled', 'exception', 'returning');

-- drop table if exists orders cascade;
create table orders (
	order_id serial primary key,
	customer_id int4,
	product_id int4,
	quantity int4,
	amount numeric (20,2),
	staff_id int4,
	status_delivery status_enum,
	address_id int4,
	source_id int4,
	comments varchar,
	date_created date default current_timestamp,
	date_completion date,
	store_id int4,
	created timestamp default current_timestamp
);
--=== Замечание 20230418 (1)
--- к одному заказу может относиться несколько товаров, в таблице orders сейчас не учтен этот момент
--- Исправил - добавил таблицу связей Заказы-Товары
-- drop table if exists products_orders cascade;
create table products_orders (
  product_order_id int4 primary key,
  product_id int4 not null,
  order_id int4 not null,
  quantity int4
);

-- drop table if exists supplies_history cascade;
create table supplies_history (
    supplies_history_id serial primary key,
	product_id int4,
	partner_id int4 not null,
	price_netto numeric (20,2) default 0.00,
	price_brutto numeric (20,2) default 0.00,
	quantity int4 default 0,
	capacity numeric,
	date_delivery date,
	product_type varchar,
	store_id int4 not null,
	created timestamp default current_timestamp
);

-- drop table if exists orders_history cascade;
create table orders_history (
	orders_history_id serial primary key,
	orders_id int4,
	customer_id int4,
	product_id int4,
	quantity int4,
	amount numeric (20,2),
	staff_id int4,
	status_delivery status_enum,
	address_id varchar,
	source_id int4,
	date_created date default current_timestamp,
	date_completion date,
	created timestamp default current_timestamp
);

-- Несколько замечаний, что стоит еще доработать, чтобы структура отвечала на условия задания:
--- к одному заказу может относиться несколько товаров, в таблице orders сейчас не учтен этот момент
--- аналогично в таблице поставок, может быть поставлено несколько товаров в одной поставке одним поставщиком