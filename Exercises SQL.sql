use employees;

#Exercise 1
SELECT 
    d.dept_name, e.gender, AVG(s.salary)
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_name , e.gender
ORDER BY d.dept_name; 

#Exercise 2
SELECT 
    MIN(dept_no)
FROM
    dept_emp; 
SELECT 
    MAX(dept_no)
FROM
    dept_emp;
    
#Exercise 3
SELECT 
    e.emp_no,
    (SELECT 
            MIN(de.dept_no)
        FROM
            dept_emp de
        WHERE
            de.emp_no = e.emp_no) AS dept_no,
    (CASE
        WHEN emp_no <= 10020 THEN '110022'
        ELSE '110039'
    END) AS manager
FROM
    employees e
WHERE
    e.emp_no <= 10040;

#Exercise 4
SELECT 
    *
FROM
    employees
WHERE
    YEAR(hire_date) = 2000;
    
#Exercise 5
SELECT 
    *
FROM
    titles
WHERE
    title LIKE ('%Engineer%');
    
SELECT 
    *
FROM
    titles
WHERE
    title LIKE ('%Senior Engineer%');
    
#Exercise 6
delimiter $$
create procedure last_dep(in p_emp_no varchar(255))
begin
	select p_emp_no, d.dept_no, d.dept_name
    from employees e join dept_emp de on de.emp_no=e.emp_no 
    join departments d on d.dept_no=de.dept_no
    where p_emp_no=e.emp_no 
		and de.from_date=(select max(de.from_date) 
							from dept_emp de 
                            where de.emp_no=e.emp_no);
    end$$ 
    delimiter ;
call employees.last_dep(10010);

#Exercise 7
SELECT 
    COUNT(*)
FROM
    salaries
WHERE
    DATEDIFF(to_date, from_date) > 365
        AND salary >= 100000;
        
#Exercise 8
delimiter $$
CREATE trigger t_hire_date
before insert on employees
for each row
begin
	if new.hire_date> date_format(sysdate(),'%Y-%m-%d') 
    then set new.hire_date= date_format(sysdate(),'%Y-%m-%d');
    end if;
end $$
delimiter ;

INSERT employees VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');  

SELECT 
    *
FROM
    employees
ORDER BY emp_no DESC;

#Exercise 9
delimiter $$
create function large_cont (f_emp_no integer) returns decimal(10,2)
DETERMINISTIC NO SQL READS SQL DATA
begin
	declare f_salary decimal(10,2);
SELECT 
    MAX(salary)
INTO f_salary FROM
    salaries
WHERE
    f_emp_no = emp_no;
    return f_salary;
end$$
delimiter ;

delimiter $$
create function low_cont (f_emp_no integer) returns decimal(10,2)
DETERMINISTIC NO SQL READS SQL DATA
begin
	declare f_salary decimal(10,2);
SELECT 
    MIN(salary)
INTO f_salary FROM
    salaries
WHERE
    f_emp_no = emp_no;
    return f_salary;
end$$
delimiter ;

select large_cont(11356);
select low_cont(11356);

#Exercise 10
delimiter $$
create function max_min_cont (f_emp_no integer,max_min varchar(255)) returns decimal(10,2)
DETERMINISTIC NO SQL READS SQL DATA
begin
	declare f_salary decimal(10,2);
SELECT 
    CASE
        WHEN max_min = 'max' THEN MAX(salary)
        WHEN max_min = 'min' THEN MIN(salary)
        ELSE (MAX(salary) - MIN(salary))
    END
INTO f_salary FROM
    salaries
WHERE
    f_emp_no = emp_no;
    return f_salary;
end$$
delimiter ;

select max_min_cont(11356,'minn');
select max_min_cont(11356,'max');
select max_min_cont(11356,'min');