#'---
#' title: ARC diagram --- example co-authorship network of a researcher
#' output: github_document
#'---

#+ message=FALSE
pacman::p_load(
        rio,            # import and export files
        here,           # locate files 
        tidyverse,      # data management and visualization
        igraph,
        ggraph
)

#' ### Data
data_url <- "https://raw.githubusercontent.com/holtzy/data_to_viz/master/Example_dataset/13_AdjacencyUndirectedUnweighted.csv"
data_raw <- rio::import(data_url, header = TRUE)

data_raw %>% tibble()

#' ### Transform the adjacency matrix in a long format

(connect <- data_raw %>%
        pivot_longer(cols = -from,
                     names_to = "to",
                     values_to = "value") %>%
        drop_na(value))


#' ### Number of connection per person
(coauth <- c(connect$from, connect$to) %>%
        as_tibble() %>%
        group_by(value) %>%
        summarise(n = n()) %>%
        rename(name = value))

#' ### Create igraph object

(net_igraph <- graph_from_data_frame(d = connect,
                                     vertices = coauth,
                                     directed = FALSE))

#' ### Find community
(community <- cluster_walktrap(net_igraph))

#' ### Reorder dataset + make graph
(coauth <- coauth %>% 
        mutate(grp = community$membership) %>%
        arrange(grp) %>%
        mutate(name = factor(name, name)))

# keep only 10 first communities
(coauth_10com <- coauth %>% 
        filter(grp < 11))

# keep only people 10 first communities in edges
(connect_10com <- connect %>%
        filter(from %in% coauth_10com$name) %>%
        filter(to %in% coauth_10com$name))

# Create a graph object with igraph
(net_graph_10com <- graph_from_data_frame(d = connect_10com,
                                         vertices = coauth_10com,
                                         directed = FALSE ))

# prepare vector of n color in viridis scale
(colors <- rainbow(n = max(coauth_10com$grp)))


# Make the graph
ggraph(net_graph_10com, layout = "linear") +
  geom_edge_arc(edge_colour = "black",
                edge_alpha = 0.2,
                edge_width = 0.3,
                fold = TRUE) +
  geom_node_point(aes(size = n,
                      color = as.factor(grp),
                      fill = grp),
                  alpha = 0.5) +
  scale_size_continuous(range = c(0.5, 8)) +
  scale_color_manual(values = colors) +
  geom_node_text(aes(label = name),
                 angle = 65,
                 hjust = 1,
                 nudge_y = -1.1,
                 size = 2.3) +
  theme_void() +
  theme(legend.position = "none",
        plot.margin = unit(c(0, 0, 0.4, 0), "null"),
        panel.spacing = unit(c(0, 0, 3.4, 0), "null")) +
  expand_limits(x = c(-1.2, 1.2),
                y = c(-5.6, 1.2))


# rmarkdown::render()
