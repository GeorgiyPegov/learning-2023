--a. Напишите SQL запрос который возвращает имена студентов и их аккаунтв Telegram у которых родной город “Казань” или “Москва”. 
-- Результат отсортируйте по имени студента в убывающем порядке.

select name, telegram_contact from student
where city  = 'Казань' or city = 'Москва'
order by name desc 

--b. Напишите SQL запрос который возвращает данные по университетам в следующем виде (один столбец со всеми данными внутри)
-- с сортировкой по полю “полная информация”.

select concat ('Университет: ', name,'; количество студентов: ', size) as "полная информация" from college
order by "полная информация"

--c. Напишите SQL запрос который возвращает список университетов и количество студентов, если идентификатор университета должен быть
-- выбран из списка 10, 30, 50. Пожалуйста примените конструкцию IN.
-- Результат запроса отсортируйте по количеству студентов и затем по наименованию университета.

select * from college
where id in (10, 30, 50)
order by size, name

--d. Напишите SQL запрос который возвращает список университетов и количество студентов, если идентификатор университета НЕ должен
-- соответствовать значениям из списка 10, 30, 50. Пожалуйста в основе примените конструкцию IN. Результат запроса отсортируйте по
-- количеству студентов и затем по наименованию университета.

select * from college
where id not in (10, 30, 50)
order by size, name

--e. Напишите SQL запрос который возвращает название online курсов университетов и количество заявленных слушателей. Количество
-- заявленных слушателей на курсе должно быть в диапазоне от 27 до 310 студентов. Результат отсортируйте по названию курса и по количеству
-- заявленных слушателей в убывающем порядке для двух полей.

select name, amount_of_students from course
where is_online = true and amount_of_students between 27 and 130
order by name desc, amount_of_students desc

--f. Напишите SQL запрос который возвращает имена студентов и название курсов университетов в одном списке. Результат отсортируйте в
-- убывающем порядке.

select name from student
union
select name from course
order by name desc

--g. Напишите SQL запрос который возвращает имена университетов и название курсов в одном списке, но с типом что запись является или
-- “университет” или “курс”. Результат отсортируйте в убывающем порядке по типу записи и потом по имени.

select name, 'универститет' as "object_type" from college
union
select name, 'курс' as "object_type" from course
order by "object_type" desc, name

--h. Напишите SQL запрос который возвращает название курса и количество заявленных студентов в отсортированном списке по количеству
-- слушателей в возрастающем порядке, НО запись с количеством слушателей равным 300 должна быть на первом месте. Ограничьте
-- вывод данных до 3 строк.

(select name, amount_of_students from course --вариант 1 (произвольная форма)
where amount_of_students = 300)

union all

(select name, amount_of_students from course
where amount_of_students != 300
order by amount_of_students asc)
limit 3

select name, amount_of_students from course --вариант 2 (в соответствии с рекомендациией задания)
order by case 
			when amount_of_students = 300 then '1-amount_of_students'
     		else '2-amount_of_students'
	end asc
limit 3

--i. Напишите DML запрос который создает новый offline курс со следующими характеристиками:
-- id = 60
-- название курса = Machine Learning
-- количество студентов = 17
-- курс проводится в том же университете что и курс Data Mining

insert into course values (60,'Machine Learning', false, 17 , 
			(select cg.id from college cg join course cs
			on cg.id = cs.college_id
			where cs.name = 'Data Mining'))
			
select * from course

--j. Напишите SQL скрипт который подсчитывает симметрическую разницу множеств A и B. (A \ B) ⋃ (B \ A)
-- где A - таблица course, B - таблица student_on_course, “\” - это разница множеств, “⋃” - объединение множеств. Необходимо подсчитать на
-- основании атрибута id из обеих таблиц. Результат отсортируйте по 1 столбцу.

select id from course cs
except
select id from student_on_course st

union

select id from student_on_course st
except
select id from course cs
order by 1

--k. Напишите SQL запрос который вернет имена студентов, курс на котором они учатся, названия их родных университетов (в которых они
-- официально учатся) и соответствующий рейтинг по курсу. С условием что рассматриваемый рейтинг студента должен быть строго больше (>)
-- 50 баллов и размер соответствующего ВУЗа должен быть строго больше (>) 5000 студентов. Результат необходимо отсортировать по первым двум столбцам.

select 
st.name as student_name,
cs.name as course_name,
cl.name as student_college,
stc.student_rating as student_rating
	from student st
		left join student_on_course stc
			on st.id = stc.student_id
		left join course cs
			on cs.id = stc.course_id
		left join college cl
			on cl.id = st.college_id
where student_rating > 50 and cl."size" > 5000
order by 1, 2

--l. Выведите уникальные семантические пары студентов, родной город которых один и тот же. Результат необходимо отсортировать по первому
-- столбцу. Семантически эквивалентная пара является пара студентов например (Иванов, Петров) = (Петров, Иванов), в этом случае должна
-- быть выведена одна из пар.

select distinct on (st1.city)
st1.name as student_1,
st2.name as student_2,
st1.city as city
	from student st1
	 join student st2
	 	on st1.city = st2.city
where st1.name != st2.name

--m. Напишите SQL запрос который возвращает количество студентов, сгруппированных по их оценке. Результат отсортируйте по названию оценки студента. 
-- ЕСЛИ оценка < 30 ТОГДА неудовлетворительно
-- ЕСЛИ оценка >= 30 И оценка < 60 ТОГДА удовлетворительно
-- ЕСЛИ оценка >= 60 И оценка < 85 ТОГДА хорошо
-- В ОСТАЛЬНЫХ СЛУЧАЯХ отлично

select
	case
		when stc.student_rating < 30 then 'неудовлетворительно'
		when stc.student_rating >= 30 and stc.student_rating < 60 then 'удовлетворительно'
		when stc.student_rating >= 60 and stc.student_rating < 85 then 'хорошо'
		else 'отлично'
	end as оценка,
	count(*) as "количество студентов" 
from student_on_course stc
group by оценка
order by оценка

--n. Дополните SQL запрос из задания a), с указанием вывода имени курса и количество оценок внутри курса. Результат отсортируйте по названию
-- курса и оценки студента. Пример части результата ниже. Обратите внимание на именование результирующих столбцов в вашем
-- решении. Курс “Machine Learning”, так как у него нет студентов - проигнорируйте, используя соответствующий тип JOIN.

select
cs.name as курс,
	case
		when stc.student_rating < 30 then 'неудовлетворительно'
		when stc.student_rating >= 30 and stc.student_rating < 60 then 'удовлетворительно'
		when stc.student_rating >= 60 and stc.student_rating < 85 then 'хорошо'
		else 'отлично'
	end as оценка,
	count(*) as "количество студентов" 
from student_on_course stc
left join course cs
	on  cs.id = stc.course_id
group by курс, оценка
order by курс, оценка