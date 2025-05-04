-- SQL Practice 3

select 1
from country c ;

select * from country;

select *, * from country;

select 1, 2, 3 from country;

select 1, *, 123 from country;

select *
from country c 
limit 10;

select 
	name, 
	code, 
	c.continent,
	country.gnp 
from country c;


select 
	name, 
	code, 
	cn.continent,
	cn.gnp 
from country as cn;

-- q2
select 
	name, 
	indepyear,
	date_part('year', now()) - c.indepyear as years
	-- extract (year from now() )
from country c;

-- q3
select distinct 
	c.continent 
from country c;

select distinct on (continent) 
	continent,
	name
from country
order by continent, surfacearea desc;


-- q4
select 
	c.name,
	c.surfacearea,
	c.population,
	round(c.surfacearea::numeric / c.population, 3) as area_per_citizen
from country c
where population > 0
	and continent  in ('Europe', 'North America')
order by /*4*/ area_per_citizen desc; 


-- q5

select name 
from country c 
where capital is null;

select "name" , coalesce(capital, -1) as capital
from country c ;

select 
	"name", 
	coalesce(capital::varchar, 'N/A') as capital
from country c ;


1
2
11

1
11
2

01
02
11

--q6
-- join
select 
	ct."name" as city_name,
	ct.population as city_population, 
	ct.countrycode,
	c.population as country_population,
	1.0 * ct.population / c.population as city_country_p_share
from city ct
	join country c 
		on ct.countrycode = c.code
limit 100;


--q7
select 
	c.name as country_name,
	ct.name as capital_name
from city ct
	join country c 
		on ct.id = c.capital;

select 
	c.name as country_name,
	ct.name as capital_name
from city ct
	right join country c 
		on ct.id = c.capital;
	
	
select 
	c.name as country_name,
	coalesce(ct.name, 'Unknown') as capital_name
from city ct
	right join country c 
		on ct.id = c.capital;

--q8
(select c."name"
from country c 
order by c.gnp desc
limit 10)
union all
(select c."name"
from country c 
order by c.gnp
limit 10);


(select c."name",
	1 as group_id
from country c 
order by c.gnp desc
limit 10)
union all
(select c."name",
	2 group_id
from country c 
order by c.gnp
limit 10);



