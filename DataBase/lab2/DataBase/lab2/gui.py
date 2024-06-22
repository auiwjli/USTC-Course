import tkinter as tk
from tkinter import ttk
import sql
from PIL import Image, ImageTk
import random

def management_window() :
    root = tk.Tk() 
    root.title('图书管理系统')
    canvas = tk.Canvas(root, width=200, height=200, bg='white')
    canvas.pack()

    # 定义绘制圆形的函数
    def draw_circle():
        x = 100
        y = 100
        radius = 120
        canvas.create_oval(x - radius, y - radius, x + radius, y + radius, fill='blue')

    btn1 = tk.Button(canvas, text='查询', command=query_window)
    btn1.place(x=20, y=50)
    btn2 = tk.Button(canvas, text='借阅', command=borrow_window)
    btn2.place(x=110, y=50)
    btn3 = tk.Button(canvas, text='预约', command=reserve_window)
    btn3.place(x=20, y=100)
    btn4 = tk.Button(canvas, text='归还', command=return_window)
    btn4.place(x=110, y=100)
    btn5 = tk.Button(canvas, text='逾期查询', command=delay_window)
    btn5.place(x=20, y=150)
    btn6 = tk.Button(canvas, text='逾期归还', command=delay_return_window)
    btn6.place(x=110, y=150)

    # 调整按钮大小和字体大小
    btn1['font'] = ('Arial', 16)
    btn2['font'] = ('Arial', 16)
    btn3['font'] = ('Arial', 16)
    btn4['font'] = ('Arial', 16)
    btn5['font'] = ('Arial', 16)
    btn6['font'] = ('Arial', 16)
    btn1['width'] = 5
    btn2['width'] = 5
    btn3['width'] = 5
    btn4['width'] = 5
    btn5['width'] = 5
    btn6['width'] = 5
    # 绘制圆形并调整画布位置和大小
    draw_circle()
    canvas.place(x=0, y=0)
    root.geometry('250x250')  # 设置窗口大小，根据需要调整
    root.mainloop()

def borrow_window() :
    window = tk.Tk()
    window.title('借阅书籍')
    window.geometry('300x500')

    tk.Label(window, text='student id').place(x=50, y=50)
    tk.Label(window, text='book id').place(x=50, y=100)
    student_id = tk.StringVar()
    student_id.set('')
    student_id_entry = tk.Entry(window, textvariable=student_id)
    student_id_entry.place(x=150, y=50)
    book_id = tk.StringVar()
    book_id.set('')
    book_id_entry = tk.Entry(window, textvariable=book_id)
    book_id_entry.place(x=150, y=100)

    def confirm() :
        student_id1 = student_id_entry.get()
        book_id1 = book_id_entry.get()
        result = sql.borrow(student_id1, book_id1)
        top = tk.Toplevel()
        label = tk.Label(top, text=result)
        label.pack()
        top.mainloop()

    btn_confirm = tk.Button(window, text='确定', command=confirm)
    btn_confirm.place(x=150, y=150)
    window.mainloop()

def reserve_window() :
    window = tk.Tk()
    window.title('预约书籍')
    window.geometry('300x500')

    tk.Label(window, text='student id').place(x=50, y=50)
    tk.Label(window, text='book id').place(x=50, y=100)
    tk.Label(window, text='take date').place(x=50, y=150)
    student_id = tk.StringVar()
    student_id.set('')
    student_id_entry = tk.Entry(window, textvariable=student_id)
    student_id_entry.place(x=150, y=50)
    book_id = tk.StringVar()
    book_id.set('')
    book_id_entry = tk.Entry(window, textvariable=book_id)
    book_id_entry.place(x=150, y=100)
    take_date = tk.StringVar()
    take_date.set('')
    take_date_entry = tk.Entry(window, textvariable=take_date)
    take_date_entry.place(x=150, y=150)

    def confirm() :
        student_id1 = student_id_entry.get()
        book_id1 = book_id_entry.get()
        take_date1 = take_date_entry.get()
        result = sql.reserve(student_id1,book_id1,take_date1)
        result1 = ''
        if result :
            result1 = 'reserve success'
        else :
            result1 = 'reserve fail'
        top = tk.Toplevel()
        label = tk.Label(top, text=result1)
        label.pack()
        top.mainloop()


    btn_confirm = tk.Button(window, text='确定', command=confirm)
    btn_confirm.place(x=150, y=200)
    window.mainloop()

def return_window() :
    window = tk.Tk()
    window.title('归还书籍')
    window.geometry('300x500')

    tk.Label(window, text='student id').place(x=50, y=50)
    tk.Label(window, text='book id').place(x=50, y=100)
    student_id = tk.StringVar()
    student_id.set('')
    student_id_entry = tk.Entry(window, textvariable=student_id)
    student_id_entry.place(x=150, y=50)
    book_id = tk.StringVar()
    book_id.set('')
    book_id_entry = tk.Entry(window, textvariable=book_id)
    book_id_entry.place(x=150, y=100)

    def confirm() :
        student_id1 = student_id_entry.get()
        book_id1 = book_id_entry.get()
        result = sql.return_book(student_id1, book_id1)
        top = tk.Toplevel()
        label = tk.Label(top, text=result)
        label.pack()
        top.mainloop()

    btn_confirm = tk.Button(window, text='确定', command=confirm)
    btn_confirm.place(x=150, y=150)
    window.mainloop()

def query_window() :
    window = tk.Tk()
    window.title('查询书籍')
    window.geometry('300x500')

    tk.Label(window, text='book id').place(x=50, y=100)
    book_id = tk.StringVar()
    book_id.set('')
    book_id_entry = tk.Entry(window, textvariable=book_id)
    book_id_entry.place(x=150, y=100)

    def confirm() :
        book_id1 = book_id_entry.get()
        path = sql.query_book(book_id1)
        show_image(path)
    
    btn_confirm = tk.Button(window, text='确定', command=confirm)
    btn_confirm.place(x=150, y=150)
    window.mainloop()

def show_image(path) :
    window = tk.Toplevel()
    img = Image.open(path)
    photo = ImageTk.PhotoImage(img)
    image_label = tk.Label(window, image = photo)
    image_label.pack()
    window.mainloop()

def delay_window() :
    window = tk.Tk()
    window.title('逾期查询')
    window.geometry('300x500')

    tk.Label(window, text='student id').place(x=50, y=100)
    student_id = tk.StringVar()
    student_id.set('')
    student_id_entry = tk.Entry(window, textvariable=student_id)
    student_id_entry.place(x=150, y=100)

    def confirm() :
        student_id1 = student_id_entry.get()
        result = sql.delay_search(student_id1)
        top = tk.Toplevel()
        top.title('result')
        listbox = tk.Listbox(top)
        listbox.pack(fill=tk.BOTH, expand=True)
        for item in result :
            listbox.insert(tk.END,item)
        top.mainloop()
    
    btn_confirm = tk.Button(window, text='确定', command=confirm)
    btn_confirm.place(x=150, y=150)
    window.mainloop()

def delay_return_window() :
    window = tk.Tk()
    window.title('逾期归还')
    window.geometry('300x500')

    tk.Label(window, text='student id').place(x=50, y=50)
    tk.Label(window, text='book id').place(x=50, y=100)
    student_id = tk.StringVar()
    student_id.set('')
    student_id_entry = tk.Entry(window, textvariable=student_id)
    student_id_entry.place(x=150, y=50)
    book_id = tk.StringVar()
    book_id.set('')
    book_id_entry = tk.Entry(window, textvariable=book_id)
    book_id_entry.place(x=150,y=100)
    
    rand = int(1 + 3 * random.random())
    tip = 'Administrator ' + str(rand) + ' serves for you'
    tk.Label(window,text=tip).place(x=50,y=200)

    def confirm() :
        student_id1 = student_id_entry.get()
        book_id1 = book_id_entry.get()
        result = sql.delay_return(student_id1,book_id1)
        top = tk.Toplevel()
        label = tk.Label(top,text=result)
        label.pack()
        top.mainloop()
    
    btn_confirm = tk.Button(window, text='确定', command=confirm)
    btn_confirm.place(x=150, y=150)
    window.mainloop()