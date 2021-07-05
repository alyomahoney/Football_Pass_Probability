

model_lr <- glm(accurate~.,
                family = "binomial",
                data = events_train %>%
                  dplyr::select(subEventName,
                                playerId,
                                assist:fairplay,
                                y_start_cut,
                                x_start_cut,
                                accurate))
summary(model_lr)

events_to_lr <- function(data) {
  data %>%
    dplyr::select(subEventName,
                  playerId,
                  assist:fairplay,
                  y_start_cut,
                  x_start_cut,
                  x_start,
                  accurate) %>%
    mutate(subEventName = case_when(subEventName %in%
                                      c("Head pass","High pass","Launch","Smart pass","Cross") ~ "1_Other",
                                    TRUE ~ subEventName),
           x_start_cut = case_when(x_start < 40 ~ events_train$x_start_cut[11],
                                   TRUE ~ x_start_cut)) %>%
    dplyr::select(-x_start,-Left,-Right,-`head/body`,-blocked) %>%
    return()
}

model_lr <- glm(accurate~.,
                family = "binomial",
                data = events_to_lr(events_train))

preds_lr <- predict.glm(model_lr,
                        events_to_lr(events_test),
                        type = "response")
confusionMatrix(factor(preds_lr>0.5), factor(events_test$accurate))






# KNN

events_to_train_knn <- function(data) {
  data %>%
    dplyr::select(subEventName, assist:x_start) %>%
    mutate(y_middle = between(y_start, 30, 70),
           near_goal = x_start>60,
           hand_pass = subEventName == "Hand pass",
           simple_pass = subEventName == "Simple pass",
           ID = 1:n()) %>%
    dplyr::select(-x_start,
                  -y_start,
                  -subEventName) %>%
    return()
}

events_to_test_knn <- function(data) {
  data %>%
    dplyr::select(subEventName, assist:x_start) %>%
    mutate(y_middle = between(y_start, 30, 70),
           near_goal = x_start>60,
           hand_pass = subEventName == "Hand pass",
           simple_pass = subEventName == "Simple pass") %>%
    dplyr::select(-x_start,
                  -y_start,
                  -subEventName,
                  -accurate)
}

model_knn <- knn(
  train_set = events_to_train_knn(events_train),
  test_set = events_to_test_knn(events_test),
  k = 5,
  categorical_target = "accurate",
  comparison_measure = "jaccard",
  id = "ID"
)