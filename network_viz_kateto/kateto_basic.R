#'---
#' title: Kateto Basics Visualization
#' output: github_document
#'---

#+ message=FALSE
pacman::p_load(
        rio,            # import and export files
        here,           # locate files 
        tidyverse,      # data management and visualization
        igraph,
        visNetwork
)

#' ## Data
# data #------------------------------------------
#' ### Dataset1: Edge list
(nodes <- rio::import(here("network_viz_kateto/data/Dataset1-Media-Example-NODES.csv")) %>%
        tibble())

(links <- rio::import(here("network_viz_kateto/data/Dataset1-Media-Example-EDGES.csv")) %>%
        tibble())

#' ### Dataset2: Matrix
(nodes2 <- rio::import(here("network_viz_kateto/data/Dataset2-Media-User-Example-NODES.csv")) %>%
        tibble())

(links2 <- rio::import(here("network_viz_kateto/data/Dataset2-Media-User-Example-EDGES.csv")) %>%
        tibble())

#' ## Basic graph
# basic graph #----------------------------

#' Create graph
# dataset1
(net <- igraph::graph_from_data_frame(d = links,
                                     vertices = nodes,
                                     directed = TRUE))

# dataset2
(links2 <- as.matrix(links2))

(net2 <- graph_from_biadjacency_matrix(links2))

table(V(net2)$type)

#' Extract information
# extract edges
E(net)

# extract nodes
V(net)

# extract attribute `type` of edges
E(net)$type

# extract attribute `media` of nodes
V(net)$media

#' Find nodes and edges by attribute
V(net)[media == "BBC"]

E(net)[type == "mention"]

net[1,]

net[1, 15]

#' Get an edge list or a matrix:
as_edgelist(net, names = T)

as_adjacency_matrix(net, attr = "weight")

#' Get data frames describing nodes and edges:
as_data_frame(net, what = "edges")

as_data_frame(net, what = "vertices")

#' Basic plot
plot(net)

plot(net, edge.arrow.size = .4, vertex.label = NA)

#' ## Basic plot
#' ### Basic
# basic plot #--------------------
plot(net, edge.arrow.size = .4, edge.curved = .5)

plot(net,
  edge.arrow.size = .2, edge.color = "orange",
  vertex.color = "orange", vertex.frame.color = "#ffffff",
  vertex.label = V(net)$media, vertex.label.color = "black")

#' ### Change color & node size
# generate colors based on media type
(colrs <- c("gray50", "tomato", "gold"))
(V(net)$color <- colrs[V(net)$media.type])

# node degree (to set node size)
(deg <- degree(net, mode = "all"))
(V(net)$size <- deg*3)

# set edge width based on weight
(E(net)$width <- E(net)$weight/5)

plot(net,
     edge.arrow.size = .2,
     edge.color = "gray80",
     vertex.label = NA,
     layout = layout_with_fr)

#' ### Add legend
# legend(x = "bottomleft",
#        c("Newspaper", "Television", "Online News"),
#        pch = 21,
#        col = "#777777", pt.bg = colrs,
#        pt.cex = 2, cex = 0.8,
#        bty = "n",
#        ncol = 1)

#' ### Edges color based on nodes color
(edge.start <- ends(net, es = E(net), names = F)[,1])
(edge.col <- V(net)$color[edge.start])

plot(net,
     edge.arrow.size = .2,
     edge.color = edge.col,
     edge.curved = 0.1,
     vertex.label = NA,
     layout = layout_with_fr)

#' ## Network layout
# layout #-----------------------

(net.bg <- sample_pa(100))

V(net.bg)$size <- 8
V(net.bg)$frame.color <- "white"
V(net.bg)$color <- "orange"
V(net.bg)$label <- ""
E(net.bg)$arrow.mode <- 0

#' Set layout
plot(net.bg)

plot(net.bg, layout = layout_randomly)

plot(net.bg, layout = layout_in_circle)

plot(net.bg, layout = layout_on_sphere)

## Fruchterman Reingold #----------------------------------
plot(net.bg, layout = layout_with_fr)

plot(net.bg, layout = layout_with_fr(net.bg, niter = 50))

# save layout in `lw` to get same network in different runs
ws <- c(1, rep(100, ecount(net.bg)-1))
lw <- layout_with_fr(net.bg, weights = ws)
plot(net.bg, layout = lw)

#' Rescale layouts
# l <- layout_with_fr(net.bg)
# l <- norm_coords(l, ymin = -1, ymax = 1, xmin = -1, xmax = 1)
# par(mfrow = c(2, 2), mar = c(0, 0, 0, 0))
# plot(net.bg, rescale = F, layout = l * 0.4)
# plot(net.bg, rescale = F, layout = l * 0.6)
# plot(net.bg, rescale = F, layout = l * 0.8)
# plot(net.bg, rescale = F, layout = l * 1.0)
# 
# dev.off()

#---

# 3D version
l <- layout_with_fr(net.bg, dim = 3)
plot(net.bg, layout = l)

## Kamada Kawai #---------------------------------
l <- layout_with_kk(net.bg)
plot(net.bg, layout = l)

## Graphopt #----------------------------------
l <- layout_with_graphopt(net.bg)
plot(net.bg, layout = l)

# change mass and electric charge of nodes
l1 <- layout_with_graphopt(net.bg, charge = 0.02)
l2 <- layout_with_graphopt(net.bg, charge = 0.00000001)

plot(net.bg, layout = l1)
plot(net.bg, layout = l2)

## LGL #----------------------------------
# large, connected graphs
plot(net.bg, layout = layout_with_lgl)

## MDS #------------------------
# multidimensional scaling
plot(net.bg, layout = layout_with_mds)

#' ## Highlight aspects of network
# highlight parts #-------------------------

#' ### Community detection by optimizing modularity over partitions
## cluster #----------------
clp <- cluster_optimal(net)
class(clp)

plot(clp, net, layout = layout_with_fr)

#' Customized colors
V(net)$community <- clp$membership
colrs <- adjustcolor( c("gray50", "tomato", "gold", "yellowgreen"),
                      alpha=.6)
plot(net,
     vertex.color = colrs[V(net)$community],
     layout = layout_with_fr)

#' ### Highlight specific part
## manually #-------------------------------
plot(net,
     mark.groups = c(1, 4, 5, 8),
     mark.col = "#C5E5E7",
     mark.border = NA,
     layout = layout_with_fr)

plot(net,
  mark.groups = list(c(1, 4, 5, 8), c(15:17)),
  mark.col = c("#C5E5E7", "#ECD89A"),
  mark.border = NA,
  layout = layout_with_fr)

#' ### Highlight a path
inc.edges <- incident(net, V(net)[media == "Wall Street Journal"], mode = "all")

# Set colors to plot the selected edges.
ecol <- rep("gray80", ecount(net))
ecol[inc.edges] <- "orange"
vcol <- rep("grey40", vcount(net))
vcol[V(net)$media == "Wall Street Journal"] <- "gold"

plot(net,
     vertex.color = vcol,
     edge.color = ecol,
     vertex.label = NA)

#' ### Highlight neighbor nodes
neigh.nodes <- neighbors(net,
                         V(net)[media == "Wall Street Journal"],
                         mode = "out")
vcol[neigh.nodes] <- "#ff9d00"

plot(net,
     vertex.color = vcol,
     vertex.label = NA)

#' ## 2-mode network
# 2-mode network #------------------------
plot(net2, vertex.label = NA)

#' Customized color & shape
# media outlets = blue squares, audience nodes = orange circles
V(net2)$color <- c("steel blue", "orange")[V(net2)$type+1]
V(net2)$shape <- c("square", "circle")[V(net2)$type+1]

# media outlets -> named labels, audience members -> NA
V(net2)$label <- ""
V(net2)$label[V(net2)$type == F] <- nodes2$media[V(net2)$type == F]
V(net2)$label.cex <- .6
V(net2)$label.font <- 2

plot(net2, vertex.label.color = "white", vertex.size = (2 - V(net2)$type) * 8)

#' Layout
plot(net2, vertex.label = NA, vertex.size = 7, layout = layout.bipartite)

#' Text as node
plot(net2,
     vertex.shape = "none", 
     vertex.label = nodes2$media,
     vertex.label.color = V(net2)$color, 
     vertex.label.font = 2,
     vertex.label.cex = .6, 
     edge.color = "gray70", 
     edge.width = 2)

#' Separate mode

net2.bp <- bipartite.projection(net2)

plot(net2.bp$proj1,
  vertex.label.color = "black", vertex.label.dist = 1,
  vertex.label = nodes2$media[!is.na(nodes2$media.type)])

plot(net2.bp$proj2,
  vertex.label.color = "black", vertex.label.dist = 1,
  vertex.label = nodes2$media[is.na(nodes2$media.type)]) 


#' ## Multiplex networks
# multiplex networks #------------------
E(net)$width <- 1.5

plot(net,
  edge.color = c("dark red", "slategrey")[(E(net)$type == "hyperlink") + 1],
  vertex.color = "gray40",
  layout = layout_in_circle,
  edge.curved = .3,
  vertex.label = NA)

# delete edges using minus operator
net.m <- net - E(net)[E(net)$type == "hyperlink"]
net.h <- net - E(net)[E(net)$type == "mention"]

# plot two links separately

l <- layout_with_fr(net)
plot(net.h,
     edge.arrow.size = 0.2,
     vertex.color = "orange",
     layout = l,
     main = "Tie: Hyperlink")
plot(net.m,
     edge.arrow.size = 0.2,
     vertex.color = "lightsteelblue2",
     layout = l,
     main = "Tie: Mention")

#' ## Interactive plot
# interactive #----------------------------

#' ### tkplot
## tkplot #---------------------

# tkid: id of the tkplot that will open
# tkid <- tkplot(net) 

# grab the coordinates from tkplot
# l <- tkplot.getcoords(tkid) 

# plot(net, layout=l)

#' ### visNetwork
## visNetwork #---------------------------
visNetwork::visNetwork(nodes, 
                       links,
                       width = "100%",
                       height = "400px")

# customize color & size
(vis.nodes <- nodes %>%
                mutate(shape = "dot",
                       shadow = TRUE,
                       title = media,
                       label = type.label,
                       size = audience.size,
                       borderWidth = 2,
                       color.background = case_when(media.type == 1 ~ "slategrey",
                                                    media.type == 2 ~ "tomato",
                                                    media.type == 3 ~ "gold"),
                       color.border = "black",
                       color.highlight.background = "orange",
                       color.highlight.border = "darkred"))
(vis.links <- links)

visNetwork(vis.nodes, vis.links)

# customize arrow edges
(vis.links <- vis.links %>%
        mutate(width = 1 + links$weight/8, # line width
               color = "gray", # line color
               arrows = "middle", # arrow: `from`, `to`, `middle`
               smooth = FALSE, # edges: curved?
               shadow = FALSE))

visnet <- visNetwork(vis.nodes, vis.links)
visnet

# add legend
visnet %>%
        visGroups(groupname = "Newspaper",
                  color = list(background = "slategrey", border = "black")) %>%
        visGroups(groupname = "TV",
                  color = list(background = "tomato", border = "black")) %>%
        visGroups(groupname = "Online",
                  color = list(background = "gold", border = "black")) %>%
        visLegend(main = "Media")

# interactive options
visOptions(visnet,
           highlightNearest = TRUE,
           selectedBy = "label")

# rmarkdown::render()
