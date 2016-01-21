#Robert Dinterman, NCSU Economics PhD Student

# Downloading Quarterly Census of Employment and Wages Program
# ReadMe: http://www.bls.gov/cew/doc/layouts/enb_end_layout.htm

# http://www.bls.gov/cew/datatoc.htm
print(paste0("Started 0-QCEW at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
# library(reshape2)
library(dplyr)
library(readr)
source("0-Data/0-functions.R")

####################################################################################
# Create a directory for the data
localDir <- "0-Data/QCEW"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

tempDir  <- tempdir()
# unlink(tempDir, recursive = T)

##### QCEW Data
years  <- 1990:2013
url    <- "http://www.bls.gov/cew/data/files/"
urls   <- paste0(url, years, "/enb/", years, "_all_enb.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))

files  <- paste(data_source, basename(urls), sep = "/")

delims <- read.csv("http://www.bls.gov/cew/doc/layouts/enb_layout.csv")
starts <- delims$start_position
ends   <- delims$end_position
# tempDirr <- paste0(tempDir, "/temp")
fixed    <- c(3,5,1,1,1,6,4,2,
              1,8,9,9,9,15,15,13,8,
              1,8,9,9,9,15,15,13,8,
              1,8,9,9,9,15,15,13,8,
              1,8,9,9,9,15,15,13,8,
              1,8,9,15,15,13,8,9)
coltypes <- "cicicciiciiiiiiiiciiiiiiiiciiiiiiiiciiiiiiiiciiiiiii"
naics    <- c("10", "11", "21", "22", "23", "31-33", "42", "44-45",
              "48-49", "51",  "52", "53", "54", "55", "56", "61",
              "62", "71", "72", "81", "92")
data     <- data.frame()
data2    <- data.frame()

for (i in files){
  unzip(i, exdir = tempDir)
  j5      <- list.files(paste0(tempDir, "/county/"), pattern = "*.enb",
                        ignore.case = T)
  j5      <- j5[-c(grep("vi", j5, ignore.case = T), #removes Virgin Islands
                   grep("pr", j5, ignore.case = T))] #removes Puerto Rico
  for (j in j5){
    j6 <- tryCatch(read_fwf(paste0(tempDir, "/county/", j), fwf_widths(fixed),
                            #                             fwf_positions(starts, ends)),
                            col_types = coltypes, progress = F),
                   error = function(e){
                     read.fwf(paste0(tempDir, "/county/", j), fixed)
                   })
    j7 <- read_delim(paste0(tempDir, "/county/", j), delim = "/r", col_names = F)
    data  <- rbind_all(data, subset(j6, X4==0 & (X5==0 | X5==5) & X6 %in% naics))
    data2 <- rbind_all(data2, j7)
    rm(j6)
  }
  unlink(tempDir, recursive = T)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
}
names <- c("survey", "FIPS", "datatype", "sizecode", "ownership", "NAICS",
           "year", "aggregation", "status1", "establishments1", "employ11",
           "employ21", "employ31", "wages1", "taxwage1", "contr1", "avgwage1",
           "status2", "establishments2", "employ12", "employ22", "employ32",
           "wages2", "taxwage2", "contr2", "avgwage2", "status3",
           "establishments3", "employ13", "employ23", "employ33", "wages3",
           "taxwage3", "contr3", "avgwage3", "status4", "establishments4",
           "employ14", "employ24", "employ34", "wages4", "taxwage4", "contr4",
           "avgwage4", "statusA", "establishmentsA", "employA", "wagesA",
           "taxwageA", "contrA", "avgwageA", "avgpayA")
names(data) = names

# cbp8601<- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
#                  y = years, SIMPLIFY = F, USE.NAMES = T)
# 
# files  <- matrix(NA, nrow = length(years))
# for (i in years){
#   temp <- paste0(url, i, "/enb/", i, "_all_enb.zip")
#   file <- paste(tempDir, basename(temp), sep = "/")
#   files[i - years[1] + 1,] <- file
#   if (!file.exists(file)) download.file(temp, file)
# }

tempDirr <- paste0(tempDir, "/temp")
fixed    <- c(3,5,1,1,1,6,4,2,
              1,8,9,9,9,15,15,13,8,
              1,8,9,9,9,15,15,13,8,
              1,8,9,9,9,15,15,13,8,
              1,8,9,9,9,15,15,13,8,
              1,8,9,15,15,13,8,9)
naics    <- c("10    ", "11    ", "21    ", "22    ", "23    ", "31-33 ",
              "42    ", "44-45 ", "48-49 ", "51    ", "52    ", "53    ",
              "54    ", "55    ", "56    ", "61    ", "62    ", "71    ",
              "72    ", "81    ", "92    ")
data     <- data.frame()

for (i in files){
  if (!file.exists(tempDirr)) dir.create(tempDirr)
  unzip(i,exdir=tempDirr)
  j5      <- list.files(paste0(tempDirr, "/county/"))[1:51]
  for (j in j5){
    j6    <- read.fwf(paste0(tempDirr, "/county/", j), widths = fixed)
    j6$V6 <- as.character(j6$V6)
    data  <- rbind_all(data, subset(j6, V4==0 & (V5==0 | V5==5) & V6 %in% naics))  
  }
  unlink(tempDirr, recursive = T)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
}
names <- c("survey", "FIPS", "datatype", "sizecode", "ownership", "NAICS",
           "year", "aggregation", "status1", "establishments1", "employ11",
           "employ21", "employ31", "wages1", "taxwage1", "contr1", "avgwage1",
           "status2", "establishments2", "employ12", "employ22", "employ32",
           "wages2", "taxwage2", "contr2", "avgwage2", "status3",
           "establishments3", "employ13", "employ23", "employ33", "wages3",
           "taxwage3", "contr3", "avgwage3", "status4", "establishments4",
           "employ14", "employ24", "employ34", "wages4", "taxwage4", "contr4",
           "avgwage4", "statusA", "establishmentsA", "employA", "wagesA",
           "taxwageA", "contrA", "avgwageA", "avgpayA")
names(data) <- names

### Change FIPS with 999 at end to 000
data$fips <- as.character(data$FIPS)
place     <- substr(data$fips, nchar(data$fips) - 2, nchar(data$fips)) == "999"
data$FIPS[place] = data$FIPS[place] - 999


write_csv(data, paste0(localDir, "/QCEW.csv"))
save(data, file = paste0(localDir, "/QCEW.Rda"))

#Annual Data
annual <- select(data, year, FIPS, NAICS, ownership, establishmentsA, employA,
                 wagesA, taxwageA, contrA, avgwageA, avgpayA)
write_csv(annual, paste0(localDir, "/QCEWAnnual.csv"))
save(annual, file = paste0(localDir, "/QCEWAnnual.Rda"))

#Quarterly Data
data1 <- select(data, year, FIPS, NAICS, ownership, establishments1, employ11,
                employ21, employ31, wages1, taxwage1, contr1, avgwage1)
data1$quarter <- 1

data2 <- select(data, year, FIPS, NAICS, ownership, establishments2, employ12,
                employ22, employ32, wages2, taxwage2, contr2, avgwage2)
data2$quarter <- 2

data3 <- select(data, year, FIPS, NAICS, ownership, establishments3, employ13,
                employ23, employ33, wages3, taxwage3, contr3, avgwage3)
data3$quarter <- 3

data4 <- select(data, year, FIPS, NAICS, ownership, establishments4, employ14,
                employ24, employ34, wages4, taxwage4, contr4, avgwage4)
data4$quarter <- 4

names <- c("year", "FIPS", "NAICS", "ownership", "establishments", "employ1",
           "employ2", "employ3", "wages", "taxwage", "contr", "avgwage",
           "quarter")
names(data1)  <- names
names(data2)  <- names
names(data3)  <- names
names(data4)  <- names
quarterly     <- bind_rows(data1, data2, data3, data4)
rm(data1, data2, data3, data4)

write_csv(quarterly, paste0(localDir, "/QCEWquarter.csv"))
save(quarterly, file = paste0(localDir, "/QCEWquarter.Rda"))

zip(paste0(localDir, "/QCEW.zip"), 
    files = c(paste0(localDir, "/QCEW.csv"),
              paste0(localDir, "/QCEWAnnual.csv"),
              paste0(localDir, "/QCEWquarter.csv")))

rm(list = ls())

print(paste0("Finished 0-QCEW at ", Sys.time()))