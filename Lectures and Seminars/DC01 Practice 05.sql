-- q1
select 
	a.city->>'en' as city_name,
	count(*) as departed
from flights as f join airports_data as a
on f.departure_airport = a.airport_code
where status = 'Arrived'
group by 1
order by departed desc
limit 5;


-- q2
select 
	c."name",
	surfacearea,
	surfacearea - avg(surfacearea) as diff
from country c 
where c.continent = 'Europe'
group by 1, 2;


select 
	c."name",
	surfacearea,
	surfacearea 
		- (select avg(surfacearea) 
			from country c 
			where c.continent = 'Europe') 
		as diff
from country c 
where c.continent = 'Europe'
group by 1, 2
order by diff desc;


select 
	c."name",
	surfacearea,
	surfacearea 
		-  avg_sa
		as diff
from country c cross join 
	(select avg(surfacearea) as avg_sa 
			from country c 
			where c.continent = 'Europe') as c_avg
where c.continent = 'Europe'
group by 1, 2, 3
order by diff desc;

--q3
select 
	name, 
	region,
	gnp 
		- (select avg(gnp) 
			from country c2
			where c2.region = c.region)
from country c 
order by 2, 3;


select 
	name, 
	c.region,
	gnp 
		- avg_region.a as diff
from country c 
	join (select avg(gnp) as a,
			region
			from country c2
			group by c2.region) as avg_region
		on c.region = avg_region.region
where gnp - avg_region.a <>0
order by 2, 3;


--q4
select c.countrycode 
from city c 
order by c.population desc
limit 50;

--explain
select *
from country
where code in (select c.countrycode 
	from city c 
	order by c.population desc
	limit 50);


--explain
with top50 as(
select c.countrycode 
	from city c 
	order by c.population desc
	limit 50
),
top50_u as (
select distinct * from top50
)
select country.*
from country join top50_u
 on top50_u.countrycode = code ;

-- q5
select 
	avg(population) as avg_c_p 
from city ct 
where id in (select c.capital from country c);


select 
	c."name" as country_name,
	c2.population as c_p
from country c join city c2 
	on c.capital = c2.id;


select 
	c."name" as country_name,
	c2.population as c_p
from country c join city c2 
	on c.capital = c2.id
where c2.population > (
	select 
		avg(population) as avg_c_p 
	from city ct 
	where id 
		in (select c.capital 
			from country c)
);

-- q6
select *
from country c 
where c.population > 
	0.9 * (select max(population) from country c2
		where c2.region = c.region);


select region, max(population) as m_p
from country c 
group by 1;


select 
	c.*
from 
country c join
	(select 
			region, 
			max(population) as m_p
	from country c 
	group by 1) as m
	on c.region = m.region
where c.population > 0.9 * m_p;


-- q7
select *
from city ct
where population > 8000000
	and not exists(select 0
	from country c where c.capital = ct.id);


-- q8
-- month_first_day
-- airport_name
-- airport_flight_count

-- departures
select 
	f.departure_airport as airport_code,
	date_trunc('month', f.actual_departure)::date as m
from flights as f
where f.status ='Arrived'

-- arrivals
select 
	f.arrival_airport as airport_code,
	date_trunc('month', f.actual_arrival)::date as m
from flights as f
where f.status ='Arrived'


select 
	m,
	airport_code,
	count(*) as flights_count
from
	(select 
		f.departure_airport as airport_code,
		date_trunc('month', f.actual_departure)::date as m
	from flights as f
	where f.status ='Arrived'
	union all
	select 
		f.arrival_airport as airport_code,
		date_trunc('month', f.actual_arrival)::date as m
	from flights as f
	where f.status ='Arrived') as fl
group by 1, 2;
	


with fl as (select 
		f.departure_airport as airport_code,
		date_trunc('month', f.actual_departure)::date as m
	from flights as f
	where f.status ='Arrived'
	union all
	select 
		f.arrival_airport as airport_code,
		date_trunc('month', f.actual_arrival)::date as m
	from flights as f
	where f.status ='Arrived'),
agg as (select 
	m,
	airport_code,
	count(*) as flights_count
from fl
group by 1, 2)
select agg1.*, a.airport_name->>'en'
from agg as agg1
	join airports_data as a on agg1.airport_code = a.airport_code
where flights_count = (select min(flights_count) from agg where 
	agg.m=agg1.m)
;








