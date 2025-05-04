-- q1
select count(*) from country c ;

select count(indepyear) from country c;

select count(coalesce(indepyear, 0)) from country c;

select count(distinct region) from country;

select count(*),
	max(lifeexpectancy),
	min(surfacearea),
	avg(gnp)
from country c ;

-- error
select count(*),
	max(lifeexpectancy),
	min(surfacearea),
	avg(gnp),
	region
from country c ;



-- q2
select 
	count(*),
	max(population),
	min(population),
	max(population) - min(population)
from country c 
where c.surfacearea <= 30000;



-- q3
select sum(population) total_population,
count(*) country_count
from country c 
where continent in('Asia', 'North America');


-- q4
SELECT sum(population),
sum(case when continent = 'Europe' then population end) population_europe, 
sum(case when continent = 'Asia' then population end) population_asia
from country;

SELECT sum(population),
sum(population) filter(where continent = 'Europe') population_europe, 
sum(population) filter(where continent = 'Asia') population_asia
from country;


-- q5
select region,
	sum(population)
from country c;

select region,
	sum(population)
from country c
group by c.region;

select region,
	sum(population)
from country c
group by 1;


select region,
	sum(population)
from country c
group by 1, population ;


select
	sum(population)
from country c
group by region;

--q6
select 
	c."name",
	ct.population 
from country c 
	join city ct on c.code = ct.countrycode
where c.continent = 'Africa';


select 
	c."name",
	avg(ct.population) 
from country c 
	join city ct on c.code = ct.countrycode
where c.continent = 'Africa'
group by c.name;

-- distinct
select region
from country c 
group by region


--q7
/*
C1 E 100
C1 R 0
C2 E 2
C2 R 130
C3 E 0
C3 R 0
....
*/



select unnest(array ['English', 'Russian']) language;

select name from country c;


with lng as (
	select unnest(array ['English', 'Russian']) language
),
cnt as (
	select name,
		code,
		population
	from country c
),
pairs as (
select 
	cnt.name,
	lng.language,
	cnt.code,
	cnt.population
from 
	lng 
		cross join cnt
)
select 
	pairs.name,
	pairs.language,
	cl.percentage /100 * pairs.population
from pairs left join 
	countrylanguage cl
		on pairs.language = cl."language"
			and pairs.code = cl.countrycode
;


--q8
select region
from country c 
group by region 
having count(*) > 10;

select region, count(*)
from country c 
group by region 
having count(*) > 10
order by 2;

select count(*)
from country c 
group by region 
having count(*) > 10
order by 1;


--q10
/*
 * C1   c1;c2;c190
 * C2   c3;c4;c200
 * 
 * */

select 
	continent,
	string_agg(code, ';') 
from country c
group by 1;

--q11

select 
	f.flight_id,
	f.aircraft_code,
	f.status,
	count(*) as available_seats,
	count(bp.flight_id) as occupied_seats,
	count(*) - count(bp.flight_id) as free_seats
from flights f 
	join seats s 
		on s.aircraft_code = f.aircraft_code
	left join boarding_passes bp 
		on bp.flight_id = f.flight_id 
			and bp.seat_no = s.seat_no 
where
	f.arrival_airport = 'DME' 
	and f.actual_arrival >= '2017-01-01'
	and f.actual_arrival < '2017-01-02'
group by 1, 2, 3;




