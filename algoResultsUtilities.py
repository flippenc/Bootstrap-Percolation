import time, shelve
import algoResults

def getAlgoResults(g):
    if isinstance(g, str):
        results = algoResults.baeMortonResults(g)
        g = Graph(g)
    else:
        results = algoResults.baeMortonResults(g.graph6_string())
    start = time.time()
    B = bae_morton_recursive_edge(g)
    end = time.time()
    results.edgeTime = end - start
    start = time.time()
    B = bae_morton_recursive_vertex(g)
    end = time.time()
    results.vertexTime = end - start
    start = time.time()
    B = bae_morton(g)
    end = time.time()
    results.originalTime = end - start
    results.B = B
    return results

def saveAlgoResults(newResultsList, resultsShelf):
    with shelve.open(resultsShelf) as shelf:
        for newResults in newResultsList:
            if newResults.graphString in shelf:
                shelfResults = shelf[newResults.graphString]
                shelfResults.edgeTime = (shelfResults.edgeTime + newResults.edgeTime)/2
                shelfResults.vertexTime = (shelfResults.vertexTime + newResults.vertexTime)/2
                shelfResults.originalTime = (shelfResults.originalTime + shelfResults.originalTime)/2
            else:
                shelf[newResults.graphString] = newResults

def findFastest(resultsShelf):
    edgeFastest = []
    vertexFastest = []
    originalFastest = []
    with shelve.open(resultsShelf) as shelf:
        keyList = list(shelf.keys())
        for key in keyList:
            currentResult = shelf[key]
            edgeTime = currentResult.edgeTime
            vertexTime = currentResult.vertexTime
            originalTime = currentResult.originalTime
            if max(edgeTime, vertexTime, originalTime) == edgeTime:
                edgeFastest.append([currentResult.graphString, currentResult.B])
            elif max(edgeTime, vertexTime, originalTime) == vertexTime:
                vertexFastest.append([currentResult.graphString, currentResult.B])
            else:
                originalFastest.append([currentResult.graphString, currentResult.B])
    return edgeFastest, vertexFastest, originalFastest

def printResults(results):
    print(f"Graph('{results.graphString}') has B(G)={results.B}, originalTime={results.originalTime}, vertexTime={results.vertexTime}, edgeTime={results.edgeTime}")