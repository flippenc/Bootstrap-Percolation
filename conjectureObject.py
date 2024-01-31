from enum import Enum
#from sage.graphs.graph import Graph

#def checkImport(g):
#    return Graph(g).graph6_string()

class conjStatus(Enum):
    UNFALSIFIED = 1
    FALSIFIED = 2
    PROVEN = 3

class Conjecture:
    def __init__(self, conjText):
        self.conjText = conjText
        self.status = conjStatus.UNFALSIFIED
        # save falsifyingGraphs and specialProperties as sets so they can be updated efficiently using set union
        # https://docs.python.org/3/library/stdtypes.html?highlight=list#set-types-set-frozenset
        self.falsifyingGraphs = set()
        self.specialProperties = set()