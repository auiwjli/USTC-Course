SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS reader;
DROP TABLE IF EXISTS borrow;
DROP TABLE IF EXISTS reserve;
DROP TABLE IF EXISTS administrator;

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

CREATE TABLE book(
    bid char(8) Primary Key,
    bname varchar(100) not null,
    author varchar(50),
    price float,
    bstatus int default 0,
    borrow_times int default 0,
    reserve_times int default 0,
    paths varchar(255) not null
);

CREATE TABLE reader(
    rid char(8) Primary Key,
    rname varchar(20),
    age int,
    addresses varchar(100)
);

CREATE TABLE borrow(
    book_id char(8),
    reader_id char(8),
    borrow_date date,
    return_date date,
    CONSTRAINT PK PRIMARY KEY (book_id, reader_id, borrow_date),
    CONSTRAINT FK_book_id foreign key (book_id) references book(bid),
    CONSTRAINT FK_reader_id FOREIGN KEY (reader_id) references reader(rid)
);

CREATE TABLE reserve(
    book_id char(8),
    reader_id char(8),
    reserve_date DATE default (curdate()),
    take_date DATE,
    CONSTRAINT PK PRIMARY KEY (book_id, reader_id, reserve_date),
    CONSTRAINT check_take_date CHECK (take_date > reserve_date)
);

CREATE TABLE administrator(
    aid char(8) Primary Key,
    aname varchar(100) not null,
    age int
);

-- 插入图书数据
INSERT INTO book (bid, bname, author, price, borrow_times, reserve_times, bstatus,paths) 
VALUES 
('B001', 'The Hobbit', 'J.R.R. Tolkien', 18.99, 4, 1, 2,'/Users/guyuhang/Course/Experiment/DataBase/lab2/photo/photo1.png'),
('B002', 'Harry Potter and the Chamber of Secrets', 'J.K. Rowling', 25.50, 3, 0, 1,'/Users/guyuhang/Course/Experiment/DataBase/lab2/photo/photo2.png'),
('B003', 'Harry Potter and the Philosophers Stone', 'J.K. Rowling', 14.7, 2, 0, 1,'/Users/guyuhang/Course/Experiment/DataBase/lab2/photo/photo3.png'),
('B004', 'To Kill a Mockingbird', 'Harper Lee', 12.99, 0, 0, 0,''),
('B005', '1984', 'George Orwell', 10.50, 0, 1, 2,''),
('B006', 'Learning MySQL: Get a Handle on Your Data', 'Seyed M.M. (Saied) Tahaghoghi, Hugh E. Williams', 29.99, 1, 0, 1,''),
('B007', 'Pride and Prejudice', 'Jane Austen', 14.25, 1, 0, 1,''),
('B008', 'The Catcher in the Rye', 'J.D. Salinger', 11.20, 0, 2, 2,''),
('B009', 'Brave New World', 'Aldous Huxley', 13.80, 1, 0, 1,''),
('B010', 'Animal Farm', 'George Orwell', 8.99, 1, 1, 1,'') ,
('B011', 'MySQL Cookbook: Solutions for Database Developers and Administrators', 'Paul DuBois', 35.50, 1, 0, 0,''),
('B012', 'Test your trigger here', 'TA', 10.4, 0, 0, 0,'')
;


-- 插入读者数据
INSERT INTO reader (rid, rname, age, addresses)
VALUES
('R001', 'John', 35, '456 Oak St, Othertown'),
('R002', 'Rose', 35, '123 Main St, Anytown'),
('R003', 'Emma', 30, '123 Elm St, Anytown'),
('R004', 'Sophia', 28, '789 Maple St, Somewhere'),
('R005', 'Emily', 28, '456 Elm St, Othertown'),
('R006', 'Michael', 40, '789 Oak St, Somewhere');

-- 插入借阅数据
INSERT INTO borrow (book_id, reader_id, borrow_date, return_date)
VALUES
('B001', 'R002', '2024-03-01', '2024-03-15'),
('B003', 'R001', '2024-03-05', '2024-03-20'),
('B002', 'R001', '2024-03-10', NULL),
('B001', 'R004', '2024-03-15', '2024-03-16'),
('B006', 'R005', '2024-03-03', NULL),
('B003', 'R001', '2024-03-21', NULL),
('B001', 'R005', '2024-03-17', '2024-03-18'),
('B001', 'R006', '2024-03-19', '2024-03-20'),
('B002', 'R001', '2024-03-08', '2024-03-09'),
('B002', 'R005', '2024-03-09', '2024-03-10'),
('B011', 'R005', '2024-03-11', '2024-03-25'),
('B010', 'R002', '2024-03-12', NULL),
('B007', 'R005', '2024-03-03', NULL),
('B009', 'R005', '2024-03-03', NULL);

-- 插入预约数据
INSERT INTO reserve (book_id, reader_id, take_date)		-- ver1将预约数据中4月改为6月
VALUES
('B001', 'R001', '2024-07-08'),
('B005', 'R004', '2024-07-08'),
('B008', 'R005', '2024-07-10'),
('B008', 'R002', '2024-07-10'),
('B010', 'R006', '2024-07-15');

INSERT INTO administrator(aid, aname, age)
VALUES
('A001', 'M001', 35),
('A002', 'M002', 40),
('A003', 'M003', 30);

DROP PROCEDURE IF EXISTS BorrowBook;

DELIMITER //

CREATE PROCEDURE BorrowBook(IN readerid char(8), IN bookid char(8), OUT result char(50))
BEGIN
    DECLARE borrow_day DATE DEFAULT '2024-06-18' ;
    DECLARE is_exists_reserve INT DEFAULT 0;
    DECLARE is_reserve INT DEFAULT 0;
    DECLARE is_borrowed INT DEFAULT 0;
    DECLARE borrowed_book INT DEFAULT 0;
    DECLARE cond INT DEFAULT 0;

    select count(*) from borrow where reader_id = readerid and return_date is null into borrowed_book;
    if borrowed_book > 2 then
        set cond = 1;
        set result = 'more than 2 books are not return';
    end if;

    select count(*) from borrow where reader_id = readerid and book_id = bookid and borrow_date = borrow_day into is_borrowed;
    if is_borrowed > 0 then
        set cond = 1;
        set result = 'today has borrowed';
    end if;

    select reserve_times from book where bid = bookid into is_exists_reserve;
    select count(*) from reserve where book_id = bookid and reader_id = readerid into is_reserve;
    if is_exists_reserve > 0 and is_reserve = 0 then
        set cond = 1;
        set result = 'you have not reserved while other have';
    end if;

    if cond = 0 then
        update book
            set borrow_times = borrow_times + 1, bstatus = 1, reserve_times = reserve_times - 1
            where bid = bookid;
        insert into borrow (book_id, reader_id, borrow_date, return_date)
            values
            (bookid, readerid, borrow_day, null);
        delete from reserve
            where book_id = bookid and reader_id = readerid;
        set result = 'success borrow book';
    end if;
END //

DELIMITER ;

drop procedure if exists ReturnBook;

DELIMITER //

create procedure ReturnBook(in readerid char(8), in bookid char(8), in ncheck int, out result char(50))
begin 
    declare return_day date default curdate();
    declare is_exist int default -1;
    declare is_exist_reserve int default -1;
    declare book_state int default -1;
    declare take_day date default '2024-01-01';
    declare is_delay int default -1;

    select count(*) from borrow where reader_id = readerid and book_id = bookid into is_exist;
    select reserve_times from book where bid = bookid into is_exist_reserve;
    select borrow_date from borrow where reader_id = readerid and book_id = bookid and return_date is null into take_day;

    if is_exist_reserve > 0 then
        set book_state = 2;
    else
        set book_state = 0;
    end if;
    
    if is_exist = 0 then
        set result = 'no borrow';
	elseif datediff(return_day, take_day) > 30 and ncheck > 0 then
        set result = 'return delay';
    else 
        set result = 'success';
        update borrow
            set return_date = return_day
            where book_id = bookid and reader_id = readerid and return_date is null;
        update book
            set bstatus = book_state
            where bid = bookid;
    end if;
end //

DELIMITER ;

drop trigger if exists status_update_reserve;

DELIMITER //

CREATE TRIGGER status_update_reserve AFTER INSERT ON reserve FOR EACH ROW
BEGIN
    UPDATE book
		SET bstatus = 2,reserve_times = reserve_times+1
        WHERE bid = NEW.book_id;
END //

DELIMITER ;

drop trigger if exists status_update_return;

DELIMITER //

CREATE TRIGGER status_update_return AFTER DELETE ON reserve FOR EACH ROW
BEGIN
	DECLARE reserve_count INT DEFAULT -1;
    SELECT reserve_times FROM book WHERE bid = OLD.book_id INTO reserve_count;
	UPDATE book
		SET reserve_times = reserve_times - 1
        WHERE bid = OLD.book_id;
    IF reserve_count = 1 THEN
		UPDATE book
			SET bstatus = 0
            WHERE bid = OLD.book_id;
	END IF;
END //

DELIMITER ;
