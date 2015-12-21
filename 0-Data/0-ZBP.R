#Robert Dinterman

# Zip Code Business Patterns
# https://www.census.gov/econ/cbp/download/
# BEWARE: From 1994 to 1997, classification uses SIC. 1998+ is NAICS

print(paste0("Started 0-ZBP at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
source("0-Data/0-functions.R")

# Create a directory for the data
localDir    <- "0-Data/ZBP"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

tempDir  <- tempdir()

# Get layout files for data
urls <- paste0("https://www.census.gov/econ/cbp/download/full_layout/",
               c("ZIP_Totals_Layout.txt", "ZIP_Detail_Layout.txt",
                 "ZIP_Detail_Layout_SIC.txt"))
lapply(urls, function(x) bdown(url = x, folder = data_source))

# ---- ZBP Data from 1994 to 2001
years  <- c(as.character(94:99), "00", "01")
url    <- "ftp://ftp.census.gov/Econ2001_And_Earlier/CBP_CSV/"

# Download Totals
urls       <- paste0(url, "zbp", years, "totals.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))
files      <- paste(data_source, basename(urls), sep = "/")
year       <- 1994:2001
zbptot9401 <- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
                     y = year, SIMPLIFY = F, USE.NAMES = T)

zbptot9401 <- bind_rows(zbptot9401)
# Values are in $1,000s
zbptot9401$qp1 <- 1000*zbptot9401$qp1
zbptot9401$ap  <- 1000*zbptot9401$ap

write_csv(zbptot9401, path = paste0(localDir, "/ZBPtotal94-01.csv"))
save(zbptot9401, file = paste0(localDir, "/ZBPtotal94-01.Rda"))
rm(zbptot9401)

# Download Industries
urls       <- paste0(url, "zbp", years, "detail.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))
files      <- paste(data_source, basename(urls), sep = "/")
year       <- 1994:2001
zbpind9401 <- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
                     y = year, SIMPLIFY = F, USE.NAMES = T)

zbpind9401 <- bind_rows(zbpind9401)
write_csv(zbpind9401, path = paste0(localDir, "/ZBPdetail94-01.csv"))
save(zbpind9401, file = paste0(localDir, "/ZBPdetail94-01.Rda"))
rm(zbpind9401)

# ---- ZBP Data from 2002 to 2013
years  <- as.character(2002:2013)
url    <- "ftp://ftp.census.gov/econ"

# Download Totals
urls       <- paste0(url, years, "/CBP_CSV/zbp", substr(years, 3, 4),
                     "totals.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))
files      <- paste(data_source, basename(urls), sep = "/")
year       <- 2002:2013
zbptot0213 <- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
                     y = year, SIMPLIFY = F, USE.NAMES = T)

zbptot0213 <- bind_rows(zbptot0213)
# Values are in $1,000s
zbptot0213$qp1 <- 1000*zbptot0213$qp1
zbptot0213$ap  <- 1000*zbptot0213$ap

write_csv(zbptot0213, path = paste0(localDir, "/ZBPtotal02-13.csv"))
save(zbptot0213, file = paste0(localDir, "/ZBPtotal02-13.Rda"))
rm(zbptot0213)

# Download Industries
urls       <- paste0(url, years, "/CBP_CSV/zbp", substr(years, 3, 4),
                     "detail.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))
files      <- paste(data_source, basename(urls), sep = "/")
year       <- 2002:2013
zbpind0213 <- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
                     y = year, SIMPLIFY = F, USE.NAMES = T)

zbpind0213 <- bind_rows(zbpind0213)
write_csv(zbpind0213, path = paste0(localDir, "/ZBPdetail02-13.csv"))
save(zbpind0213, file = paste0(localDir, "/ZBPdetail02-13.Rda"))

rm(list = ls())

print(paste0("Finished 0-ZBP at ", Sys.time()))