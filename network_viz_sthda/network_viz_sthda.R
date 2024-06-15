#'---
#' title: Network Visualization Essentials in R - STHDA
#' output: github_document
#'---

#+ message=FALSE
pacman::p_load(
        rio,            # import and export files
        here,           # locate files 
        tidyverse,      # data management and visualization
        igraph,         # network visualization
        tidygraph,      # network data manipulation
        ggraph          # network visualization
)

#' ## Demo dataset

# data #-----------------------
(phone_call <- import(here("network_viz_sthda/phone.call.rda")))

#' - nodes: countries in `source`, `destination`
#' - edges weight: values in `n.call`

#---

#' ### Node list
## node list #----------------------

# take the distinct countries from “source” and “destination” columns
(sources <- phone_call %>%
        distinct(source) %>%
        rename(label = source))

(destinations <- phone_call %>%
        distinct(destination) %>%
        rename(label = destination))

# join two data to create node
(nodes <- sources %>%
        full_join(destinations, by = "label") %>%
        # create unique node ID
        rowid_to_column(var = "id"))
        

#' ### Edge list
## edge list #----------------------
# join nodes id for `source` column
(edges <- phone_call %>%
        left_join(nodes,
                  by = c("source" = "label")) %>%
        rename(from = id))

# join nodes id for `destination` column
(edges <- edges %>%
        left_join(nodes,
                  by = c("destination" = "label")) %>%
        rename(to = id))

# keep only the columns `from` and `to`
(edges <- edges %>%
        select(from, to,
               weight = n.call) %>%
        mutate(weight = as.numeric(weight)))

#' ## Visualize

# plot #--------------------

#' ### `igraph`
## igraph #------------------

# create igraph network object
(net.igraph <- graph_from_data_frame(d = edges,
                                    vertices = nodes, 
                                    directed = TRUE))

# create network graph
set.seed(123)

plot(net.igraph,
     edge.arrow.size = 0.2,
     layout = layout_with_graphopt)

#' ### `tidygraph` + `ggraph`
## ggraph #------------------

# create network object
(net.tidy <- tbl_graph(nodes = nodes,
                      edges = edges,
                      directed = TRUE))

# plot
ggraph(net.tidy, layout = "graphopt") + 
        geom_node_point() +
        geom_edge_link(aes(width = weight), alpha = 0.8) + 
        scale_edge_width(range = c(0.2, 2)) +
        geom_node_text(aes(label = label), repel = TRUE) +
        labs(edge_width = "phone.call") +
        theme_graph()

### arc layout #------------------------
#### arc #--------------
ggraph(net.tidy, layout = "linear") + 
        geom_edge_arc(aes(width = weight), alpha = 0.8) + 
        scale_edge_width(range = c(0.2, 2)) +
        geom_node_text(aes(label = label), repel = TRUE) +
        labs(edge_width = "Number of calls") +
        theme_graph()+
        theme(legend.position = "top") 

#### circular #---------------
ggraph(net.tidy, layout = "linear", circular = TRUE) + 
        geom_edge_arc(aes(width = weight), alpha = 0.8) + 
        scale_edge_width(range = c(0.2, 2)) +
        geom_node_text(aes(label = label), repel = TRUE) +
        labs(edge_width = "Number of calls") +
        theme_graph()+
        theme(legend.position = "top")

### treemap layout #-------------
# colors for each country 
(cols <- rainbow(nrow(nodes)+1))

set.seed(123)

(weight <- edges$weight)

fig <- ggraph(net.tidy, 'treemap', weight = weight) + 
        geom_node_tile(aes(fill = label), size = 0.25, color = "white")+
        geom_node_text(aes(label = paste(label, weight, sep = "\n"),
                           size = weight*12),
                       color = "white")+
        scale_fill_manual(values = cols)+
        scale_size(range = c(0, 12) )+
        theme_void()+
        theme(legend.position = "none")

fig

# rmarkdown::render()

