#Robert Dinterman

# Yearly CPI: manual download
# https://research.stlouisfed.org/fred2/series/CPIAUCSL/downloaddata

print(paste0("Started 0-CPI at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "0-Data/CPI"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# FILE HOSTED SOMEWHERE??

read_csv(paste0(data_source, "/CPIAUCSL.csv")) %>%
  mutate(year = as.numeric(format(DATE, "%Y")), CPI = as.numeric(VALUE)) %>%
  select(year, CPI) %>% 
  filter(year != 2015) -> CPI

write_csv(CPI, path =  paste0(localDir, "/CPI.csv"))
save(CPI, file = paste0(localDir, "/CPI.Rda"))


rm(list = ls())

print(paste0("Finished 0-CPI at ", Sys.time()))