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

cat("Training class distribution:\n")
print(table(train_data$Diabetes))

cat("\nTest class distribution:\n")
print(table(test_data$Diabetes))

# Downsample Training Data
set.seed(123)

train_bal <- downSample(
  x = train_data %>% select(-Diabetes),
  y = train_data$Diabetes,
  yname = "Diabetes"
)

cat("\nBalanced training data distribution:\n")
print(table(train_bal$Diabetes))

