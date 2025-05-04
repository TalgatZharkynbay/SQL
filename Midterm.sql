select 1, 2, 3, 4 a, * from (select name from country) as c

select distinct region from country

select distinct continent, region from country

select distinct name, region from country

select localname,
array_length(string_to_array(trim(localname), ' '), 1) AS word_count
from country c 
where population <> 0
and (surfacearea / population) > 0.02

select code,
    country.name,
    city.name
from country
join city ct
    on countrycode = code
 
select code, name, gnp, continent from country c 
where gnp < 0.01*(select 
	max(gnp)
from country)
order by continent asc, gnp desc


select c.name as countryName, 
    ct.name as cityName, 
    1.0*ct.population/ca.population as share
from city as ct 
    join country as c 
        on c.code = ct.countrycode 
    join city as ca 
        on ca.id = c.capital

select c.continent, c.name as country, c3.language as lngname,
UPPER(SUBSTRING(c3.language, 1, 3)) AS lngcode,
round(c.population * c3.percentage/100) as speakingnr 
from country c
left join countrylanguage c3 
on c.code = c3.countrycode
where c.name in (select c.name as country_name
	from country c 
	left join city c2 
	on c.code = c2.countrycode 
	and c.capital = c2.id
	where c2.population > (select 0.8* max(city.population) as max_population
	from country  
	left join city  
	on country.code = city.countrycode))
and c3.isofficial = True

select c.name, c3.*,
round(c.population * c3.percentage/100) as speakingnr 
from country c 
left join countrylanguage c3 
on c.code = c3.countrycode
where c.surfacearea < 200000
and c3."language" = 'English'
order by speakingnr desc

select duedate::date, a.countryregioncode, sum(totaldue)
from salesorderheader s
join address a on s.shiptoaddressid=a.addressid
group by duedate, a.countryregioncode
having sum(totaldue) > 1000000
order by duedate

select count(distinct cl.language) nr, c.continent
from country c join countrylanguage cl ON cl.countrycode = c.code
where isofficial = true
group by c.continent

select count(distinct cl.language) nr, c.continent
from country c join countrylanguage cl ON cl.countrycode = c.code
group by c.continent, isofficial
having isofficial = true

select *
from (select count(distinct cl.language) nr, c.continent
          from country c join countrylanguage cl ON cl.countrycode = c.code
          group by c.continent, isofficial as data) 
where data.isofficial = true


select sum(linetotal)
from salesorderdetail s 
left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
left join product p on p.productid = s.productid
left join productsubcategory p2 on p2.productsubcategoryid = p.productsubcategoryid
left join productcategory p3 on p3.productcategoryid = p2.productcategoryid
where date_trunc('month', orderdate)::date between '2013-01-01' and '2013-12-01'
and p."name" = 'Water Bottle - 30 oz.'


select name, p.productid, sum(total) as total from 
(select sd.productid,
    sum(sd.linetotal) total,
    extract('y' from sh.duedate) as year, 
    extract('mon' from sh.duedate) as month
from salesorderheader as sh 
    join salesorderdetail as sd on sh.salesorderid = sd.salesorderid 
group by 1, 3, 4) mn_amt 
join 
    product p on p.productid = mn_amt.productid
where year = 2012 and month = 1
group by name, p.productid
order by total desc
limit 1

WITH monthly_sales AS (
select date_trunc('month', orderdate) as order_month,
	customer.customerid, customer.companyname ,sum(subtotal)
	from salesorderdetail s 
	left join salesorderheader s2 on s.salesorderid = s2.salesorderid
	left join product p on p.productid = s.productid
	left join customer on s2.customerid = customer.customerid
where date_trunc('month', orderdate)::date between '2012-01-01' and '2012-12-01'
group by customer.customerid, customer.companyname, order_month
HAVING sum(subtotal) >= 55000
order by sum(subtotal)) 
SELECT 
    customerid, companyname
FROM 
    monthly_sales
GROUP BY 
    customerid, companyname
HAVING 
    COUNT(order_month) >= 5;


with hour_intervals as (
    select generate_series(
        '2017-03-01 00:00:00+03'::timestamptz,
        '2017-03-01 23:00:00+03'::timestamptz,
        interval '1 hour'
    ) as hour_start
),
flight_stats as (
    select
        hi.hour_start,
        count(f.flight_id) filter (where f.actual_departure at time zone 'Europe/Moscow' < hi.hour_start) as flights_before_hour,
        count(f.flight_id) filter (where f.actual_departure at time zone 'Europe/Moscow' >= hi.hour_start - interval '1 hour' 
                                  and f.actual_departure at time zone 'Europe/Moscow' < hi.hour_start) as flights_last_hour,
        count(f.flight_id) filter (where f.status = 'Cancelled' and f.actual_departure < hi.hour_start) as cancelled_before_hour
    from
        hour_intervals hi
    left join
        bookings.flights f on f.departure_airport = 'DME'
                  and f.actual_departure at time zone 'Europe/Moscow' >= '2017-03-01 00:00:00+03' 
                  and f.actual_departure at time zone 'Europe/Moscow' < '2017-03-02 00:00:00+03'
    group by
        hi.hour_start
)
select
    hour_start,
    flights_before_hour ,
    flights_last_hour ,
    cancelled_before_hour,
    'Talgat Zharkynbay' as "My_Name"  
from
    flight_stats
order by
    1 desc
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
















    
    