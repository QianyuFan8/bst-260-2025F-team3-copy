# Load required packages
library(NHANES)
library(tidyverse)
library(janitor)
library(ggpubr)
library(here)

set.seed(2025)

ourdat <- NHANES |>
  # Remove duplicate rows
  distinct(ID, .keep_all = TRUE) |>
  # Adults age >= 40 and exclude pregnant women
  filter(Age >= 40, 
         PregnantNow == "No" | is.na(PregnantNow)) |>
  # Remove all empty variables after filter steps
  select(-c(ID, SurveyYr, PregnantNow, Length, HeadCirc, BMICatUnder20yrs, TVHrsDayChild, CompHrsDayChild))

# Save our dataset 
saveRDS(ourdat, file = here("data", "ourdata.rds"))


# After initial EDA, remove outliers and data inconsistency
dat <- ourdat |> 
  mutate(
    # BPDiaAve has outlier, replace 0 as NA
    BPDiaAve = ifelse(BPDiaAve == 0 , NA, BPDiaAve),
    # PhysActive == "No", then PhysActiveDays needs to be 0
    PhysActiveDays = ifelse(PhysActive == "No", 0, PhysActiveDays),
    # Inconsistency: when Alcohol12PlusYr == "No" & AlcoholDay * AlcoholYear > 12, set AlcoholDay and AlcoholYear as NA
    AlcoholDay  = ifelse(Alcohol12PlusYr == "No" & AlcoholDay * AlcoholYear > 12,
                         NA, AlcoholDay),
    AlcoholYear = ifelse(Alcohol12PlusYr == "No" & AlcoholDay * AlcoholYear > 12,
                         NA, AlcoholYear))

# KNN Imputation
dat_imputed <- kNN(dat, k = 5, imp_var = FALSE)

# Save dataset after KNN imputation
saveRDS(dat_imputed, file = here("data", "dat_imputed.rds"))


# Clean Data
clean_dat <- dat_imputed |>
  mutate(
    # Encode Education into 3 groups
    Education = case_when(
      Education %in% c("8th Grade", "9 - 11th Grade", "High School") ~ "≤HighSchool",
      Education == "Some College" ~ "SomeCollege",
      Education == "College Grad" ~ "College+"),
    Education = factor(Education, levels = c("≤HighSchool", "SomeCollege", "College+")),
    
    # Encode MaritalStatus into 3 groups
    MaritalStatus = case_when(
      MaritalStatus == "NeverMarried" ~ "NeverMarried",
      MaritalStatus == "Married" ~ "Married",
      MaritalStatus %in% c("Divorced", "LivePartner", "Separated", "Widowed") ~ "NotMarried"),
    MaritalStatus = factor(MaritalStatus, levels = c("NeverMarried", "Married", "NotMarried")),
    
    # Encode Poverty into 3 groups
    PovertyLvl = case_when(
      Poverty <= 1 ~ "LowIncome",
      Poverty > 1 & Poverty < 4 ~ "MiddleIncome",
      Poverty >= 4 ~ "HighIncome"),
    PovertyLvl = factor(PovertyLvl, levels = c("HighIncome", "MiddleIncome", "LowIncome")),
    
    # Create Smoking Status
    SmokeStatus = case_when(
      SmokeNow == "Yes" ~ "Current",
      Smoke100 == "Yes" & SmokeNow == "No" ~ "Former",
      Smoke100 == "No" ~ "Never"),
    SmokeStatus = factor(SmokeStatus, levels = c("Never", "Former", "Current")),
    
    # Create Alcohol drinking pattern category
    TotalAlcohol = AlcoholDay * AlcoholYear,
    AlcoholCategory = case_when(
      Alcohol12PlusYr == "No" ~ "Non-drinker",
      TotalAlcohol < 730 ~ "Light-Moderate",  # <2 drinks/day
      TotalAlcohol >= 730 ~ "Heavy"),         # ≥2 drinks/day
    AlcoholCategory = factor(AlcoholCategory, levels = c("Light-Moderate", "Non-drinker", "Heavy")),
    
    # Create Sleep hours category
    SleepHrsCategory = case_when(
      SleepHrsNight < 7 ~ "Short",
      SleepHrsNight >= 7 & SleepHrsNight <= 9 ~ "Adequate",
      SleepHrsNight > 9 ~ "Long"),
    SleepHrsCategory = factor(SleepHrsCategory, levels = c("Adequate", "Short", "Long")),
    
    # Create ActivityLevel category
    PhysActiveLvl = case_when(
      PhysActive == "No" ~ "Inactive",
      PhysActive == "Yes" & PhysActiveDays < 3 ~ "Low Active",
      PhysActive == "Yes" & PhysActiveDays >= 3 ~ "High Active"),
    PhysActiveLvl = factor(PhysActiveLvl, levels = c("High Active", "Inactive", "Low Active")),
    
    # Transform CompHrsDay to numeric
    TVHrsDay = case_when(
      TVHrsDay == "0_hrs" ~ 0,
      TVHrsDay == "0_to_1_hr" ~ 0.5,
      TVHrsDay == "1_hr" ~ 1,
      TVHrsDay == "2_hr" ~ 2,
      TVHrsDay == "3_hr" ~ 3,
      TVHrsDay == "4_hr" ~ 4,
      TVHrsDay == "More_4_hr" ~ 5),
    # Transform CompHrsDay to numeric
    CompHrsDay = case_when(
      CompHrsDay == "0_hrs" ~ 0,
      CompHrsDay == "0_to_1_hr" ~ 0.5,
      CompHrsDay == "1_hr" ~ 1,
      CompHrsDay == "2_hr" ~ 2,
      CompHrsDay == "3_hr" ~ 3,
      CompHrsDay == "4_hr" ~ 4,
      CompHrsDay == "More_4_hr" ~ 5),
    # Reorder Race3, HealthGen
    Race3 = factor(Race3, levels = c("Black", "White", "Asian", "Mexican", "Hispanic", "Other")),
    Work = factor(Work, levels = c("Working", "NotWorking", "Looking")),
    HealthGen = factor(HealthGen, levels = c("Excellent", "Vgood", "Good", "Fair", "Poor"))
  ) |>
  # Transform LittleInterest and Depressed as binary (Yes/No)
  mutate(
    LittleInterest = factor(ifelse(LittleInterest == "None", "No", "Yes"), levels = c("No", "Yes")),
    Depressed = factor(ifelse(Depressed == "None", "No", "Yes"), levels = c("No", "Yes"))) |>
  # Select interest variables and outcome
  select(
    # Outcomes
    Diabetes,
    # Confounders
    Gender, Age, Race3, 
    # Socioeconomic factors
    Education, MaritalStatus, PovertyLvl, Work, HomeOwn,
    # Behavioral factors
    SleepHrsCategory, SleepTrouble, PhysActive, TVHrsDay, CompHrsDay, AlcoholCategory, SmokeStatus,
    # Psychosocial factors
    LittleInterest, Depressed)

# Save final cleaned dataset
saveRDS(clean_dat, file = here("data", "clean_data.rds"))
