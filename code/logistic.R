# Load required packages

library(tidyverse)
library(car)

clean_data <- readRDS("data/clean_data.rds")

logistic <- glm(
  Diabetes ~ Gender + Age + Race1 + Education + MaritalStatus +
    Poverty + Work + BMI + BPSysAve + BPDiaAve + DirectChol +
    SleepHrsNight + SleepTrouble + PhysActive + Alcohol12PlusYr +
    Smoke100 + HealthGen + LittleInterest + Depressed,
  data = clean_data,
  family = "binomial"
)

vif(logistic)


par(mfrow = c(2, 1))  # two plots in one figure
mar = c(4, 4, 3, 2)
# --- Plot 1: Residual vs Fitted ---
plot(
  logistic$fitted.values,
  residuals(logistic, type = "deviance"),
  xlab = "Fitted Probabilities",
  ylab = "Deviance Residuals",
  main = "Residual vs Fitted"
)
abline(h = 0, col = "red")

# --- Plot 2: Cook's Distance ---
plot(
  cooks.distance(logistic),
  type = "h",
  main = "Cook's Distance",
  ylab = "Cook's Distance",
  xlab = "Index"
)
abline(
  h = 4 / (nrow(clean_data) - length(logistic$coefficients)),
  col = "red",
  lty = 2
)

par(mfrow = c(1, 1))  # reset to default

