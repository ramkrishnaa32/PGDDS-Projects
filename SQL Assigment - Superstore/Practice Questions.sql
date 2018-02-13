-- 1. Retrieve all the data from employee
select * from 
employee;

-- 2. Retrieve first name and last name from employee
select fname as 'First Name' , lname as 'Last Name' from 
employee;

-- 3. Retrieve all male employee who draw salary atleast 30000
select * from
employee
where sex='M' and salary >= 30000;
-- 4. Details of all dependents of essn 333445555
select * from 
dependent
where essn = 333445555;

-- 5. Display the name of the department and the year in which the manager
--    was appointed (Hint: Use the YEAR() function YEAR(mgr_start_date)
select dname as 'Department Name', year(mgr_start_date) as 'Year'
from department;

-- 6. Display the SSN of all employees who live in Houston
--    (Hint: use LIKE() function as in address LIKE '%Houston'
select super_ssn from
employee
where address like '%Houston%';

-- 7. Display employees whose name begins with J
select * 
from employee
where fname like 'j%';

-- 7. Display details of all (male employee who earn more than 30000) or female employees who earn less than 30000)
select * 
from employee
where (sex='M' and salary >30000) or (sex='F' and salary<30000);

-- 8. Display the essn of employees who have worked betwen 25 and 50 hours
--      a) Use AND clause
--      b) use BETWEEN clause  as in Hours between 25 and 30
 -- select * from works_on;
select essn, hours
from works_on
-- where hours >= 25 and hours <=50;
where hours between 25 and 50;


-- 9. Display the names of projects that are based out of houston or stafford
--      a) Use OR clause
--      b) Use IN clause as in Plocation in ('Houston', 'Stafford')
select * 
from project
where plocation in ('Houston','Stafford');
-- where plocation = 'Houston' or plocation = 'Stafford';

-- 10. Display the names of the project that are neither based out of houston nor out of stafford
--      a) Use AND/OR clause
--      b) use NOT IN clause as in Plocation NOT IN ('Houston','Stafford')
select * from project
where plocation not in  ('Houston','Stafford');

-- 11. Display the ssn and fully concatenated name of all employees
-- 	Use CONCAT function as in CONCAT(fname, ' ', minit, ' ', lname)

select ssn, concat(fname,' ',minit,' ',lname) as name
from employee;

-- 12. Display the employee details who does not have supervisor
-- 	Use IS NULL as in super_ssn IS NULL
select * from employee
where super_ssn is null;

-- 13. Display the ssn of employees sorted by their salary in ascending mode
-- 	Use ORDER by SALARY
select * from employee
order by salary asc;

select * from employee
order by salary desc;

-- distinct command
select distinct fname from employee;
-- limit command
select * from employee
limit 2;

-- 14. Sort the works_on table based on Pno and Hours
select * from works_on
order by pno,hours asc;

-- 15. Display the average project hours 
select avg(hours) as Avrage_Hours from works_on;
select min(hours) as Minimum_Hours from works_on;
select max(hours) as Miximum_Hours from works_on;
select sum(hours) as Total_Hours from works_on;
select count(*) as Total_count from works_on;

-- 16. Display the number of employees who do not have a manager
select count(*) as Count_of_Non_Manager from employee
where super_ssn is null;
-- select count(super_ssn) from employee;

-- 17. What is the average salary of employees who do not have a manager

select avg(salary) from employee
where super_ssn is null;

-- 18. What is the highest salary of female employees
select max(salary) as Max_Salary
from employee
where sex='F';

-- 19. What is the least salary of male employees
select min(salary) as Max_Salary
from employee
where sex='M';

-- 20. Display the number of employees in each department
select dno, count(*) as 'No. of employee'
from employee
group by dno;

select dno, count(*) as 'No. of employee'
from employee
group by dno
order by dno;

-- 21. Display the average salary of employees (department-wise and gender-wise)
-- 	GROUP BY Dno, Sex
select dno,sex, avg(salary)
from employee
group by dno,sex;

select dno,sex, avg(salary)
from employee
where ssn=333445555
group by dno,sex;

-- 22. Display the number of male employees in each department
select dno,sex, count(*) as 'No. of employees'
from employee
where sex='M'
group by dno;

-- 23. Display the average, minimum, maximum hours spent in each project
select pno, avg(hours) as 'Avg Hours', min(hours) as 'Min Hours', max(hours) as 'Max Hours'
from works_on
group by pno;

-- 24. Display the year-wise count of employees based on their year of birth
select year(bdate) as 'Born Year', count(*) as 'Total Count'
from employee
group by year(bdate)
order by year(bdate);

-- 25. Dipslay the number of projects each employee is working on
select essn, count(*) as 'Emp Count'
from works_on
group by essn;

-- 26. Display the Dno of those departments that has at least 3 employees
select dno, count(*) as 'Emp Coount'
from employee
group by dno
having count(*)>=3;

-- 27. Among the people who draw at least 30000 salary, what is the department-wise average?
select dno, avg(salary) as 'Avg Salary'
from employee
where salary >=30000
group by dno;

-- 27b. Instead of dno, display dname
select dno,dname, avg(salary) as 'Avg Salary'
from employee inner join department
on dno=dnumber
where salary >=30000
group by dno
order by dno;

-- 28. Display the fname of employees working in the Research department
-- select * from department;
-- select * from employee;
select fname from employee
where dno = (select dnumber from department where dname='Research');

-- 29. Display the fname and salary of employees whose salary is more than the average salary of all the employees

select fname,salary from employee
where salary >= (select avg(salary) from employee);

-- 30. Which project(s) have the least number of employees?
select * from works_on;
select pno, count(*) numemps 
from works_on 
group by pno 
having numemps = 
	(select min(nemps) 
	from (
		select pno, count(*) nemps 
		from works_on group by pno
	     ) tempproj
	 ); 

-- 31. Display the fname of those employees who work for at least 20 hours
select * from works_on;
select * from employee;

-- Need to check
select fname from employee
where ssn = (select essn from works_on where hours >= 20);

-- 32. What is the average salary of those employees who have at least one
--     dependent
select * from dependent;
select * from employee;
-- Need to check
select avg(salary) from employee
where ssn = (select essn from dependent where (select count(*) from department group by dependent_name having count(*)>=10));

-- JOIN EXAMPLES

select * from employee 
inner join department 
on employee.dno=department.dnumber;

select * from employee e
inner join department d
on e.dno=d.dnumber;

select e.fname, d.dname from employee e
inner join department d
on e.dno=d.dnumber;

-- 33. Display the ssn, lname and the name of the department of all the employees
select e.ssn, e.lname, d.dname from employee e
inner join department d
on e.dno=d.dnumber
order by ssn;

-- 34. Display the ssn, lname, name of project of all the employees

select e.ssn, e.lname, p.pname from employee e
inner join works_on w
on e.ssn=w.essn
inner join project p
on w.pno=p.pnumber
order by ssn;

-- 35a. Display the ssn, their department, the project they work on and
--     the name of the department which runs that project
-- 	Hint: Needs a 5 table join
-- 	Output heading: ssn, emp-dept-name, pname, proj-dept-no

select e.fname, ed.dname 'emp-dept-name', p.pname, pd.dname 'proj-dept-no'
from employee e
inner join department ed on e.dno=ed.dnumber
inner join works_on w on w.essn= e.ssn
inner join project p on p.pnumber=w.pno
inner join department pd on pd.dnumber=p.dnum;

-- 35b. Display the deptname, the project the department runs
-- 	Output heading: dept-name, pname

Select d.dname 'dept-name', p.pname 'Project-name'
from department d
inner join project p on d.dnumber=p.dnum
order by dname;

-- OUTER JOIN

-- Inner join between employee and dependent
select e.ssn, e.fname, d.dependent_name
from employee e inner join dependent d on e.ssn = d.essn;

-- Left Outer join between employee and dependent
select e.ssn, e.fname, d.dependent_name
from employee e left join dependent d on e.ssn = d.essn;

select e.fname, p.pname from employee e
Left join project p on e.dno=p.dnum;

-- Right out joint between dependent and employee
select e.ssn, e.fname, d.dependent_name
from deparment d right join employee e on e.ssn = d.essn;

select e.fname, p.pname from employee e
right join project p on e.dno=p.dnum;

-- Corelted Subquery
-- Show has >= the average salary in their respective department in employee table

select fname,salary,dno
from employee e1
where salary >= (select avg(salary) from employee e2 where  e2.dno=e1.dno);
