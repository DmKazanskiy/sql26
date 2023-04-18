

set search_path to flowers_delivery_db;

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

COMMENT ON TABLE cities IS E'Список городов';
COMMENT ON COLUMN cities.city_id IS E'Идентификатор';
COMMENT ON COLUMN cities.city IS E'';

COMMENT ON TABLE addresses IS E'Список адресов';
COMMENT ON COLUMN addresses.address_id IS E'Идентификатор';
COMMENT ON COLUMN addresses.zipcode IS E'Индекс';
COMMENT ON COLUMN addresses.address IS E'Улица и номер дома';
COMMENT ON COLUMN addresses.city_id IS E'Идентификатор города';
COMMENT ON COLUMN addresses.address_str IS E'Улица с Индексом';

COMMENT ON TABLE partners IS E'Поставщики';
COMMENT ON COLUMN partners.partner_id IS E'Идентификатор поставщика';
COMMENT ON COLUMN partners.partner_name IS E'Наименование поставщика';
COMMENT ON COLUMN partners.address_id IS E'ID Адреса поставщика';
COMMENT ON COLUMN partners.phone IS E'Телефон поставщика';
COMMENT ON COLUMN partners.company_details IS E'Реквизиты компании';

COMMENT ON TABLE stores IS E'Склады';
COMMENT ON COLUMN stores.store_id IS E'Идентификатор склада';
COMMENT ON COLUMN stores.address_id IS E'ID Адреса склада';
COMMENT ON COLUMN stores.capacity IS E'Вместимость склада в куб.м.';

COMMENT ON TABLE customers IS E'Клиенты';
COMMENT ON COLUMN customers.customers_id IS E'ID клиента';
COMMENT ON COLUMN customers.address_id IS E'ID Адреса клиента';
COMMENT ON COLUMN customers.nickname IS E'ФИО клиента';
COMMENT ON COLUMN customers.phone IS E'Телефон клиента для связи';

COMMENT ON TABLE staff IS E'Сотрудники';
COMMENT ON COLUMN staff.staff_id IS E'ID сотрудника';
COMMENT ON COLUMN staff.staff_address IS E'Адрес сотрудника';
COMMENT ON COLUMN staff.staff_nickname IS E'ФИО сотрудника';
COMMENT ON COLUMN staff.staff_phone IS E'Телефон сотрудника';
COMMENT ON COLUMN staff.staff_position IS E'Должность сотрудника';
COMMENT ON COLUMN staff.staff_salary IS E'Оклад сотрудника';


COMMENT ON TABLE prices IS E'Цены товаров';
COMMENT ON COLUMN prices.price_id IS E'ID записи установления цены';
COMMENT ON COLUMN prices.product_id IS E'ID товара';
COMMENT ON COLUMN prices.price_netto IS E'Цена товара без налога';
COMMENT ON COLUMN prices.price_brutto IS E'Цена товара итоговая';
COMMENT ON COLUMN prices.date_changed IS E'Дата изменения цены товара';

COMMENT ON TABLE products IS E'Товары';
COMMENT ON COLUMN products.product_id IS E'ID товара';
COMMENT ON COLUMN products.partner_id IS E'ID поставщика';
COMMENT ON COLUMN products.product_type IS E'Тип товара';

COMMENT ON TABLE supplies IS E'Поставки товаров';
COMMENT ON COLUMN supplies.supply_id IS E'ID поставки';
COMMENT ON COLUMN supplies.product_id IS E'ID товара';
COMMENT ON COLUMN supplies.partner_id IS E'ID партнера-поставщика';
COMMENT ON COLUMN supplies.quantity IS E'Количество';
COMMENT ON COLUMN supplies.store_id IS E'Идентификатор склада';
COMMENT ON COLUMN supplies.capacity IS E'Объем товара, куб.м.';
COMMENT ON COLUMN supplies.date_delivery IS E'Дата поставки';
COMMENT ON COLUMN supplies.best_before IS E'Срок хранения в днях с даты поставки';

COMMENT ON TABLE products_stores IS E'Таблица мест хранения товаров';
COMMENT ON COLUMN products_stores.product_store_id IS E'ID записи ';
COMMENT ON COLUMN products_stores.product_id IS E'ID товара';
COMMENT ON COLUMN products_stores.store_id IS E'Идентификатор склада';

COMMENT ON TABLE supplies_history IS E'История поставок Товаров';
COMMENT ON COLUMN supplies_history.supplies_history_id IS E'ID записи о поставке товара';
COMMENT ON COLUMN supplies_history.product_id IS E'ID поставки товара';
COMMENT ON COLUMN supplies_history.partner_id IS E'ID поставщика';
COMMENT ON COLUMN supplies_history.price_netto IS E'Цена без налога';
COMMENT ON COLUMN supplies_history.price_brutto IS E'Цена итоговая';
COMMENT ON COLUMN supplies_history.quantity IS E'Количество';
COMMENT ON COLUMN supplies_history.capacity IS E'Объем товара, куб.м.';
COMMENT ON COLUMN supplies_history.date_delivery IS E'Дата поставки';
COMMENT ON COLUMN supplies_history.product_type IS E'Тип товара';
COMMENT ON COLUMN supplies_history.store_id IS E'Идентификатор склада хранения';

COMMENT ON TABLE sources_sale IS E'Источники продаж';
COMMENT ON COLUMN sources_sale.source_id IS E'ID источника продаж';
COMMENT ON COLUMN sources_sale.source_sale_name IS E'Наименование источника продаж';

COMMENT ON TABLE orders IS E'Заказы';
COMMENT ON COLUMN orders.orders_id IS E'ID заказа';
COMMENT ON COLUMN orders.customers_id IS E'Идентификатор клиента';
COMMENT ON COLUMN orders.product_id IS E'Идентификатор товара';
COMMENT ON COLUMN orders.quantity IS E'Количество единиц товара';
COMMENT ON COLUMN orders.amount IS E'Сумма заказа, включая стоимость доставки';
COMMENT ON COLUMN orders.staff_id IS E'Идентификатор сотрудника ответственного за заказ';
COMMENT ON COLUMN orders.status_delivery IS E'Статус заказа';
COMMENT ON COLUMN orders.address_id IS E'ID Адреса доставки заказа';
COMMENT ON COLUMN orders.source_id IS E'ID источника продаж';
COMMENT ON COLUMN orders.comments IS E'Комментарии к заказу';
COMMENT ON COLUMN orders.date_created IS E'Дата создания заказа';
COMMENT ON COLUMN orders.date_completion IS E'Дата завершения заказа';
COMMENT ON COLUMN orders.store_id IS E'Идентификатор склада выдачи заказа';

COMMENT ON TABLE orders_history IS E'Заказы история';
COMMENT ON COLUMN orders_history.orders_history_id IS E'Идентификатор записи в истории заказаов';
COMMENT ON COLUMN orders_history.orders_id IS E'ID заказа';
COMMENT ON COLUMN orders_history.customers_id IS E'Идентификатор клиента';
COMMENT ON COLUMN orders_history.product_id IS E'Идентификатор товара';
COMMENT ON COLUMN orders_history.quantity IS E'Количество единиц товара';
COMMENT ON COLUMN orders_history.amount IS E'Сумма заказа, включая стоимость доставки';
COMMENT ON COLUMN orders_history.staff_id IS E'Идентификатор сотрудника ответственного за заказ';
COMMENT ON COLUMN orders_history.status_delivery IS E'Статус заказа';
COMMENT ON COLUMN orders_history.address_id IS E'ID Адреса доставки заказа';
COMMENT ON COLUMN orders_history.source_id IS E'ID источника продаж';
COMMENT ON COLUMN orders_history.date_created IS E'Дата создания заказа';
COMMENT ON COLUMN orders_history.date_completion IS E'Дата завершения заказа';
