from project1_funs import *
myBoard = loadBoard("board.txt")
printBoard(myBoard)
possibleMoves((3,3),myBoard)
possibleMoves((2,1),myBoard)
legalMoves( possibleMoves((1,2), myBoard), ( (1,0),(2,0),(2,1),(2,2) ))
legalMoves( possibleMoves((2,2), myBoard), ( (1,1),(1,2),(1,3),(2,3),(3,2) ) )
myDict = frozenset(word.strip() for word in open("twl06.txt"))
examineState(myBoard,(0,3),( (1,1), (0,1),(0,2) ) ,myDict)
examineState(myBoard,(0,0),( (3,3), (2,2), (1,1) ) ,myDict)
examineState(myBoard,(3,3),( (2,2),(2,1),(2,0),(3,0),(3,1),(3,2) ) ,myDict)

