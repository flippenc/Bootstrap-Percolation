import re
import os
from sage.graphs.graph_input import from_graph6
from itertools import zip_longest
from sage.graphs.connectivity import is_connected

falseConjListPrefix = 'conjectures/falseConjectures'
falseConjVerboseListPrefix = 'conjectures/falseConjecturesVerbose'
falsifyingGraphPrefix = 'conjectures/falsifyingGraphs'
stillUnfalsifiedPrefix = 'conjectures/unfalsifiedConjectures'

minFalsifyingGraphPrefix = 'conjectures/minFalsifyingGraphs'
minFalsifiedConjecturesPrefix = 'conjectures/minFalsifiedConjectures'

def checkFalseConjList(conj, suffix, sufficient=True):
    if sufficient:
        necessOrSuff = 'sufficient'
    else:
        necessOrSuff = 'necessary'
    falseConjList = '{}-{}-{}.txt'.format(falseConjListPrefix, suffix, necessOrSuff)
    #open the falseConjecture file and check if conj is present in it
    with open(falseConjList, 'a+') as f:
        if not any(value == x.rstrip('\r\n') for x in f):
            return True

def recordFalseConj(conj, falseGraph, suffix, sufficient=True):
    if sufficient:
        necessOrSuff = 'sufficient'
    else:
        necessOrSuff = 'necessary'
    falseConjVerboseList = '{}-{}-{}.txt'.format(falseConjVerboseListPrefix, suffix, necessOrSuff)
    with open(falseConjVerboseList, 'a+') as falseConjVerboseFile:
        falseConjVerboseFile.write('Conjecture {} is false because of graph: {}\n'.format(conj,falseGraph.graph6_string()))
    falseConjList = '{}-{}-{}.txt'.format(falseConjListPrefix, suffix, necessOrSuff)
    with open(falseConjList, 'a+') as falseConjFile:
        falseConjFile.write('{}\n'.format(conj))

def recordStillUnfalsified(conj, suffix, sufficient=True):
    if sufficient:
        necessOrSuff = 'sufficient'
    else:
        necessOrSuff = 'necessary'
    stillUnfalsified = '{}-{}-{}.txt'.format(stillUnfalsifiedPrefix, suffix, necessOrSuff)
    with open(stillUnfalsified, 'a+') as stillUnfalsifiedFile:
        stillUnfalsifiedFile.write('{}\n'.format(conj))

def recordFalsifyingGraph(falseGraph, suffix, sufficient=True):
    if sufficient:
        necessOrSuff = 'sufficient'
    else:
        necessOrSuff = 'necessary'
    falsifyingGraph = '{}-{}-{}.txt'.format(falsifyingGraphPrefix, suffix, necessOrSuff)
    with open(falsifyingGraph, 'a+') as falsifyingGraphFile:
        falsifyingGraphFile.write('{}\n'.format(falseGraph.graph6_string()))

def getSuffix(line, suff):
    if suff:
        suffix = line.split('->')[1]
    else:
        suffix = line.split('<-')[1]
    suffix = suffix.strip()[1:-1]
    return suffix

def replaceNeg(s):
    s = s.replace('~(True)','False')
    s = s.replace('~(False)','True')
    return s

def replaceAND(s):
    s = s.replace('(True)&(True)','True')
    s = s.replace('(True)&(False)','False')
    s = s.replace('(False)&(True)','False')
    s = s.replace('(False)&(False)','False')
    return s

def replaceOR(s):
    s = s.replace('(True)|(True)','True')
    s = s.replace('(True)|(False)','True')
    s = s.replace('(False)|(True)','True')
    s = s.replace('(False)|(False)','False')
    return s

def replaceXOR(s):
    s = s.replace('(True)^(True)','True')
    s = s.replace('(True)^(False)','False')
    s = s.replace('(False)^(True)','False')
    s = s.replace('(False)^(False)','False')
    return s

def replaceImp(s):
    s = s.replace('(False)->(True)','True')
    s = s.replace('(False)->(False)','True')
    s = s.replace('(True)->(False)','False')
    s = s.replace('(True)->(True)','True')
    return s

def replaceConv(s):
    s = s.replace('(False)<-(True)','False')
    s = s.replace('(False)<-(False)','True')
    s = s.replace('(True)<-(False)','True')
    s = s.replace('(True)<-(True)','True')
    return s

def evaluateString(s):
    #print(s)
    if '~' in s:
        s = replaceNeg(s)
    if '&' in s:
        s = replaceAND(s)
    if '|' in s:
        s = replaceOR(s)
    if '^' in s:
        s = replaceXOR(s)
    if '->' in s:
        s = replaceImp(s)
    if '<-' in s:
        s = replaceConv(s)
    if (s == 'True'):
        return 'True'
    elif (s == 'False'):
        return 'False'
    else:
        return evaluateString(s)

def checkSingleConj(conj, testAgainst):
    #print(testAgainst)
    regex = r"\(([^)([^)]+)\)"
    matches = re.finditer(regex, conj, re.MULTILINE)
    propList = []
    for _, match in enumerate(matches, start=1):
        #if match.group() != '->':
        propList.append(match.group(1))
    # print(propList)
    for g in testAgainst:
        # print(g)
        currentConj = conj
        for i in propList:
            try:
                result = getattr(g, i)()
            except:
                func = globals()[i]
                result = func(g)
            currentConj = currentConj.replace('({})'.format(i),'({})'.format('{}'.format(result)))
            # print(currentConj)
        result = evaluateString(currentConj)
        #print(result)
        if result == 'False':
            return False, g
    return True, ""

def checkConjListAgainstGraphs(conjList, testAgainst, outputFileName):
    # print(conjList)
    for currentConj in conjList:
        # print(currentConj)
        # print('testAgainst is: {}'.format(testAgainst))
        if '->' in currentConj:
            suff = True
            necOrSuff = 'sufficient'
            suffix = getSuffix(currentConj, suff)
        elif '<-' in currentConj:
            suff = False
            necOrSuff = 'necessary'
            suffix = getSuffix(currentConj, suff)
        else:
            suff = False
            necOrSuff = 'expression'
            suffix = 'expressions'
        file = open(outputFileName, 'a+')
        if (not checkFalseConjList(currentConj, suffix, sufficient = suff)):
            file.write('Conjecture {} is in the false conjecture list\n'.format(currentConj))
        else:
            result = checkSingleConj(currentConj, testAgainst)
            # print('testAgainst again is {}'.format(testAgainst))
            if result[0]:
                file.write('Conjecture {} is true for all tested graphs\n'.format(currentConj))
                recordStillUnfalsified(currentConj, suffix, sufficient = suff)
            else:
                file.write('Conjecture {} is false because of graph: {}\n'.format(currentConj, result[1].graph6_string()))
                recordFalseConj(currentConj, result[1], suffix, sufficient = suff)
                recordFalsifyingGraph(result[1], suffix, sufficient = suff)
        file.close()

def checkConjListAgainstFile(conjList, graphFile, outputFileName):
    testAgainst = []
    G = Graph()
    with open('{}.txt'.format(graphFile), 'r') as gF:
        for line in gF:
            testAgainst.append(Graph(line.strip()))
    checkConjListAgainstGraphs(conjList, testAgainst, outputFileName)

def randConnected(n, p, c = 2000):
    counter = 0
    gnp = graphs.RandomGNP(n,p)
    while not (is_connected(gnp) and has_3BG_blocks_property(gnp)):
        gnp = graphs.RandomGNP(n,p)
        counter+=1
        if counter == c:
            gnp = k3
    return gnp

def makeCheckingGraphs():
    objects = []
    objects += [g for g in graph_objects if g.order() < 20 & has_blocks_property(g)]
    for n in range(1,100):
        vertices = randint(20,60)
        prob = random()
        g=randConnected(vertices,prob)
        objects += [g]
    return objects

def checkConjListDefault(conjList, outputFileName):
    testAgainst = makeCheckingGraphs()
    checkConjListAgainstGraphs(conjList, testAgainst, outputFileName)

def checkConjFileAgainstGraphs(conjListFile, testAgainst):
    with open('{}.txt'.format(conjListFile), 'r') as cL:
        for line in cL:
            currentConj = line.strip()
            if '->' in currentConj:
                suff = True
                necOrSuff = 'sufficient'
                suffix = getSuffix(line, suff)
            elif '<-' in currentConj:
                suff = False
                necOrSuff = 'necessary'
                suffix = getSuffix(line, suff)
            else:
                suff = False
                necOrSuff = 'expression'
                suffix = 'expressions'
            outputFileName = '{}-{}-{}-checked.txt'.format(conjListFile, suffix, necOrSuff)
            file = open(outputFileName, 'a+')
            if (not checkFalseConjList(currentConj, suffix, sufficient = suff)):
                file.write('Conjecture {} is in the false conjecture list\n'.format(line))
            else:
                result = checkSingleConj(currentConj, testAgainst)
                if result[0]:
                    file.write('Conjecture {} is true for all tested graphs\n'.format(currentConj))
                    recordStillUnfalsified(currentConj, suffix, sufficient = suff)
                else:
                    file.write('Conjecture {} is false because of graph: {}\n'.format(currentConj, result[1].graph6_string()))
                    recordFalseConj(currentConj, result[1], suffix, sufficient = suff)
                    recordFalsifyingGraph(result[1], suffix, sufficient = suff)
            file.close()

def checkConjFileDefault(conjListFile):
    testAgainst = makeCheckingGraphs()
    checkConjFileAgainstGraphs(conjListFile, testAgainst)

def checkConjFileAgainstFile(conjListFile, graphFile):
    testAgainst = []
    G = Graph()
    with open('{}.txt'.format(graphFile), 'r') as gF:
        for line in gF:
            testAgainst.append(Graph(line.strip()))
    checkConjFileAgainstGraphs(conjListFile, testAgainst)

def recordMinFalsifying(conj, falseGraphString):
    if '->' in conj:
        suff = True
        necOrSuff = 'sufficient'
        suffix = getSuffix(conj, suff)
    elif '<-' in conj:
        suff = False
        necOrSuff = 'necessary'
        suffix = getSuffix(conj, suff)
    else:
        suff = False
        necOrSuff = 'expression'
        suffix = 'expressions'
    minFalsifyingGraph = '{}-{}-{}.txt'.format(minFalsifyingGraphPrefix, suffix, necOrSuff)
    minFalsifiedConjectures = '{}-{}-{}.txt'.format(minFalsifiedConjecturesPrefix, suffix, necOrSuff)
    # with open(falsifyingGraph, 'a+') as falsifyingGraphFile:
    #     falsifyingGraphFile.write('{}\n'.format(falseGraph.graph6_string()))
    with open(minFalsifyingGraph, 'a+') as minFalsifyingGraphFile:
        minFalsifyingGraphFile.write('{}\n'.format(falseGraphString))
    with open(minFalsifiedConjectures, 'a+') as minFalsifiedConjecturesFile:
        minFalsifiedConjecturesFile.write('{}\n'.format(conj))

def findMinFalsifyingGraph(conj, falseGraphString):
    falseGraph = Graph(falseGraphString)
    maxOrder = falseGraph.order()
    # check every small graph up to order min(10, maxOrder)
    # if maxOrder if larger than 10 and nothing smaller is found,
    # a smarter way of finding a falsifying graph is needed
    # -> check properties of falseGraph and construct graphs with those properties
    for j in range(3, min(10, maxOrder)):
        # print('on graphs with {} vertices'.format(j))
        graphParam = "{} -c".format(j)
        for G in graphs.nauty_geng(graphParam):
            checkAgainst = [G]
            checked = checkSingleConj(conj, checkAgainst)
            if not checked[0]:
                print('Conjecture {} has smaller falsifying graph given by {}'.format(conj, G.graph6_string()))
                recordMinFalsifying(conj, G.graph6_string())
                return
    print('No smaller falsifying graphs found with fewer than {} vertices for {}'.format(min(10,maxOrder), conj))
    recordStillUnfalsified(conj, suffix, sufficient = suff)

#output format: tuples of form (conjecture, g6string)
def makeConjTuplesList(conjList, falseGraphList):
    fileList = ['{}.txt'.format(conjList), '{}.txt'.format(falseGraphList)]
    files = [open(fileName) for fileName in fileList]
    tupleList = []
    for lines in zip_longest(*files):
        tupleList.append(tuple(l.strip() for l in lines))
    return tupleList

# https://stackoverflow.com/questions/34936961/read-lines-from-multiple-files-python
# https://stackoverflow.com/questions/14278360/python-strip-spaces-in-tuple
def findMinFalsifyingGraphFile(conjList, falseGraphList):
    tupleList = makeConjTuplesList(conjList, falseGraphList)
    for t in tupleList:
        findMinFalsifyingGraph(t[0],t[1])

def removeSmallFalsifying(minFalseSize, conjList, falseGraphList):
    tupleList = makeConjTuplesList(conjList, falseGraphList)
    newConj = '{}-minOrder{}.txt'.format(conjList, minFalseSize)
    newGraph = '{}-minOrder{}.txt'.format(falseGraphList, minFalseSize)
    newConjFile = open(newConj, 'a+')
    newGraphFile = open(newGraph, 'a+')
    for i in tupleList:
        G = Graph(i[1].strip())
        if G.order() >= minFalseSize:
            newConjFile.write('{}\n'.format(i[0]))
            newGraphFile.write('{}\n'.format(i[1]))
    newConjFile.close()
    newGraphFile.close()

def checkAgainstSmallGraphs(conj, minOrder = 4, maxOrder=8, graphCond = '-c'):
    #print(conj)
    if '->' in conj:
        suff = True
        necOrSuff = 'sufficient'
        suffix = getSuffix(conj, suff)
    elif '<-' in conj:
        suff = False
        necOrSuff = 'necessary'
        suffix = getSuffix(conj, suff)
    else:
        suff = False
        necOrSuff = 'expression'
        suffix = 'expressions'
    for j in range(minOrder,maxOrder+1):
        #print('On graphs with {} vertices'.format(j))
        graphParam = '{} {}'.format(j, graphCond)
        for G in graphs.nauty_geng(graphParam):
            if has_3BG_blocks_property(G):
                checkAgainst = [G]
                checked = checkSingleConj(conj, checkAgainst)
                if not checked[0]:
                    recordFalseConj(conj, G, suffix, suff)
                    recordFalsifyingGraph(G, suffix, suff)
                    print('Conjecture {} is false because of graph {}'.format(conj, G.graph6_string()))
                    return
    print('No smaller falsifying graphs found with fewer than {} vertices for {}'.format(maxOrder, conj))
    recordStillUnfalsified(conj, suffix, sufficient = suff)

def checkFileAgainstSmallGraphs(conjListFile, minOrder=4, maxOrder=8, graphCond='-c'):
    with open('{}.txt'.format(conjListFile), 'r') as conjFile:
        for line in conjFile:
            conj = line.strip()
            checkAgainstSmallGraphs(conj, minOrder, maxOrder, graphCond)

def checkAgainstRandomGNP(conj, n = 8, prob = random(), checkNum = 1000):
    if '->' in conj:
        suff = True
        necOrSuff = 'sufficient'
        suffix = getSuffix(conj, suff)
    elif '<-' in conj:
        suff = False
        necOrSuff = 'necessary'
        suffix = getSuffix(conj, suff)
    else:
        suff = False
        necOrSuff = 'expression'
        suffix = 'expressions'
    for i in range(1,checkNum):
        G = randConnected(n, prob, c = 2000)
        checkAgainst = [G]
        checked = checkSingleConj(conj, checkAgainst)
        if not checked[0]:
            recordFalseConj(conj, G, suffix, suff)
            recordFalsifyingGraph(G, suffix, suff)
            print('Conjecture {} is false because of graph {}'.format(conj, G.graph6_string()))
            return
    print('Conjecture {} not falsified after checking {} random connected graphs with {} vertices'.format(conj, checkNum, n))
    recordStillUnfalsified(conj, suffix, sufficient = suff)

def checkFileAgainstRandomGNP(conjListFile, n = 8, prob = random(), checkNum = 100000):
    with open('{}.txt'.format(conjListFile), 'r') as conjFile:
        for line in conjFile:
            conj = line.strip()
            checkAgainstRandomGNP(conj, n, prob, checkNum)