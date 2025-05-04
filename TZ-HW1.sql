-- Задача 1
-- Создайте базу данных dc1_hw1
create database dc1_hw1;

--Создайте три таблицы в своей базе данных, используя нижеприведённый скрипт SQL DDL:
/* Пользователи */
CREATE TABLE app_user(
user_id int NOT NULL generated always as identity PRIMARY KEY,
user_name varchar(80) NOT NULL,
created_at timestamptz NOT NULL default now()
);
/* Данные о поездке */
CREATE TABLE trip(
  trip_id int NOT NULL generated always as identity PRIMARY KEY, 
  trip_name varchar(500) NOT NULL,
  start_date date not NULL, 
  user_id int NOT NULL
 );
/* Города, которые стоит посетить во время поездки, ord_num — порядковый номер каждого города в одной поездке */
CREATE TABLE trip_cities(
  trip_id int not null,
  ord_number int not null,
  city_id int not null,
  stay_duration int null
);

/* Города */
CREATE TABLE city( 
  city_id int NOT NULL, 
  city_name varchar(50) not null,  
  country_name varchar(50) NOT NULL,
  is_capital boolean NOT NULL
 );

-- После выполнения первого скрипта SQL DDL добавьте недостающие настройки, описанные в тексте. 
alter table city
alter city_id
ADD GENERATED always AS identity ,
ADD CONSTRAINT PK_city PRIMARY KEY (city_id);

alter table trip_cities
ADD CONSTRAINT PK_trip_cities PRIMARY KEY (trip_id, ord_number),
ADD CONSTRAINT FK_city FOREIGN KEY (city_id) REFERENCES city(city_id),
ADD CONSTRAINT FK_trip FOREIGN KEY (trip_id) REFERENCES trip(trip_id)
;

-- Добавьте пять городов и внесите две поездки с указанием посещения городов (таблицы trip и trip_cities) в базу данных.
insert into city(city_name, country_name, is_capital) 
values
('London', 'United Kingdom', True), 
('Paris', 'France', True), 
('Moscow', 'Russia', True), 
('Astana', 'Kazakhstan', True), 
('Almaty', 'Kazakhstan', False) 
;

-- Здесь я решил добавить FK в таблицу trip для поля user_id, т.к. это PK в таблице app_user
alter table trip
ADD CONSTRAINT FK_user FOREIGN KEY (user_id) REFERENCES app_user(user_id)
;

-- Здесь я решил добавить поля user_id в таблице app_user
insert into app_user(user_name) 
values
('Talgat Zharkynbay'), 
('John Smith')
;

insert into trip(trip_name, start_date, user_id) 
values
('London to Paris', '2025-09-02', 1), 
('Paris to London', '2025-10-02', 1)
;

insert into trip_cities(trip_id, ord_number, city_id, stay_duration) 
values
(1, 1, 2, 1), 
(2, 2, 1, 1)
;


-- Задача 2 Создайте пять таблиц с помощью кода SQL DDL

CREATE TABLE guest(
    id int NOT NULL generated always as identity PRIMARY KEY,
    name varchar(50) NOT NULL, 
    phone varchar(25), 
    is_male boolean NOT null --  пол гостя
);
    
CREATE TABLE building (
    id int NOT NULL generated always as identity,
    building_code varchar(10) not null,
    room_count INT NOT NULL,
    floor_count INT NOT NULL,
    description varchar(500),
    CONSTRAINT PK_building PRIMARY KEY (id, building_code) -- я вот здесь хотел, чтобы помимо кода типо 1А, 2Б был также обычный id,
    -- который вместе с ним был бы уникальным
);

CREATE TABLE room (
    id int NOT NULL generated always as identity PRIMARY KEY,
    sq_meters int not null, 
    bed int not null, 
    window_view varchar(50) not null, 
    max_guests int not null, 
    room_number int not null, 
    floor int not null,
    building_id int not null,
    building_code varchar(10) not null,
    CONSTRAINT building_fk FOREIGN KEY (building_id, building_code) REFERENCES building(id, building_code),
    CONSTRAINT ck_window_view check (window_view IN ('сад', 'бассейн', 'океан'))
);


CREATE TABLE booking (
    booking_id int NOT NULL generated always as identity PRIMARY KEY,
    start_date DATE NOT NULL, 
    duration_days int not null, 
    guest_id int not null,
    room_id int not null,
    meal_plan VARCHAR(2) not null,
    CONSTRAINT fk_guest_id FOREIGN KEY (guest_id) REFERENCES guest(id),
    CONSTRAINT fk_room_id FOREIGN KEY (room_id) REFERENCES room(id),
    CONSTRAINT ck_meal_plan CHECK (meal_plan IN ('NO', 'BB', 'HB'))
);


INSERT INTO building (building_code, room_count, floor_count, description)
VALUES
    ('1A', 100, 10, 'Старый корпус'),
    ('1B', 200, 20, 'Новый корпус');


INSERT INTO room (sq_meters, bed, window_view, max_guests, room_number, floor, building_id, building_code)
VALUES
    (15, 1, 'сад', 1, 1, 1, 1, '1A'),
    (15, 1, 'бассейн', 1, 2, 1, 1, '1A'),
    (30, 2, 'океан', 2, 3, 10, 1, '1A'),
    (20, 1, 'сад', 1, 4, 1, 2, '1B'),
    (25, 2, 'бассейн', 2, 5, 1, 2, '1B'); 

   
INSERT INTO guest(name, phone, is_male)
VALUES
    ('Talgat Zharkynbay', '87786205872', True),
    ('Kulshaim Adilbekova', '87771987713', False); 
   
INSERT INTO booking (start_date, duration_days, guest_id, room_id, meal_plan)
VALUES
    ('2025-02-01', 7, 1, 3, 'HB'),
    ('2025-02-01', 7, 2, 3, 'HB');
   

INSERT INTO building (building_code, room_count, floor_count, description)
VALUES ('1A', 200, 20, 'Старый корпус реставрация')
ON CONFLICT (id, building_code)
DO UPDATE SET
    floor_count = EXCLUDED.floor_count,
    description = EXCLUDED.description,
    room_count = EXCLUDED.room_count;


DELETE FROM booking
WHERE booking_id = 1;

SELECT * FROM guest;
   
CREATE TABLE guest_copy AS
SELECT * FROM guest;
