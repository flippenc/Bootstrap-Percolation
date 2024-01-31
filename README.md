# Bootstrap Percolation
 
**General Research Information:**

-   This research was conducted over the course of several semesters
    under the leadership of Dr. Neal Bushaw. In the spring of 2020, I
    took MATH 356 (Undergraduate Graph Theory) as an Honors course
    (information about Honors courses can be found
    [here](https://honors.vcu.edu/academics/courses/honors-contracts/))
    in which I worked with Dr. Bushaw on this research. In the spring and
    summer of 2021 as well as spring of 2022, I continued working on
    this research with Dr. Bushaw. The research I did during the spring
    of 2022 fulfilled 2 credits of MATH 492 (Independent Study) course
    credit

-   This research built upon work done by Dr. Neal Bushaw, Dr. Craig
    Larson, and a group of VCU graduate and undergraduate students
    during the summer of 2018. This research was published in 2023 and
    can be accessed for free
    [here](https://amc-journal.eu/index.php/amc/article/view/2340)

-   In the spring of 2022, I began writing a manuscript of the results
    from this research with Dr.Neal Bushaw and Kishen Narayan. This
    manuscript was referenced in a paper by Hudson LaFayette, Rayan
    Ibrahim, and Kevin McCall, three PhD students from VCU. The preprint
    of their paper can be found [here](https://arxiv.org/abs/2309.13138)

-   The code and data in this repository is the work of Christopher
    Flippen unless otherwise stated

**Theory Explanation:**

-   $r$-neighbor bootstrap percolation is a monotone infection process
    which takes place on a graph $G$. Given any set of initially
    infected vertices $A_0$, we allow the infection to spread
    via a simple rule – any vertex in the graph with at least *r*
    infected neighbors becomes infected. Formally, we set
    $$A_1=\{v\in V(G):|N(v)\cap A_0|\ge r\}\cup A_0.$$
    Then, we repeat, setting
    $$A_t=\{v\in V(G):|N(v)\cap A_{t-1}|\ge r\}\cup A_{t-1}.$$
    If our graph is finite, the infection process must stop: either
    every vertex becomes infected, or no new infection takes place at
    some step. We denote this final stable infected set as $\langle{G}\rangle$

-   In this research, we were interested in those initial infection sets
    which eventually infect the entire graph, where we find
    $\langle{G}\rangle = V(G)$. In these cases, we say that
    $A_0$ *percolates* $G$. A natural extremal question arises:
    given a graph $G$, how small can a percolating set be in
    $r$-neighbor bootstrap percolation?

-   In each semester of this research, we studied slightly different
    versions of the bootstrap percolation problem. However, we extensively used the automated conjecturing
    program entitled Conjecturing (which can be downloaded
    [here](http://nvcleemp.github.io/conjecturing/)) during every semester. More information
    about what Conjecturing does can be found in [this
    paper](https://arxiv.org/abs/1801.01814). Due to the amount of time
    spent using Conjecturing in this project, I wrote many utilities for
    working with large numbers of conjectures. I started working on some
    of these utilities in 2020 and 2021, but I greatly improved them
    in 2022. Explanations of these utilities and many other functions
    from the research are in the Code Explanation section

-   Our initial research in the spring of 2020 focused on determining
    which graphs were what we called *2-bootstrap-good*. We say a graph
    $G$ is 2-bootstrap-good if there exists an initially infected set
    $A_0$ of size 2 which percolates $G$ in 2-neighbor
    bootstrap percolation. In other words, we want to find which graphs
    are possible to fully infect using two initially infected vertices
    where new vertices are infected if at least two of their neighbors
    are infected

-   During the spring and summer of 2021, we spent some more time
    looking at 2-bootstrap-good graphs, but our main focus was on
    *3-bootstrap-good* graphs. We say a graph $G$ is 3-bootstrap-good if
    there exists an initially infected set $A_0$ of size 3
    which percolates $G$ in 3-neighbor bootstrap percolation. In other
    words, we want to find which graphs are possible to fully infect
    using three initially infected vertices where new vertices are
    infected if at least three of their neighbors are infected

-   During the spring of 2022, we continued our work with
    3-bootstrap-good graphs. We also spent some time working with more
    general versions of the bootstrap problem such as studying
    *3,2-bootstrap-good* graphs in which the initially infected set
    $A_0$ is size 3, but a vertex is infected if at least 2 of
    its neighbors are infected

**Code Explanation:**

-   Files in `2020-2bootstrapResearch` are from the 2020 session of
    research. Almost all code utilities that were previously in here
    have been greatly improved in other files either in
    `2021-3bootstrapResearch` or in the main directory

-   Files in `2021-3bootstrapResearch` are files from the 2021 session
    of research which might still be useful. Most code and utilities in
    here has been replaced with new code in the main folder

-   The file `Bootstrap Documentation.txt` has explanations of all of
    the functions from functions in the main directory

-   The file `conjectureSorting.py` contains utilities for sorting large
    files of conjectures. The Conjecturing program created hundreds of
    conjectures during our research, so having tools for keeping track
    of information such as conjectures that were made multiple times and
    conjectures that were disproven/proven is important

-   The file `fileFunctions.sage` contains further utilities for
    organizing files full of conjectures

-   The file `threeBootstrapDefinitions.sage` contains functions for
    checking if graphs are 3-bootstrap-good as well as other similar
    graph conditions

-   The file `bootstrap_definitions.sage` contains functions for general
    $r$-neighbor bootstrap percolation problems. This file also contains
    functions which check for certain necessary and sufficient
    conditions related to certain types of bootstrap percolation
    problems

-   The file `conjectureCreatingUtilities.sage` contains functions for
    loading preexisting conjectures, saved graphs, and graph properties
    and functions for creating new conjectures

-   The file `conjectureCheckingUtilities.sage` contains many functions
    for automating the process of testing conjectures against lists of
    graphs and recording the results

-   The file `conjectureCheckingUtilities.sage` contains many functions
    for automating the process of testing conjectures against lists of
    graphs and recording the results
