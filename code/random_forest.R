# Load Required Packages
library(randomForest)
library(caret)
library(pROC)
library(PRROC)
library(vip)
library(tidyverse)
library(here)

set.seed(123)

# Load Dataset
df <- readRDS(here("data", "clean_data.rds")) 
#%>%
#  mutate(Diabetes = factor(Diabetes, levels = c("Yes", "No")))  # positive = Yes

# Train–Test Split
trainIndex <- createDataPartition(df$Diabetes, p = 0.80, list = FALSE)
train_data <- df[trainIndex, ]
test_data  <- df[-trainIndex, ]

# cat("Training class distribution:\n")
# print(table(train_data$Diabetes))
# 
# cat("\nTest class distribution:\n")
# print(table(test_data$Diabetes))

# Downsample Training Data
set.seed(123)

train_bal <- downSample(
  x = train_data %>% select(-Diabetes),
  y = train_data$Diabetes,
  yname = "Diabetes"
)

# cat("\nBalanced training data distribution:\n")
# print(table(train_bal$Diabetes))

# Cross-Validation Control
control <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = TRUE
)

# Tuning Grid for mtry
p <- ncol(train_bal) - 1

grid <- expand.grid(
  mtry = unique(pmax(1, c(
    floor(sqrt(p)/2),
    floor(sqrt(p)),
    floor(1.5*sqrt(p)),
    floor(2*sqrt(p))
  )))
)

# print(grid)

# Train Balanced RF with Tuning
rf_balanced <- train(
  Diabetes ~ .,
  data = train_bal,
  method = "rf",
  metric = "ROC",
  tuneGrid = grid,
  trControl = control,
  ntree = 500,
  importance = TRUE
)

# print(rf_balanced)

# Test-Set Evaluation
pred_prob <- predict(rf_balanced, test_data, type = "prob")[,"Yes"]
pred_class <- predict(rf_balanced, test_data)

cm <- confusionMatrix(pred_class, test_data$Diabetes, positive = "Yes")
# print(cm)

# ROC + AUC
roc_obj <- roc(test_data$Diabetes, pred_prob)

# plot(roc_obj, col = "blue", legacy.axes = TRUE,
#      main = "ROC Curve - Balanced Random Forest")

auc_value <- auc(roc_obj)
# print(paste("AUC:", round(auc_value, 4)))

# Precision–Recall Curve
pr <- pr.curve(
  scores.class0 = pred_prob[test_data$Diabetes=="Yes"],
  scores.class1 = pred_prob[test_data$Diabetes=="No"],
  curve = TRUE
)

# plot(pr, main = "Precision–Recall Curve - Balanced RF")
# # print(paste("PR-AUC:", round(pr$auc.integral, 4)))

# Feature Importance (Gini)
rf_final <- rf_balanced$finalModel

importance_matrix <- importance(rf_final)

# varImpPlot(rf_final, main = "Variable Importance (Gini Index)")

# Permutation Importance (ROC-based)
vi <- vi_permute(
  rf_balanced,
  train = train_bal,
  target = "Diabetes",
  metric = "roc_auc",
  event_level = "second",
  pred_wrapper = function(object, newdata) {
    predict(object, newdata, type = "prob")[,"Yes"]
  }
)

# vip(vi, num_features = 10, geom = "col",
#     main = "Permutation Importance (Δ ROC-AUC)")
