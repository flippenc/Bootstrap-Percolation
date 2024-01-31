# needs bootstrapDefinitions and fileFunctions.sage to be loaded to work

import datetime

def loadObjGraphs():
    objGraphList = []
    objList = ['new_3bg_graphs_via_bip','new_3bg_graphs_via_ba', 'new_3bg_graphs_via_bip_2']#, 'new_3bg_graphs_via_ham', 'new_3bg_graphs_via_gnp', 'new_3bg_graphs_mixed']
    for i in objList:
        currentFileList = load(i)
        objGraphList.extend(currentFileList)
    objList2 = ['new_3bg_graphs_via_gnp', 'new_3bg_graphs_mixed']
    for i in objList2:
        currentFileList = load(i)
        for i in currentFileList:
            if i.order() < 70:
                objGraphList.append(i)
    return objGraphList

# https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.RandomRegular
def makeRegularGraphs(numPerVertices = 5, minV = 10, maxV = 60):
    regulars = []
    for i in range(minV, maxV+1):
        for j in range(numPerVertices+1):
            G = graphs.RandomRegular(6,i)
            if (has_3BG_blocks_property(G)):
                regulars.append(G)
#            regulars.append(graphs.RandomRegular(6,i))
    return regulars

# def getFalsifying():
#     falsifying = []
#     removeDupes('conjectures/falsifyingGraphs-is_3_bootstrappable-sufficient')
#     with open('conjectures/falsifyingGraphs-is_3_bootstrappable-sufficient-unDuped.txt') as falsifyingFile:
#         for line in falsifyingFile:
#             G = Graph(line)
#             if has_3BG_blocks_property(G):
#                 falsifying.append(G)
#     return falsifying

def loadConjecturingGraphs():
    objects = []
    regulars = makeRegularGraphs()
    falsifying = getFalsifying()
    for g in graph_objects:
        if has_3BG_blocks_property(g) and g.order()<100:
            objects.append(g)
    for g in regulars:
        if has_3BG_blocks_property(g) and g.order()<100:
            objects.append(g)
    for g in falsifying:
        if has_3BG_blocks_property(g) and g.order()<100:
            objects.append(g)
    objects.extend(loadObjGraphs())
    return objects

def makeTheoremList():
    gunderson2 = lambda g: g.order() >= 30 and min(g.degree_sequence()) >= floor(g.order()/2) + 1
    freund1 = lambda g: min(g.degree_sequence()) >= ceil(1.5*g.order())
    wesolek5 = lambda g: g.order() >= 8 and g.size() >= binomial(g.order()-1, 2) +1
    return [gunderson2, freund1, wesolek5]

def createConjectures():
    objects = loadConjecturingGraphs()
    properties = [is_3_bootstrappable, is_2_bootstrap_good]#, isSixRegular]
    properties.extend(sample(efficiently_computable_properties, 20))
    #print('Current properties: {}'.format(properties))
    prop = properties.index(is_3_bootstrappable)

    theorems = makeTheoremList()
    print('Making conjectures with {} graphs, {} properties, and {} theorems'.format(len(objects), len(properties), len(theorems)))
    conj = propertyBasedConjecture(objects, properties, prop, theory = theorems, precomputed = precomputed_properties_for_conjecture(), sufficient = True)
    outputFileName = makeConjectureFileName('is_3_bootstrappable')
    file = open('{}.txt'.format(outputFileName), 'a+')
    for c in conj:
        #print('Conj: {}'.format(c))
        file.write('{}\n'.format(c))
    print('Made {} conjectures'.format(len(conj)))
    file.close()
    #sortConjectures(outputFileName)

def isSixRegular(G):
    return G.is_regular(6)