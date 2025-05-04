-- Задание 1. Найдите регионы и континенты со странами, которые стали независимыми в период с 1900 по 1920 год, 
-- имеют ожидаемую продолжительность жизни 70 лет и выше и имеют площадь на душу населения 0,05 и более.

select region, continent, name from country
where indepyear between 1900 and 1920
and lifeexpectancy > 70
and (surfacearea / population) > 0.05

-- Задание 2. Найдите страны с различающимися местными и международными названиями

select name, localname from country 
where name <> localname 

-- Задание 3. Выведите все континенты вместе с названием страны с наибольшей численностью населения. 
-- Запрос должен возвращать результат с полями:
-- - континент
-- - страна с наибольшим населением на континенте
-- - площадь наибольшей страны

select distinct on (continent) continent, name, population, surfacearea
from country
where population > 0
order by continent, population DESC;

-- Задание 4. Перечислите формы правления стран с ожидаемой продолжительностью жизни менее 61 года 
-- и расположенных на одном из двух континентов - Азии и Европе

select distinct governmentform from country
where lifeexpectancy < 61
and continent in ('Asia', 'Europe')

-- Задание 5. Какие страны имеют названия, включающие их коды? Используйте оператор конкатенации || и ilike.

select name, code 
from country
where name ilike '%' || code || '%';

-- Задание 6. 
-- Найдите рейсы, которые фактически вылетели из аэропорта DME между 2017-02-20 15:00:00.000 +0300 и 
-- 2017-02-20 18:00:00.000 +0300 (не включая). 
-- Выведите следующие поля:
-- - номер рейса flight_id
-- - время в минутах от фактического момента отправления до прибытия
-- Вам понадобятся таблица bookings.flights и поля actual_departure, actual_arrival, departure_airport, flight_id

select flight_id, extract(epoch from (actual_arrival - actual_departure)) / 60 as minutes
from bookings.flights
where departure_airport = 'DME'
and actual_departure > '2017-02-20 15:00:00.000 +0300' :: timestamp
and actual_departure < '2017-02-20 18:00:00.000 +0300' :: timestamp

-- Здание 7.
-- Посчитайте количество людей, говорящих на каждом языке. Найдите языки, популярность которых в стране составляет 30% и выше. 
-- Выведите код страны, название страны, язык, является он официальным, количество людей, говорящих на этом языке. 
-- Отсортируйте данные по названию страны в алфавитном порядке. Официальные языки должны отображаться первыми.

select c.code, c.name, c2.language, c2.isofficial, c2.percentage,
round(c.population * c2.percentage/100) as people_speak
from country c
left join countrylanguage c2 
on c.code = c2.countrycode 
where percentage > 30 
order by name, isofficial desc 

-- Запрос 8.
-- Найдите топ 10 городов с наибольшим населением в странах, в которых говорят на английском языке.

select c2.name, c2.population
from country c 
left join city c2 
on c.code = c2.countrycode 
-- and c.capital = c2.id -- кажется нужно только для столиц
left join countrylanguage c3 
on c.code = c3.countrycode
where language = 'English' 
and c2.name is not null
and c3.percentage > 0
order by c2.population desc
limit 10

-- Запрос 9.
with temp_table as (select distinct name as geo_name, 'Страна' as geo_type from country
union
select distinct continent as geo_name, 'Континент' as geo_type from country
union
select distinct region as geo_name, 'Регион' as geo_type from country)
select left(geo_name, 1) as first_letter, geo_name, geo_type
from temp_table
order by first_letter asc

-- Запрос 10
-- Сравните население каждого города с населением столицы в той же стране. 
-- Напишите запрос, чтобы показать отношение в процентах (поделите население города на население столицы), 
-- название города, название столицы, страну и континент. 
-- Отсортируйте результат по названию континента и города в алфавитном порядке.

with 
	capitals_table as (
	select c.name as country_name,
	c2.name as capital_name, c2.population as capital_population
	from country c 
	left join city c2 
	on c.code = c2.countrycode 
	and c.capital = c2.id),
		city_table as
		(select continent, c.name as country_name,
		c2.name as city_name, c2.population as city_population
		from country c 
		left join city c2 
		on c.code = c2.countrycode 
		and c.capital <> c2.id)
			select continent, capitals_table.country_name, capital_name, capital_population, city_name,
			city_population, cast(city_population AS FLOAT) / capital_population AS ratio
			from 
			capitals_table right join city_table
			on capitals_table.country_name = city_table.country_name
			order by continent, city_name

















