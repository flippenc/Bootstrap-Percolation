from math import inf
import os
from enum import Enum
import re
import pickle
import shelve
import conjectureObject as conjObj
#from conjectureObject import conjStatus
from collections import defaultdict

class graphObjType(Enum):
    FILE = 1
    LIST = 2
    GRAPH = 3
    GRAPHSTRING = 4
    OTHER = 5

class graphListType(Enum):
    GRAPHSTRINGLIST = 1
    GRAPHOBJECTLIST = 2
    EMPTY = 3
    OTHER = 4

class conjectureObjType(Enum):
    CONJTEXT = 1
    CONJLIST = 2
    CONJFILE = 3
    CONJOBJ = 4
    CONJOBJFILE = 5
    OTHER = 6

class fileType(Enum):
    PICKLE = 1
    GRAPHOBJECT = 2
    GRAPHSTRING = 3
    EMPTY = 4
    OTHER = 5

# TODO: add support for a list of conjecture files
# conjectures is any object containing conjectures except sobj :
# (text, Conjecture object, list of text, list of objects, file of text, shelf of conjectures)
# testAgainst is any object containing graphs
# (Graph, graph string, list of Graphs, list of graph strings, txt file of graph strings, sobj of graph objects, pickle)
# if testAgainst is None, then a set of graphs made with makeCheckingGraphs is used
# largeFile is a boolean for if testAgainst is large - should be true if using something like a pickle
# saveTo is a shelf, if saveTo is None, then the results are just returned
def checkConjectures(conjectures, testAgainst = None, largeFile = False, saveTo = None):
    conjectureType = determineConjectureObjectType(conjectures)
    graphType = determineGraphObjectType(testAgainst)
    conjList = toConjList(conjectures, conjectureType)
    if testAgainst is None:
        testAgainst = makeCheckingGraphs()
        checkConjectures(conjectures, testAgainst, largeFile = False)
    else:
        conjObjList = []
        if not largeFile:
            graphList = toGraphObjectList(testAgainst, graphType)
            for conj, propList in conjList:
                currentConjObj = conjObj.Conjecture(conj)
                for g in graphList:
                    result = checkSingleConj(conj, g, propList)
                    if not result[0]:
                        currentConjObj = conjFalsify(currentConjObj, g)
                conjObjList.append(currentConjObj)
            # now either return conjObjList or save them to a file
            return saveResults(conjObjList, saveTo)
        if largeFile:
            conjObjList = []
            if determineGraphObjectType(testAgainst) != graphObjType.FILE:
                print('largeFile flag only used if the input is a file')
                return
            elif determineFileType(testAgainst) == fileType.PICKLE:
                for conj, propList in conjList:
                    currentConjObj = conjObj.Conjecture(conj)
                    for g in getPickleGenerator(testAgainst):
                        result = checkSingleConj(conj, g, propList)
                        if not result[0]:
                            currentConjObj = conjFalsify(currentConjObj, g)
                    conjObjList.append(currentConjObj)
                return saveResults(conjObjList, saveTo)
            elif determineFileType(testAgainst) == fileType.GRAPHSTRING:
                for conj, propList in conjList:
                    currentConjObj = conjObj.Conjecture(conj)
                    with open(testAgainst, 'r') as graphFile:
                        for line in graphFile:
                            g = Graph(line)
                            result = checkSingleConj(conj, g, propList)
                            if not result[0]:
                                currentConjObj = conjFalsify(currentConjObj, g)
                        conjObjList.append(currentConjObj)
                return saveResults(conjObjList, saveTo)
            elif determineFileType(testAgainst) == fileType.GRAPHOBJECT:
                for conj, propList in conjList:
                    currentConjObj = conjObj.Conjecture(conj)
                    with open(testAgainst, 'r') as graphFile:
                        for g in graphFile:
                            result = checkSingleConj(conj, g, propList)
                            if not result[0]:
                                currentConjObj = conjFalsify(currentConjObj, g)
                        conjObjList.append(currentConjObj)
                return saveResults(conjObjList, saveTo)

# mark this conjecture as falsified and add the falsifying graphs to its falsifying graph list
# first check if falsifyingGraph actually falsifies the conjectures, then add it to the conjecture's graph list
def conjFalsify(conj, falsifying):
    # check if falsifyingGraph actually falsifies the conjecture
    gObjectList = toGraphObjectList(falsifying, determineGraphObjectType(falsifying))
    for g in gObjectList:
        if confirmFalsifying(conj.conjText, conj.specialProperties, g):
            # if falsifyingGraph does falsify, then update the conjecture's status
            conj.status = conjObj.conjStatus.FALSIFIED
            g.relabel(inplace = False)
            conj.falsifyingGraphs.add(g.copy(immutable=True))
    return conj

# this function cannot unprove a conjecture since a conjecture couldn't have had any falsifying graphs if it was proven
# this function can change a falsified conjecture to unfalsified if all of its falsifying graphs are removed by adding {properties}
def conjAddSpecialProperties(conj, properties):
    if isinstance(properties, list):
        conj.specialProperties.extend(properties)
    elif isinstance(properties, str):
        conj.specialProperties.add(properties)
    else:
        print(f'Tried to add something that is not a property or list of properties to conjecture {conj.conjText}')
        return
    updatedFalsifyingGraphs = set()
    for g in conj.falsifyingGraphs:
        if confirmFalsifying(conj.conjText, conj.specialProperties, g):
            updatedFalsifyingGraphs.add(g)
    if not updatedFalsifyingGraphs and conj.status == conjObj.conjStatus.FALSIFIED:
        print(f'Adding the properties {properties} to {conj.conjText} changed the conjecture from falsified to unfalsified')
        conj.status = conjObj.conjStatus.UNFALSIFIED
    conj.falsifyingGraphs = updatedFalsifyingGraphs
    return conj

# update the status of the conjecture to PROVEN
# if a conjecture has graphs in its falsifying graph list, then it cannot be true, 
# so we don't update the status and print a message
def conjProve(conj):
    if not conj.falsifyingGraphs:
        print(f'Conjecture "{conj.conjText}" cannot be true if has graphs in its falsifyingGraph list')
        return
    conj.status = conjObj.conjStatus.PROVEN
    return conj

# print the status, special properties, and list of falsifying conjectures for the current conjecture object
def conjCheckStatus(conj):
    print(f'Conjecture "{conj.conjText}" has status {conj.status}')
    if conj.specialProperties:
        print(f'Conjecture "{conj.conjText}" has the follow special property requirements: {conj.specialProperties}')
    if conj.status == conjObj.conjStatus.FALSIFIED:
        if len(conj.falsifyingGraphs) < 20:
            print(f'Conjecture "{conj.conjText}" is falsified by:')
            printGraphObjList(conj.falsifyingGraphs)
        else:
            print(f'Conjecture "{conj.conjText}" is falsified by {len(conj.falsifyingGraphs)}')

# prints the g6strings of a list of graphs
def printGraphObjList(gList):
    for g in gList:
        print(g.graph6_string())

# get the graphs which falsified the conjectures in conjShelf
# if we just want the graphs with falsified some subset of the conjShelf conjectures, that is the keyList variable
# if we want to exclude graphs which satisfy a certain set of properties, the exclude variable takes a list of function pointers to check
# if we want to include only graphs which satisfy a certain set of properties, the include variable takes a list of function pointers to check
def getFalsifyingGraphList(conjShelf, keyList = None, exclude = [], include = []):
    if not exclude and not include:
        with shelve.open(conjShelf) as shelf:
            if keyList is None:
                keyList = list(shelf.keys())
            graphSet = set()
            for key in keyList:
                graphSet = graphSet.union(shelf[key].falsifyingGraphs)
        return list(graphSet)
    else:
        with shelve.open(conjShelf) as shelf:
            if keyList is None:
                keyList = list(shelf.keys())
            graphSet = set()
            for key in keyList:
                currentKeySet = shelf[key].falsifyingGraphs
                currentSet = set()
                for g in currentKeySet:
                    if not any(i(g) for i in exclude) and all(j(g) for j in include):
                        currentSet = currentSet.union(g)
                graphSet = graphSet.union(currentSet)
        return list(graphSet)

# add a conjecture object newConj to a pre-existing shelf of conjecture objects, conjShelf
def addConjecture(newConj, conjShelf):
    with shelve.open(conjShelf) as shelf:
        # check if the new conjecture's text is a key in shelf
        if newConj.conjText in shelf:
            shelfConj = shelf[newConj.conjText]
            # update conj's list of falsifyingGraphs using set union
            # before updating the falsifyingGraphs list, make sure conj and newConj have the same specialProperties lists
            # can take union of conj and newConj's special properties lists and make sure 
            if newConj.status == conjObj.conjStatus.FALSIFIED:
                newFalsifying = set()
                checkFalsifying = shelfConj.falsifyingGraphs.union(newConj.falsifyingGraphs)
                checkProps = shelfConj.specialProperties.union(newConj.specialProperties)
                for check in checkFalsifying:
                    if confirmFalsifying(shelfConj.conjText, checkProps, check):
                        newFalsifying.add(check)
                # if newFalsifying is not empty, then there are graphs which falsify the conjecture
                if not newFalsifying:
                    newConj.status = conjObj.conjStatus.UNFALSIFIED
                    newConj.falsifyingGraphs = set()
                else:
                    newConj.status = conjObj.conjStatus.FALSIFIED
                    newConj.falsifyingGraphs = newFalsifying
                shelf[newConj.conjText] = newConj
            return
        else:
            # if newConj is not in the shelf:
            shelf[newConj.conjText] = newConj

# due to how the text of some files has been read, there are duplicate conjectures with whitepace in them
# if conjectures with whitespace are found, the data from the whitespace conjectures is moved to non-whitespace entries 
# and the whitespace ones are removed
def removeDuplicates(conjShelf):
    with shelve.open(conjShelf) as shelf:
        conjList = list(shelf.keys())
        dupes = [conjStatement for conjStatement in conjList if conjStatement.strip() != conjStatement]
        nonWhitespaceList = []
        for duplicate in dupes:
            nonWhitespace = shelf[duplicate]
            nonWhitespace.conjText = nonWhitespace.conjText.strip()
            nonWhitespaceList.append(nonWhitespace)
            del shelf[duplicate]
    for nonWhitespace in nonWhitespaceList:
        addConjecture(nonWhitespace, conjShelf)

# check if the graph object 'graph' satisfies everything in specialProperties and satisfies the conjecture string 'conj'
def confirmFalsifying(conj, specialProperties, graph):
    if not checkYesProperties(graph, specialProperties):
        return False
    if checkSingleConj(conj, graph):
        return True
    return False

# evaluates the function 'funcString' using the input 'param'
def evalFuncString(funcString, param):
    try:
        try:
            result = getattr(param, funcString)()
        except:
            func = globals()[funcString]
            result = func(param)
    except:
        param = param.relabel(inplace = False)
        return evalFuncString(funcString, param)
    return result

# returns True if G DOES NOT satisfy any properties in noProps
def checkNoProperties(G, noProps):
    for prop in noProps:
        result = evalFuncString(prop, G)
        if result:
            return False
    return True

# returns True if G DOES satisfy every property in yesProps
def checkYesProperties(G, yesProps):
    for prop in yesProps:
        result = evalFuncString(prop, G)
        if not result:
            return False
    return True

# checks if G satisfies EVERYTHING in yesProps and NOTHING in noProps
def yesAndNoProperties(G, yesProps, noProps):
    if not checkYesProperties(G, yesProps):
        return False
    else:
        if checkNoProperties(G, noProps):
            return True
        return False

# same as yesAndNoProperties but for a list of graphs
# returns a list of graphs which satisfy yesProps but fail noProps
def yesAndNoPropertiesList(gList, yesProps, noProps):
    goodGraphs = []
    for G in gList:
        if yesAndNoProperties(G, yesProps, noProps):
            goodGraphs.append(G)
    return goodGraphs

def saveResults(conjObjList, saveTo):
    if not saveTo:
        for c in conjObjList:
            conjCheckStatus(c)
    else:
        for conjObj in conjObjList:
            conjObj = addConjecture(conjObj, saveTo)
    return conjObjList

# convert anything into a list of tuples: (conjText, propList)
def toConjList(conjectures, inputType):
    conjTuples = []
    if inputType == conjectureObjType.CONJLIST:
        # we know this is a list of conjectures, 
        # check if it is a string list or object list
        if isinstance(conjectures[0], conjObj.Conjecture):
            for c in conjectures:
                currentTuple = (c.conjText, getProperties(c.conjText))
                conjTuples.append(currentTuple)
        elif isinstance(conjectures[0], str):
            for c in conjectures:
                # append the tuple (c, getProperties(c))
                currentTuple = (c, getProperties(c))
                conjTuples.append(currentTuple)
        return conjTuples
    elif inputType == conjectureObjType.CONJTEXT:
        return [(conjectures, getProperties(conjectures))]
    # if a single Conjecture object
    elif inputType == conjectureObjType.CONJOBJ:
        return [(conjectures.conjText, getProperties(conjectures.conjText))]
    # conjFile is for .txt file
    elif inputType == conjectureObjType.CONJFILE:
        with open(conjectures, 'r') as conjFile:
            for line in conjFile:
                currentTuple = (line.strip(), getProperties(line.strip()))
                conjTuples.append(currentTuple)
        return conjTuples
    # conjobjfile is for shelf of conjectures
    elif inputType == conjectureObjType.CONJOBJFILE:
        conjTextList = []
        with shelve.open(conjectures) as shelf:
            conjTextList = list(shelf.keys())
        for c in conjTextList:
            conjTuples.append(c, getProperties(c))
        return conjTuples
    return []

# determine what type of conjecture storing object checkType is
# conjecture objects are only going to be stored in shelf files
def determineConjectureObjectType(checkType):
    if isinstance(checkType, str):
        # the only two options for files of conjectures are text files and shelves
        # shelves can have a bunch of different file extensions or none at all,
        # so we first check for .txt and otherwise if it is a file not using .txt, it must be a shelf
        if checkType.lower().endswith('.txt'):
            return conjectureObjType.CONJFILE
        elif os.path.isfile(checkType):
            return conjectureObjType.CONJOBJFILE
        else:
            if isConjecture(checkType):
                return conjectureObjType.CONJTEXT
            return conjectureObjType.OTHER
    if isinstance(checkType, list):
        return conjectureObjType.CONJLIST
    if isinstance(checkType, conjObj.Conjecture):
        return conjectureObjType.CONJOBJ
    return conjectureObjType.OTHER

# we know that checkStr is a string, but we want to know if it is a conjecture
def isConjecture(checkText):
    propList = getProperties(checkText)
    for p in propList:
        checkText = checkText.replace(f'({p})', f'(True)')
    result = evaluateString(checkText, loopNum = 2*len(propList))
    if result == 'True' or result == 'False':
        return True
    return False

# get a list of properties from the conjecture conj
def getProperties(conj):
    # https://stackoverflow.com/a/69281590
    regex = r"\(([^()]+)\)"
#    regex = r"\(([^)([^)]+)\)"
    matches = re.finditer(regex, conj, re.MULTILINE)
    propList = []
    for _, match in enumerate(matches, start=1):
        propList.append(match.group(1))
    return propList

# https://stackoverflow.com/a/52982365
# adds pickles to a file
def pickleGraphs(gList, pickleFile):
    with open(pickleFile, 'a+') as pickleJar:
        for g in gList:
            pickle.dump(g, pickleJar)

# add pickles to a file while avoiding duplicates
# this requires that the pickle file is small enough where all of its contents can be in memory at once
# https://stackoverflow.com/a/33524137
def pickleGraphsUnique(gList, pickleFile):
    oldGraphs = set(toGraphObjectList(pickleFile, graphObjType.FILE))
    gSet = oldGraphs.union(set(gList))
    with open(pickleFile, 'wb') as pickleJar:
        for g in gSet:
            pickle.dump(g, pickleJar)

# every conjecture must have some graph that caused it to be generated
# this function helps us find what graphs caused weird conjectures to appear
def findConjCause(conjectures, testAgainst, largeFile = False, printResults = False):
    conjDict = defaultdict(list)
    conjectureType = determineConjectureObjectType(conjectures)
    graphType = determineGraphObjectType(testAgainst)
    conjList = toConjList(conjectures, conjectureType)
    if testAgainst is None:
        print('testAgainst must be an object containing graphs')
        return
    else:
        if not largeFile:
            graphList = toGraphObjectList(testAgainst, graphType)
            for conj, propList in conjList:
                for g in graphList:
                    result = findSingleConjCause(conj, g, propList)
                    if result[0]:
                        conjDict[conj.strip()].append(g.graph6_string())
            # now either return conjObjList or save them to a file
            if printResults:
                printConjDict(conjDict)
            else:
                return conjDict
        if largeFile:
            if determineGraphObjectType(testAgainst) != graphObjType.FILE:
                print('largeFile flag only used if the input is a file')
                return
            elif determineFileType(testAgainst) == fileType.PICKLE:
                for conj, propList in conjList:
                    for g in getPickleGenerator(testAgainst):
                        result = findSingleConjCause(conj, g, propList)
                        if result[0]:
                            conjDict[conj.strip()].append(g.graph6_string())
                if printResults:
                    printConjDict(conjDict)
                else:
                    return conjDict
            elif determineFileType(testAgainst) == fileType.GRAPHSTRING:
                for conj, propList in conjList:
                    with open(testAgainst, 'r') as graphFile:
                        for line in graphFile:
                            g = Graph(line)
                            result = findSingleConjCause(conj, g, propList)
                            if result[0]:
                                conjDict[conj.strip()].append(g.graph6_string())
                if printResults:
                    printConjDict(conjDict)
                else:
                    return conjDict
            elif determineFileType(testAgainst) == fileType.GRAPHOBJECT:
                for conj, propList in conjList:
                    with open(testAgainst, 'r') as graphFile:
                        for g in graphFile:
                            result = findSingleConjCause(conj, g, propList)
                            if result[0]:
                                conjDict[conj.strip()].append(g.graph6_string())
                if printResults:
                    printConjDict(conjDict)
                else:
                    return conjDict

# every conjecture must have some graph that caused it to be generated
# this function helps us find what graphs caused weird conjectures to appear
def findSingleConjCause(conj, testAgainst, propList = []):
    # https://docs.python.org/3/library/stdtypes.html#str.rsplit
    # we want the rightmost '->' as our split
    # a few conjectures have multiple implications in them
    leftSide = conj.rsplit('->',1)[0]
    return checkSingleConj(leftSide, testAgainst, propList)

# results in findConjCause are returned as a dictionary, so we need to print it
# conjDict is a dictionary of lists, each key in conjDict is a conjecture, 
# each value in conjDict[conj] is a graph string
def printConjDict(conjDict):
    conjList = conjDict.keys()
    for c in conjList:
        satisfiedList = conjDict[c]
        if len(satisfiedList) > 20:
            print(f'The left side of conjecture {c} is satisfied by: {len(satisfiedList)}')
        else:
            print(f'The left side of conjecture {c} is satisfied by: {satisfiedList}')

# conj is a single conjecture, 
# testAgainst is a single graph object,
# propList is the list of properties present in conj
def checkSingleConj(conj, testAgainst, propList = []):
    if not propList:
        propList = getProperties(conj)
    for prop in propList:
        eval = evalFuncString(prop, testAgainst)
        conj = conj.replace(f'({prop})', f'({eval})')
    result = evaluateString(conj, 2*len(conj))
    if result == 'False' or result == '(False)':
        return False, testAgainst
    return True, None

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

def evaluateString(s, loopNum = inf):
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
    if s == 'True' or s == 'False':
        return s
    if loopNum != 0:
        return evaluateString(s, loopNum-1)
    else:
        return s

# graphs is an object of type inputType
# we want to return a list of graph objects
def toGraphObjectList(graphs, inputType):
    # if graphs is a list object, it is either already a list of graphs,
    # is a list of graph strings, or is something invalid
    if inputType == graphObjType.LIST:
        inputListType = determineGraphListType(graphs)
        if inputListType == graphListType.GRAPHSTRINGLIST:
            graphList = []
            for g in graphs:
                graphList.append(Graph(g))
                return graphList
        elif inputListType == graphListType.GRAPHOBJECTLIST:
            return graphs
        else: #else it is an invalid string
            return []
    # if a graphs is a single graph string, convert to graph object and return as list
    elif inputType == graphObjType.GRAPHSTRING:
        return [Graph(graphs)]
    # if graphs is just a single graph object, return it as a list
    elif inputType == graphObjType.GRAPH:
        return [graphs]
    elif inputType == graphObjType.FILE:
        return graphFileToList(graphs, determineFileType(graphs))

def graphFileToList(graphFile, inputType):
    graphList = []
    if inputType == fileType.PICKLE:
        # build a list from getPickleGenerator
        for g in getPickleGenerator(graphFile):
            graphList.append(g)
        return graphList
    if inputType == fileType.GRAPHOBJECT:
        with open(graphFile, 'r') as gF:
            for g in gF:
                graphList.append(g)
        return graphList
    if inputType == fileType.GRAPHSTRING:
        with open(graphFile, 'r') as gF:
            for line in gF:
                graphList.append(Graph(line))
        return graphList
    if inputType == fileType.OTHER or inputType == fileType.EMPTY:
        return []

# take a pickle file and return a generator of graphs
def getPickleGenerator(graphFile):
    with open(graphFile, 'rb') as pickleJar:
        while True:
            try:
                yield pickle.load(pickleJar)
            except EOFError:
                break

# determine what type of graph storing object checkType is
def determineGraphObjectType(checkType):
    if isinstance(checkType, str):
        # https://docs.python.org/3.9/library/stdtypes.html?highlight=endswith#str.endswith
        # https://stackoverflow.com/a/5899544
        # using endswith is faster than using .isfile but there are some weird edge cases it wouldn't work with
        # to ensure this works, files must always be .pkl, .sobj, or .txt, extensionless files would require isfile
        if checkType.lower().endswith(('.pkl', '.sobj', '.txt')):
        #if os.path.isfile(checkType):
            return graphObjType.FILE
        try:
            G = Graph(checkType)
            return graphObjType.GRAPHSTRING
        except:
            return graphObjType.OTHER
    if isinstance(checkType, list):
        return graphObjType.LIST
    elif isinstance(checkType, Graph):
        return graphObjType.GRAPH
    return graphObjType.OTHER

# we know checkType is a list, but we want to know what kind of list
def determineGraphListType(checkType):
    # https://stackoverflow.com/a/53522
    if not checkType:
        return graphListType.EMPTY
    elementType = determineGraphObjectType(checkType[0])
    if elementType == graphObjType.GRAPH:
        return graphListType.GRAPHOBJECTLIST
    elif elementType == graphObjType.GRAPHSTRING:
        return graphListType.GRAPHSTRINGLIST
    else:
        return graphListType.OTHER

# we know checkType is a file, but we want to know what kind of file
def determineFileType(checkType):
    if checkType.lower().endswith('.pkl'):
        return fileType.PICKLE
    if checkType.lower().endswith('.sobj'):
        return fileType.GRAPHOBJECT
    if checkType.lower().endswith('.txt'):
        with open(checkType, 'r') as checkFile:
            # https://stackoverflow.com/a/2507871
            if os.stat(checkType).st_size == 0:
                return fileType.EMPTY
            for checkItem in checkFile:
                try:
                    G = Graph(checkItem)
                    return fileType.GRAPHSTRING
                except:
                    return fileType.OTHER
    return fileType.OTHER

def makeCheckingGraphs():
    gList = set()
    for g in graph_objects:
        if g.order() < 80:
            gList = gList.union(g)
    for n in range(1,8):
        for g in graphs.nauty_geng(options=f'{n} -c'):
            gList = gList.union(g)
    for n in range(8,12):
        for g in graphs.nauty_geng(options=f'{n} -cb'):
            gList = gList.union(g)
    gList = gList.union(set(getFalsifyingGraphList(conjShelf='conjectureShelf.db', keyList = None)))
    return list(gList)