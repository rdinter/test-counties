#Robert Dinterman

# Crime JSON
# https://github.com/maliabadi/ucr-json

print(paste0("Started 0-Crime-JSON at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(tidyr)
library(jsonlite)

# Create a directory for the data
localDir <- "0-Data/Controls/Crime"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

files <- list.files(localDir, pattern = "*.json", full.names = T)

JSON_year <- function(file){
  data <- fromJSON(file)
  year <- substr(basename(file), 1, 4)
  data$year <- as.numeric(year)
  data$fips <- as.numeric(data$fips_state_code)*1000 +
    as.numeric(data$fips_county_code)
  return(data)
}

crime <- files %>% sapply(JSON_year) %>% bind_rows() %>%
  filter(!is.na(fips))

crime$fips[crime$fips==12086] <- 12025

write_csv(crime, path =  "0-data/Controls/Govt/crimejson.csv")
save(crime, file = "0-data/Controls/Crime/crimejson.RData")

rm(list = ls())

print(paste0("Finished 0-Crime-JSON at ", Sys.time()))