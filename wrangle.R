##################################################################################
# events data (2018 premier league)
# IMPROVEMENT: read in appropriate elements to save processing power
##################################################################################
events_England_master <-
  fromJSON(file = "data/events_England.json")

##################################################################################
# keep relevant events - pass
##################################################################################
ind_keep <- 
  lapply(events_England_master, `[[`, 1) %>%
  unlist == 8
events_England <-
  events_England_master[ind_keep]
# rm(ind_keep, events_England_master)

##################################################################################
# read in tags2name and filter on relevant rows (determined by observing data)
# IMPROVEMENT: read in relevant events (similar to above)
##################################################################################
tags2name <- 
  read_csv("data/tags2name.csv") %>%
  slice(c(3:15, 19:21, 53:59))

##################################################################################
# convert list into data frame
##################################################################################
events_df <- 
  events_England %>%
  sapply("[", i = 1:12) %>%
  t() %>%
  data.frame()

##################################################################################
# convert lists into variables/observations, typical of a data frame
# convert tags into string variable instead of a list of lists
##################################################################################
events_df_tidy <- 
  data.frame(lapply(events_df[,-c(3,5)], unlist),
             tags = paste0(" ", sapply(events_df$tags, unlist) %>%
                             lapply(paste, collapse = " "), " "))

##################################################################################
# check there are no events without end positions
##################################################################################
sum(lapply(events_England, "[[", 5) %>%
      lapply(length) %>%
      unlist == 1)

##################################################################################
# include individual tag boolean columns
# remove tags which never appear
# IMPROVEMENT: this reinitialises the data frame each time
#              using something like mutate might be more efficient
##################################################################################
for (i in 1:nrow(tags2name)) {
  events_df_tidy[[toString(tags2name$Label[i])]] <-
    str_detect(events_df_tidy$tags,paste0(" ",tags2name$Tag[i]," "))
}
events_df_tidy <- 
  events_df_tidy[,!names(events_df_tidy) %in%
                   names(which(colSums(events_df_tidy[,12:34])==0))]

##################################################################################
# check events are either accurate of not accurate
# remove `not accurate` row as it is redundant
##################################################################################
sum(events_df_tidy$accurate==events_df_tidy$`not accurate`)
events_df_tidy %<>%
  subset(select = -`not accurate`)

##################################################################################
# include separate variables for each start/end x/y positions
# note: using mutate instead of loop didn't improve efficiency
# split x,y coordinates into deciles with cut function
# also, change y coordinate to denote closeness to left side of pitch
##################################################################################
pos_names <- c("y_start", "x_start", "y_end", "x_end")
for (i in 1:4) {
  events_df_tidy[[pos_names[i]]] <-
    sapply(events_df$positions, unlist)[i,]
}
events_df_tidy %<>%
  mutate(y_start = 100-y_start,
         y_start_cut = cut(y_start, seq(0, 100, by = 10),
                           include.lowest = TRUE),
         x_start_cut = cut(x_start, seq(0, 100, by = 10),
                           include.lowest = TRUE))
# rm(events_df, pos_names, i, tags2name, events_England)

##################################################################################
# create a validation data set - this is used to assess the final model
# events data set is used for model training and selection
##################################################################################
set.seed(4)
validation_index <-
  createDataPartition(events_df_tidy$accurate, times = 1, p = 0.15, list = FALSE)
events_validation <-
  events_df_tidy %>%
  slice(validation_index)
events <- events_df_tidy %>%
  slice(-validation_index)

##################################################################################
# create train and test sets from events
# train is used to construct various models and test is used to assess their performances
# the best performing model will then be retrained using the event data set
# and assessed using the validation data set
##################################################################################
set.seed(16)
test_index <-
  createDataPartition(events$accurate, times = 1, p = 0.15, list = FALSE)
events_train <-
  events %>%
  slice(-test_index)
events_test <-
  events %>%
  slice(test_index)
# rm(events_df_tidy, test_index, validation_index)


