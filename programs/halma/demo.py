from tkinter import *
import pdb
root = Tk()
CANVAS_DIM = 30
class Position:
    def __init__(self, row, column, board):
        self.row = row
        self.column = column
        self.board = board
        self.canvas_instance = Canvas(
            root, width=CANVAS_DIM, height=CANVAS_DIM, bg="grey")
        self.canvas_instance.grid(row=row, column=column)
        self.canvas_instance.create_text(
            CANVAS_DIM/2,CANVAS_DIM/2,text="%d,%d"%(row,column))
        if row+column <= 2:
            self.oval_id = self.canvas_instance.create_oval(
                0, 0, CANVAS_DIM, CANVAS_DIM,
                fill="white")
            self.canvas_instance.tag_bind(
                self.oval_id,"<Button-1>",self.clickPiece)
    def clickPiece(self, e):
        prev = self.board.PREV_HILITE
        if prev is not None:
            prev.canvas_instance.itemconfig(prev.oval_id, fill="white")
        self.canvas_instance.itemconfig(self.oval_id, fill="red")
        self.board.PREV_HILITE = self
class Board:
    def __init__(self, N_POSITIONS=10):
        self.PREV_HILITE = None
        for row in range(N_POSITIONS):
            for column in range(N_POSITIONS):
                Position(row=row, column=column, board=self)
board_instance = Board()
root.mainloop()

