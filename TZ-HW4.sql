--q1
select 	
	extract (year from orderdate) as order_year,
	extract (month from orderdate) as order_month,
	p3.name as category_name,
	count(p3.name),
	lag(count(p3.name), 1) over (partition by p3.name order by extract (year from orderdate), 
																  extract (month from orderdate)),
	coalesce(count(p3.name) - 	lag(count(p3.name), 1) over (partition by p3.name order by extract (year from orderdate), 
																  extract (month from orderdate)), 0)
																  as change_one_month
	from salesorderdetail s 
	left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
	left join product p on p.productid = s.productid
	left join productsubcategory p2 on p2.productsubcategoryid = p.productsubcategoryid
	left join productcategory p3 on p3.productcategoryid = p2.productcategoryid
	where date_trunc('month', orderdate)::date between '2012-01-01' and '2012-03-01'
	group by 1,2,3
	order by 1,2,3

--q2
select 
	p."name",
	sum(s.linetotal) as product_total, 
	round(sum(s.linetotal)/sum(sum(s.linetotal)) over(), 2) as perc_share
	from salesorderdetail s 
	left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
	left join product p on p.productid = s.productid
where orderdate between 
	'2013-01-01 00:00:00' and '2013-12-31 23:59:59'
	group by p."name"
	order by product_total desc
	limit 10

--q3

select 	distinct on (s.salesorderid)
	s.salesorderid,
	count(s.productid) over (partition by s.salesorderid) as count_products,
	a.city, 
	s2.totaldue,
	sum(s2.totaldue) over (partition by a.city) as totaldue_in_city,
	round(s2.totaldue / sum(s2.totaldue) over (partition by a.city), 2) as totaldue_perc,
	max(s.unitprice) over (partition by s.salesorderid),
	string_agg(p.productnumber, ', ') over (partition by s.salesorderid) as purchased_products
	from salesorderdetail s 
	left join salesorderheader s2 on s.salesorderid = s2.salesorderid
	left join product p on p.productid = s.productid
	left join address a on s2.shiptoaddressid = a.addressid
	where date_trunc('month', orderdate) = '2013-05-01'	

--q4
create view s_dict as (
select 
	0.8 * sum(s.linetotal) as s_a,
	0.95 * sum(s.linetotal) as s_b,
	sum(s.linetotal) as s_total
	from salesorderdetail s 
	left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
where orderdate between 
	'2013-01-01 00:00:00' and '2013-12-31 23:59:59')

select 
	p."name",
	sum(s.linetotal) as product_total,
	sum(sum(s.linetotal)) over(order by sum(s.linetotal) desc) as srti,
		case when sum(sum(s.linetotal)) over(order by sum(s.linetotal) desc) <= (select s_a from s_dict) then 'A'
			 when sum(sum(s.linetotal)) over(order by sum(s.linetotal) desc) <= (select s_b from s_dict) then 'B'
			 else 'C'
		end as test
	from salesorderdetail s 
	left join salesorderheader s2 ON s.salesorderid = s2.salesorderid
	left join product p on p.productid = s.productid
where orderdate between 
	'2013-01-01 00:00:00' and '2013-12-31 23:59:59'
	group by p."name"
	order by product_total desc
	
--q5
with main_table as (
select 
orderdate::date as date,
sum(totaldue) as total,
	avg(sum(totaldue)) over(order by orderdate
	rows between 4 preceding and current row) as total_ma_5,	
	case when lag(sum(totaldue), 4) over (order by orderdate) is not null 
		 then 5*sum(totaldue) + 4*lag(sum(totaldue), 1) over (order by orderdate)+
			 3*lag(sum(totaldue), 2) over (order by orderdate) + 2*lag(sum(totaldue), 3) over (order by orderdate)+
			   lag(sum(totaldue), 4) over (order by orderdate)			   
         when lag(sum(totaldue), 3) over (order by orderdate) is not null 
         then  4*sum(totaldue) + 3*lag(sum(totaldue), 1) over (order by orderdate)+
			   2*lag(sum(totaldue), 2) over (order by orderdate) + 1*lag(sum(totaldue), 3) over (order by orderdate)			   
         when lag(sum(totaldue), 2) over (order by orderdate) is not null 
         then  3*sum(totaldue) + 2*lag(sum(totaldue), 1) over (order by orderdate)+
			   1*lag(sum(totaldue), 2) over (order by orderdate)
         when lag(sum(totaldue), 1) over (order by orderdate) is not null 
         then  2*sum(totaldue) + lag(sum(totaldue), 1) over (order by orderdate)
         else sum(totaldue)
   		 end as numerator,
	case when lag(sum(totaldue), 4) over (order by orderdate) is not null then 15
         when lag(sum(totaldue), 3) over (order by orderdate) is not null then 10
         when lag(sum(totaldue), 2) over (order by orderdate) is not null then 6
         when lag(sum(totaldue), 1) over (order by orderdate) is not null then 3
         else 1
    end as denominator            
from salesorderheader s 
where date_trunc('month', orderdate) = '2013-05-01'		
group by orderdate)
		select date, total, total_ma_5, numerator, denominator,
		numerator/denominator as weighted_avg from main_table

--q6
with af as (
	select distinct
    flight_id,
    actual_departure at time zone 'Europe/Moscow' as start_dttm, 
    actual_arrival at time zone 'Europe/Moscow' as end_dttm
    from bookings.flights
    where (actual_departure at time zone 'Europe/Moscow')::date = '2017-02-01')
select
    af.start_dttm,
    af.end_dttm,
    count(f.flight_id) filter (where f.actual_departure at time zone 'Europe/Moscow' <= af.start_dttm
        					   and f.actual_arrival at time zone 'Europe/Moscow' >= af.start_dttm) as flights_air_cnt,
    count(f.flight_id) filter (where f.actual_arrival at time zone 'Europe/Moscow' <= af.start_dttm) as flights_finished_cnt
from
    af cross join
    bookings.flights f
where
 	(f.actual_departure at time zone 'Europe/Moscow')::date = '2017-02-01'
	group by af.flight_id, af.start_dttm, af.end_dttm
	order by flights_air_cnt desc



		
		
		
		
		
		
		
		
		
		
		
		
		
	



