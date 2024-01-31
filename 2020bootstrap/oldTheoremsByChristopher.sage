def chvatals_weak_condition(g):
    """
    True if degrees d_1,...,d_n, for all i, d_i >= i+1 or d_(n-1) >= n-i-1 for all i, 1<=i<=n/2
    This property is described in theorm 3 of:
    Ore and Chvatal-type Degree Conditions for Bootstrap Percolation from Small Sets
    which can be found at: https://arxiv.org/abs/1610.04499

    Theorem 3 states:
    If G is a graph with degree sequence d1<=...<= dn that satisfies the weak Chvatal condition, then either m(G,2) = 2 [where m(G,k) is the minimum size of a k-contagious set in G]
    or one of the following holds:
    - G is disconnected
    - G contains exactly two vertices of degree 1 and G is not in {P2,P3} [Path graphs of 2 and 3 vertices]
    - G is C5 [Cycle graph of 5 vertices]

    This code was contributed by Christopher Flippen, 3/17/20
    """
    if g.order() < 3:
        return False
    degrees = g.degree()
    degrees.sort()
    n = g.order()
    return all(degrees[i] > i+1 or degrees[n-i] >= n-i-1 for i in range (0,len(degrees)))

def df_mp_drs_condition(g,k):
    """
    If this condition is true, G is k-bootstrap good
    If a graph has n nodes, each with a minimum degree ceil((k-1)/k)*n)), then G is k-bootstrap good for k>=2
    This is theorem 1 of Contagious Sets in Dense Graphs
    Since the property is not given a name, I named it after the authors' initials:
    Daniel Fruend, Matthias Poloczek, and Daniel Reichman -> DF, MP, and DR

    This code was contributed by Christopher Flippen, 3/17/20
    """
    if g.order() < 3 or k < 2:
        return False
    minDegree = ceil( ((k-1)/k) * n)
    degrees = g.degree()
    for d in degrees:
        if d < minDegree:
            return False
    return True

def second_df_mp_drs_condition(g):
    """
    If this condition is true, G is 2-bootstrap good
    Returns true if DF_MP_DRs_Condition(g,2) is true
    """
    return df_mp_drs_condition(g,2)

def df_mp_drs_extremal_condition(g):
    """
    If this is true, G is not 2-bootstrap good, false is inconclusive
    Returns true if M(n,2,2) >= |E| where n is the number of vertices and |E| is the number of edges in G
    M(n,k,r) is the maximum number of edges in an n-vertex graph G satisfying m(G,r) > k
    m(G,r) is the minimum size of an r-contagious set in G
    Therefore, if |E| <= M(n,2,2), then m(G,2) > 2, and therefore, G is not 2-bootstrap good
    Theorem 11 of Contagious Sets in Dense Graphs by Daniel Fruend, Matthias Poloczek, and Daniel Reichman states:
    Let k >= 1. For n>= 2k+2, we have M(n,k,k) = C(n-1,2) [where C(n,k) is n choose k]
    Since n>= 2k+2 and k=2, n must be >= 6

    This code was contributed by Christopher Flippen, 3/17/20
    """
    if g.order() < 6 :
        return False
    if g.size() <= binomial(g.order()-1,2) :
        return True
    return False

def second_df_mp_drs_extremal_condition(g):
    """
    If this is true, G is not 2-bootstrap good, false is inconclusive
    Returns true if G has 3 vertices and M(3,2,2) >= |E| |E| is the number of edges in G
    M(n,k,r) is the maximum number of edges in an n-vertex graph G satisfying m(G,r) > k
    m(G,r) is the minimum size of an r-contagious set in G
    Therefore, if |E| <= M(3,2,2), then m(G,2) > 2, and therefore, G is not 2-bootstrap good
    Theorem 12 of Contagious Sets in Dense Graphs by Daniel Fruend, Matthias Poloczek, and Daniel Reichman states:
    For all n>=2 we have M(n,n-1,n-1) = C(n,2) - ceil(n/2) holds [where C(n,k) is n choose k]
    Since we care about 2-bootstrap-good graphs, n-1=2 and therefore n=3

    This code was contributed by Christopher Flippen, 3/17/20
    """
    if g.order() < 2:
        return False
    if g.size() <= binomial(g.order(),2) - ceil(n/2):
        return True
    return False

def gundersons_condition(g):
    """
    If this condition is true, G is 2-bootstrap good
    Returns true if this graph fulfills delta(2) >= floor(n/2) [minimum degree of G >= floor(n/2)]
    This is described in Minimum degree conditions for small percolating sets in bootstrap percolation by Karen Gunderson found at https://arxiv.org/abs/1703.10741
    The author states that using df_mp_drs_condition_1, one can obtain: for sufficiently large n, and delta(n)>= floor(n/2), then m(G,2) = 2 [where m(G,k) is the minimum size of a k-contagious set in G]

    This code was contributed by Christopher Flippen, 3/17/20
    """
    if n<2:
        return False
    minDegree = floor( n/2 )
    degrees = g.degree()
    for d in degrees:
        if d < minDegree:
            return False
    return True

def general_gundersons_condition(g,r):
    """
    If this condition is true, G is 2-bootstrap good
    Returns true if this graph fulfills delta(G) >= floor(n/2)+(r-3)
    This is theorem 1 of Minimum degree conditions for small percolating sets in bootstrap percolation by Karen Gunderson found at https://arxiv.org/abs/1703.10741
    For sufficiently large n, if G is a graph on n vertices with delta(G) >= floor(n/2) + (r-3), then m(G,r)=r [where m(G,k) is the minimum size of an r-contagious set in G]

    This code was contributed by Christopher Flippen, 3/17/20
    """
    if n<2:
        return False
    minDegree = floor(n/2) + (r-3)
    degrees = g.degree()
    for d in degrees:
        if d < minDegree:
            return False
    return True