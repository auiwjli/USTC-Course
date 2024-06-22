-- 该测试样例是根据数据库规则设计好的
-- 不需要事先定义任何存储过程和触发器，定义好基本表后直接运行即可
-- 对测试样例有任何问题都可以联系yxy助教

CREATE TABLE book(
	bid char(8) Primary Key,
    bname varchar(100) not null,
    author varchar(50),
    price float,
    bstatus int default 0,
    borrow_times int default 0,
    reserve_times int default 0
);

CREATE TABLE reader(
	rid char(8) Primary Key,
    rname varchar(20),
    age int,
    address varchar(100)
);

CREATE TABLE borrow(
	book_id char(8),
    reader_id char(8),
    borrow_date date,
    return_date date,
    constraint PK primary key (book_id, reader_id, borrow_date),
    constraint FK_book_id foreign key (book_id) references book(bid),
    constraint FK_reader_id foreign key (reader_id) references reader(rid)
);

CREATE TABLE reserve(
    book_id char(8),
    reader_id char(8),
    reserve_date DATE default (curdate()),
    take_date DATE,
    CONSTRAINT PK PRIMARY KEY (book_id, reader_id, reserve_date),
    CONSTRAINT check_take_date CHECK (take_date > reserve_date)
);

-- 插入图书数据
INSERT INTO book (bid, bname, author, price, borrow_times, reserve_times, bstatus) 
VALUES 
('B001', 'The Hobbit', 'J.R.R. Tolkien', 18.99, 4, 1, 2),
('B002', 'Harry Potter and the Chamber of Secrets', 'J.K. Rowling', 25.50, 3, 0, 1),
('B003', 'Harry Potter and the Philosophers Stone', 'J.K. Rowling', 14.7, 2, 0, 1),
('B004', 'To Kill a Mockingbird', 'Harper Lee', 12.99, 0, 0, 0),
('B005', '1984', 'George Orwell', 10.50, 0, 1, 2),
('B006', 'Learning MySQL: Get a Handle on Your Data', 'Seyed M.M. (Saied) Tahaghoghi, Hugh E. Williams', 29.99, 1, 0, 1),
('B007', 'Pride and Prejudice', 'Jane Austen', 14.25, 1, 0, 1),
('B008', 'The Catcher in the Rye', 'J.D. Salinger', 11.20, 0, 2, 2),
('B009', 'Brave New World', 'Aldous Huxley', 13.80, 1, 0, 1),
('B010', 'Animal Farm', 'George Orwell', 8.99, 1, 1, 1) ,
('B011', 'MySQL Cookbook: Solutions for Database Developers and Administrators', 'Paul DuBois', 35.50, 1, 0, 0),
('B012', 'Test your trigger here', 'TA', 10.4, 0, 0, 0)
;


-- 插入读者数据
INSERT INTO reader (rid, rname, age, address)
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
('B001', 'R001', '2024-06-08'),
('B005', 'R004', '2024-06-08'),
('B008', 'R005', '2024-06-10'),
('B008', 'R002', '2024-06-10'),
('B010', 'R006', '2024-06-15');

-- 查询读者 Rose 借过的书(包括已还和未还)的图书号、书名和借期

SELECT book_id, bname, borrow_date
	FROM reader, borrow, book
    WHERE borrow.book_id = book.bid 
		and borrow.reader_id = reader.rid 
        and reader.rname = 'Rose' ;
    
-- 查询从没有借过图书也从没有预约过图书的读者号和读者姓名

SELECT rid, rname
	FROM reader
    WHERE rid NOT IN
    (	SELECT DISTINCT reader_id
			FROM borrow
		UNION
        SELECT DISTINCT reader_id
			FROM reserve
    );

-- 查询被借阅次数最多的作者

SELECT author
FROM 
	(SELECT author, sum(borrow_times) as borrow_count
		FROM book
		GROUP BY author
		ORDER BY borrow_count DESC
		LIMIT 1) Search ;

-- 查询目前借阅未还的书名中包含 ‘MySQL’ 的图书号和书名

SELECT book_id, bname
	FROM borrow, book
    WHERE borrow.return_date is NULL 
		and borrow.book_id = book.bid
		and book.bname LIKE '%MySQL%';
        
-- 查询借阅图书数目超过 3 本的读者姓名

SELECT rname
	FROM reader,
		(SELECT reader_id, count(*)
			FROM borrow
			GROUP BY reader_id
			HAVING count(*) > 3 ) Search
    WHERE reader.rid = Search.reader_id;

-- 查询没有借阅过任何一本 J.K. Rowling 所著的图书的读者号和姓名

SELECT rid, rname
	FROM reader
	WHERE rid NOT IN(
		SELECT DISTINCT reader_id
			FROM borrow, book
			WHERE borrow.book_id = book.bid
				and book.author = 'J.K. Rowling' );
                
-- 查询 2024 年借阅图书数目排名前 3 名的读者号、姓名以及借阅图书数

SELECT rname, reader_id, book_count
	FROM reader,
		(SELECT reader_id , count(*) book_count
			FROM borrow
			WHERE borrow.borrow_date > '2023-12-31'
			GROUP BY reader_id
			ORDER BY count(*) DESC
			LIMIT 3) as Search
    WHERE Search.reader_id = reader.rid;

/* 创建一个读者借书信息的视图，该视图包含读者号、姓名、所借图书号、图书名和借期
   (对于没有借过图书的读者，是否包含在该视图中均可); 并使用该视图查询 2024 年所有
   读者的读者号以及所借阅的不同图书数 */

 CREATE VIEW borrow_view(reader_id, reader_name, book_id, book_name, borrow_date)
	AS SELECT rid, rname, bid, bname, borrow_date
		   FROM reader, book, borrow
           WHERE borrow.book_id = book.bid
		       AND borrow.reader_id = reader.rid;


SELECT reader_id, count(distinct book_name) book_count
	FROM borrow_view 
    WHERE borrow_view.borrow_date > '2023-12-31'
    GROUP BY reader_id;
    
/* 设计一个存储过程 updateReaderID ,实现对读者表的 ID 的修改
   (本题要求不得使用外键定义时的 on update cascade 选项,因为该选项不是所有 DBMS 都支持)。
   使用该存储过程:将读者ID中‘R006’改为‘R999’ */
DROP PROCEDURE IF EXISTS UpdateReaderID;
Delimiter //

CREATE PROCEDURE UpdateReaderID(IN reader_id_old char(8), IN reader_id_new char(8))
	BEGIN
    SET SQL_SAFE_UPDATES = 0;
	SET FOREIGN_KEY_CHECKS = 0;
	UPDATE reader
		SET rid = reader_id_new
		WHERE rid = reader_id_old;
	UPDATE borrow
		SET reader_id = reader_id_new
        WHERE reader_id = reader_id_old;
	UPDATE reserve
		SET reader_id = reader_id_new
        WHERE reader_id = reader_id_old;
	SET FOREIGN_KEY_CHECKS = 1;
    SET SQL_SAFE_UPDATES = 1;
	END //
Delimiter ;

CALL UpdateReaderID('R006', 'R999');
SELECT * FROM reader;
SELECT * FROM borrow;
SELECT * FROM reserve;

/* 设计一个存储过程 borrowBook ,当读者借书时调用该存储过程完
   成借书处理。要求:
   A. 一个读者最多只能借阅 3 本图书，意味着如果读者已经借阅了 3 本图书并且未归还则不允许再借书;
   B. 同一天不允许同一个读者重复借阅同一本读书;
   C. 如果该图书存在预约记录，而当前借阅者没有预约，则不许借阅;
   (思考:在实现时，处理借书请求的效率是否和 A、B、C 的实现顺序有关系?)
   D. 如果借阅者已经预约了该图书，则允许借阅，但要求借阅完成后删除借阅者对该图书的预约记录;
   E. 借阅成功后图书表中的 times 加 1;
   F. 借阅成功后修改 bstatus。
   使用该存储过程处理:
   (1)ID为 ‘R001’ 的读者借阅ID为 ‘B008’ 的书的请求(未预约)，显示借阅失败信息。
   (2)ID为 ‘R001’ 的读者借阅ID为 ‘B001’ 的书的请求(已预约)，显示借阅成功信息，
   并展示预约表相关预约记录被删除，以及图书表对应书籍的 borrow_times 和 bstatus 属性的变化。
   (3)ID为 ‘R001’ 的读者再次借阅ID为 ‘B001’ 的书的请求(同一天已经借阅过)，显示借阅失败信息。
   (4)ID为 ‘R005’ 的读者借阅ID为‘B008’的书的请求(已借三本书未还)，显示借阅失败信息。
   (以上借阅日期默认为‘2024-03-28’) */

DELIMITER //

CREATE PROCEDURE BorrowBook(IN readerid char(8), IN bookid char(8), OUT state char(50))
	BEGIN
    DECLARE borrow_day DATE DEFAULT '2024-05-9';
    DECLARE is_exists_reserve INT DEFAULT 0;
    DECLARE is_reserve INT DEFAULT 0;
    DECLARE is_borrowed INT DEFAULT 0;
    DECLARE borrowed_book INT DEFAULT 0;
    DECLARE cond INT DEFAULT 0;
            
    SELECT count(*) FROM borrow WHERE reader_id = readerid AND return_date IS NULL INTO borrowed_book;
    IF borrowed_book > 2 THEN
		SET cond = 1;
        SET state = 'A';
    END IF;
    
    SELECT count(*) FROM borrow WHERE reader_id = readerid AND book_id = bookid AND borrow_date = borrow_day INTO is_borrowed;
    IF is_borrowed > 0 THEN
		SET cond = 1;
        SET state = 'B';
	END IF;
    
    SELECT reserve_times FROM book WHERE bid = bookid INTO is_exists_reserve;
    SELECT count(*) FROM reserve WHERE book_id = bookid AND reader_id = readerid INTO is_reserve;
    IF is_exists_reserve > 0 AND is_reserve = 0 THEN
		SET cond = 1;
        SET state = 'C';
	END IF;
    
    IF cond = 0 THEN
        UPDATE book 
			SET borrow_times = borrow_times + 1, bstatus = 1, reserve_times = reserve_times - 1
            WHERE bid = bookid;
		INSERT INTO borrow (book_id, reader_id, borrow_date, return_date)
			VALUES
			(bookid, readerid, borrow_day, NULL);
        DELETE FROM reserve
			WHERE book_id = bookid AND reader_id = readerid;
		SET state = 'success';
    END IF;
	END //
DELIMITER ;

CALL BorrowBook('R001','B008',@state);
SELECT @state;
CALL BorrowBook('R001','B001',@state);
SELECT @state;
CALL BorrowBook('R001','B001',@state);
SELECT @state;
CALL BorrowBook('R005','B008',@state);
SELECT @state;
SELECT * FROM book;
SELECT * FROM reserve;
/* 参考 4，设计一个存储过程 returnBook ，当读者还书时调用该存储过程完成还书处理。要求:
   A. 还书后补上借阅表 borrow 中对应记录的 return_date ;
   B. 还书后将图书表 book 中对应记录的 bstatus 修改为 0(没有其他预约)或2(有其他预约) 。
   使用该存储过程处理:
   (1) ID为 ‘R001’ 的读者归还ID为 ‘B008’ 的书的请求(未借阅)，并展示还书失败信息。
   (2) ID为 ‘R001’ 的读者归还ID为 ‘B001’ 的书的请求，并展示相关书籍在 book 表中的
   bstatus 以及在 borrow 表中的 return_date 的变化。
   (以上还书日期默认为 ‘2024-03-29’ ) */

DELIMITER //

CREATE PROCEDURE ReturnBook(IN readerid char(8), IN bookid char(8), OUT state char(50))
BEGIN
	DECLARE return_day DATE DEFAULT '2024-05-10';
    DECLARE is_exist INT DEFAULT -1;
    DECLARE is_exist_reserve INT DEFAULT -1;
    DECLARE book_state INT DEFAULT -1;
    
    SELECT count(*) FROM borrow WHERE reader_id = readerid AND book_id = bookid INTO is_exist;
	SELECT reserve_times FROM book WHERE bid = bookid INTO is_exist_reserve;
    
    IF is_exist_reserve > 0 THEN
		SET book_state = 2;
	ELSE
		SET book_state = 0;
	END IF;
    
    IF is_exist = 0 THEN
		SET state = 'no borrow';
	ELSE
		SET state = 'success';
		UPDATE borrow
			SET return_date = return_day
			WHERE book_id = bookid AND reader_id = readerid;
		UPDATE book
			SET bstatus = book_state
            WHERE bid = bookid;
	END IF;
END //
DELIMITER ;

CALL ReturnBook('R001','B008',@state);
SELECT @state;
SELECT * FROM book;
SELECT * FROM borrow;
CALL ReturnBook('R001','B001',@state);
SELECT @state;
SELECT * FROM book;
SELECT * FROM borrow;

/* 设计触发器，实现:
   A. 当一本书被预约时,自动将图书表 book 中相应图书的 bstatus 修改为 2 ，并增加 reserve_Times ;
   B. 当某本预约的书被借出时或者读者取消预约时, 自动减少 reserve_Times ;
   C. 当某本书的最后一位预约者取消预约且该书未被借出(修改前 bstatus 为 2 )时，将 bstatus 改为 0
   定义并创建该触发器，然后处理:
   (1)ID为 ‘R001’ 的读者预约ID为 ‘B012’ 的书，再取消预约的请求，展示过程中 reserve_Times 
   和 bstatus 的变化  */
DELIMITER //

CREATE TRIGGER status_update_reserve AFTER INSERT ON reserve FOR EACH ROW
BEGIN
    UPDATE book
		SET bstatus = 2,reserve_times = reserve_times+1
        WHERE bid = NEW.book_id;
END //
DELIMITER ;

SELECT * FROM book;
SELECT * FROM reserve;
INSERT INTO reserve (book_id, reader_id, take_date)		-- ver1将预约数据中4月改为6月
	VALUES
	('B012', 'R001', '2024-06-08');
SELECT * FROM book;
SELECT * FROM reserve;

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

DELETE FROM reserve
	WHERE reader_id = 'R001' AND book_id = 'B012';
SELECT * FROM book;
SELECT * FROM reserve;
