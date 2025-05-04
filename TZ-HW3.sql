
--q1
create view tz_table as (select
f.actual_departure at time zone ad.timezone as tz,
extract (hour from f.actual_departure at time zone ad.timezone) as hour,
case when (extract (hour from f.actual_departure at time zone ad.timezone) between 21 and 23) or
		  (extract (hour from f.actual_departure at time zone ad.timezone) between 0 and 1) then 'evening'
	 when extract (hour from f.actual_departure at time zone ad.timezone) between 6 and 9 then 'morning'
	 else 'other'
	 end as period,
f.departure_airport || '-' || f.arrival_airport as destination
from bookings.flights f 
left join bookings.airports_data ad 
on f.departure_airport = ad.airport_code 
where actual_departure is not null
and extract (year from f.actual_departure at time zone ad.timezone) = 2017
and extract (month from f.actual_departure at time zone ad.timezone) = 3)

select 
	(select count(*) filter(where period = 'evening') from tz_table) as evening_flights,
	(select count(*) filter(where period = 'morning') from tz_table) as morning_flights,
	(select destination
	from tz_table
	where period = 'morning'
	group by destination
	order by count(destination) desc 
	limit 1) as morning_destination,
	(select destination
	from tz_table
	where period = 'evening'
	group by destination
	order by count(destination) desc 
	limit 1) as evening_destination

--q2
with main_table as (select
date_trunc('day', f.actual_departure at time zone 'Europe/Moscow')::date as departure_day, 
fare_conditions,
sum(amount)
from
bookings.flights f 
left join bookings.ticket_flights tf 
on f.flight_id = tf.flight_id 
where actual_departure is not null 
and extract (year from f.actual_departure at time zone 'Europe/Moscow') = 2017
and extract (month from f.actual_departure at time zone 'Europe/Moscow') = 3
and amount is not null
group by departure_day, fare_conditions
order by departure_day asc)
	select departure_day, fare_conditions, sum(sum) as sum
	from main_table
	group by departure_day, fare_conditions

--q3
with wheels_orders as (select distinct s.salesorderid from productsubcategory p 
left join product p2 
on p.productsubcategoryid  = p2.productsubcategoryid
left join salesorderdetail s 
on p2.productid = s.productid
where p."name" = 'Wheels'
and salesorderid is not null)
	select p.productsubcategoryid, p."name", count(s.salesorderid)
	from productsubcategory p 
	left join product p2 
	on p.productsubcategoryid  = p2.productsubcategoryid
	left join salesorderdetail s 
	on p2.productid = s.productid
	where s.salesorderid in (select salesorderid from wheels_orders)
	and p."name" <> 'Wheels'
	group by 1,2
	order by 3 desc
	
--q4
with first_cte as (select left(name, 1) as first_letter from country c)
select first_letter, count(first_letter) as cnt
from first_cte
group by first_letter
order by cnt desc

--q5
with english_german as (select c.code, c.name, c2.language, c2.isofficial
from country c
left join countrylanguage c2 
on c.code = c2.countrycode
where isofficial = true 
and language in ('English', 'German')
order by name, isofficial desc)
	select count(*) from english_german
	
--q6
with region_life as (select region, avg(lifeexpectancy) as avg_life
from country c 
group by region
having avg(lifeexpectancy) > 0)
	select name, c.region, lifeexpectancy, avg_life from country c
	left join region_life
	on c.region = region_life.region
	where lifeexpectancy > avg_life

--q7
with africa as (select language from country c
left join countrylanguage c2 
on c.code = c2.countrycode
where c.continent in ('Africa')),
asia as (select language from country c
left join countrylanguage c2 
on c.code = c2.countrycode
where c.continent in ('Asia'))
select distinct africa.language from africa inner join asia
ON africa.language = asia.language

--q8
with Sales_2012 as (select date_trunc('month', orderdate)::date as order_month,
p3.name as category_name, sum(linetotal) as Sales_2012
from salesorderdetail s 
left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
left join product p on p.productid = s.productid
left join productsubcategory p2 on p2.productsubcategoryid = p.productsubcategoryid
left join productcategory p3 on p3.productcategoryid = p2.productcategoryid
where date_trunc('month', orderdate)::date between '2012-01-01' and '2012-12-01'
group by order_month, category_name
order by order_month asc, category_name asc),
	Sales_2013 as (select (date_trunc('month', orderdate) - INTERVAL '1 year')::date as order_month,
	p3.name as category_name, sum(linetotal) as Sales_2013
	from salesorderdetail s 
	left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
	left join product p on p.productid = s.productid
	left join productsubcategory p2 on p2.productsubcategoryid = p.productsubcategoryid
	left join productcategory p3 on p3.productcategoryid = p2.productcategoryid
	where date_trunc('month', orderdate)::date between '2013-01-01' and '2013-12-01'
	group by order_month, category_name
	order by order_month asc, category_name asc)
		select Sales_2012.category_name, 
		Sales_2012.order_month as order__month_2012,
		Sales_2012,
		(Sales_2013.order_month + INTERVAL '1 year')::date as order__month_2013,
		Sales_2013,
		round((Sales_2013-Sales_2012)/Sales_2012,2) as percentage_change
		from Sales_2012 inner join Sales_2013 on 
		Sales_2012.order_month = Sales_2013.order_month
		and Sales_2012.category_name = Sales_2013.category_name

--q9
with departure as 
	(select
	departure_airport as airport,
	count(distinct f.flight_id) as departure_flights,
	count(distinct f.flight_id || '-' ||boarding_no) as departure_passengers
	from flights f
	left join boarding_passes bp 
	on f.flight_id = bp.flight_id 
	where actual_departure is not null 
	and extract (year from f.actual_departure at time zone 'Europe/Moscow') = 2017
	and extract (month from f.actual_departure at time zone 'Europe/Moscow') = 3
	and boarding_no is not null
	group by departure_airport
	order by departure_flights desc),
	arrival as 
		(select
		arrival_airport as airport,
		count(distinct f.flight_id) as arrival_flights,
		count(distinct f.flight_id || '-' ||boarding_no) as arrival_passengers
		from flights f
		left join boarding_passes bp 
		on f.flight_id = bp.flight_id 
		where actual_arrival is not null 
		and extract (year from f.actual_arrival at time zone 'Europe/Moscow') = 2017
		and extract (month from f.actual_arrival at time zone 'Europe/Moscow') = 3
		and boarding_no is not null
		group by arrival_airport
		order by arrival_flights desc),
			names as (select departure_airport as airport from flights
						union
						select arrival_airport as airport from flights)
							select names.airport, 
								   departure_flights,
								   departure_passengers,
								   arrival_flights,
								   arrival_passengers,
								   departure_flights + arrival_flights as total_flights
								   from
								   names left join departure on names.airport = departure.airport
								   left join arrival on names.airport = arrival.airport
								   where departure_flights + arrival_flights > 0
								   order by total_flights desc
								   







