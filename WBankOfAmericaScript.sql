use master
go

if db_id('WBankOfAmerica') is not null
begin
	alter database WBankOfAmerica set single_user with rollback immediate;
	drop database WBankOfAmerica;
end
go

create database WBankOfAmerica
go

use WBankOfAmerica
go

create schema WBank;
go

--create AccountType table
create table WBank.AccountType (
	AccountTypeID int identity (1,1) primary key
	,AccountType varchar (150) not null
)

--create Customers table
create table WBank.Customers (
	CustomerID int identity (1,1) primary key
	,DateCreated smalldatetime not null
	,AccountNumber int not null
	,AccountTypeID int foreign key references WBank.AccountType (AccountTypeID) not null
	,CustomerFirstName varchar (100) not null
	,CustomerLastName varchar (100) not null
	,Gender varchar (10)
	,CustomerAddress varchar (50) 
	,CustomerCity varchar (50)
	,CustomerState char (2)
	,PhoneNumber varchar (50) not null
	,EmailAddress varchar (100)
)

--create Locations table
create table WBank.Locations (
	LocationID int identity (1,1) primary key
	,LocationCode char (3) not null
	,LocationAddress varchar(50) not null
	,LocationCity varchar (50) not null
	,LocationState char (2) not null
)

--create Employees table
create table WBank.Employees (
	EmployeeID int identity (1,1) primary key
	,EmployeeNumber int not null
	,EmployeeFirstName varchar (100) not null
	,EmployeeLastName varchar (100) not null
	,Title varchar (50)
	,CanCreateNewAccount bit not null
)

--create CheckCashing table
create table WBank.CheckCashing (
	CheckCashingID int identity (1,1) primary key
	,LocationID int foreign key references WBank.Locations (LocationID) not null
	,EmployeeID int foreign key references WBank.Employees (EmployeeID) not null
	,CustomerID int foreign key references WBank.Customers (CustomerID) not null
	,CheckCashingDate smalldatetime not null
	,CheckCashingAmount money not null
)

--create Deposits table
create table WBank.Deposits (
	DepositID int identity (1,1) primary key
	,LocationID int foreign key references WBank.Locations (LocationID) not null
	,EmployeeID int foreign key references WBank.Employees (EmployeeID) not null
	,CustomerID int foreign key references WBank.Customers (CustomerID) not null
	,DepositDate smalldatetime not null
	,DepositAmount money not null
)

--create Withdrawals table
create table WBank.Withdrawals (
	WithdrawalID int identity (1,1) primary key
	,LocationID int foreign key references WBank.Locations (LocationID) not null
	,EmployeeID int foreign key references WBank.Employees (EmployeeID) not null
	,CustomerID int foreign key references WBank.Customers (CustomerID) not null
	,WithdrawalDate smalldatetime not null
	,WithdrawalAmount money not null
	,WithdrawalSuccessful bit not null
)
go

--insert 4 entries into WBank.AccountType
--select * from WBank.AccountType
insert into WBank.AccountType 
values
	('Savings Account')
	,('Checking Account')
	,('Money Market Account')
	,('Certificate of Deposit Account');
go

--insert 25 entries into WBank.Customers
--select * from WBank.Customers
insert into WBank.Customers
values
	('2014-03-11', 1, 2, 'Gretchin', 'Smith', 'Female', '22 Rock Lane', 'Branson', 'MO', '(417)889-7756', 'grSmith@cox.net')
	,('2015-08-22', 2, 2, 'Hank', 'Smith', 'Male', '22 Rock Lane', 'Branson', 'MO', '(417)889-7757', 'haSmith@cox.net')
	,('2016-12-05', 3, 2, 'Delilah', 'Smith', 'Female', '23 Rock Lane', 'Branson', 'MO', '(417)889-7767', 'deSmith@gmail.com')
	,('2017-05-18', 4, 1, 'Jeremiah', 'Crankson', 'Male', '4955 Sword Road', 'VA Beach', 'VA', '(757)556-1344', 'jerryCrank12@gmail.com')
	,('2013-04-17', 10, 3, 'Ivan', 'Kelly', 'Male', '465 South Country Drive', 'Randolph', 'MA', '(781)234-3347', 'iksmail@icloud.com')
	,('2014-11-02', 11, 4, 'Bob', 'Jones', 'Male', '98 Harrison Street', 'Grosse Pointe', 'MI', '(313)456-4456', 'bobsmailbox@gmail.com')	
	,('2021-08-14', 18, 2, 'Jeremy', 'Jones', 'Male', '33 Brook Lane', 'Montgomery Village', 'MD', '(240)889-9989', 'jj3@gmail.com')
	,('2012-12-20', 19, 2, 'Jeremy', 'Jones', 'Male', '639 Catherine Road', 'Council Bluffs', 'IA', '(712)988-9899', 'jj1@gmail.com')
	,('2013-07-03', 20, 2, 'Jeremy', 'Jones', 'Male', '895 Meadow Lane', 'Hobart', 'IN', '(219)898-8988', 'jj3@gmail.com')
	,('2014-02-09', 21, 2, 'Bob', 'Yuely', 'Male', '300 Pulaski Ave', 'Tulare', 'CA', '(559)579-1234', 'bymail@icloud.com')
	,('2015-09-27', 22, 2, 'Shelly', 'Yuely', 'Female', '300 Pulaski Ave', 'Tulare', 'CA', '(559)579-4321', 'symail@icloud.com')
	,('2016-04-04', 23, 2, 'Bobby', 'Yuely', 'Male', '300 Pulaski Ave', 'Tulare', 'CA', '(559)579-9876', 'bbymail@icloud.com')
	,('2017-11-19', 24, 2, 'Diana', 'Yuely', 'Female', '300 Pulaski Ave', 'Tulare', 'CA', '(559)579-6789', 'dymail@icloud.com');

insert into WBank.Customers
	(DateCreated, AccountNumber, AccountTypeID, CustomerFirstName, CustomerLastName, Gender, PhoneNumber) 
values
	('2018-10-30', 5, 1, 'Hailey', 'Swanson', 'Female', '(334)230-2223')
	,('2021-11-25', 8, 1, 'Shelly', 'Winslow', 'Female', '(353)985-5556')
	,('2012-09-10', 9, 1, 'Jack', 'Harrison', 'Male', '(245)365-8878')
	,('2015-06-29', 12, 1, 'Jill', 'Hill', 'Female', '(665)973-6654')
	,('2016-01-15', 13, 4, 'Jack', 'Hill', 'Male', '(665)973-66545')
	,('2018-06-12', 25, 3, 'Paul', 'Roberts', 'Male', '(656)320-4563');

insert into WBank.Customers
	(DateCreated, AccountNumber, AccountTypeID, CustomerFirstName, CustomerLastName, Gender, CustomerAddress, CustomerCity, CustomerState, PhoneNumber ) 
values
	('2019-02-14', 6, 4, 'Bob', 'Hampton', 'Male', '128 Summit Road', 'Wheaton', 'IL', '(630)225-5565')
	,('2020-07-07', 7, 4, 'Bailey', 'Hampton', 'Female', '128 Summit Road', 'Wheaton', 'IL', '(630)225-5576')
	,('2017-08-08', 14, 3, 'Jim', 'Jones', 'Male', '952 South Country Club Road', 'South Ozone Park', 'NY', '(718)123-1234')
	,('2018-01-23', 15, 2, 'Jim', 'Johnson', 'Male', '953 South Country Club Road', 'South Ozone Park', 'NY', '(718)133-1245')
	,('2019-10-11', 16, 2, 'Delilah', 'Jones', 'Female', '952 South Country Club Road', 'South Ozone Park', 'NY', '(718)123-1234')
	,('2020-03-06', 17, 1, 'Jimmy', 'Jones', 'Male', '952 South Country Club Road', 'South Ozone Park', 'NY', '(718)123-1234');
go

--insert 25 entries into WBank.Employees
--select * from WBank.Employees 
insert into WBank.Employees
values
	(1, 'Rutherford', 'Palenski', 'Mr', 1)
	,(2, 'Samantha', 'Palenski', 'Mrs', 1)
	,(3, 'Jacob', 'Wilson', 'Mr', 1)
	,(4, 'Tammy', 'Wilson', 'Mrs', 1)
	,(6, 'William', 'Bugel', 'Mr', 1)
	,(7, 'Shelly', 'Bugel', 'Mrs', 1)
	,(8, 'Paleena', 'Palenski', 'Ms', 1)
	,(9, 'Jebediah', 'Schlatt', 'Mr', 1)
	,(10, 'Shelly', 'Shellson', 'Mrs', 1)
	,(11, 'Jebodiah', 'Schlatt', 'Mr', 1)
	,(14, 'Uriah', 'Williamson', 'Mr', 1)
	,(15, 'Pam', 'Shell', 'Mrs', 0)
	,(19, 'David', 'Attenborough', 'Sir', 1)
	,(20, 'Robert', 'Frost', 'Dr', 1)
	,(21, 'Hank', 'Green', 'Prof', 1)
	,(22, 'David', 'Green', 'Rev', 1);

insert into WBank.Employees
	(EmployeeNumber, EmployeeFirstName, EmployeeLastName, CanCreateNewAccount)
values
	(5, 'Riley', 'Roberts', 0)
	,(16, 'Jack', 'Jackson', 0)
	,(17, 'Jill', 'Jillson', 0)
	,(18, 'Pam', 'Pamperton', 1)
	,(12, 'Jack', 'Winslow', 1)
	,(13, 'Bob', 'Henderson', 0)
	,(23, 'Hailey', 'Blues',  0)
	,(24, 'Bob', 'Baker',  0)
	,(25, 'Pam', 'Baker',  0);
go

--insert 10 entries into WBank.Locations
--select * from WBank.Locations
insert into WBank.Locations
values
	('VA1', '3936 Portsmouth Boulevard', 'Portsmouth', 'VA')
	,('VA2', '5716 High Street West', 'Portsmouth', 'VA')
	,('VA3', '608 J Clyde Morris Boulevard', 'Newport News', 'VA')
	,('CA1', '707 Wilshire Blvd Suite 209', 'Los Angelas', 'CA')
	,('CA2', '1690 S El Camino Real', 'San Mateo', 'CA')
	,('MO1', '434 State Hwy Y',' St Robert', 'MO')
	,('NY1', '270 Park Avenue', 'New York City', 'NY')
	,('NC1', '100 North Tyron Street', 'Charlotte', 'NC')
	,('PA1', '300 Fifth Avenue', 'Pittsburg', 'PA')
	,('NJ1', '1701 Route 70 East', 'Cherry Hill', 'NJ');
go

--insert 15 entries into WBank.Deposits
--select * from WBank.Deposits
insert into WBank.Deposits 
values 
	 (1, 1, 1, '2013-09-15 08:30:00', $127)
	,(2, 2, 2, '2014-05-21 14:45:00', $213)
	,(3, 3, 3, '2015-02-28 10:20:00', $317)
	,(4, 4, 4, '2016-10-05 16:55:00', $422)
	,(5, 5, 5, '2017-07-11 09:10:00', $511)
	,(6, 6, 6, '2018-03-17 11:25:00', $198)
	,(7, 7, 7, '2019-11-24 13:40:00', $305)
	,(8, 8, 8, '2020-08-30 15:55:00', $487)
	,(9, 9, 9, '2012-12-06 18:10:00', $545)
	,(10, 10, 10, '2013-06-12 20:25:00', $163)
	,(1, 11, 11, '2014-01-18 22:40:00', $246)
	,(2, 12, 12, '2015-08-25 00:55:00', $374)
	,(3, 13, 13, '2016-04-02 03:10:00', $561)
	,(4, 14, 14, '2017-11-08 05:25:00', $201)
	,(5, 15, 15, '2018-06-14 07:40:00', $589);
go

--insert 15 entries into WBank.Withdrawals
--select * from WBank.Withdrawals
insert into WBank.Withdrawals 
values 
	 (1, 1, 1, '2012-10-10 09:30:00', $40, 1)
	,(2, 2, 2, '2013-04-17 11:45:00', $30, 0)
	,(3, 3, 3, '2014-11-24 08:20:00', $30, 1)
	,(4, 4, 4, '2015-06-30 14:55:00', $30, 1)
	,(5, 5, 5, '2016-02-06 09:10:00', $30, 1)
	,(6, 6, 6, '2017-09-13 11:25:00', $40, 1)
	,(7, 7, 7, '2018-04-20 13:40:00', $40, 0)
	,(8, 8, 8, '2019-12-26 15:55:00', $40, 1)
	,(9, 9, 9, '2020-09-01 18:10:00', $40, 1)
	,(10, 10, 10, '2013-01-07 20:25:00', $50, 1)
	,(1, 11, 11, '2014-08-14 22:40:00', $50, 1)
	,(2, 12, 12, '2015-03-21 00:55:00', $50, 1)
	,(3, 13, 13, '2016-10-27 03:10:00', $50, 1)
	,(4, 14, 14, '2017-05-03 05:25:00', $60, 1)
	,(5, 15, 15, '2018-12-09 07:40:00', $20, 0);
go

--insert 15 entries into WBank.CheckCashing
--select * from WBank.CheckCashing
insert into WBank.CheckCashing 
values 
	 (1, 1, 1, '2012-11-11 08:30:00', $1023)
	,(2, 2, 2, '2013-05-18 14:45:00', $1156)
	,(3, 3, 3, '2014-12-25 10:20:00', $1205)
	,(4, 4, 4, '2015-07-01 16:55:00', $1348)
	,(5, 5, 5, '2016-02-07 09:10:00', $1421)
	,(6, 6, 6, '2017-09-14 11:25:00', $1579)
	,(7, 7, 7, '2018-04-21 13:40:00', $1692)
	,(8, 8, 8, '2019-12-27 15:55:00', $1291)
	,(9, 9, 9, '2020-09-02 18:10:00', $1827)
	,(10, 10, 10, '2013-01-08 20:25:00', $1456)
	,(1, 11, 11, '2014-08-15 22:40:00', $1389)
	,(2, 12, 12, '2015-03-22 00:55:00', $1292)
	,(3, 13, 13, '2016-10-28 03:10:00', $1498)
	,(4, 14, 14, '2017-05-04 05:25:00', $1376)
	,(5, 15, 15, '2018-12-10 07:40:00', $1104);
go