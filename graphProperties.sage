def genCubicWeaklyChordal(maxOrder = 25):
    k = 3
    #graphList = []
    with open('cubicWeaklyChordal.txt','a+') as graphFile:
        for n in range(k+1, maxOrder+1):
            graphParam = '{} -c -d{} -D{}'.format(n, k, k)
            print(graphParam)
            try:
                for G in graphs.nauty_geng(graphParam):
                    if G.is_weakly_chordal() and has_3BG_blocks_property(G):
                        graphString = G.graph6_string()
                        graphFile.write('{}\n'.format(graphString))
                        print(graphString)
                        #graphList.append(G)
            except:
                print('No results for {},{},{}'.format(n,k,k))

from sage.graphs.graph_coloring import number_of_n_colorings

# creates pairs of each graph with the properties it satisfies
def checkGraphProperties(G, propList = efficiently_computable_properties):
    propertyPairs = []
    for p in propList:
        try:
            func = globals()[p]
            result = func(G)
        except:
            result = getattr(G, p)()
        currentPair = tuple([result, p])
        propertyPairs.append(currentPair)
    # print(propertyPairs)
    return propertyPairs

# returns True if G satisfies everything in propList, else false
def checkGraphConditions(G, propList):
    check = checkGraphProperties(G, propList)
    for c in check:
        if not c[0]:
            return False
    return True

def checkGraphListConditions(gList, propList):
    i = 0
    for g in gList:
        i+=1
        if i%10 == 0:
            print('i is: {}'.format(i))
        if checkGraphConditions(g, propList):
            print('Graph {} satisfies all condtions in {}'.format(g.graph6_string(), propList))

def checkGraphFileConditions(gFile, propList, outputFile):
    with open('{}.txt'.format(outputFile), 'a+') as out:
        with open('{}.txt'.format(gFile), 'r') as f:
            for line in f:
                sline = line.strip()
                G = Graph(sline)
                if checkGraphConditions(G, propList):
                    g.write('{}\n'.format(sline))
#                    print('Graph {} satisfies all conditions in {}'.format(sline, propList))

# https://stackoverflow.com/questions/10312204/computing-the-degeneracy-of-a-graph
# degeneracy is max{cores}
def isThreeDegen(G):
    degen = max(G.cores())
#    print(degen)
    return degen == 3

def fakeIsThreeDegen(G):
    return number_of_n_colorings(G,3) > 0

def isSixRegular(G):
    return G.is_regular(6)


def find6Reg3Degen():
    maxOrder = 13
    k = 6
    i = 0
    graphSet = set()
    graphConditions = ['isSixRegular', 'isThreeDegen']
    for n in range(k+1, maxOrder+1):
        graphParam = '{} -c -d{} -D{}'.format(n, k, k)
        print(graphParam)
        for G in graphs.nauty_geng(graphParam):
            i+=1
            if checkGraphConditions(G, graphConditions):
                #return(G)
                graphSet.add(G.graph6_string())
                #print('Graph {} satisfies all condtions in {}'.format(G.graph6_string(), graphConditions))
    return graphSet

def find3Degen():
    with open('conjectures/3Degen3BG.txt','a+') as bootstrapFile:
        with open('conjectures/3Degen.txt','a+') as degenFile:
            for n in range(3,11):
                graphParam = '{} -c'.format(n)
                print(graphParam)
                for G in graphs.nauty_geng(graphParam):
                    if checkGraphConditions(G, ['isThreeDegen']):
                        degenFile.write('{}\n'.format(G.graph6_string()))
                        if checkGraphConditions(G, ['is_3_bootstrappable']):
                            bootstrapFile.write('{}\n'.format(G.graph6_string()))

def makeMTF(g):
    g2 = g.copy()
    from itertools import combinations
    for (v,w) in combinations(sample(g2.vertices(), k = g2.order()), 2): # Sample so output not deterministic
        if not g2.has_edge(v, w) and all(u not in g2.neighbors(v) for u in g2.neighbors(w)):
            g2.add_edge(v, w)
    return g2

def is_maximal_triangle_free(g):
    if not g.is_triangle_free():
        #print "has triangles!"
        return False
    gc = g.complement()
    for e in gc.edges(labels=False):
        gprime = copy(g)
        gprime.add_edge(e[0],e[1])
        if gprime.is_triangle_free():
            return False
    return True