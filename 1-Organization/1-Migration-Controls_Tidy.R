# Robert Dinterman

# ---- Start --------------------------------------------------------------

print(paste0("Started 1-Migration-Controls_Tidy at ", Sys.time()))

library(dplyr)
library(readr)
library(tidyr)

# Create a directory for the data
localDir <- "1-Organization/Migration"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/Migration/netmigration.Rda")

# ---- Controls -----------------------------------------------------------
load("0-Data/IRS/CTYPop.Rda") # Population, Households, Income for county
ctydata <- left_join(aggdata, IRS_POP)
rm(aggdata, IRS_POP)

load("0-Data/CBP/CBPimpute.Rda") # County Business Patterns, establishments
ctydata <- left_join(ctydata, cbpimpute[, c("year", "fips", "est")])
rm(cbpimpute)

load("0-Data/LAU/LAUnemp.RData")
ctydata <- left_join(ctydata, unemp)
rm(unemp)

load("0-Data/ERS/ERS.Rda") # Problem with the different years ??
temp <- expand.grid(unique(ERS$fips), 1990:2013)
names(temp) <- c("fips", "year")
temp <- left_join(temp, ERS)

temp %>% select(-(metro93:metro13)) %>% 
  group_by(fips) %>% do(zoo::na.locf(.)) -> temp

ctydata <- left_join(ctydata, temp)
rm(temp, ERS)

load("0-Data/Poverty/pov.Rda") # Poverty Data w/ MEDHHINC
temp <- expand.grid(unique(pov$fips), 1989:2013)
names(temp) <- c("fips", "year")
temp %>% left_join(pov) %>% group_by(fips) %>% do(zoo::na.locf(.)) -> temp

ctydata <- left_join(ctydata, temp)
rm(pov, temp)

load("0-Data/NOAA/noaabasic.Rda") # Storm Data
noaabasic %>% rename(year = YEAR) %>% 
  left_join(ctydata, .) -> ctydata

rm(noaabasic)

write_csv(ctydata, paste0(localDir, "/Aggctydata.csv"))
save(ctydata, file = paste0(localDir, "/Aggctydata.Rda"))


# ---- Combine with Origin-Destination ------------------------------------

load("1-Organization/Migration/ctycty.Rda")
apply(ctycty, 2, function(x) sum(is.na(x)))

origin_names    <- paste0(names(ctydata), "_o")
origin_names[1] <- "year"

dest_names      <- paste0(names(ctydata), "_d")
dest_names[1]   <- "year"

names(ctydata) <- origin_names
ctycty         <- left_join(ctycty, ctydata)

names(ctydata) <- dest_names
ctycty         <- left_join(ctycty, ctydata)

write_csv(ctycty, paste0(localDir, "/ODmodeldata.csv"))
save(ctycty, file = paste0(localDir, "/ODmodeldata.Rda"))


rm(list = ls())

print(paste0("Finished 1-Migration-Controls_Tidy at ", Sys.time()))