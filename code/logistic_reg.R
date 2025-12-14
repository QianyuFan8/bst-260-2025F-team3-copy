# Load Required Packages
library(car)

clean_data <- read_rds("data/clean_data.rds")

mod <- glm(
  Diabetes ~ Gender + Age + Race3 + Education + MaritalStatus + 
    PovertyLvl + Work + HomeOwn + SleepHrsCategory + 
    SleepTrouble + PhysActive + TVHrsDay + CompHrsDay + 
    SmokeStatus + AlcoholCategory + LittleInterest + Depressed,
  family = binomial, 
  data = clean_data
)