# Robert Dinterman

# Read in FCC Zip code files from 1999 to 2008

print(paste0("Started 0-FCC_99_08 at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(tidyr)


# Create a directory for the data
localDir <- "0-Data/FCC"
data_source <- paste0(localDir, "/Raw/Providers")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# STEP FOR DOWNLOADING DATA?!?!?!

# Get layout files for data
files  <- list.files(data_source, full.names = T)

data <- sapply(files, read_csv, simplify = F, USE.NAMES = T)
data <- data %>% bind_rows() %>%
  rename(zip = ZIP) %>%
  mutate(time = as.Date(year, format = "%m-%d-%Y")) %>%
  distinct(zip, time)

# Spread the data so we fill in missing zip codes
data %>%
  select(-year) %>%
  spread(time, Prov) %>%
  distinct(zip) -> data2

library(zoo)

data2 %>%
  gather(time, Prov, `1999-12-31`:`2008-06-30`) %>%
  group_by(zip) %>% do(na.locf(.)) -> data2
data2 %>%
  mutate(time = as.Date(time, format = "%Y-%m-%d"),
         Prov = ifelse(is.na(Prov), 0, Prov),
         Prov = ifelse(Prov == "*", "1-3", Prov),
         Prov_num  = ifelse(Prov == "1-3", 2, as.numeric(Prov))) %>%
  distinct(zip, time) -> data

data     <- data[, c("time", "zip", "STATE", "Prov", "Prov_num")]
data$zip <- as.numeric(data$zip)

FCC <- data

write_csv(FCC, path = paste0(localDir, "/FCClong.csv"))
save(FCC, file = paste0(localDir, "/FCClong.Rda"))

rm(list = ls())

print(paste0("Finished 0-FCC_99_08 at ", Sys.time()))