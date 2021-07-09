##################################################################################
# construct a logistic regression model
# uses a selection of appropriate variables
# output from summary(model_lr) is used for feature selection
##################################################################################
model_lr_v1 <- glm(accurate~.,
                   family = "binomial",
                   data = events_train %>%
                     dplyr::select(subEventName,
                                   teamId,
                                   assist:fairplay,
                                   y_start_cut,
                                   x_start_cut,
                                   accurate,
                                   eventSec,
                                   matchPeriod) %>%
                     mutate(teamId = factor(teamId)))
summary(model_lr_v1)

##################################################################################
# the function below takes an events dataset and converts it to a form suitable
# for using to construct a logistic regression model (as per the summary output)
##################################################################################
events_to_lr <- function(data) {
  data %>%
    dplyr::select(subEventName,
                  playerId,
                  assist:fairplay,
                  y_start_cut,
                  x_start_cut,
                  x_start,
                  accurate,
                  teamId,
                  eventSec) %>%
    mutate(subEventName = case_when(subEventName %in%
                                      c("Head pass","High pass","Launch","Smart pass","Cross") ~ "1_Other",
                                    TRUE ~ subEventName),
           x_start_cut = case_when(x_start < 40 ~ events_train$x_start_cut[11],
                                   TRUE ~ x_start_cut),
           teamId = factor(teamId)) %>%
    dplyr::select(-x_start,-Left,-Right,-`head/body`,-blocked) %>%
    return()
}

##################################################################################
# train the logistic regression model and define predictions
##################################################################################
model_lr <- glm(accurate~.,
                family = "binomial",
                data = events_to_lr(events_train))

preds_lr <- predict.glm(model_lr,
                        events_to_lr(events_test),
                        type = "response")

##################################################################################
# view confusion matrix. accuracy is around 85.24%
##################################################################################
confusionMatrix(factor(preds_lr>0.5), factor(events_test$accurate), positive = "TRUE")

##################################################################################
# this section aims to train a k-NN model, however the dataset is too large
# jaccard distance needs to be calculated for 237435*41905 pairs of observations
# DO NOT RUN
##################################################################################
#events_to_train_knn <- function(data) {
#  data %>%
#    dplyr::select(subEventName, assist:x_start) %>%
#    mutate(y_middle = between(y_start, 30, 70),
#           near_goal = x_start>60,
#           hand_pass = subEventName == "Hand pass",
#           simple_pass = subEventName == "Simple pass",
#           ID = 1:n()) %>%
#    dplyr::select(-x_start,
#                  -y_start,
#                  -subEventName) %>%
#    return()
#}
#
#events_to_test_knn <- function(data) {
#  data %>%
#    dplyr::select(subEventName, assist:x_start) %>%
#    mutate(y_middle = between(y_start, 30, 70),
#           near_goal = x_start>60,
#           hand_pass = subEventName == "Hand pass",
#           simple_pass = subEventName == "Simple pass") %>%
#    dplyr::select(-x_start,
#                  -y_start,
#                  -subEventName,
#                  -accurate)
#}
#
#model_knn <- knn(
#  train_set = events_to_train_knn(events_train),
#  test_set = events_to_test_knn(events_test),
#  k = 5,
#  categorical_target = "accurate",
#  comparison_measure = "jaccard",
#  id = "ID"
#)

##################################################################################
# construct a decision tree
##################################################################################

##################################################################################
# the function below takes an events dataset and converts it to a form suitable
# for using to construct a decision tree
# IMPROVEMENT: summary(model_lr) was used again for feature selection. ideally,
# the decision tree would not rely on summary statistics from another model
##################################################################################
events_to_dt <- function(data) {
  data %>%
    dplyr::select(subEventName,
           teamId,
           eventSec,
           assist:accurate,
           y_start_cut:x_start_cut,
           -`head/body`) %>%
    mutate(teamId = factor(teamId),
           subEventName = factor(subEventName),
           accurate = factor(accurate)) %>%
    return()
}

##################################################################################
# the train function in the caret package is used to select an optimal
# complexity parameter (cp) using 25 bootstrap samples with replacement
##################################################################################
set.seed(64)
model_tree_cv <- train(accurate~.,
                       method = "rpart",
                       tuneGrid = data.frame(cp = seq(0, 0.05, len = 25)),
                       data = events_to_dt(events_train))

##################################################################################
# visualise the performance of each cp
##################################################################################
ggplot(model_tree_cv, highlight = TRUE)

##################################################################################
# visualise the error for each cp
##################################################################################
model_tree_cv$results %>% 
  ggplot(aes(x = cp, y = Accuracy)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(x = cp, 
                    ymin = Accuracy - AccuracySD,
                    ymax = Accuracy + AccuracySD))

##################################################################################
# define the optimal cp
##################################################################################
opt_cp <- model_tree_cv$bestTune

##################################################################################
# redefine the model using the train data set and optimal cp
# NOTE: this is only retrained with the rpart function to allow for the plot below
##################################################################################
model_tree <- rpart(accurate~., cp = opt_cp, data = events_to_dt(events_train)) 

##################################################################################
# plot the model - this really helps to understand how the algorithm works
##################################################################################
rpart.plot(model_tree, type = 5)
title("Decision Tree")

##################################################################################
# define predictions and view confusion matrix. accuracy is around 85.36%
##################################################################################
preds_tree <- predict(model_tree, events_to_dt(events_test))[,2]
confusionMatrix(factor(preds_tree>0.5), factor(events_test$accurate),
                positive = "TRUE")

##################################################################################
# random forest
# similar to KNN, the dataset is too large to train this algorithm in a reasonable time
# DO NOT RUN
##################################################################################
#model_rf <- train(accurate~.,
#                  method = "rf",
#                  tuneGrid = data.frame(mtry = 3:11),
#                  data = events_to_dt(events_train))
#
#ggplot(model_rf, highlight = TRUE) +
#  scale_x_discrete(limits = 2:12) +
#  ggtitle("Accuracy for each number of randomly selected predictors")
#
#model_rf$results %>% 
#  ggplot(aes(x = mtry, y = Accuracy)) +
#  geom_line() +
#  geom_point() +
#  geom_errorbar(aes(x = mtry, 
#                    ymin = Accuracy - AccuracySD,
#                    ymax = Accuracy + AccuracySD))
#
#preds_rf <- predict(model_rf, test)
#
#cm_rf <- confusionMatrix(preds_rf, test$class)
#
#importance(model_rf$finalModel)
#
##################################################################################
# ensemble of logistic regression and decision tree
# simply take the mean of each probability prediction
# confusion matrix indicates accuracy of around 85.46%
##################################################################################
preds_ens <- (predict(model_tree, events_to_dt(events_test))[,2] + preds_lr)/2
confusionMatrix(factor(preds_ens>0.5), factor(events_test$accurate), positive = "TRUE")
