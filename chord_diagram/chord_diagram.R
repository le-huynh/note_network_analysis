#'---
#' title: Chord Diagram
#' output: github_document
#'---

#+ message=FALSE
pacman::p_load(
        rio,            # import and export files
        here,           # locate files 
        tidyverse,      # data management and visualization
        igraph,
        tidygraph,
        ggraph,
        circlize,
        chorddiag
        )

# Install package `chorddiag`
# devtools::install_github("mattflor/chorddiag")

#' ## Data
# data #--------------------------------

# create example edge list
(origin <- paste0("orig ", sample(c(1:10), 20, replace = T)))

(destination <- paste0("dest ", sample(c(1:10), 20, replace = T)))

(data <- data.frame(origin, destination))


#' ## `chorddiag` package: Chord Diagram from Edge List
# chorddiag pkg #--------------------

data_matrix <- as.matrix(as_adjacency_matrix(as_tbl_graph(data)))

chorddiag(data = data_matrix,
          groupnamePadding = 30,
          groupPadding = 3,
          groupColors = c("#ffffe5",
                          "#fff7bc",
                          "#fee391",
                          "#fec44f",
                          "#fe9929",
                          "#ec7014",
                          "#cc4c02",
                          "#8c2d04"),
          groupnameFontsize = 13 ,
          showTicks = FALSE,
          margin=150,
          tooltipGroupConnector = "    &#x25B6;    ",
          chordedgeColor = "#B3B6B7"
)


#' ## `circlize` package: Chord Diagram from Edge List
# circlize pkg #--------------------

# transform input data in a adjacency matrix
(adjacencyData <- with(data, table(origin, destination)))

## type 1 #-----------------------
set.seed(1234)
chordDiagram(adjacencyData,
             transparency = 0.5)

## type 2 #---------------------------------------
circos.clear()
par(cex = 1, mar = c(0, 0, 0, 0))

set.seed(1234)
chordDiagram(adjacencyData,
             directional = 1,
             direction.type = c("diffHeight", "arrows"),
             link.arr.type = "big.arrow")

## type 3 #-----------------------
# parameters
circos.clear()
circos.par(start.degree = 90,
           gap.degree = 4,
           track.margin = c(-0.1, 0.1),
           points.overflow.warning = FALSE)
par(cex = 0.8, mar = rep(0, 4))

# Base plot
set.seed(1234)
chordDiagram(adjacencyData,
             transparency = 0.25,
             directional = 1,
             direction.type = c("arrows", "diffHeight"), 
             diffHeight  = -0.04,
             annotationTrack = "grid", 
             annotationTrackHeight = c(0.05, 0.1),
             link.arr.type = "big.arrow", 
             link.sort = TRUE, 
             link.largest.ontop = TRUE)

# Add text and axis
circos.trackPlotRegion(
        track.index = 1, 
        bg.border = NA, 
        panel.fun = function(x, y) {
                
                xlim = get.cell.meta.data("xlim")
                sector.index = get.cell.meta.data("sector.index")
                
                # Add names to the sector. 
                circos.text(
                        x = mean(xlim), 
                        y = 3.2, 
                        labels = sector.index, 
                        facing = "bending", 
                        cex = 0.8
                )
                
                # Add graduation on axis
                circos.axis(
                        h = "top", 
                        major.at = seq(from = 0, 
                                       to = xlim[2], 
                                       by = ifelse(test = xlim[2]>10, 
                                                   yes = 2, 
                                                   no = 1)), 
                        minor.ticks = 1, 
                        major.tick.length = 0.5,
                        labels.niceFacing = FALSE)
        }
)


#' ## References
#' - [Circular Visualization in R](https://jokergoo.github.io/circlize_book/book/the-chorddiagram-function.html)
#' - [Chord Diagrams in R with chorddiag](https://xang1234.github.io/chorddiagrams/)


# rmarkdown::render()
