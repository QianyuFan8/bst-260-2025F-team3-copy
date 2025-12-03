# Load required packages
library(NHANES)
library(tidyverse)
library(janitor)
library(ggpubr)
library(here)

rawdat <- NHANES |>
  # Remove duplicate rows
  distinct(ID, .keep_all = TRUE) |>
  # Adults age >= 40 and exclude pregnant women
  filter(Age >= 40, 
         PregnantNow == "No" | is.na(PregnantNow)) 

# Save raw dataset for EDA
saveRDS(rawdat, file = here("data", "raw_data.rds"))

# Clean Data
dat <- rawdat |>
  # Drop NA in these columns
  drop_na(Education, MaritalStatus, Poverty, Alcohol12PlusYr,
          HealthGen, LittleInterest, Depressed) |>
  mutate(
    # Encode Education into 3 groups
    Education = case_when(
      Education %in% c("8th Grade", "9 - 11th Grade", "High School") ~ "≤HighSchool",
      Education == "Some College" ~ "SomeCollege",
      Education == "College Grad" ~ "College+"),
    # Encode MaritalStatus into 3 groups
    MaritalStatus = case_when(
      MaritalStatus == "NeverMarried" ~ "NeverMarried",
      MaritalStatus == "Married" ~ "Married",
      MaritalStatus %in% c("Divorced", "LivePartner", "Separated", "Widowed") ~ "NotMarried"),
    # Encode Poverty into 3 groups
    Poverty = case_when(
      Poverty <= 1 ~ "LowIncome",
      Poverty > 1 & Poverty < 4 ~ "MiddleIncome",
      Poverty >= 4 ~ "HighIncome"),
    # Transform chr into factor
    Education = factor(Education, levels = c("≤HighSchool", "SomeCollege", "College+")),
    MaritalStatus = factor(MaritalStatus, levels = c("NeverMarried", "Married", "NotMarried")),
    Poverty = factor(Poverty, levels = c("LowIncome", "MiddleIncome", "HighIncome")),
    # Reorder HealthGen
    HealthGen = factor(HealthGen, levels = c("Poor", "Fair", "Good", "Vgood", "Excellent"))
  ) |>
  # Use median to impute NA
  mutate(
    BMI = ifelse(is.na(BMI), median(BMI, na.rm=TRUE), BMI),
    BPSysAve = ifelse(is.na(BPSysAve), median(BPSysAve, na.rm=TRUE), BPSysAve),
    BPDiaAve = ifelse(is.na(BPDiaAve) | BPDiaAve == 0 , median(BPDiaAve[BPDiaAve != 0], na.rm=TRUE), BPDiaAve),
    DirectChol = ifelse(is.na(DirectChol), median(DirectChol, na.rm=TRUE), DirectChol),
    SleepHrsNight = ifelse(is.na(SleepHrsNight), median(SleepHrsNight, na.rm=TRUE), SleepHrsNight)) |>
  # Transform LittleInterest and Depressed as binary (Yes/No)
  mutate(
    LittleInterest = factor(ifelse(LittleInterest == "None", "No", "Yes"), levels = c("No", "Yes")),
    Depressed = factor(ifelse(Depressed == "None", "No", "Yes"), levels = c("No", "Yes"))) |>
  # Select interest variables and outcome
  select(Gender, Age, Race1, Education, MaritalStatus, Poverty, Work, BMI, 
         BPSysAve, BPDiaAve, DirectChol, SleepHrsNight, SleepTrouble, PhysActive, 
         Alcohol12PlusYr, Smoke100, HealthGen, LittleInterest, Depressed, Diabetes)

# Save final cleaned dataset
saveRDS(dat, file = here("data", "clean_data.rds"))

