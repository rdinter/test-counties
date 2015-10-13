#Robert Dinterman

print(paste0("Started 0-IRS_Mig_2 at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)

# Create a directory for the data
localDir <- "0-Data/IRS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

load(paste0(localDir, "/inflows9213.Rda"))
load(paste0(localDir, "/outflows9213.Rda"))

allindata$key  <- paste0(allindata$ofips, allindata$dfips,
                         allindata$year)
alloutdata$key <- paste0(alloutdata$ofips, alloutdata$dfips,
                        alloutdata$year)

check1 <- allindata$key %in% alloutdata$key
sum(check1)
sum(!check1)

check2 <- alloutdata$key %in% allindata$key
sum(check2)
sum(!check2)

rm(list = ls())

print(paste0("Finished 0-IRS_Mig_2 at ", Sys.time()))
