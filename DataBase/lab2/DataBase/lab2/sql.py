import mysql.connector

def connect_to_db() :
    conn = mysql.connector.connect(
        user = '',
        password = '',
        database = ''
        )
    return conn

def init_db() :
    conn = connect_to_db()
    cursor = conn.cursor()
    with open('lab2.sql', 'r', True, 'UTF-8') as f:
        sql = f.read()
        cursor.execute(sql)
    cursor.close()
    conn.close()

def borrow(studentid, bookid) :
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute("CALL BorrowBook(%s,%s,@output);", (studentid, bookid))
    cursor.execute('SELECT @output')
    result = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return result
    
def reserve(studentid, bookid, takedate) :
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute('select * from reserve where book_id = %s and reader_id = %s and reserve_date = curdate()',(bookid, studentid))
    result = cursor.fetchone()
    if result is None :
        cursor.execute('insert into reserve(book_id, reader_id, take_date) values (%s,%s,%s)',(bookid,studentid,takedate))
    conn.commit()
    cursor.close()
    conn.close()
    return result is None

def return_book(studentid, bookid) :
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute('CALL ReturnBook(%s,%s,1,@output)',(studentid,bookid))
    cursor.execute('select @output')
    result = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return result

def query_book(bookid) :
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute('select paths from book where bid = %s',(bookid,))
    result = cursor.fetchone()
    conn.commit()
    cursor.close()
    conn.close()
    return result[0]

def delay_search(studentid) :
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute('select book_id from borrow where reader_id = %s and return_date is null',(studentid,))
    result = cursor.fetchall()
    result1 = []
    for i in result :
        result1.append(i[0])
    conn.commit()
    cursor.close()
    conn.close()
    return result1

def delay_return(studentid,bookid) :
    conn = connect_to_db()
    cursor = conn.cursor()
    cursor.execute('CALL ReturnBook(%s,%s,0,@output)',(studentid,bookid))
    cursor.execute('select @output')
    result = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return result