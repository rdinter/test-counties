# Robert Dinterman
# http://www.broadbandmap.gov/developer

print(paste0("Started 0-BB_API at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
# library(dplyr)
# library(readr)
# library(stringr)
# library(tidyr)
# source("0-Data/0-functions.R")


# Create a directory for the data
localDir <- "0-Data/Broadband_Map"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)