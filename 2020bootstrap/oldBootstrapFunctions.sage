def is_2_bootstrap_good(G):
    return ktBootstrappable(G,2,2)

def ktBootstrappable(G,k,t):
    S=Subsets(G.vertices(),t)
    for s in S:
        if percolate(k,G,s):
            return true
    return false

def percolate(k,G,initial):
    G.relabel()
    V=G.vertices()
    n=G.order()
    neighbs=[0]*n
    uninfected=[]
    for v in V:
        if v in initial:
            for s in G.neighbors(v):
                neighbs[s]=neighbs[s]+1
        else:
            uninfected.append(v)
    while not len(uninfected)==0:
        flaggity=0
        for v in uninfected:
            if neighbs[v]>k-1:
                flaggity=1
                uninfected.remove(v)
                for s in G.neighbors(v):
                    neighbs[s]=neighbs[s]+1
        if len(uninfected)==0:
            return true
        if not flaggity:
            return false
    return true