#########################################
# this script explores the data with 
# basic summaries and visualisations
#########################################

#########################################
# mean success rate of passes
#########################################
events_train %$%
  mean(accurate)

#########################################
# successful passes split by variable high
#########################################
events_train %$%
  table(high, accurate)

#########################################
# the above table would be more intuitive 
# if proportions were used instead of counts
# e.g. what proportion of high passes were successful?
# the function below achieves this for any variable
#########################################
#' generate row proportion table for accurate and one other tag variable
#' @param tag  character - specifies the variable to compare against accurate
#' @return     row proportion table for accurate and `tag`
#' @details    the returned table shows the proportion of events, satisfying a
#'             specified tag, which are accurate. For example, tag = "high" returns
#'             a table showing the proportion of high and low passes which are accurate
acc_prop <- function(data, tag) {
  
  # tag must be a character variable
  if (class(tag) != "character" || length(tag) != 1)
    stop("argument tag must be a numeric vector or length 1")
  
  # tag must exist in argument data
  if (!tag %in% names(data)[11:23])
    stop("argument tag must be a tag from argument data")
  
  # define index of accurate and tag columns
  acc_ind <- which("accurate" == names(data))
  tag_ind <- which(tag == names(data))
  
  # create and return the table
  scale(data %>%
          dplyr::select(all_of(acc_ind), all_of(tag_ind)) %>%
          table(),
        center = F,
        scale = rowSums(data %>%
                          dplyr::select(all_of(tag_ind), all_of(acc_ind)) %>%
                          table())) %>%
    t() %>%
    return
}

#########################################
# test out function for a few variables
#########################################
acc_prop(events_train, "high")
acc_prop(events_train, "keyPass")

#########################################
# here is code to plot the mean success
# rate of passes by coordinates on a pitch
#########################################
if (!"football_pitch.png" %in% list.files())
  download.file("https://upload.wikimedia.org/wikipedia/commons/f/f3/Football_field_105x68.PNG",
                destfile = "football_pitch.png")
football_pitch <- readPNG("football_pitch.png")
fp <- rasterGrob(football_pitch, interpolate = TRUE)

events_train %>%
  group_by(y_start_cut, x_start_cut) %>%
  summarise(success_rate = mean(accurate)) %>%
  ggplot(aes(x_start_cut,
             y_start_cut,
             z = success_rate,
             fill = success_rate)) +
  annotation_custom(fp, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +
  geom_raster(alpha = 0.7) +
  scale_fill_gradientn(colors=c("blue","white","red"),
                       breaks = c(0.5, 0.6, 0.7, 0.8)) +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1)) +
  coord_fixed(ratio=0.65) +
  labs(title = "Proportion of Successful Passes by Position on the Pitch",
       x = "",
       y = "") + 
  theme(axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank())
rm(football_pitch, fp)




cor_events_train <- events_train %>%
  dplyr::select(assist:fairplay) %>%
  cor
p.cor_events_train <- events_train %>%
  dplyr::select(assist:fairplay) %>%
  cor %>%
  cor_pmat
cor_events_train %>%
  ggcorrplot(lab = TRUE, type = "lower", method = "circle",
             insig = "blank", p.mat = p.cor_events_train,
             sig.level = 0.05,
             ggtheme = theme_gdocs(),
             colors = c("#6D9EC1", "white", "#E46726"),
             title = "Correlation Plot of Logical Variables", legend.title = "Correlation")
