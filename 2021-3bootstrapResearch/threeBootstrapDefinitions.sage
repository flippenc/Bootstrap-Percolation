def is_3_bootstrappable(G):
    # if this doesn't work, use the reset vertices command
    # generate the initial infected sets
    initialSets = Subsets(G.vertices(), 3)
    if (not has_3_degree_condition(G)):
        return False
    else:
        # try percolating which each set
        for i in initialSets:
            if percolate(G,set(i)):
                return True
        return False

def k_percolate(G,infected,k):
    uninfected = set(G.vertices()) - set(infected)
    newInfections = True
    while newInfections:
        newInfections = False
        for v in uninfected:
            if len(set(G.neighbors(v)).intersection(infected)) >= k:
                infected.add(v)
                uninfected-=set([v])
                newInfections = True
                break
    return len(uninfected) == 0

def percolate(G,infected):
    return k_percolate(G,infected,3)

# if this is false, then G cannot be k-bootstrap good since it has > k vertices of degree <k
def has_k_degree_condition(G,k):
    numDegK = 0
    for i in G.degree_iterator():
        if i < k:
            numDegK+=1
    if numDegK > k:
        return False
    return True

def has_3_degree_condition(G):
    return has_k_degree_condition(G,3)

def has_k_connected_condition(G,k):
    if (not G.is_connected()) and G.order() > k:
        return False
    return True

def has_3_connected_condition(G):
    return has_k_connected_condition(G,3)