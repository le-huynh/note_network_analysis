#'---
#' title: Alluvial Diagram
#' output: github_document
#'---

#+ message=FALSE
pacman::p_load(
        tidyverse,  # data management and visualization
        ggalluvial  # generate alluvial diagram
)

#' ### Import data
data("majors")
majors %>% tibble()

#' ### Data overview
#' Data of 10 students and their majors across 8 semesters.

majors %>% count(student)

majors %>% count(semester)

majors %>% count(curriculum)

#' ### Check lodes_form
majors %>% is_lodes_form(key = semester,
                         value = curriculum,
                         id = "student")

#' Alluvial plot
majors %>% ggplot(aes(alluvium = student,
                      x = semester,
                      stratum = curriculum)) +
        geom_alluvium(color = "black") +
        geom_stratum(aes(fill = curriculum),
                     color = "black") +
        scale_y_discrete(breaks = seq(1, 10, by = 1)) +
        labs(y = "Number of students enrolled",
             title = "Majors opted across semesters")

#' ### Check alluvial_form
(majors_alluvia <- majors %>% 
        to_alluvia_form(key = semester,
                        value = curriculum,
                        id = student) %>%
        tibble())

#' Alluvial plot

majors_alluvia %>% ggplot(aes(axis1 = CURR1,
                              axis2 = CURR7,
                              axis3 = CURR13)) +
        geom_alluvium(aes(fill = as.factor(student)),
                      color = "black") +
        geom_stratum() +
        geom_text(aes(label = after_stat(stratum)),
                  stat = "stratum",
                  size = 3,
                  discern = TRUE)


#rmarkdown::render()
