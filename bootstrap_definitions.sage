import itertools

def has_blocks_property(g):
    return g.is_connected() and len(g.blocks_and_cut_vertices()[0]) <= 2

def has_3_blocks_property(g):
    return g.is_connected() and len(g.blocks_and_cut_vertices()[0]) <= 3

# def has_3BG_blocks_property(g):
    #Returns TRUE if g is connected and either: a single block, or two blocks (with one block a single edge).  Returns FALSE for all other graphs.
    # B,_ = g.blocks_and_cut_vertices()
    # at least one block to have size at most 2
    # blocks = min(B, key=len)

# a wheel graph has a middle "hub" vertex surrounded by a cycle
def is_wheel(g):
    maybeWheel = False
    for v in g.vertices():
        if len(g.neighbors(v)) == g.order() - 1:
            g.delete_vertex(v)
            maybeWheel = True
            break
    if maybeWheel and g.is_cycle():
        return True
    return False

# paths are connected graphs with degree sequence 1,2,2,...,2,2,1
def is_path(g):
    degSeq = g.degree_sequence()
    if degSeq.count(2) == g.order() - 2 and degSeq.count(1) == 2 and g.is_connected():
        return True
    return False

def makeTheoremList():
    cycle = lambda g: g.is_cycle() and (g.order() == 5 or g.order() == 6)
    path = lambda g: is_path(g) and (g.order() == 4 or g.order() == 5)
    return [cycle, path]

def numLeafBlocksGreaterThanK(g,k):
    g.relabel(inplace=False)
    # blocks is a list of lists of vertex names
    numLeaf = 0
    blocks, cuts = g.blocks_and_cut_vertices()
    # b in blocks is a list
    # leaf block if the block has exactly one vertex in the cut vertex set
    # https://stackoverflow.com/a/3697438
    for b in blocks:
        if len(set(b) & set(cuts)) <= 1:
            numLeaf += 1
    return numLeaf > k

def numLeafBlocksAtMost3(g):
    g.relabel(inplace=False)
    # blocks is a list of lists of vertex names
    numLeaf = 0
    blocks, cuts = g.blocks_and_cut_vertices()
    # b in blocks is a list
    # leaf block if the block has exactly one vertex in the cut vertex set
    # https://stackoverflow.com/a/3697438
    for b in blocks:
        if len(set(b) & set(cuts)) <= 1:
            numLeaf += 1
    return numLeaf <= 3

def numLeafBlocksGreaterThan2(g):
    return numLeafBlocksGreaterThanK(g,2)

def has_3BG_blocks_property(g):
    g.relabel(inplace=False)
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
    return g.diameter() <= 2

def is_dirac(g):
    return min_degree(g) >= 0.5*g.order()

def girth_less_than_five(g):
    return g.girth() < 5

def min_degree(g):
    return min(g.degree())

def is_k_bootstrappable(G, k):
    #print(f'Graph {G.graph6_string()} has order {G.order()}')
    if G.order()<k:
        return True
    try:
        for s in itertools.combinations(G.vertices(), k):
            if k_percolate(G, set(s), k):
                return True
    except:
        G.relabel()
        for s in itertools.combinations(G.vertices(), k):
            if k_percolate(G, set(s), k):
                return True
    return False

def is_3_bootstrappable(G):
    return is_k_bootstrappable(G, 3)

def is_2_bootstrap_good(G):
    return is_k_bootstrappable(G, 2)

def is_3_bootstrap_bad(G):
    return not is_3_bootstrappable(G)

def is_2_bootstrap_bad(G):
    return not is_2_bootstrap_good(G)

# if 2BG then return False, else call percolate like in line 97 but with 2 percolate rather than 3
# can use ktBootstrappable
# G,2,2 - bad
# G,2,3 - good
def is_2_bootstrap_at_most_3(G):
    G.relabel(inplace=False)
    if G.order()<=2:
        return True
    for s in itertools.combinations(G.vertices(), 3):
        if k_percolate(G, set(s), 2):
            return True
    return False

def is_2_bootstrap_exactly_3(G):
    G.relabel(inplace=False)
    return yesAndNoProperties(G, ['is_2_bootstrap_at_most_3'], ['is_2_bootstrap_good'])

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