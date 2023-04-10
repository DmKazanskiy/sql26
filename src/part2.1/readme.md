# **Модуль 2. Домашнее задание по теме "Хранимые процедуры"**

**Преподаватель:** Николай Хащанов, Екатерина Волочаева

**Цель домашнего задания:**

-   закрепить навыки создания функций, процедур, триггеров в PostgreSQL

> Все задания следует выполнять в базе данных HR

**Задание 1. Напишите функцию, которая принимает на вход название должности (например, стажер), а также даты периода поиска, и возвращает количество вакансий, опубликованных по этой должности в заданный период.**

```sql
create or replace function vacancies_cnt(
  vac_title_name text, -- полное наименование должности
  ds date, -- date_start дата начала периода
  de date, -- date_end дата окончания период
  out vac_title_cnt int4 -- количество опубликованных должностей за период c ds по de
) as
$$
begin
  if ds is null or de is null
    then raise exception 'Одна из дат отсутствует';
  elseif ds::date > de::date
    then raise exception 'Дата начала больше чем дата окончания';
  else
    select count(vac_title) cnt
    from vacancy
    where vac_title like vac_title_name --'%' || vac_title_name || '%'
      and create_date between ds::date and de::date
    into vac_title_cnt;
  end if;
end;
$$ language plpgsql;
```


**Задание 2. Напишите триггер, срабатывающий тогда, когда в таблицу position добавляется значение grade, которого нет в таблице-справочнике grade_salary. Триггер должен возвращать предупреждение пользователю о несуществующем значении grade.**

```sql
create or replace function grade_warning() returns trigger as 
$$
  begin
    if not exists (select * from grade_salary where grade = new.grade)
	  then raise warning 'exception: grade value % is not exist in grade_salary table', new.grade;
	  return null;
	else
	  raise warning 'success: grade value % exist in grade_salary table', new.grade;
	  return new;
	end if;
  end
$$ language plpgsql;
create or replace trigger position_grade_check
before insert or update on "position"
for each row execute function grade_warning();

-- проверка:
INSERT INTO hr."position" (pos_id,pos_title,pos_category,unit_id,grade,address_id,manager_pos_id) VALUES
	 (4611,'QA-инженер','',204,3,20,4568), -- row add to position
	 (4612,'QA-инженер','',204,8,20,4568), -- exception: grade value 8 is not exist in grade_salary table
	 (4613,'QA-инженер','',204,null,20,4568); -- exception: grade value <NULL> is not exist in grade_salary table
	 
```

**Задание 3. Создайте таблицу employee_salary_history с полями:**

-   emp_id - id сотрудника
-   salary_old - последнее значение salary (если не найдено, то 0)
-   salary_new - новое значение salary
-   difference - разница между новым и старым значением salary
-   last_update - текущая дата и время

```sql
create table employee_salary_history (
	emp_id integer NOT NULL,
	salary_old numeric default 0.00 NOT NULL,
	salary_new numeric NOT NULL,
 	difference numeric generated always as (salary_new - salary_old) stored NOT NULL,
 	last_update	TIMESTAMP NOT NULL
);
comment on column employee_salary_history.emp_id is 'id сотрудника';
comment on column employee_salary_history.salary_old is 'последнее значение salary (если не найдено, то 0)';
comment on column employee_salary_history.salary_new is 'новое значение salary';
comment on column employee_salary_history.difference is 'разница между новым и старым значением salary';
comment on column employee_salary_history.last_update is 'текущая дата и время';
```

Напишите триггерную функцию, которая срабатывает при добавлении новой записи о сотруднике или при обновлении значения salary в таблице employee_salary, и заполняет таблицу employee_salary_history данными.

```sql
create or replace function employee_salary_history_add() returns trigger as 
$$
  declare
	employee_id int4 = (select(coalesce(new.emp_id, 0.00)));
    salary_last numeric;
    salary_next numeric = (select(coalesce(new.salary, 0.00)));
  begin
    if TG_OP = 'INSERT' then
	  salary_last = (select coalesce((select salary_new from employee_salary_history
	    where emp_id = new.emp_id
	    order by last_update desc, salary_old desc
	    limit 1),0.00)
      );
    elseif TG_OP = 'UPDATE' then
  	  salary_last = old.salary;
    end if;  
  	insert into employee_salary_history(emp_id, salary_old, salary_new, last_update) values
	  (employee_id, salary_last, salary_next, now());  	
    return null;
  end   
$$ language plpgsql;
create or replace trigger employee_salary_control
after insert or update on "employee_salary"
for each row execute function employee_salary_history_add();
```

**Проверка INSERT:**
```sql
insert into employee_salary(order_id, emp_id, salary, effective_from) values
  (50,11,19893,'2015-01-01'::date),
  (51,11,10366,'2016-02-01'::date),
  (52,8,3000,'2018-09-01'::date),
  (53,8,19826,'2019-01-01'::date)
;
```

**employee_salary(before)**
| order_id|emp_id|salary|effective_from |
|---|---|---|---|
| 25024|11|9893.00|2014-06-10|
| 25023	|11|12366.00|2016-01-01|
| 25017	|8|9826.00|2018-09-17|
| 25016|8|12130.00|2020-01-01|

**employee_salary(after)**
| order_id|emp_id|salary|effective_from |
|---|---|---|---|
|25024|11|9893.00|2014-06-10|
|50|11|19893.00|2015-01-01|
|25023|11|12366.00|2016-01-01|
|51|11|10366.00|2016-02-01|
|52|8|3000.00|2018-09-01|
|25017|8|9826.00|2018-09-17|
|53|8|19826.00|2019-01-01|
|25016|8|12130.00|2020-01-01|

**employee_salary_history(after)**
|emp_id|salary_old|salary_new|difference|last_update|
|---|---|---|---|---|
|11|0.00|19893.00|10000.00|2023-04-07 16:09:23.622|
|11|19893.00|10366.00|-9527.00|2023-04-07 16:09:23.622|
|8|0.00|3000.00|3000.00|2023-04-07 16:09:23.622|
|8|3000.00|19826.00|16826.00|2023-04-07 16:09:23.622|

**Проверка UPDATE:**
```sql
update employee_salary
  set salary = 20000
  where (emp_id = 11 and effective_from = '2016-01-01'::date)
  or (emp_id = 8 and effective_from = '2018-09-17'::date)
;
```

**employee_salary(before)**
| order_id|emp_id|salary|effective_from |
|---|---|---|---|
|25024|11|9893.00|2014-06-10|
|50|11|19893.00|2015-01-01|
|25023|11|12366.00|2016-01-01|
|51|11|10366.00|2016-02-01|
|52|8|3000.00|2018-09-01|
|25017|8|9826.00|2018-09-17|
|53|8|19826.00|2019-01-01|
|25016|8|12130.00|2020-01-01|

**employee_salary_history(before)**
|emp_id|salary_old|salary_new|difference|last_update|
|---|---|---|---|---|
|11|9893.00|19893.00|10000.00|2023-04-07 16:09:23.622|
|11|12366.00|10366.00|-2000.00|2023-04-07 16:09:23.622|
|8|0.00|3000.00|3000.00|2023-04-07 16:09:23.622|
|8|9826.00|19826.00|10000.00|2023-04-07 16:09:23.622|


**employee_salary(after)**
| order_id|emp_id|salary|effective_from|
|---|---|---|---|
|25024|11|9893.00|2014-06-10|
|50|11|19893.00|2015-01-01|
|25023|11|20000.00|2016-01-01|
|51|11|10366.00|2016-02-01|
|52|8|3000.00|2018-09-01|
|25017|8|20000.00|2018-09-17|
|53|8|19826.00|2019-01-01|
|25016|8|12130.00|2020-01-01|

**employee_salary_history(after)**
|emp_id|salary_old|salary_new|difference|last_update|
|---|---|---|---|---|
|11|9893.00| 19893.00|10000.00|2023-04-07 16:09:23.622|
|11|12366.00|10366.00|-2000.00|2023-04-07 16:09:23.622|
|8|0.00|3000.00|3000.00|2023-04-07 16:09:23.622|
|8|9826.00|19826.00|10000.00|2023-04-07 16:09:23.622| 
|8|9826.00|20000.00|10174.00|2023-04-07 16:18:34.448|
|11|12366.00|20000.00|7634.00|2023-04-07 16:18:34.448|



**Задание 4. Напишите процедуру, которая содержит в себе транзакцию на вставку данных в таблицу employee_salary. Входными параметрами являются поля таблицы employee_salary**

```sql
create or replace procedure employee_salary_trn_data_ins(orderid int4, emp int4,salary numeric(12,2), effective_from date) as 
$$ 
begin
  if exists (select * from employee_salary where emp_id = emp) 
  and not exists(select * from employee_salary where order_id = orderid) then 
    insert into employee_salary values
	  (orderid, emp,salary, effective_from);
    commit;
  else
    raise warning 'insert error: employee id=% not exist or order_id=% exist', emp, orderid;
  end if;
end
$$ language plpgsql;
```

Проверка - успех:

```sql
call employee_salary_trn_data_ins(61,2,12926.00, (now()+interval '1 day')::date);
```

Проверка - ошибка:

```sql
call employee_salary_trn_data_ins(61,2,12926.00, (now()+interval '2 day')::date);
```

```bash
insert error: employee id=2 not exist or order_id=61 exist
```