'' -- text
"" -- identifier

-- single row queries
select 1, 2, 3;

select 1 as col1, 2 col2, 3 c3;

select 1,
	1 as my_column,
	1 my_column,
	'Database course' as course,
	'DWH course' as "Course";


select 1 as col1, 2 col2, 3 c3, col1 + col2;


1. value
1, 2.45, 'some string', '2024-10-01', true

2. value with data type
date '2024-10-01'

int '123'

numeric(10,2) '23.33'

timestamp '2024-10-12 10:05:44.01'

select 
	timestamp '2024-10-12 10:05:44.01',
	date '2024-10-01',
	int '123',
	numeric(10,2) '23.33';

3. assign data type by type conversion 
value::type
cast(value as type)

select '2024-10-12 10:05:44.01'::timestamp as a,
	'2024-10-12 10:05:44.01'::date as b,
	'2024-10-12 10:05:44.01' as c,
	'2024-10-12 10:05:44.01'::time as d;

-- numbers
select 1;
select int '1';
select int '1 25';
select '1'::int;
select bigint '200000000000';

select bigint 200000000000;
select int 200000000000;

select 200000000000::int;

select 1.25;
select float '1.25';
select numeric(10,2) '1.25';
select numeric(10,2) '1,25';
select ((1 + 29 + 1) * 2 ) % 3;
select ((1 + 29 + 1) * int '2' ) % 3;
select ((1 + 29 + 1) * int '2' ) / 3;


select 1/2;
select 1/2.0;

select ( 1 / 2 ) * 1.0;
select ( (1.0 * 1) / 2  );
select ( (1.0 * 1) / '2' );

select 
	ceil(10.5), 
	floor(10.5), 
	round(10.5), 
	round(10.564, 2);

select 
	width_bucket(3, 1, 10, 5);

-- text data
select 'A string';
select 'A ' || 'string' as c;
select text '1.25';
select varchar '1.25';
select varchar(100) '1.25';
select concat('A',' ' ,'string' );

select 
	substring('Hello world!', 1) as s1, 
	substring('Hello World!', 6, 6) as s2,
	length('Hello World!'),
	position('World' in 'Hello World!');

select
	left('Hello World!', 5),
	upper('Hello World!'),
	lower('Hello World!'),
	trim(' Database '),
	to_char(225.567, '999000.00');
	

-- date & time
select date '01.01.2019';
select timestamp '01.01.2019 10:00:02';
select '01.01.2019'::timestamp;
select '01.01.2019'::date;
select '01.01.2019'::timestamp;
select '01.01.2019'::timestamptz;

select 
	interval '1 day',
	'1 day'::interval,
	'1 day' interval; -- This is not an interval !!

select interval '2 mon 1 day 3 hrs 2 min 50 sec';

-- show timezone;

select 
	extract(month from now()),
	extract(hour from current_timestamp),
	date_trunc('month', current_date),
	date_trunc('sec', '2024-01-23 10:09:02.123'::timestamp),
	date_trunc('day', now());

select 
	'2022-09-01'::date + 2 as plus2,
	'2022-09-01'::timestamp + interval '1 min',
	'2022-09-01'::date - '2022-09-02'::date,
	'2022-09-01'::timestamp - '2022-09-02'::timestamp
	;

select 
	extract(month from '2024-06-06'::timestamp),
	extract(hour from '2024-06-06 10:03:55'::timestamp),
	extract(epoch from '2024-09-20'::timestamp),
	( extract(epoch from '2024-09-20'::timestamp)
		- extract(epoch from '2024-09-19'::timestamp) ) / 60 / 60;

select to_char('2024-09-20 12:04:34'::timestamp, 'DD.MM.YYYY') as dt;



select extract(epoch from '1970-01-01'::timestamp);


-- null value
select 1 + null, 
	'string' || null,
	true and null,
	coalesce(null, 1),
	coalesce(null, null, 33, 222),
	coalesce(null, null);


-- search conditions
select 
	1 > 0,
	10 < 0,
	null = null,
	null is null,
	null is not null,
	1 is null,
	null > 4,
	null is distinct from 4,
	1 <> 2,
	1 != 2,
	1 >= 0,
	1 <= 0;


select 
	'Database' like 'd%',
	'Database' like 'D%',
	'Database' ilike 'd%',
	'id_01' like 'id_%', 'idx01' like 'id_%',
	'id_01' like 'id\_%',
	'id_01' like 'id!_%' escape '!';

select 
	('2024-01-20'::timestamp, '2024-01-24'::timestamp) 
		overlaps ('2024-01-20'::timestamp, '2024-01-24'::timestamp),
	('2024-01-20'::timestamp, '2024-01-24'::timestamp) 
		overlaps ('2024-01-23'::timestamp, '2024-01-26'::timestamp),
	('2024-01-20'::timestamp, '2024-01-24'::timestamp) 
		overlaps ('2024-01-24'::timestamp, '2024-01-29'::timestamp);

select true and false,
	true and true,
	true or false,
	false or false,
	null and true,
	null or true,
	null and false,
	null and null,
	null or null;


select 
	1 > 0 or 3 > 10,
	'Database' like 'Data%' 
	and 1 = 1;


select unnest( array ['Kirill', 'Leonid', 'Polina', 'Gleb'] );


