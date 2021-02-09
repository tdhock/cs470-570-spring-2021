from program2_funs import Searcher, hSLD, SNode
# (b) Show your program loading in the 30-node sample file. 
s=Searcher("30node.txt")
# (c) Show you program setting start node=U and end node=T. 
s.setStartGoal('U','T')
# myViz should be a DRDViz instance -> save map to file on disk.
s.myViz.save("30node.png")
# (d) Show the one open node.
[n.showBasic() for n in s.open]
# (e) Show successors of only open node.
initial_children = s.successors(s.open.pop(0))
[n.showBasic() for n in initial_children]

# (f) Show three inserts: at the front, and the end, and "in order"
s.reset()
initial_children = s.successors(s.open.pop(0))
ignored = s.insert_front(initial_children)
[n.showBasic() for n in s.open]

s.reset()
initial_children = s.successors(s.open.pop(0))
ignored = s.insert_end(initial_children)
[n.showBasic() for n in s.open]

s.reset()
initial_children = s.successors(s.open.pop(0))
ignored = s.insert_ordered(initial_children)
[n.showBasic() for n in s.open]

# (g) Now let's make sure your INSERT handles duplicates properly:
# manually create new nodes for (K,500), (C,91) and (J,10). INSERT
# these into your OPEN list, showing the results.
newdata = (("K",500), ("C",91), ("J",10))
newlist = [SNode(label=label, pathcost=pathcost) for label, pathcost in newdata]
ignored = s.insert_end(newlist)
[n.showBasic() for n in s.open]

# 3. hSLD heuritic function being called on three nodes.
[hSLD(x, s) for x in ("V", "AC", "J")]
