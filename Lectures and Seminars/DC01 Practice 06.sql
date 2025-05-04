-- q1
/*
 * 
 * all columns of country
 * share in continent's population
 * share in world population
 * 
 */
select 
	c.*,
	round(population * 1.0 / sum(population) over(partition by continent), 4) as s_continent,
	round(population * 1.0 / sum(population) over(), 4) as s_world
from country c 
where population >0;


-- q2
/*
country code
language
percentage
max percentage (for the language)
difference max - perc.
*/

select 
	c.countrycode,
	c."language",
	c.percentage,
	max(percentage) over(partition by c."language"),
	max(percentage) over(partition by c."language") - percentage as diff
from countrylanguage c;


-- q3
/*
Order id
Date when order was created
Total due of order
% share in daily revenue from online orders (window function)

 * */
select 
	salesorderid as order_id,
	orderdate,
	totaldue,
	 round(
	 	totaldue 
	 	/ sum(totaldue) over(partition by orderdate::date) 
	 	* 100,
	 	1) as perc_share
from salesorderheader
where orderdate between 
	'2013-01-01 00:00:00' and '2013-12-31 23:59:59'
and onlineorderflag = true;

-- q4
/*
Order Date
Month
Total due of all orders that were created this day
Total due from start of the month to the date (MTD)

year = 2012
 * 
 */
select 
	orderdate::date as order_date,
	date_trunc('month', orderdate) as order_month,
	sum(totaldue) as total_day,
	sum(sum(totaldue)) over(partition by date_trunc('month', orderdate) 
	   order by orderdate::date)
from salesorderheader
where orderdate between 
	'2012-01-01 00:00:00' and '2012-12-31 23:59:59'
and onlineorderflag = true
group by 1, 2;



-- q5
/*
 * 
 * compare ma(5) and ma(20) for subtotal
 * granularity = 1 day
 * trend indicator: inc - ma_5 > ma_20, dec - ma_5 < ma_20, eq - ma_5 = ma_20
 * 
 * year = 2012
 */
with data as (select 
	orderdate::date as order_date,
	sum(totaldue) as total_day,
	avg(sum(totaldue)) over(
	   order by orderdate::date
	   rows between 4 preceding and current row) as ma_5,
	avg(sum(totaldue)) over(
	   order by orderdate::date
	   rows between 19 preceding and current row) as ma_20
from salesorderheader
where orderdate between 
	'2012-01-01 00:00:00' and '2012-12-31 23:59:59'
group by 1)
select 
	*,
	case 
		when ma_5 > ma_20 then 'inc'
		when ma_5 < ma_20 then 'dec'
		else 'eq'
	end as trend_desc
from data;
		

--q6
/*
 * product
 * place by number of orders
 * 
 */

select 
	productid,
	dense_rank() over(order by count(salesorderid) desc) as rank_by_orders
from salesorderdetail s 
group by 1;


--q7
/*
 * 
 * absolute month to month changes in revenue 
 * from sales orders of each product
 * 
 * 
 * */

select 
	date_trunc('month', h.orderdate) as order_month,
	s.productid,
	sum(linetotal) as product_sales,
	lag(sum(linetotal), 1, sum(linetotal)) over(partition by productid order by date_trunc('month', h.orderdate)),
	sum(linetotal) 
		- lag(sum(linetotal), 1, sum(linetotal)) 
			over(partition by productid 
				order by date_trunc('month', h.orderdate)) 
	as diff
from salesorderdetail s 
	join salesorderheader h on s.salesorderid = h.salesorderid 
group by 
	date_trunc('month', h.orderdate),
	productid;

-- q8
/* flights db
required fields:
 * time_from
 * time_to
 * number of aircrafts in the air during the time period
 
 Consider only one day for analysis - 1st of January, 2017 msk. Apply this filter to actual_departure
 */

select 
	f.flight_id,
	f.actual_departure,
	f.actual_arrival
from flights f
where 
	f.actual_departure >= '2017-01-01' 
		and f.actual_departure < '2017-01-02';


select 
	f.flight_id,
	f.actual_departure,
	f.actual_arrival,
	max(f.min_arrival) over(order actual_departure)
from flights f
where 
	f.actual_departure >= '2017-01-01' 
		and f.actual_departure < '2017-01-02';


-- we find time ranges between all actual arrivals and departures
with dts as (
	select 
		f.actual_departure as dt
	from 
		flights f
	where 
		f.actual_departure >= '2017-01-01' 
			and f.actual_departure < '2017-01-02'
	union
	select 
		f.actual_arrival
	from 
		flights f
	where 
		f.actual_departure >= '2017-01-01' 
			and f.actual_departure < '2017-01-02'
),
dt_rng as (
	select 
		dt as dt1,
		lead(dt) over(order by dt) as dt2
	from dts
)
select * 
from dt_rng;


-- a possible solution:
-- 1) add +1 to number of flights, if the left boundary of time range equals actual_departure field
-- 2) subtract 1, if the left boundary equals actual_arrival
with dts as (
	select 
		f.actual_departure as dt
	from 
		flights f
	where 
		f.actual_departure >= '2017-01-01' 
			and f.actual_departure < '2017-01-02'
	union
	select 
		f.actual_arrival
	from 
		flights f
	where 
		f.actual_departure >= '2017-01-01' 
			and f.actual_departure < '2017-01-02'
),
dt_rng as (
	select 
		dt as dt1,
		lead(dt) over(order by dt) as dt2
	from dts
),
flights_dt_rng as (
	select 
		f.actual_departure as d_dt, -- departure
		f.actual_arrival as a_dt, -- arrival
		dt1,
		dt2,
		case 
			when f.actual_departure = dt1 then 1
			when f.actual_arrival = dt1 then -1
		end as flight_cnt
	from 
		flights f
			join dt_rng 
				on f.actual_departure = dt1 -- departed or arrived at the beginning of the time span
					or f.actual_arrival = dt1
	where 
		f.actual_departure >= '2017-01-01' 
			and f.actual_departure < '2017-01-02'
)
select 
	dt1,
	dt2,
	sum(sum(flight_cnt)) over(order by dt1) as flights_count 
from 
	flights_dt_rng
group by
	dt1, dt2 -- removing duplicates from the output
;

	

