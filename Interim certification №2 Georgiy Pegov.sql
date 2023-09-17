--1) Используя SQL язык и произвольные две таблицы из модели данных необходимо объединить их различными способами (UNION , JOIN)

(select arrival_airport from flights limit 10)
union all
(select airport_name from airports limit 10)

(select model from aircrafts)
union
(select fare_conditions from seats)

select
t.passenger_name as passenger_name,
tf.fare_conditions as service_class
	from tickets t
		left join ticket_flights tf
			using (ticket_no) 

--2) Используя SQL язык напишите запрос с любым фильтром WHERE к произвольной таблице и результат отсортируйте (ORDER BY) с ограничением
--вывода по количеству строк (LIMIT)

select distinct passenger_name from tickets
where passenger_name like '%OVA'
order by passenger_name desc
limit 20

select distinct amount as am from ticket_flights
where amount between  40000 and 50000
order by amount desc
limit 25

--3) Используя SQL язык напишите OLAP запрос к произвольной связке таблиц (в рамках JOIN оператора), используя оператор GROUP BY и любые агрегатные
--функции count, min, max, sum.

select
t.passenger_name as passenger_name,
tf.fare_conditions as service_clas, 
count (tf.amount),
sum (bk.total_amount)
	from tickets t
		left join ticket_flights tf
			using (ticket_no) 
		join bookings bk
			on bk.book_ref = t.book_ref 
			--using (book_ref)
group by passenger_name, service_clas
order by count desc
limit 10

--4) Используя SQL язык примените JOIN операторы (INNER, LEFT, RIGHT) для более чем двух таблиц из модели данных.

select --distinct 
f.departure_airport, f.scheduled_departure, a.city, ac.model, s.fare_conditions
from flights f
	right join airports a
		on f.departure_airport = a.airport_code
	left join aircrafts ac
		using (aircraft_code)
	join seats s
		using (aircraft_code)
where city like 'Москва'
order by scheduled_departure, fare_conditions
limit 20

--5) Создайте виртуальную таблицу VIEW с произвольным именем для SQL запроса из задания 2)
drop view if exists passengers

create or replace view passengers as
select distinct passenger_name from tickets
where passenger_name like '%OVA'
order by passenger_name desc
limit 20