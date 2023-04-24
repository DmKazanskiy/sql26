admin

select * from customer 

select * from pg_catalog.pg_roles pr

create role netology with login password 'NetoSQL2019'

create database "sqlfree-4"

revoke all privileges on database "sqlfree-4" from netology

revoke all privileges on database "sqlfree-4" from public

grant connect on database "sqlfree-4" to netology

grant create on database "sqlfree-4" to netology

revoke all privileges on schema public from netology

revoke all privileges on schema public from public

revoke all privileges on schema pg_catalog from netology

revoke all privileges on schema pg_catalog from public

revoke all privileges on schema information_schema from public

revoke all privileges on schema information_schema from netology

grant usage on schema public to netology

grant usage on schema pg_catalog to netology

grant usage on schema information_schema to netology

revoke all on all tables in schema public from netology

revoke all on all tables in schema public from public

grant all on all tables in schema public to netology

grant select on all tables in schema information_schema to netology

grant select on all tables in schema pg_catalog to netology

grant insert, update on public.customer, public.payment to netology