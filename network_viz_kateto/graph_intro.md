Working with Graphs
================
trucl
2024-09-10

``` r
pacman::p_load(
        rio,            # import and export files
        here,           # locate files 
        tidyverse,      # data management and visualization
        igraph
)
```

## Graph

``` r
# graph basic #--------------
```

### From edgelist

``` r
## from edgelist #-----------------
(gwork_edgelist <- data.frame(
        from = c("David", "David", "David", "Jane", "Jane"),
        to = c("Zubin", "Suraya", "Jane", "Zubin", "Suraya")
))
```

    ##    from     to
    ## 1 David  Zubin
    ## 2 David Suraya
    ## 3 David   Jane
    ## 4  Jane  Zubin
    ## 5  Jane Suraya

``` r
(gwork_edgelist <- as.matrix(gwork_edgelist))
```

    ##      from    to      
    ## [1,] "David" "Zubin" 
    ## [2,] "David" "Suraya"
    ## [3,] "David" "Jane"  
    ## [4,] "Jane"  "Zubin" 
    ## [5,] "Jane"  "Suraya"

``` r
(igraph::graph_from_edgelist(el = gwork_edgelist,
                             directed = FALSE))
```

    ## IGRAPH 3e58819 UN-- 4 5 -- 
    ## + attr: name (v/c)
    ## + edges from 3e58819 (vertex names):
    ## [1] David --Zubin  David --Suraya David --Jane   Zubin --Jane   Suraya--Jane

``` r
(igraph::graph_from_edgelist(el = gwork_edgelist,
                             directed = TRUE))
```

    ## IGRAPH 3e5c357 DN-- 4 5 -- 
    ## + attr: name (v/c)
    ## + edges from 3e5c357 (vertex names):
    ## [1] David->Zubin  David->Suraya David->Jane   Jane ->Zubin  Jane ->Suraya

### From adjacency matrix

``` r
## from adjacency matrix #-----------------

(adj_flights <- matrix(c(0, 5, 2, 4, 0, 0, 4, 1, 0), nrow = 3, ncol = 3))
```

    ##      [,1] [,2] [,3]
    ## [1,]    0    4    4
    ## [2,]    5    0    1
    ## [3,]    2    0    0

``` r
rownames(adj_flights) <- c("SFO", "PHL", "TUS")
colnames(adj_flights) <- rownames(adj_flights)

adj_flights
```

    ##     SFO PHL TUS
    ## SFO   0   4   4
    ## PHL   5   0   1
    ## TUS   2   0   0

``` r
# create multigraph from adjacency matrix
(flightgraph <- igraph::graph_from_adjacency_matrix(
        adjmatrix = adj_flights,
        mode = "directed"))
```

    ## IGRAPH 3e6328c DN-- 3 16 -- 
    ## + attr: name (v/c)
    ## + edges from 3e6328c (vertex names):
    ##  [1] SFO->PHL SFO->PHL SFO->PHL SFO->PHL SFO->TUS SFO->TUS SFO->TUS SFO->TUS
    ##  [9] PHL->SFO PHL->SFO PHL->SFO PHL->SFO PHL->SFO PHL->TUS TUS->SFO TUS->SFO

``` r
# create weighted graph 
(flightgraph_weighted <- igraph::graph_from_adjacency_matrix(
        adjmatrix = adj_flights,
        mode = "directed",
        weighted = TRUE))
```

    ## IGRAPH 3e642cc DNW- 3 5 -- 
    ## + attr: name (v/c), weight (e/n)
    ## + edges from 3e642cc (vertex names):
    ## [1] SFO->PHL SFO->TUS PHL->SFO PHL->TUS TUS->SFO

``` r
(flightgraph_simple <- igraph::simplify(
        flightgraph))
```

    ## IGRAPH 3e6573b DN-- 3 5 -- 
    ## + attr: name (v/c)
    ## + edges from 3e6573b (vertex names):
    ## [1] SFO->PHL SFO->TUS PHL->SFO PHL->TUS TUS->SFO

### From dataframe

``` r
## from dataframe #---------------------
# edge dataframe
(edge_df <- data.frame(
        from = c("David", "David", "Jane", "Jane", "Zubin", "Suraya"),
        to = c("Sandra", "Jake", "Mae-Li", "Jake", "Sandra", "Mae-Li")))
```

    ##     from     to
    ## 1  David Sandra
    ## 2  David   Jake
    ## 3   Jane Mae-Li
    ## 4   Jane   Jake
    ## 5  Zubin Sandra
    ## 6 Suraya Mae-Li

``` r
# vertex dataframe
(vertex_df <- data.frame(
        name = c("David", "Jane", "Zubin", "Suraya", 
                 "Sandra", "Jake", "Mae-Li"),
        Dept = c(rep("A", 4), rep("B", 3))))
```

    ##     name Dept
    ## 1  David    A
    ## 2   Jane    A
    ## 3  Zubin    A
    ## 4 Suraya    A
    ## 5 Sandra    B
    ## 6   Jake    B
    ## 7 Mae-Li    B

``` r
# create graph
(gnew <- igraph::graph_from_data_frame(
        d = edge_df,
        directed = FALSE,
        vertices = vertex_df))
```

    ## IGRAPH 3e6b888 UN-- 7 6 -- 
    ## + attr: name (v/c), Dept (v/c)
    ## + edges from 3e6b888 (vertex names):
    ## [1] David --Sandra David --Jake   Jane  --Mae-Li Jane  --Jake   Zubin --Sandra
    ## [6] Suraya--Mae-Li

### Add attribute

``` r
## add attribute #----------------------
igraph::V(gnew)
```

    ## + 7/7 vertices, named, from 3e6b888:
    ## [1] David  Jane   Zubin  Suraya Sandra Jake   Mae-Li

``` r
igraph::V(gnew)$name
```

    ## [1] "David"  "Jane"   "Zubin"  "Suraya" "Sandra" "Jake"   "Mae-Li"

``` r
igraph::V(gnew)$Dept
```

    ## [1] "A" "A" "A" "A" "B" "B" "B"

``` r
igraph::E(gnew)
```

    ## + 6/6 edges from 3e6b888 (vertex names):
    ## [1] David --Sandra David --Jake   Jane  --Mae-Li Jane  --Jake   Zubin --Sandra
    ## [6] Suraya--Mae-Li

``` r
igraph::E(gnew)$weight <- c(4, 4, 5, 1, 2, 2)

gnew
```

    ## IGRAPH 3e6b888 UNW- 7 6 -- 
    ## + attr: name (v/c), Dept (v/c), weight (e/n)
    ## + edges from 3e6b888 (vertex names):
    ## [1] David --Sandra David --Jake   Jane  --Mae-Li Jane  --Jake   Zubin --Sandra
    ## [6] Suraya--Mae-Li

``` r
# rmarkdown::render()
```
