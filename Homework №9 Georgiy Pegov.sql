-------------------------------------------------------------------------------------------------
    --Решение №1 по требованиям задания-- (не смог добиться корректной работы триггеров)
-------------------------------------------------------------------------------------------------

create table students (
    id serial primary key,
    name text,
    total_score integer,
    scholarship integer
);

create table activity_scores (
	id serial primary key,
    student_id integer references students(id),
    activity_type text,
    score integer
); 

insert into students (name, total_score)
values
	('Erik the Red', 90),
    ('Leif Erikson', 80),
    ('Hagar the Horrible', 70),
    ('Bjorn Ironside', 95),
    ('Ragnar Lothbrok', 85),
    ('Sigrid the Haughty', 75),
    ('Olaf the Stout', 79),
    ('Freydis Eiriksdottir', 89),
    ('Gunnar Hamundarson', 0);

drop table activity_scores

drop table students

insert into activity_scores (student_id, activity_type, score)
values
    (1, 'homework', 0),
    (2, 'exam', 3),
    (3, 'project', 1),
    (4, 'project', 1),
    (5, 'exam', 6),
    (7, 'homework', 1),
    (8, 'exam', 2),
    (9, 'project', 1000);
    
   
-- задача 1
   
drop function update_total_score

create or replace function update_total_score(student_id integer) returns void as $$
declare
    total_activity_score integer;
    student_total_score integer;
    activity_record record;
begin 
    select total_score into student_total_score from students where id = student_id;
    
    total_activity_score := 0;
    
    for activity_record in
        select score from activity_scores as a where a.student_id = update_total_score.student_id
    loop
        total_activity_score := total_activity_score + activity_record.score;
    end loop;
    
    update students set total_score = student_total_score + total_activity_score where id = student_id;
end;
$$ language plpgsql;

--select update_total_score(9);

--drop function update_total_score_trigger()

create or replace function update_total_score_trigger() returns trigger as $$
begin
    perform update_total_score(new.student_id);
    return new;
end;
$$ language plpgsql;

create trigger update_total_score_trigger
after insert or update on activity_scores
for each row
execute function update_total_score_trigger();

-- задача 2

--drop function calculate_scholarship    

create or replace function calculate_scholarship(student_id integer)
returns integer as $$
declare
    student_total_score integer;
    scholarship_amount integer;
begin
    select total_score into student_total_score from students where id = student_id;
    
    if student_total_score >= 90 then
        scholarship_amount := 1000;
    elsif student_total_score >= 80 then
        scholarship_amount := 500;
    else
        scholarship_amount := 0;
    end if;
    return scholarship_amount;
end;
$$ language plpgsql;

--update students
--set scholarship = calculate_scholarship(id);

--drop function calculate_scholarship_trigger()

create or replace function calculate_scholarship_trigger() returns trigger as $$
begin
    if tg_op = 'insert' or tg_op = 'update' then
        update students
        set scholarship = calculate_scholarship(new.student_id)
        where id = new.student_id;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger calculate_scholarship_trigger
after insert or update on activity_scores
for each row
execute function calculate_scholarship_trigger();

select st.id, st.name, st.total_score, st.scholarship, acts.activity_type, acts.score
from students st
left join activity_scores acts on st.id = acts.student_id
order by st.id;

-------------------------------------------------------------------------------------------------
    --Решение №2-- (все работает)
-------------------------------------------------------------------------------------------------
drop table activity_scores

drop table students

create table students (
    id serial primary key,
    name text,
    total_score integer,
    scholarship integer
);

create table activity_scores (
	id serial primary key,
    student_id integer references students(id),
    activity_type text,
    score integer
); 

insert into students (name, total_score)
values
	('Erik the Red', 90),
    ('Leif Erikson', 80),
    ('Hagar the Horrible', 70),
    ('Bjorn Ironside', 95),
    ('Ragnar Lothbrok', 85),
    ('Sigrid the Haughty', 75),
    ('Olaf the Stout', 79),
    ('Freydis Eiriksdottir', 89),
    ('Gunnar Hamundarson', 0);

create or replace function calculate_scholarship(student_id integer)
returns integer as $$
declare
    student_total_score integer;
    scholarship_amount integer;
begin
    select total_score into student_total_score from students where id = student_id;
    
    if student_total_score >= 90 then
        scholarship_amount := 1000;
    elsif student_total_score >= 80 then
        scholarship_amount := 500;
    else
        scholarship_amount := 0;
    end if;
   
    return scholarship_amount;
end;
$$ language plpgsql;

create or replace function sum_total_score(activity_student_id integer)
returns integer as $$
declare
    total_score_new integer;
    current_total_score integer; --важно добавить переменную для текущего значения total_score
begin
    select total_score into current_total_score from students where id = activity_student_id;

    total_score_new := current_total_score + coalesce((select sum(score) from activity_scores acs where acs.student_id = activity_student_id), 0);
    
    return total_score_new;
end
$$ language plpgsql;
    
create or replace function update_total_score_and_scholarship()
returns trigger as $$
declare 
	k record;
begin
	for k in 
		select id from students 
	loop
		update 
			students 
		set
			total_score = sum_total_score(k.id)
		where 
			id = k.id;
		
		update 
			students 
		set
			scholarship = calculate_scholarship(k.id)
		where 
			id = k.id;
		
		end loop;
	
	return new;
end;
$$ language plpgsql;

create or replace trigger update_total_score_and_scholarship
after insert or update on activity_scores
execute function update_total_score_and_scholarship()

insert into activity_scores (student_id, activity_type, score)
values
    (1, 'homework', 0),
    (1, 'exam', 5),
    (1, 'project', 0),
    (2, 'homework', 3),
    (2, 'exam', 3),
    (2, 'project', 1),
    (3, 'homework', 2),
    (3, 'exam', 0),
    (3, 'project', 1),
    (4, 'homework', 2),
    (4, 'exam', 0),
    (4, 'project', 1),
    (5, 'homework', 0),
    (5, 'exam', 4),
    (5, 'project', 0),
    (6, 'homework', 0),
    (6, 'exam', 3),
    (6, 'project', 3),
    (7, 'homework', 1),
    (7, 'exam', 0),
    (7, 'project', 0),
    (8, 'homework', 0),
    (8, 'exam', 2),
    (8, 'project', 0),
    (9, 'homework', 10),
    (9, 'exam', 100),
    (9, 'project', 1000);

select st.id, st.name, st.total_score, st.scholarship, acts.activity_type, acts.score
from students st
left join activity_scores acts on st.id = acts.student_id
order by st.id;