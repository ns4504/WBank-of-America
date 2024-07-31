use WBankOfAmerica
go
--Question 1
--Create Insert/Update Triggers on the Customers and Employees tables that will uppercase all the varchar fields
drop trigger if exists WBank.upperCustomers
go

create trigger WBank.upperCustomers on WBank.Customers
for insert, update
as
begin
	update WBank.Customers
	set
		CustomerFirstName = upper(CustomerFirstName)
		,CustomerLastName = upper(CustomerLastName)
		,Gender = upper(Gender)
		,CustomerAddress = upper(CustomerAddress)
		,CustomerCity = upper(CustomerCity)
		,CustomerState = upper(CustomerState)
		,EmailAddress = upper(EmailAddress);
end
go

drop trigger if exists WBank.upperEmployees
go

create trigger WBank.upperEmployees on WBank.Employees
for insert, update
as
begin
	update WBank.Employees
	set
		EmployeeFirstName = upper(EmployeeFirstName)
		,EmployeeLastName = upper(EmployeeLastName)
		,Title = upper(Title);
end
go

--Question 2
--Create Insert/Update Triggers on the deposits and withdrawal tables that rollbacks a transaction that has a negative amount.
drop trigger if exists WBank.rollbackNegativesWithdrawal
go

create trigger WBank.rollbackNegativesWithdrawal on WBank.Withdrawals
for insert, update
as
begin
	declare @withdrawAmt money
	declare @customerID int
	select 
		@withdrawAmt = WithdrawalAmount 
		,@customerID = CustomerID
	from 
		WBank.Withdrawals;

	declare @NewBal money 
	select @NewBal = WBank.fn_balance(@customerID) - @withdrawAmt;
	
	if @NewBal < 0 or @withdrawAmt < 0
	begin
		print 'Withdrawal amount cannot be more than what is in the account, or a negative value.'
		rollback
	end
end
go

drop trigger if exists WBank.rollbackNegativesDeposit
go

create trigger WBank.rollbackNegativesDeposit on WBank.Deposits
for insert, update
as
begin
	declare @depositAmt money
	declare @customerID int
	select 
		@depositAmt = DepositAmount 
		,@customerID = CustomerID
	from 
		inserted;

	if  @depositAmt < 0
	begin
		print 'Deposits cannot be negative.'
	rollback
	end
end

go

--Question 3
--Create a function, called fn_balance, that takes in a customerID as a parameter, and then returns the total balance available 
--for that customer. This function should return a money parameter that shows the customer's current balance.
drop function if exists WBank.fn_balance
go

create function WBank.fn_balance
(
	@customerID int
)
returns money
as
begin
	declare @deposits money
	declare @withdrawals money
	declare @initialValue money
	declare @balance money
	select
		@deposits = sum(d.DepositAmount)
		,@withdrawals = sum(w.WithdrawalAmount)
		,@initialValue = sum(cc.CheckCashingAmount)
	from
		WBank.Customers c
		join WBank.Deposits d on c.CustomerID = d.CustomerID
		join WBank.Withdrawals w on c.CustomerID = w.CustomerID
		join WBank.CheckCashing cc on c.CustomerID = cc.CustomerID
	where
		@customerID = c.CustomerID
	set @balance = (@initialValue + @deposits) - @withdrawals;
	return @Balance
end
go

--Question 4
--Create a view, called  vw_Customers, that shows all the customers (Full name in one column, Account Number, 
--and Type of Account they have, and their current balance). Have the columns returned be called full_name, account_number,  
--type_of_account, balance (Hint, you should use your Function created in question 3 to help with this).
create or alter view WBank.vw_Customers
as
select
	c.CustomerFirstName + ' '
		+ c.CustomerLastName CustomerName
	,c.AccountNumber
	,a.AccountType
	,WBank.fn_balance(c.CustomerID) Balance
from
	WBank.Customers c
	join WBank.AccountType a on c.AccountTypeID = a.AccountTypeID
go

select * from WBank.vw_Customers;
go

--Question 5
--Create a stored procedure called sp_all_customers that returns a select statement based on 
--all columns of your view created in question 4 above.
drop proc if exists WBank.sp_all_customers
go

create proc WBank.sp_all_customers
as
begin
	select 
		* 
	from 
		WBank.vw_Customers
end
go

exec WBank.sp_all_customers;
go

--Question 6
--Create a stored procedure, called sp_customer, that takes in a CustomerID as a parameter, and then returns a select statement 
--that shows the full name of the customer, the full name of the employee that does the transaction, the name/code of the branch 
--where the transaction was done, the transaction type (Deposit, or Withdrawal), and the amount of the transaction.  
--The columns returned should be cust_full_name, emp_full_name, location, transaction_type, amount, customer_id
drop proc if exists WBank.sp_customer
go

create proc WBank.sp_customer
	@customerID int
as
begin
	select
		*
	from
	(
			select
			c.CustomerFirstName + ' ' 
				+ c.CustomerLastName cust_full_name
			,e.EmployeeFirstName + ' ' 
				+ e.EmployeeLastName emp_full_name
			,l.LocationCode [location]
			,'Deposit' transaction_type
			,d.DepositAmount amount
			,c.CustomerID customer_id
		from
			WBank.Customers c
			join WBank.Deposits d on c.CustomerID = d.CustomerID
			join WBank.Employees e on d.EmployeeID = e.EmployeeID
			join WBank.Locations l on d.LocationID = l.LocationID

		union all

			select
			c.CustomerFirstName + ' ' 
				+ c.CustomerLastName cust_full_name
			,e.EmployeeFirstName + ' ' 
				+ e.EmployeeLastName emp_full_name
			,l.LocationCode [location]
			,'Withdrawal' transaction_type
			,w.WithdrawalAmount amount
			,c.CustomerID customer_id
		from
			WBank.Customers c
			join WBank.Withdrawals w on c.CustomerID = w.CustomerID
			join WBank.Employees e on w.EmployeeID = e.EmployeeID
			join WBank.Locations l on w.LocationID = l.LocationID
	) transactions

	where @customerID = transactions.customer_id
end
go 

exec WBank.sp_customer @customerID = 1
go

--Question 7
--Create a stored procedure, called sp_Employees, that returns a select statement that shows all the employees working for the company. 
--This procedure should have the emp_full_name and employee_id columns in your select.
drop proc if exists WBank.sp_Employees
go

create proc WBank.sp_Employees
as
begin
	select
		e.EmployeeFirstName + ' '
			+ e.EmployeeLastName emp_full_name
		, e.EmployeeID employee_id
	from
		WBank.Employees e
end
go

exec WBank.sp_Employees
go

--Question 8
--Create a stored procedure, called sp_Locations, that returns a select statement that shows all the locations that this bank has. 
--This procedure should have the location_id, and location_code columns in your select.
drop proc if exists WBank.sp_Locations
go

create proc WBank.sp_Locations
as
begin
	select
		l.LocationID
		,l.LocationCode
		,*
	from
		WBank.Locations l
end
go

exec WBank.sp_Locations
go

--Question 9
--Create an Insert procedure, called sp_Insert_Deposit, for adding a deposit for a customer into the database. 
--In your procedure ensure that the locationId, employeeid, and customerID are valid values.  
--If they are not, throw an error.  Also, ensure that the deposit date is a valid date.
----If all the validation passes, insert the data into your deposits table and return the depositID as an out parameter.
----Parameters to your procedure should be: locationID, employeeID, customerID, and return a depositID.
drop proc if exists WBank.sp_Insert_Deposit
go

create proc WBank.sp_Insert_Deposit
	@locationID int
	,@employeeID int
	,@customerID int
	,@depositAmount money
as
begin
	if exists
	(	
		select 
			1 
		from 
			WBank.Deposits d
			join WBank.Locations l on d.LocationID = l.LocationID
			join WBank.Employees e on d.EmployeeID = e.EmployeeID
			join WBank.Customers c on d.CustomerID = c.CustomerID
		where
			l.LocationID = @locationID
			and e.EmployeeID = @employeeID
			and c.CustomerID = @customerID
	)
	begin
		create table #newestDeposit (
			DepositID int primary key
		)

		insert into WBank.Deposits
		output inserted.DepositID into #newestDeposit
		values
			(
				@locationID
				,@employeeID
				,@customerID
				,getdate()
				,@depositAmount
			)

		declare @depositID int
		select
			@depositID = DepositID
		from
			#newestDeposit

		print 'DepositID for this transaction: ' + cast(@depositID as varchar)

		drop table #newestDeposit
	end
	else
	begin
		throw 50001, '@locationID, @employeeID, or @customerID is incorrect. Review the provided IDs and try again.', 1;
	end;
end;
go

exec WBank.sp_Insert_Deposit 
	@locationID = 1
	,@employeeID = 1
	,@customerID = 1
	,@depositAmount = 150
go

--Question 10
--Create an Insert procedure, called sp_WithDraw, for adding a withdrawal for a customer into the database. 
--In your procedure ensure that the locationId, employeeid, and customerID are valid values.  
--If they are not, throw an error.  Also, ensure that the withdrawal date is a valid date.  
--Finally, ensure that the customer has enough money to withdraw and  if they don't throw an error.
----If all the validation passes, insert the data into your withdrawal table and return the withdrawalID as an out parameter.
drop proc if exists WBank.sp_WithDraw
go

create proc WBank.sp_WithDraw
	@locationID int
	,@employeeID int
	,@customerID int
	,@withdrawAmount money
as
begin
	if exists
	(	
		select 
			1 
		from 
			WBank.Withdrawals w
			join WBank.Locations l on w.LocationID = l.LocationID
			join WBank.Employees e on w.EmployeeID = e.EmployeeID
			join WBank.Customers c on w.CustomerID = c.CustomerID
		where
			l.LocationID = @locationID
			and e.EmployeeID = @employeeID
			and c.CustomerID = @customerID
	)
	begin
		create table #newestWithdrawal (
			DepositID int primary key
		)

		insert into WBank.Deposits
		output inserted.DepositID into #newestWithdrawal
		values
			(
				@locationID
				,@employeeID
				,@customerID
				,getdate()
				,@withdrawAmount
			)

		declare @withdrawID int
		select
			@withdrawID = DepositID
		from
			#newestWithdrawal

		print 'WithdrawalID for this transaction: ' + cast(@withdrawID as varchar)

		drop table #newestWithdrawal
	end
	else
	begin
		throw 50001, '@locationID, @employeeID, or @customerID is incorrect. Review the provided IDs and try again.', 1;
	end;
end;
go

exec WBank.sp_WithDraw
	@locationID = 1
	,@employeeID = 1
	,@customerID = 1
	,@withdrawAmount = 150
go

--Question 11
--Create a SQL Server role called CIS435L_Project. 
--Grant the role db_datareader to CIS435_Project.
--In addition, grant the ability to execute all stored procedures created for this project to this role.
create role CIS435L_Project;
grant execute to CIS435L_Project;
alter role db_datareader add member CIS435L_Project;
go

--Question 12
--Create a user called CIS435L_User1.
--Grant this user the CIS435L_Project role.  
--Prove that you can call one of the stored procedures or functions created for this project using this CIS435L_User1 user.
drop login CIS435L_User1;
drop user CIS435L_User1;
create login CIS435L_User1 with password = 'WBANK1234';
create user CIS435L_User1 for login CIS435L_User1;
alter role CIS435L_Project add member CIS435L_User1;
go

exec WBank.sp_Locations
go