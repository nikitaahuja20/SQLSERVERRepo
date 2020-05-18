--1.Display what each books price would be if a 20% price increase were to take place. Show the title id , old price and new price using meaningful headings

Select [title_id],[price] as old_price,[price]+[price]*0.2 as new_Price  from [dbo].[titles]
----------------------------------------------------------------------
--2.Summarize the total sales for each publishers

select p.pub_id, p.pub_name, sum(t.ytd_sales) as sales
from dbo.titles t,
	 dbo.publishers p
where t.pub_id = p.pub_id
group by p.pub_id, p.pub_name
----------------------------------------------------------------------
--3.For annual report, display the publisher’s id, the title id price and total sales while showing the average price and total sales for each publishers, as well as the average price and total year to date sales overall.
select pd.pub_id,
	   pd.title_id,
	   pd.price,
	   pd.ytd_sales,
	   pd.avg_price,
	   pd.total_sales,
	   avg(price) over (partition by dummy order by dummy) as avg_price_overall,
	   sum(ytd_sales) over (partition by dummy order by dummy) as ytd_sales_overall   
from
(
	select 1 as dummy,
		   pub_id, title_id, price, ytd_sales,	
		   avg(price) over (partition by pub_id order by pub_id) as avg_price,
		   sum(ytd_sales) over (partition by pub_id order by pub_id) as total_sales
	from dbo.titles
) as pd		
----------------------------------------------------------------------
--4.Display the name of books whose price are greater than $20 and less than $55.
select title
from dbo.titles
where price > 20 and price < 55
----------------------------------------------------------------------
--5.Display total sales made in each category. Category-Wise
select type as category, sum(ytd_sales) as sales
from dbo.titles
where ytd_sales is not null
group by type
----------------------------------------------------------------------
--6.Display the numeric part of every title id (the numeric part of the title eg BU1032 , 1032)
select  title_id,
		SUBSTRING(title_id, 3, len(title_id)-2) as title_numeric
from dbo.titles
----------------------------------------------------------------------
--7.You want to retrieve data for all the employees who joined after '1-12-90' have 4 – 6 years of experience.
select *
from dbo.employee 
where hire_date > '1-12-90'
  and datediff(yy,hire_date,getdate()) between 4 and 6
----------------------------------------------------------------------  
--8.You want to know the year of joining of each employee. How do you display those details:
select lname,
	   datepart(yy,hire_date) as year_of_joining
from employee
----------------------------------------------------------------------
--9.Display the collection of every book (price  * total sales) along with author_id
select ta.au_id,
	   t.title,
	   (t.price*t.ytd_sales) as collections
from dbo.titles t,
	 dbo.titleauthor ta
where t.title_id = ta.title_id
----------------------------------------------------------------------
--10.	List the stores that have ordered the  “Sushi, Anyone?”
select sa.stor_id,
	   st.stor_name
from dbo.sales sa,
	 dbo.stores st
where sa.stor_id = st.stor_id
	and	title_id =
	(
		select title_id from dbo.titles
		where title = 'Sushi, Anyone?'
	)
----------------------------------------------------------------------
--11.Who published Net Etiquette’s books?
select pub_name from dbo.publishers
where pub_id = 
(
	select pub_id from dbo.titles where title = 'Net Etiquette'
)
----------------------------------------------------------------------
--12.	List the Total_Sales for each title published by “New Moon Books” .
select title, ytd_sales 
from dbo.titles
where pub_id = 
	(
		select pub_id from dbo.publishers
		where pub_name = 'New Moon Books'
	)
----------------------------------------------------------------------
--13.Find the titles of books published by any publisher located in a city that begin with the letter ‘B’
select title, ytd_sales 
from dbo.titles
where pub_id in 
	(
		select pub_id from dbo.publishers where city like 'B%'
	)
----------------------------------------------------------------------
--14.Find the titles that obtain an advance larger than the average price for books of similar type.
select t.title, t.type, t.advance, av.avg_price
from dbo.titles t,
	(
		select type, avg(price) as avg_price
		from dbo.titles
		where price is not null
		group by type
	) as av
where t.type = av.type
  and advance > av.avg_price
----------------------------------------------------------------------
-- 15.Find the titles that obtain a larger advance than the minimum paid by “Algodata Infosystems”

select title
from dbo.titles
where advance > 
(
	select min(advance) as min_advance
	from dbo.titles
	where pub_id = 
	(
		select pub_id from dbo.publishers
		where pub_name = 'Algodata Infosystems'
	)
)
----------------------------------------------------------------------
--16.You want to know the name of the book where authors receive the highest royalty.

select title from dbo.titles
where title_id in
(
	select title_id
	from dbo.roysched
	where royalty =
	(
		select max(royalty) as max_r from dbo.roysched
	)
)
----------------------------------------------------------------------
--17.	You, as sales person, want to find out the names of all those books whose price is higher than that of all business books. Write a query to achieve this?
	
select title
from dbo.titles
where price > 
(
	select max(price) as max_price
	from dbo.titles where type = 'business'
)	


-----------------------------------Exercise 2-----------------------------------
-----------------------------------DML-----------------------------------

--1.Create your own employee table called My_Emp  by copying the data from existing table Employee in Pubs database.

select * into dbo.my_emp from dbo.employee
----------------------------------------------------------------------
--2.	Change the last name of employee ‘VPA30890F’ to Drexler.

update dbo.my_emp set lname = 'Drexler' where emp_id = 'VPA30890F'
----------------------------------------------------------------------
3.	Delete Paul Henriot from the MY_EMP table.

delete from dbo.my_emp where fname = 'Paul' and lname = 'Henriot'
----------------------------------------------------------------------
4.	Modify the job id of Pedro Afonso to 14

update dbo.my_emp set job_id = 14 where fname = 'Pedro' and lname = 'Afonso'
----------------------------------------------------------------------
5.	Add a new employee details to My_Emp table.
insert employee values ('NNV13322M', 'Nicky', 'N', 'Martin', 2, 215, '9952', '11/11/2013')
----------------------------------------------------------------------
6.	Remove all the job is which are below 5.
--assuming all people with job_id > 5 will be below its designation
delete from dbo.my_emp where job_id  > 5

--------------------------------------Exercise 3--------------------------------
--------------------------------------DDL-------------------------------
--1. Create the tables hoose the appropriate data types and constraints.

Member Table

Column Name	Member_ID	First_Name	Last_Name	Address	City	Phone	Join_Date
Key Type	PK						
Null / Unique	NN,U	NN					NN
Default Value							System Date
Data Type	Number	Varchar	Varchar	Varchar	Varchar	Varchar	DateTime
Length	10	25	25	100	30	15	

CREATE TABLE dbo.member
(
   member_id int NOT NULL CONSTRAINT PK_member_id PRIMARY KEY,
   first_name    varchar(25)  NOT NULL,
   last_name    varchar(25),
   address    varchar(100),
   city     varchar(30),
   phone    varchar(15),   
   join_date  datetime    NOT NULL DEFAULT (getdate())
)

----------------------------------------------------------------------
--2.Title Table

Column Name	Title_ID	Title	Description	Rating	Category	Release_Date
Key Type	PK					
Null / Unique	NN,U	NN	NN			
Check				G,PG,R,NC17,NR	Drama,
Comedy
Action,
Documentary
	
Data Type	Number	Varchar	Varchar	Varchar	Varchar	DateTime
Length		60	400	4	15	

CREATE TABLE dbo.title
(
   title_id int NOT NULL CONSTRAINT PK_title_id PRIMARY KEY,
   title    varchar(60)  NOT NULL,
   description    varchar(400) NOT NULL,
   rating    varchar(4)  CHECK (rating in ('G', 'PG', 'R', 'NC17', 'NR')),
   category     varchar(15) CHECK (category in ('Drama', 'Comedy', 'Action', 'Documentary')),  
   release_date  datetime 
)
----------------------------------------------------------------------
--3.Title_Copy Table

Column Name	Copy_ID	Title_ID	Status
Key Type	PK	PK,FK	
Null / Unique	NN,U	NN,U	NN
Check			Available,
Destroyed,
Rented,
Reserved


FK Ref Table		Title	
FK Ref Column		Title_ID	
Data Type	Number	Number	Varchar
Length			15

CREATE TABLE dbo.title_copy
(
   copy_id int NOT NULL UNIQUE,
   title_id int NOT NULL UNIQUE REFERENCES title(title_id),
   status     varchar(15) NOT NULL CHECK (status in ('Available', 'Destroyed', 'Rented', 'Reserved')),  
   
   CONSTRAINT PK_tcopy PRIMARY KEY (copy_id, title_id)
)
----------------------------------------------------------------------
--4.Rental Table

Column Name	Book_Date	Member_ID	Copy_ID	Act_Ret_Date	Exp_Ret_Date	Title_ID
Key Type	PK	PK,FK1	PK,FK2			PK,FK2
Default Value	System Date				System Date+2 days	
Check			
			
FK Ref Table		Member	Title_Copy			Title_Copy
FK Ref Column		Member_ID	Copy_ID			Title_ID
Data Type	DateTime	Number	Number	DateTime	DateTime	Number
Length						


CREATE TABLE dbo.rental
(
   book_date  datetime  DEFAULT (getdate()),
   member_id int REFERENCES member(member_id),
   copy_id int REFERENCES title_copy(copy_id),
   act_ret_date  datetime,
   exp_ret_date  datetime DEFAULT (getdate()+2),
   title_id int REFERENCES title_copy(title_id),
   
   CONSTRAINT PK_rental PRIMARY KEY (book_date, member_id, copy_id, title_id)
)

----------------------------------------------------------------------
--5.Reservation Table

Column Name	RES_Date	Member_ID	Title_ID
Key Type	PK	PK,FK1	PK,FK2
Null/Unique	NN,U	NN,U	NN
FK Ref Table		Member	Title
FK Ref Column		Member_ID	Title_ID
Data Type	DateTime	Number	Number


CREATE TABLE dbo.reservation
(
   res_date  datetime NOT NULL UNIQUE,   
   member_id int NOT NULL UNIQUE REFERENCES member(member_id),
   title_id int NOT NULL REFERENCES title(title_id),
   
   CONSTRAINT PK_res PRIMARY KEY (res_date, member_id, title_id)
)

--------------------------------Exercise 4-------------------------------------
--------------------------------Views--------------------------------------
--1.	Create a view called Title_View based on the Title numbers, Title names, and Publishers numbers from the Title table. Change the heading for the title to Books Name .


CREATE VIEW title_view
AS
select title_id, title as book_name, pub_id
from dbo.titles

---------------------------------------------------------------------
--2.	See the view text from the dictionary.
select * from dbo.title_view
sp_help title_view

---------------------------------------------------------------------
--3.	Create a view named Pub_City that contains the Title id, title  names, and publishers numbers for all title published by 0877. 

CREATE VIEW pub_city
AS
select title_id, title, pub_id
from dbo.titles where pub_id = 0877

---------------------------------------------------------------------

--4.	Create a view to display pub number, title, and type for every publishers 
     resides in the country USA


CREATE VIEW pub_usa
AS
select pub_id, title, type
from dbo.titles
where pub_id in



(
	select pub_id from dbo.publishers where country = 'USA'
)


---------------------------------------------------------------------
--1.	Create a nonunique index on the Pub_ID in the Title table.
CREATE INDEX idx_nu_pubid ON dbo.titles (pub_id)

select o.name as obj_name, i.name as idx_name,
	   i.type_desc, i.is_unique,
	   i.is_primary_key, i.is_unique_constraint
from sys.indexes i,
	 sys.objects o
where i.object_id = o.object_id
  and o.name in ('titles','publishers')


---------------------------------------------------------------------
--2.	Display the indexes Titles and Publishers table.










