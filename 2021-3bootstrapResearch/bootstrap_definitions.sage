import itertools

def has_blocks_property(g):
    if g.is_connected() and len(g.blocks_and_cut_vertices()[0]) <= 2:
        return True
    else:
        return False

def has_3_blocks_property(g):
    if g.is_connected() and len(g.blocks_and_cut_vertices()[0]) <= 3:
        return True
    else:
        return False

# def has_3BG_blocks_property(g):
    #Returns TRUE if g is connected and either: a single block, or two blocks (with one block a single edge).  Returns FALSE for all other graphs.
    # B,_ = g.blocks_and_cut_vertices()
    # at least one block to have size at most 2
    # blocks = min(B, key=len)

def has_3BG_blocks_property(g):
    g.relabel()
    if not g.is_connected():
        return False
    else:
        B,_ = g.blocks_and_cut_vertices()
        return (len(B) == 1 or (len(B) == 2 and len(min(B, key=len)) <= 2))

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

def diameter_no_more_than_two(g):
    if g.diameter() <= 2:
        return True
    else:
        return False

def is_dirac(g):
    if min_degree(g) >= 0.5*g.order():
        return True
    else:
        return False

def girth_less_than_five(g):
    if g.girth() < 5:
        return True
    else:
        return False

def min_degree(g):
    return min(g.degree())

def is_k_bootstrappable(G, k):
    G.relabel()
    for s in itertools.combinations(G.vertices(), k):
        if k_percolate(G, set(s), k):
            return True
    return False

def is_3_bootstrappable(G):
    G.relabel()
    for s in itertools.combinations(G.vertices(), 3):
        if k_percolate(G, set(s), 3):
            return True
    return False

def is_2_bootstrap_good(G):
    G.relabel()
    for s in itertools.combinations(G.vertices(), 2):
        if k_percolate(G, set(s), 2):
            return True
    return False

def is_3_bootstrap_bad(G):
    return not is_3_bootstrappable(G)

def is_2_bootstrap_bad(G):
    return not is_2_bootstrap_good(G)

# returns True if G DOES NOT satisfy any properties in noProps
def checkNoProperties(G, noProps):
    for prop in noProps:
        try:
            func = globals()[prop]
            result = func(G)
        except:
            result = getattr(G, prop)()
        if result:
            return False
    return True

# returns True if G DOES satisfy every property in yesProps
def checkYesProperties(G, yesProps):
    for prop in yesProps:
        try:
            func = globals()[prop]
            result = func(G)
        except:
            result = getattr(G, prop)()
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

# if 2BG then return False, else call percolate like in line 97 but with 2 percolate rather than 3
# can use ktBootstrappable
# G,2,2 - bad
# G,2,3 - good
def is_2_bootstrap_at_most_3(G):
    G.relabel()
    for s in itertools.combinations(G.vertices(), 3):
        if k_percolate(G, set(s), 2):
            return True
    return False

def is_2_bootstrap_exactly_3(G):
    G.relabel()
    if yesAndNoProperties(G, ['is_2_bootstrap_at_most_3'], ['is_2_bootstrap_good']):
        return True
    return False