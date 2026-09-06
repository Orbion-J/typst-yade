#import "../../src/lib.typ" as yade

#set page(width: auto, height: auto, margin: 0%)

#show: yade.yade

#let diag = ```yade
{"graph":{"activeTabId":0,"latexBackgroundColor":"white","latexPreamble":"\\newcommand{\\coqproof}[1]{\\checkmark}","nextTabId":1,"tabs":[{"edges":[{"from":0,"id":4,"label":{"label":"h","options":{},"zindex":0},"to":1},{"from":2,"id":5,"label":{"label":"f","options":{},"zindex":0},"to":3},{"from":0,"id":6,"label":{"label":"k","options":{"alignment":"right"},"zindex":0},"to":2},{"from":1,"id":7,"label":{"label":"g","options":{},"zindex":0},"to":3}],"freehandDrawings":[],"id":0,"nextGraphId":8,"nodes":[{"id":0,"label":{"label":"A","options":{},"pos":[533,117],"zindex":0}},{"id":1,"label":{"label":"B","options":{},"pos":[611,117],"zindex":0}},{"id":2,"label":{"label":"C","options":{},"pos":[585,195],"zindex":0}},{"id":3,"label":{"label":"D","options":{},"pos":[663,195],"zindex":0}}],"sizeGrid":26,"title":"1"}]},"version":20}
```

#diag

#yade.diagram(diag, scale: none)

#yade.diagram(diag, scale: .5)

#yade.diagram(diag, scale: 2)

