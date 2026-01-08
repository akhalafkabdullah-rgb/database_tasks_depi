
create database company

use company

/*The company has a number of employees; each employee has SSN, Birth Date,
Gender and Name which represented as Fname and Lname*/
create table employee (ssn int primary key ,fname char(20),lname char(20),gender char(10),birth_data date ) 

--The company has a set of departments; each department has a set of attributes DName, DNUM (unique) and locations.
create table departments(dnum int primary key ,dname varchar(20))
create table locations (dnum int ,location varchar(100),
constraint fk8 foreign key(dnum) references departments(dnum)) 


--Employees work in several projects; each project has Pname, PNumber as an identifier, Location City.

create table project(pname varchar(20),pnum int primary key,location varchar(50) )

--Each employee may have a set of dependents; each dependent has Dependent Name (unique), Gender and Birthdate.
--Note: if the employee left the company no needs to store his dependents info.
create table dependant(name varchar(20) primary key,gender varchar(20),birth_date date,rely_on int ,
constraint fk1 foreign key (rely_on) references employee(ssn) on delete cascade)

--For each Department, there is always one employee assigned to manage that Department and each manager has a hiring Date.


alter table departments add manger_id int ,hiring_date date
alter table departments add constraint fk2 foreign key(manger_id) references employee(ssn) 
on delete set null on update cascade


--Department may have employees but employee must work on Only One department.
alter table employee add dp_work_on int
alter table employee add constraint fk3 foreign key(dp_work_on) references departments(dnum)


--Each department may have a set of projects and each project must assigned to one department.

alter table project add dp_id int
alter table project add constraint fk4 foreign key (dp_id) references departments(dnum)


--Employees work in several projects and each project has several employees and
--each employee has a number of working hours in each project.
create table eployee_in_project (employee_id int,project_id int,hours_of_work int,PRIMARY key (employee_id, project_id),
constraint fk5 foreign key(employee_id) references employee(ssn) on delete cascade on update cascade,
constraint fk6 foreign key(project_id) references project(pnum) on delete cascade on update cascade )


--Each employee has a supervisor.


alter table employee add supervisor_id int
alter table employee add constraint fk7 foreign key(supervisor_id) references employee(ssn) 

INSERT INTO employee (ssn, fname, lname, gender, birth_data, supervisor_id, dp_work_on)
VALUES 
(100, 'Ahmed', 'Ali', 'Male', '1985-01-01', 100, NULL),
(200, 'Mona', 'Samy', 'Female', '1990-05-10', 200, NULL),
(300, 'Hany', 'Fawzy', 'Male', '1982-12-12', 300, NULL);


INSERT INTO departments (dnum, dname, manger_id, hiring_date)
VALUES 
(10, 'HR', 100, '2020-01-01'),
(20, 'IT', 200, '2021-06-15'),
(30, 'Sales', 300, '2019-03-01');

INSERT INTO locations (dnum, location)
VALUES 
(10, 'Cairo'), (10, 'Giza'),
(20, 'Alexandria'), (20, 'Smart Village'),
(30, 'Mansoura');

INSERT INTO employee (ssn, fname, lname, gender, birth_data, supervisor_id, dp_work_on)
VALUES 

(101, 'Ziad', 'Hassan', 'Male', '1995-03-20', 100, 10),
(102, 'Noha', 'Karim', 'Female', '1996-07-15', 100, 10),

(201, 'Sara', 'Amr', 'Female', '1998-11-05', 200, 20),
(202, 'Omar', 'Khaled', 'Male', '1993-02-28', 200, 20),
(203, 'Yassin', 'Ehab', 'Male', '1994-09-12', 201, 20), 

(301, 'Laila', 'Zaki', 'Female', '1991-04-18', 300, 30),
(302, 'Mostafa', 'Gad', 'Male', '1989-10-10', 300, 30);

INSERT INTO project (pnum, pname, location, dp_id)
VALUES 
(1, 'Cloud System', 'Cairo', 20),
(2, 'ERP Update', 'Alexandria', 20),
(3, 'Hiring Campaign', 'Cairo', 10),
(4, 'Annual Sales', 'Mansoura', 30);

INSERT INTO eployee_in_project (employee_id, project_id, hours_of_work)
VALUES 
(201, 1, 20), (201, 2, 20), 
(202, 1, 40),               
(101, 3, 30),               
(301, 4, 15), (302, 4, 45); 


UPDATE employee SET dp_work_on = 10 WHERE ssn = 100;
UPDATE employee SET dp_work_on = 20 WHERE ssn = 200;
UPDATE employee SET dp_work_on = 30 WHERE ssn = 300;