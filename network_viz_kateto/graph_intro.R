#'---
#' title: Working with Graphs
#' output: github_document
#'---

#+ message=FALSE
pacman::p_load(
        rio,            # import and export files
        here,           # locate files 
        tidyverse,      # data management and visualization
        igraph
)

#' ## Graph
# graph basic #--------------

#' ### From edgelist
## from edgelist #-----------------
(gwork_edgelist <- data.frame(
        from = c("David", "David", "David", "Jane", "Jane"),
        to = c("Zubin", "Suraya", "Jane", "Zubin", "Suraya")
))

(gwork_edgelist <- as.matrix(gwork_edgelist))

(igraph::graph_from_edgelist(el = gwork_edgelist,
                             directed = FALSE))

(igraph::graph_from_edgelist(el = gwork_edgelist,
                             directed = TRUE))

#' ### From adjacency matrix
## from adjacency matrix #-----------------

(adj_flights <- matrix(c(0, 5, 2, 4, 0, 0, 4, 1, 0), nrow = 3, ncol = 3))
rownames(adj_flights) <- c("SFO", "PHL", "TUS")
colnames(adj_flights) <- rownames(adj_flights)

adj_flights

# create multigraph from adjacency matrix
(flightgraph <- igraph::graph_from_adjacency_matrix(
        adjmatrix = adj_flights,
        mode = "directed"))

# create weighted graph 
(flightgraph_weighted <- igraph::graph_from_adjacency_matrix(
        adjmatrix = adj_flights,
        mode = "directed",
        weighted = TRUE))

(flightgraph_simple <- igraph::simplify(
        flightgraph))

#' ### From dataframe
## from dataframe #---------------------
# edge dataframe
(edge_df <- data.frame(
        from = c("David", "David", "Jane", "Jane", "Zubin", "Suraya"),
        to = c("Sandra", "Jake", "Mae-Li", "Jake", "Sandra", "Mae-Li")))

# vertex dataframe
(vertex_df <- data.frame(
        name = c("David", "Jane", "Zubin", "Suraya", 
                 "Sandra", "Jake", "Mae-Li"),
        Dept = c(rep("A", 4), rep("B", 3))))

# create graph
(gnew <- igraph::graph_from_data_frame(
        d = edge_df,
        directed = FALSE,
        vertices = vertex_df))

#' ### Add attribute
## add attribute #----------------------
igraph::V(gnew)

igraph::V(gnew)$name

igraph::V(gnew)$Dept

igraph::E(gnew)

igraph::E(gnew)$weight <- c(4, 4, 5, 1, 2, 2)

gnew





# rmarkdown::render()
