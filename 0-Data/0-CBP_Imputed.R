# Robert Dinterman

print(paste0("Started 0-CBP_Imputed at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)

load("0-Data/CBP/CBP86-13.Rda") # 1986 to 2013 data

cbpall <- filter(cbp, sic == "----" | naics == "------")

# Problem with FIPS that need to be condensed:
# 51540 51570 51580 51590 51595 51600 51620 51640 51670 51678 
# 51685 51690 51720 51730 51775 51790 

test <- lm(emp ~ n1_4 + n5_9 + n10_19 + n20_49 + n50_99 + n100_249 + n250_499 +
             n500_999 + n1000_1 + n1000_2 + n1000_3 + n1000_4 - 1,
           filter(cbpall, empflag == ""))
summary(test)

cbpimpute      <- filter(cbpall, empflag != "")
imputed        <- predict(test, cbpimpute)
imputed        <- as.data.frame(round(imputed))
names(imputed) <- "imputed"

cbpimpute <- bind_cols(cbpimpute, imputed)
cbpimpute <- cbpimpute %>% rowwise() %>%
  mutate(emp_ = imputed,
         emp_ = ifelse(empflag == "A", max(min(emp_, 19), 0), emp_),
         emp_ = ifelse(empflag == "B", max(min(emp_, 99), 20), emp_),
         emp_ = ifelse(empflag == "C", max(min(emp_, 249), 100), emp_),
         emp_ = ifelse(empflag == "E", max(min(emp_, 499), 250), emp_),
         emp_ = ifelse(empflag == "F", max(min(emp_, 999), 500), emp_),
         emp_ = ifelse(empflag == "G", max(min(emp_, 2499), 1000), emp_),
         emp_ = ifelse(empflag == "H", max(min(emp_, 4999), 2500), emp_),
         emp_ = ifelse(empflag == "I", max(min(emp_, 9999), 5000), emp_),
         emp_ = ifelse(empflag == "J", max(min(emp_, 24999), 10000), emp_),
         emp_ = ifelse(empflag == "K", max(min(emp_, 49999), 25000), emp_),
         emp_ = ifelse(empflag == "L", max(min(emp_, 99999), 50000), emp_),
         emp_ = ifelse(empflag == "M", max(emp_, 100000), emp_))

cbpall %>% filter(empflag == "" | is.na(empflag)) %>%
  bind_rows(cbpimpute) %>%
  mutate(emp_ = ifelse(is.na(emp_), emp, emp_)) -> cbpimpute

# A 0-19
# B 20-99
# C 100-249
# E 250-499
# F 500-999
# G 1,000-2,499
# H 2,500-4,999
# I 5,000-9,999
# J 10,000-24,999
# K 25,000-49,999
# L 50,000-99,999
# M 100,000 or More

write_csv(cbpimpute, path = "0-Data/CBP/CBPimpute.csv")
save(cbpimpute, file = "0-Data/CBP/CBPimpute.Rda")

cbpfull <- expand.grid(fips = unique(cbpimpute$fips),
                       year = unique(cbpimpute$year))
cbpfull <- left_join(cbpfull, select(cbpimpute, fips, year, emp:est, emp_))

library(zoo)
cbpfull %>%
  group_by(fips) %>% do(na.locf(.)) -> cbpfull
cbpfull %>%
  group_by(fips) %>%
  do(na.locf(., fromLast = T)) -> cbpfull

write_csv(cbpfull, path = "0-Data/CBP/CBPfull.csv")
save(cbpfull, file = "0-Data/CBP/CBPfull.Rda")

rm(list = ls())

print(paste0("Finished 0-CBP_Imputed at ", Sys.time()))