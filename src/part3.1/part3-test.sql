--=== Модуль 3. Тест для домашнего задания "Зависимости. Нормализация. Денормализация"
-- Для выполнения задания создана схема hr_mod3
set search_path to hr_mod3;

--- inserts or update

insert into cities values 
-- (city_id, city)
  (default,'Bradford'), 	--1
  (default,'Birmingham'), 	--2
  (default,'Bradford'),		--3
  (default,'Swansea')		--4
 ;

insert into addresses values 
-- (address_id, zipcode, address, city_id)
 (default, 'GL1', '72 Shaw Land Lake Holly',1),
 (default, 'BT60', '8 Row West Tonytown',2),
 (default, 'BS4', '40 Wood Isle Port',3),
 (default, 'M46', 'Studio 12 Way Lake',4),
 (default, 'HU14', '63 Knight Corn East',2),
 (default, 'LU7', '91 Davies Points New',2),
 (default, 'W1D', '113 Meadow Freyaview',3),
 (default, 'RM12', '625 Bailey Center',2),
 (default, 'BR6', '557 Harbours New Sally',4),
 (default, 'RM02', '001 leaders address',2)
;

insert into persons values
-- (person_id, first_name, last_name, birth_date, address_id)
  (1, 'Mary','Roberts','1975-07-15',1),
  (2, 'Oscar','Fowler','1988-11-01',2),
  (3, 'Everett','Garcia','1981-05-22',3),
  (4, 'John','Obrien','1978-03-31',4),
  (5, 'Linda','Smith','1989-07-07',5),
  (6, 'Leon','Mitchell','1900-01-01',10),
  (7, 'Sharon','Hunter','1900-01-01',10),
  (8,'Everett','Garcia','1900-01-01',10),
  (9, 'David','Morgan','1900-01-01',10),
  (10, 'William','Lewis','1900-01-01',10),
  (11, 'Charles','Johnson','1900-01-01',10)
;
insert into departments values
-- (dept_id, dept_name, address_id, actual)
	(default,'Design',7),
	(default,'Maintenance and Administration',7),
	(default,'IT Help Desk',8),
	(default,'Project Office',8),
	(default,'Software Development',9)
;

insert into positions values
-- (position_id, position_title, dept_id, actual)
	(default,'Graphic Designer', 1),
	(default,'Web Designer',2),
	(default,'Computer Programmer', 3),
	(default,'Project Manager', 4),
	(default,'Project Office Team Leader', 2),
	(default,'Web Application Developer', 5),
	(default,'Analyst', 5)
;

insert into leaders values
-- (lead_id, positions_id, person_id)
	(1, array[1], 6),
	(2, array[1,7], 7),
	(3, array[2,3,4], 8),
	(4, array[4], 9),
	(5, array[5], 10),
	(6, array[60], 11)
;

insert into employees values
-- (emp_id, person_id, email, position_id, salary, lead_id, actual)
	(1,1, 'MaryRoberts@default.com', 1,17000,1,'2020-04-01'),
	(2,1, 'MaryRoberts@default.com', 1,18500,2,'2020-04-02'),
	(3,1, 'MaryRoberts@default.com', 2,23500,3,'2020-04-03'),
	(4,2, 'OscarFowler@default.com', 3,19700,3,'2020-04-04'),
	(5,3, 'EverettGarcia@default.com', 4,12000,4,'2020-04-05'),
	(6,3, 'EverettGarcia@default.com', 5,27990,5,'2020-04-06'),
	(7,4, 'JohnObrien@default.com', 6,20100,6,'2020-04-07'),
	(8,5, 'LindaSmith@default.com', 4,14600,3,'2020-04-08'),
	(9,5, 'LindaSmith@default.com', 7,15900, 2,'2020-04-09')
;

insert into employees values
-- (emp_id, person_id, email, position_id, salary, lead_id, actual)
  (10,5, 'LindaSmith@default.com', 6,15900, 2,'2021-05-09')
;
update employees 
set salary = 23200
where emp_id = 7
;

update employees 
set actual = false
where emp_id = 7
;
-- в таблицу employees_history добавились 2 записи:
/*
|employees_history_id|person_id|position_id|salary|lead_person_id|dept_id|dept_address_id|date_changes|actual|created|
|--------------------|---------|-----------|------|--------------|-------|---------------|------------|------|-------|
| 1 | 4 | 6 | 23200.00|11|5|9|2020-04-07|true|2023-04-16 16:47:55.226|
| 2 | 4 | 6 | 23200.00|11|5|9|2020-04-07|false|2023-04-16 16:47:59.196|
*/