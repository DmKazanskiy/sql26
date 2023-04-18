
drop schema if exists flowers_delivery_db cascade;
create schema flowers_delivery_db;
set search_path to flowers_delivery_db;

-- DROP TABLE IF EXISTS cities CASCADE;
create table if not exists cities (
	city_id serial primary key,
	city varchar(50) not null
);
-- DROP TABLE IF EXISTS addresses CASCADE;
create table if not exists addresses (
	address_id serial primary key,
	zipcode varchar(10),
	address varchar(50) not null,
	city_id int4 not null,
	address_str varchar generated always as (address || ' ' || zipcode) stored not null
);

-- DROP TABLE IF EXISTS partners CASCADE;
CREATE TABLE partners (
	partner_id int4 primary key,
	partner_name varchar,
	address_id int4,
	phone varchar,
	company_details varchar,
	created timestamp default current_timestamp
);
-- DROP TABLE IF EXISTS prices CASCADE;
CREATE TABLE prices (
	price_id int4 primary key,
	product_id int4,
	price_netto NUMERIC (20,2) DEFAULT 0.00,
	price_brutto NUMERIC (20,2) DEFAULT 0.00,
	date_changed date,
	created timestamp default current_timestamp
);

-- DROP TABLE IF EXISTS stores CASCADE;
CREATE TABLE stores (
	store_id int4 primary key,
	address_id int4,
	capacity NUMERIC,
	created timestamp default current_timestamp
);

-- DROP TABLE IF EXISTS  CASCADE;
CREATE TABLE customers (
	customers_id int4 primary key,
	address_id int4,
	nickname varchar,
	phone varchar,
	created timestamp default current_timestamp
);

-- DROP TABLE IF EXISTS  CASCADE;
CREATE TABLE staff (
	staff_id int4 primary key,
	staff_address varchar,
	staff_nickname varchar,
	staff_phone varchar,
	staff_position varchar,
	staff_salary NUMERIC,
	created timestamp default current_timestamp
);

-- DROP TABLE IF EXISTS  CASCADE;
CREATE TABLE products (
	product_id int4 primary key,
	partner_id int4 NOT null,	
	product_type varchar,
	created timestamp default current_timestamp
);
-- DROP TABLE IF EXISTS supplies CASCADE;
CREATE TABLE supplies (
	supply_id int4 primary key,
	product_id int4,
	partner_id int4 NOT null,	
	quantity int4 DEFAULT 0,
	store_id int4,	
	capacity NUMERIC,
	date_delivery date,
	best_before int4,
	created timestamp default current_timestamp
);
-- DROP TABLE IF EXISTS cities CASCADE;
create table if not exists products_stores (
	product_store_id int4 primary key,
	product_id int4 not null,
	store_id int4 not null
);


-- DROP TABLE IF EXISTS  CASCADE;
CREATE TABLE sources_sale (
	source_id int4 primary key,
	source_sale_name varchar,
	created timestamp default current_timestamp
);

CREATE TYPE status_enum AS enum ('created', 'queue', 'accepted', 'delivered', 'canceled', 'exception', 'returning');

-- DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
	orders_id serial primary key,
	customers_id int4,
	product_id int4,
	quantity int4,
	amount NUMERIC (20,2),
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
-- DROP TABLE IF EXISTS supplies_history CASCADE;
CREATE TABLE supplies_history (
    supplies_history_id serial primary key,
	product_id int4,
	partner_id int4 NOT null,
	price_netto NUMERIC (20,2) DEFAULT 0.00,
	price_brutto NUMERIC (20,2) DEFAULT 0.00,
	quantity int4 DEFAULT 0,
	capacity NUMERIC,
	date_delivery date,
	product_type varchar,
	store_id int4 NOT null,
	created timestamp default current_timestamp
);

CREATE TABLE orders_history (
	orders_history_id serial primary key,
	orders_id int4,
	customers_id int4,
	product_id int4,
	quantity int4,
	amount NUMERIC (20,2),
	staff_id int4,
	status_delivery status_enum,
	address_id varchar,
	source_id int4,
	date_created date default current_timestamp,
	date_completion date,
	created timestamp default current_timestamp
);
