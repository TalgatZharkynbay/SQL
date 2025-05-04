
--------------------------------------------
create database practice_01;

--------------------------------------------
create table cafe_orders(
  order_id int primary key,
  product_name varchar(50) not null,
  state_code char(1) not null,
  created_time timestamp,
  price decimal(15,2) not null
);

--------------------------------------------
-- number
1
123.4
3.45

-- text
'some text'

"some text" -- not text!!!

-- date and time
-- timestamp
'2024-01-27 18:10:00'
'2024-01-27'
'18:10:00'
'2024-01-27 18:10:00 +03:00'


-- boolean
true
false
't'
'f'
'yes'
'no'

--------------------------------------------
-- read, select
select *
from public.cafe_orders;

-- create data, insert
insert into
	cafe_orders (order_id,
	product_name,
	state_code,
	created_time,
	price)
values(1000,
'latte',
'N',
'2024-01-27 18:10:05',
200);

-- delete
delete from cafe_orders where order_id = 1000;


-- change, update
update
	cafe_orders
set
	--product_name = '',
	state_code = 'P'
	/*,
	 * created_time = '',
	price = 0
	*/
where
	order_id = 133;


--------------------------------------------
CREATE TABLE driver(
	d_id int NOT NULL PRIMARY KEY,
	name varchar(50) NOT NULL,
	gender char(1) NOT NULL
);

drop table driver;

--------------------------------------------
CREATE TABLE driver(
	d_id int NOT NULL,
	name varchar(50) NOT NULL,
	gender char(1) NOT null,
	constraint driver_pk primary key (d_id)
);

--------------------------------------------
alter table driver
alter d_id
ADD GENERATED always AS identity;


--------------------------------------------
drop table driver;

CREATE TABLE driver(
	d_id int NOT null GENERATED always AS identity,
	name varchar(50) NOT NULL,
	gender char(1) NOT null,
	constraint driver_pk primary key (d_id)
);

--------------------------------------------
insert into driver(name, gender) 
values('Sophie', 'f'), 
('Ivan', 'm');

--------------------------------------------
CREATE TABLE car(
	c_id int NOT NULL PRIMARY KEY,
	make varchar(50) NOT NULL,
	year int NOT NULL,
	mileage int NOT NULL DEFAULT 0,
	cls_id char(1) NOT NULL,
	created_at timestamp default now()
);

--------------------------------------------
CREATE TABLE rental_class(
	cls_id char(1) NOT NULL PRIMARY KEY,
	capacity int NOT NULL,
	bags int NOT NULL,
	transmission char(1) NOT NULL
);


ALTER TABLE car 
ADD CONSTRAINT FK_car_rental_class_id
FOREIGN KEY(cls_id)
REFERENCES rental_class(cls_id);


--------------------------------------------
ALTER TABLE car 
drop CONSTRAINT FK_car_rental_class_id
;

ALTER TABLE car 
ADD CONSTRAINT FK_car_rental_class_id
FOREIGN KEY(cls_id)
REFERENCES rental_class(cls_id)
on update cascade
on delete cascade;


--------------------------------------------
drop table if exists rental_airport;

create table rental_airport as
select 
	*
from 
	rental_class
where 
	pick_at = 'airport';




