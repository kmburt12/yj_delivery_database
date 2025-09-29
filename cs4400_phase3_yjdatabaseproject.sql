-- link to video recording demonstrating the stored procedures: https://youtu.be/QPDDaMVgY3c

-- CS4400: Introduction to Database Systems (Summer 2025)
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use yellow_jacket_delivery;

/* START SUPPORTING VIEWS/PROCEDURES */
-- -------------------------------- --
/* END SUPPORTING VIEWS/PROCEDURES */

-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- [1] add_employee()
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (
ip_username varchar(40),
ip_tax_ID char(11),
ip_salary decimal(8,2),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    
	declare user_exists int default 0;
    declare contractor_exists int default 0;
    
    /* end variable declarations */
    
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
    
	/* start procedure body */
    
    select count(*) into user_exists
	from sys_user
	where username = ip_username;

	if user_exists > 0 then
        select count(*) into contractor_exists
        from contractor
        where username = ip_username;

        if contractor_exists > 0 then
            leave sp_main;
        end if;
	else
		insert into sys_user(username, firstname, lastname, birthdate) values (ip_username, ip_firstname, ip_lastname, ip_birthdate);
    end if;

    -- Insert into employee
    insert into employee(username, tax_ID, salary) values (ip_username, ip_tax_ID, ip_salary);
    
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [2] add_contractor()
-- -----------------------------------------------------------------------------
drop procedure if exists add_contractor;
delimiter //
create procedure add_contractor (
ip_username varchar(40),
ip_company varchar(100),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
    /* start variable declarations */
    
	declare user_exists int default 0;
    declare employee_exists int default 0;
    
    /* end variable declarations */
    
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
    
	/* start procedure body */
    
    select count(*) into user_exists
	from sys_user
	where username = ip_username;

	if user_exists > 0 then
        select count(*) into employee_exists
        from employee
        where username = ip_username;

        if employee_exists > 0 then
            leave sp_main;
        end if;
	else
		insert into sys_user(username, firstname, lastname, birthdate) values (ip_username, ip_firstname, ip_lastname, ip_birthdate);
    end if;

    -- Insert into contractor
    insert into contractor(username, company, packer_ID) values (ip_username, ip_company, null);
    
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [3] add_warehouse_worker()
-- -----------------------------------------------------------------------------
drop procedure if exists add_warehouse_worker;
delimiter //
create procedure add_warehouse_worker (
ip_username varchar(40),
ip_tax_ID char(11),
ip_salary decimal(8,2),
ip_warehouse_ID varchar(40),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    
    declare user_exists int default 0;
    declare employee_exists int default 0;
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    
    select count(*) into user_exists
	from sys_user
	where username = ip_username;

	if user_exists > 0 then
        select count(*) into employee_exists
        from employee
        where username = ip_username;

        if employee_exists > 0 then
            leave sp_main;
		else
			insert into employee(username, tax_ID, salary) values (ip_username, ip_tax_ID, ip_salary);
        end if;
	else
		insert into sys_user(username, firstname, lastname, birthdate) values (ip_username, ip_firstname, ip_lastname, ip_birthdate);
        insert into employee(username, tax_ID, salary) values (ip_username, ip_tax_ID, ip_salary);
    end if;

    -- Insert into warehouse_worker
    insert into warehouse_worker(tax_ID, warehouse_ID, packer_ID) values (ip_tax_ID, ip_warehouse_ID, null);
    
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [4] add_driver()
-- -----------------------------------------------------------------------------
drop procedure if exists add_driver;
delimiter //
create procedure add_driver (
ip_username varchar(40),
ip_tax_ID char(11),
ip_salary decimal(8,2),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100),
ip_experience integer)
sp_main: begin
	/* start variable declarations */
    
    declare user_exists int default 0;
    declare employee_exists int default 0;
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    
    select count(*) into user_exists
	from sys_user
	where username = ip_username;

	if user_exists > 0 then
        select count(*) into employee_exists
        from employee
        where username = ip_username;

        if employee_exists > 0 then
            leave sp_main;
		else
			insert into employee(username, tax_ID, salary) values (ip_username, ip_tax_ID, ip_salary);
        end if;
	else
		insert into sys_user(username, firstname, lastname, birthdate) values (ip_username, ip_firstname, ip_lastname, ip_birthdate);
        insert into employee(username, tax_ID, salary) values (ip_username, ip_tax_ID, ip_salary);
    end if;

    -- Insert into driver
    insert into driver(tax_ID, experience) values (ip_tax_ID, ip_experience);
    
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [5] fire_driver()
-- -----------------------------------------------------------------------------
drop procedure if exists fire_driver;
delimiter //
create procedure fire_driver(
ip_tax_ID char(11))
sp_main: begin
	/* start variable declarations */
	declare truck_count int default 0;
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    select count(*) into truck_count
    from truck
    where driver_id = ip_tax_ID;

    if truck_count > 0 then
        rollback;
        leave sp_main;
    end if;

    delete from driver
    where tax_id = ip_tax_ID;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [6] register_packer()
-- -----------------------------------------------------------------------------
drop procedure if exists register_packer;
delimiter //
create procedure register_packer (
    ip_username varchar(40),
    ip_packer_ID int,
    ip_shift_start time,
    ip_shift_end time
)
sp_main: begin
	/* start variable declarations */
	declare v_tax_ID varchar(20);    
	declare v_worker_exists int default 0;
    declare v_contractor_exists int default 0;
    declare v_already_packer int default 0;
	/* end variable declarations */

	declare exit handler for sqlexception 
    begin 
        rollback; 
        resignal; 
    end;

    start transaction;

	/* start procedure body */

    -- Get tax_ID for the given username
    select tax_ID into v_tax_ID
    from employee
    where username = ip_username;

    -- Check if already a packer
    select count(*) into v_already_packer
    from packer
    where packer_ID = ip_packer_ID;

    if v_already_packer > 0 then
        rollback;
        leave sp_main;
    end if;

    -- Check if user is a warehouse worker
    select count(*) into v_worker_exists
    from warehouse_worker
    where tax_ID = v_tax_ID;

    -- Check if user is a contractor
    select count(*) into v_contractor_exists
    from contractor
    where username = ip_username;

    -- If user is neither, exit
    if v_worker_exists = 0 and v_contractor_exists = 0 then
        rollback;
        leave sp_main;
    end if;
    
    -- Insert into packer table
    insert into packer (packer_ID, shift_start, shift_end)
    values (ip_packer_ID, ip_shift_start, ip_shift_end);
    
    -- Update warehouse_worker if applicable
    if v_worker_exists = 1 then
        update warehouse_worker
        set packer_ID = ip_packer_ID
        where tax_ID = v_tax_ID;
    end if;

    -- Update contractor if applicable
    if v_contractor_exists = 1 then
        update contractor
        set packer_ID = ip_packer_ID
        where username = ip_username;
    end if;

	/* end procedure body */

    commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [7] add_customer()
-- -----------------------------------------------------------------------------
drop procedure if exists add_customer;
delimiter //
create procedure add_customer (
ip_username varchar(40),
ip_phone_number char(10),
ip_address varchar(500),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    declare is_already_customer int default 0;
    declare is_existing_user int default 0;    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    select count(*) into is_existing_user
    from sys_user
    where username = ip_username;

    if is_existing_user = 0 then
        insert into sys_user (
            username, birthdate, firstname, lastname
        ) values (
            ip_username, ip_birthdate, ip_firstname, ip_lastname
        );
    end if;

    select count(*) into is_already_customer
    from customer
    where username = ip_username;

    if is_already_customer = 0 then
        insert into customer (
            username, phone_number, address
        ) values (
            ip_username, ip_phone_number, ip_address
        );
    end if;
    /* end procedure body */
   	commit;
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [8] del_all_orders()
-- -----------------------------------------------------------------------------
drop procedure if exists del_all_orders;
delimiter //
create procedure del_all_orders(
ip_username varchar(40))
sp_main: begin
	/* start variable declarations */
    /* end variable declarations */
declare exit handler for sqlexception begin rollback; resignal; end; start transaction;
	/* start procedure body */
delete from order_tab
where username = ip_username;  	
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [9] add_package()
-- -----------------------------------------------------------------------------
-- ADD ORDER TO HELP ADD PACKAGE
drop procedure if exists add_order;
delimiter //

create procedure add_order(
    in ip_username varchar(40),
    in ip_order_ID varchar(40),
    in ip_price int
)
sp_main: BEGIN
    /* start variable declarations */
	declare customer_exists int default 0;
    /* end variable declarations */

    declare exit handler for sqlexception begin rollback; resignal; end;
    start transaction;
    
    select count(*) into customer_exists
    from customer
    where username = ip_username;

    if customer_exists = 0 then
        rollback;
        leave sp_main;
    else
        insert into order_tab(order_ID, price, username)
        values (ip_order_ID, ip_price, ip_username);
    end if;

    commit;
END //
delimiter ;

drop procedure if exists add_package;
delimiter //

create procedure add_package(
    in ip_package_number int,
    in ip_packer_ID int,
    in ip_order_ID varchar(40),
    in ip_source_warehouse varchar(40),
    in ip_dest_warehouse varchar(40),
    in ip_package_desc varchar(500)
)
sp_main: BEGIN
    declare route_exists int default 0;
    declare is_warehouse_worker int default 0;
    declare is_worker_at_source int default 0;

    declare exit handler for sqlexception begin rollback; resignal; end; start transaction;
    
	select count(*) into route_exists
	from (
    select distinct rl1.route_ID
    from route_leg rl1 join leg l1 ON rl1.leg_ID = l1.leg_ID join route_leg rl2 ON rl1.route_ID = rl2.route_ID join leg l2 ON rl2.leg_ID = l2.leg_ID
	where l1.depart = ip_source_warehouse and l2.arrive = ip_dest_warehouse and rl1.sequence <= rl2.sequence
    ) as valid_routes;

    if route_exists = 0 then
        rollback;
        leave sp_main;
    end if;

    select count(*) into is_warehouse_worker
    from warehouse_worker
    where packer_ID = ip_packer_ID;

    if is_warehouse_worker > 0 then
        select count(*) into is_worker_at_source
        from warehouse_worker
        where packer_ID = ip_packer_ID and warehouse_ID = ip_source_warehouse;

        if is_worker_at_source = 0 then
            rollback;
            leave sp_main;
        end if;
    end if;

    insert into package(package_number, order_ID, packer_ID, source_warehouse, dest_warehouse, package_desc)
    values (ip_package_number, ip_order_ID, ip_packer_ID, ip_source_warehouse, ip_dest_warehouse, ip_package_desc);

    commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [10] update_package_truck()
-- -----------------------------------------------------------------------------
drop procedure if exists update_package_truck;
delimiter //
create procedure update_package_truck (
ip_package_number int,
ip_order_ID varchar(40),
ip_truck_ID char(7)
)
sp_main: begin
	/* start variable declarations */
    declare source_ varchar(40);
    declare destination varchar(40);
    declare truck_route_ID varchar(40);
    declare source_seq int;
    declare dest_seq int;
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    select source_warehouse, dest_warehouse
    into source_, destination
    from package
    where package_number = ip_package_number AND order_ID = ip_order_ID;
    
    if source_ = destination then
        update package
        set truck_ID = NULL
        where package_number = ip_package_number and order_ID = ip_order_ID;
	else
		select route_ID
		into truck_route_ID
		from truck
		where plate_number = ip_truck_ID;
    
		select min(rl.sequence)
		into source_seq
		from route_leg rl join leg l on rl.leg_ID = l.leg_ID
		where rl.route_ID = truck_route_ID and (l.depart = source_ or l.arrive = source_);
    
		select min(rl.sequence)
		into dest_seq
		from route_leg rl join leg l on rl.leg_ID = l.leg_ID
		where rl.route_ID = truck_route_ID and (l.depart = destination or l.arrive = destination);
	end if;
	
    if source_seq is not null and dest_seq is not null and source_seq < dest_seq then
        update package
        set truck_ID = ip_truck_ID
        where package_number = ip_package_number and order_ID = ip_order_ID;
    end if;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [11] add_truck()
-- -----------------------------------------------------------------------------
drop procedure if exists add_truck;
delimiter //
create procedure add_truck (
ip_driver_ID char(11),
ip_plate_number char(7),
ip_capacity int,
ip_fuel int,
ip_route_ID varchar(40))
sp_main: begin
	/* start variable declarations */
	declare route_exists int;
	declare plate_exists int default 0;
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
	start transaction;
	/* start procedure body */
	select count(*) into route_exists from route where route_ID = ip_route_ID;
	if route_exists = 0 
		then rollback;
        leave sp_main; 
    end if;
    
    select count(*) into plate_exists 
    from truck 
    where plate_number = ip_plate_number;
    if plate_exists > 0 then
        rollback;
        leave sp_main;
    end if;
    
	insert into truck (driver_ID, plate_number, capacity, fuel, route_ID)
	values (ip_driver_ID, ip_plate_number, ip_capacity, ip_fuel, ip_route_ID);
	/* end procedure body */
	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [12] reassign_trucks()
-- -----------------------------------------------------------------------------
drop procedure if exists reassign_trucks;
delimiter //
create procedure reassign_trucks (
ip_route_ID varchar(40),
ip_new_route_ID varchar(40))
sp_main: begin
	/* start variable declarations */
    declare pkg_count int;
	declare valid_new_route int;
	/* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
	start transaction;
    /* start procedure body */
	select count(*) into valid_new_route
    from route
    where route_ID = ip_new_route_ID;
    
	if valid_new_route = 0
		then rollback;
        leave sp_main;
	end if;
    
	select count(*) into pkg_count
	from package
	where truck_ID in (select plate_number from truck where route_ID = ip_route_ID);
	if pkg_count > 0 
		then rollback; 
		leave sp_main; 
	end if;
    
	update truck
	set route_ID = ip_new_route_ID
	where route_ID = ip_route_ID;
    
	/* end procedure body */
	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [13] start_route()
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (
ip_route_ID varchar(40), 
ip_leg_ID varchar(40))
sp_main: begin
	/* start variable declarations */
	declare route_exists int;
	declare leg_exists int;
	declare route_leg_exists int;
	/* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
	start transaction;
	/* start procedure body */
    
	select count(*) into leg_exists
    from leg
    where leg_ID = ip_leg_ID;
    
    if leg_exists = 0 then
        rollback;
        leave sp_main;
    end if;
    
    select count(*) into route_exists
    from route
    where route_ID = ip_route_ID;

    if route_exists > 0 then
        rollback;
        leave sp_main;
    end if;
    
	insert into route(route_ID) values (ip_route_ID);
    insert into route_leg(route_ID, leg_ID, sequence)
    values (ip_route_ID, ip_leg_ID, 1);
    
    /* end procedure body */
commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [14] extend_route()
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route(
ip_route_ID varchar(40), 
ip_leg_ID varchar(40)) 
sp_main: begin
	/* start variable declarations */
    declare last_sequence int;
    declare last_arrive_warehouse varchar(40);
    declare new_leg_depart_warehouse varchar(40);
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    select max(sequence) into last_sequence
    from route_leg
    where route_ID = ip_route_ID;

    if last_sequence is null then
        rollback;
        leave sp_main;
    end if;

    select l.arrive into last_arrive_warehouse
    from route_leg rl join leg l on rl.leg_ID = l.leg_ID
    where rl.route_ID = ip_route_ID and rl.sequence = last_sequence;

    select l.depart into new_leg_depart_warehouse
    from leg l
    where l.leg_ID = ip_leg_ID;

    if last_arrive_warehouse <> new_leg_depart_warehouse then
        rollback;
        leave sp_main;
    end if;

    insert into route_leg (route_ID, leg_ID, sequence)
    values (ip_route_ID, ip_leg_ID, last_sequence + 1);
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [15] delete_route()
-- -----------------------------------------------------------------------------
drop procedure if exists delete_route;
delimiter //
create procedure delete_route (
ip_route_ID varchar(40))
sp_main: begin
	/* start variable declarations */
    declare truck_count int default 0;
	/* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
	start transaction;
	/* start procedure body */
	select count(*) into truck_count
	from truck
	where route_ID = ip_route_ID;
	if truck_count > 0 then
		rollback;
		leave sp_main;
	end if;
    
	delete from route_leg where route_ID = ip_route_ID;
	delete from route where route_ID = ip_route_ID;
    
commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [16] add_update_leg()
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (
ip_leg_ID varchar(40),
ip_distance int,
ip_depart varchar(40),
ip_arrive varchar(40))
sp_main: begin
	/* start variable declarations */
    declare leg_exists int default 0;
    declare opposite_leg_exists int default 0;
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    select count(*) into leg_exists
    from leg
    where leg_ID = ip_leg_ID;

    if leg_exists > 0 then
        update leg
        set distance = ip_distance
        where leg_ID = ip_leg_ID;
    else
        insert into leg (leg_ID, distance, depart, arrive)
        values (ip_leg_ID, ip_distance, ip_depart, ip_arrive);
    end if;

    select count(*) into opposite_leg_exists
    from leg
    where depart = ip_arrive and arrive = ip_depart;

    if opposite_leg_exists > 0 then
        update leg
        set distance = ip_distance
        where depart = ip_arrive and arrives = ip_depart;
    end if;
    /* end procedure body */
   	commit;
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- View 1 - route_summary
-- -----------------------------------------------------------------------------
create or replace view route_summary as
select r.route_ID, count(distinct rl.leg_ID) as num_legs, group_concat(distinct rl.leg_ID order by rl.sequence separator ',') as leg_sequence, round(sum(l.distance)/count(distinct t.plate_number), 0) as total_distance, 
count(distinct t.plate_number) as num_trucks, group_concat(distinct t.plate_number order by t.plate_number separator ',') as truck_list, group_concat(distinct concat(l.depart, '->', l.arrive) order by rl.sequence separator ',') as warehouse_sequence
from route r JOIN route_leg rl on r.route_ID = rl.route_ID JOIN leg l on rl.leg_ID = l.leg_ID LEFT JOIN truck t on rl.route_ID = t.route_ID
group by r.route_ID;
/* view statement */

-- -----------------------------------------------------------------------------
-- View 2 - package_distance
-- -----------------------------------------------------------------------------
create or replace view package_distance as
select p.order_ID, p.package_number, l.distance
from package p join leg l on p.source_warehouse = l.depart and p.dest_warehouse = l.arrive
where p.truck_ID is not null;
/* view statement */

-- -----------------------------------------------------------------------------
-- View 3 - popular_legs
-- -----------------------------------------------------------------------------
create or replace view popular_legs as
select l.leg_ID, l.depart, l.arrive, l.distance, group_concat(rl.route_ID order by rl.route_ID separator ',') as routes
from leg l join route_leg rl on l.leg_ID = rl.leg_ID
group by l.leg_ID, l.depart, l.arrive, l.distance
having count(distinct rl.route_ID) > 1;
/* view statement */

