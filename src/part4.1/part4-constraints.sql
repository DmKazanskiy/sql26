set search_path to flowers_delivery_db;
---- adresses constraints
alter table addresses
  add constraint address_city_id_fk foreign key (city_id) references cities(city_id)
;

-- products constraints
alter table products
  add constraint products_partner_id_fk foreign key (partner_id) references partners(partner_id)
;
-- orders constraints
alter table orders
  add constraint orders_customer_id_fk foreign key (customer_id) references customers(customer_id), 
  add constraint  orders_staff_id_fk foreign key (staff_id) references staff(staff_id),
  add constraint  orders_source_id_fk foreign key (source_id) references sources_sale(source_id),
  add constraint  orders_address_id_fk foreign key (address_id) references addresses(address_id) 
;
-- partners constraints;
alter TABLE partners
  add constraint  partners_address_id_fk foreign key (address_id) references addresses(address_id)
;
-- stores constraints;
alter table stores
  add constraint  stores_address_id_fk foreign key (address_id) references addresses(address_id)
;
-- customers constraints
alter table customers
  add constraint  customers_address_id_fk foreign key (address_id) references addresses(address_id)
;
-- products_supplies constraints
alter table products_supplies
  add constraint  products_supplies_product_fk foreign key (product_id) references products(product_id),
  add constraint  products_supplies_store_fk foreign key (supply_id) references supplies(supply_id),
  add constraint  products_supplies_unique unique (product_id,supply_id)
;

-- products_orders constraints
alter table products_orders
  add constraint  products_orders_order_fk foreign key (order_id) references orders(order_id),
  add constraint  products_orders_product_fk foreign key (product_id) references products(product_id),
  add constraint  products_orders_unique unique (product_id,order_id)
;

-- products_stores constraints
alter table products_stores
  add constraint  products_stores_product_fk foreign key (product_id) references products(product_id),
  add constraint  products_stores_store_fk foreign key (store_id) references stores(store_id),
  add constraint  products_stores_unique unique (product_id,store_id)
;
-- prices constraints
alter table prices
  add constraint prices_product_id_fk foreign key (product_id) references products(product_id)
;

-- supplies
alter table supplies
  add constraint supplies_partner_id_fk foreign key (partner_id) references partners(partner_id),
  add constraint  supplies_store_fk foreign key (store_id) references stores(store_id)
;

