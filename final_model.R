##################################################################################
# construct ensemble model using entire events dataset (excluding validation set)
##################################################################################

final_model_lr <- glm(accurate~.,
                     family = "binomial",
                     data = events_to_lr(events))

final_model_dt <- train(accurate~.,
                        method = "rpart",
                        tuneGrid = data.frame(cp = seq(0, 0.05, len = 25)),
                        data = events_to_dt(events))

final_preds_lr <- predict.glm(model_lr,
                              events_to_lr(events_validation),
                              type = "response")

final_preds_dt <- predict(model_tree,
                          events_to_dt(events_validation))[,2]

final_preds <- factor((final_preds_lr + final_preds_dt)/2>0.5)

confusionMatrix(final_preds, factor(events_validation$accurate), positive = "TRUE")
