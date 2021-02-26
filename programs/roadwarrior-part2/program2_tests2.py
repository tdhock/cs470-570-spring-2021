from program2_funs import Searcher

# test 1
x=Searcher("10test.txt", searchType="DEPTH", verbose=True)
x.setStartGoal('h','k')
x.search()
x.stats()

x=Searcher("10test.txt", searchType="BREADTH", verbose=True)
x.setStartGoal('h','k')
x.search()
x.stats()

x=Searcher("10test.txt", searchType="BEST", verbose=True)
x.setStartGoal('h','k')
x.search()
x.stats()

x=Searcher("10test.txt", searchType="A*", verbose=True)
x.setStartGoal('h','k')
x.search()
x.stats()

## test 2.1
x=Searcher("50test.txt", searchType="DEPTH", verbose=False)
x.setStartGoal('ag','f')
x.search()
x.stats()

x=Searcher("50test.txt", searchType="BREADTH", verbose=False)
x.setStartGoal('ag','f')
x.search()
x.stats()

x=Searcher("50test.txt", searchType="BEST", verbose=False)
x.setStartGoal('ag','f')
x.search()
x.stats()

x=Searcher("50test.txt", searchType="A*", verbose=False)
x.setStartGoal('ag','f')
x.search()
x.stats()

# test 2.2
x=Searcher("50test.txt", searchType="DEPTH", verbose=False)
x.setStart('m')
x.setGoals(['c', 'af', 'ak'])
x.search()
x.stats()

x=Searcher("50test.txt", searchType="BREADTH", verbose=False)
x.setStart('m')
x.setGoals(['c', 'af', 'ak'])
x.search()
x.stats()

x=Searcher("50test.txt", searchType="BEST", verbose=False)
x.setStart('m')
x.setGoals(['c', 'af', 'ak'])
x.search()
x.stats()

x=Searcher("50test.txt", searchType="A*", verbose=False)
x.setStart('m')
x.setGoals(['c', 'af', 'ak'])
x.search()
x.stats()

x=Searcher("50test.txt", searchType="A*", verbose=False)
x.setStart('m')
x.setGoals(['c', 'af'])
x.search()
x.myViz.save("50test.png")
x.stats()

