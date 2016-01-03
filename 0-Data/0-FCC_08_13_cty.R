# Robert Dinterman

# Read in FCC Zip code files from 2008 to 2013

print(paste0("Started 0-FCC_08_13_cty at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(tidyr)

# Create a directory for the data
localDir <- "0-Data/FCC"
data_source <- paste0(localDir, "/Raw/County")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

url   <- "http://www.fcc.gov/Bureaus/Common_Carrier/Reports/FCC-State_Link/IAD/"
files <- c("csv_dec_2008_county.zip", "csv_countydata_june_2009.zip",
           "csv_countydata_dec_2009.zip", "csv_countydata_june_2010.zip",
           "csv_countydata_dec_2010.zip", "csv_countydata_june_2011.zip",
           "csv_countydata_dec_2011.zip", "csv_countydata_june_2012.zip",
           "csv_countydata_dec_2012.zip", "csv_countydata_june_2013.zip",
           "csv_countydata_dec_2013.zip")
urls  <- paste0(url, files)
files <- paste(data_source, files, sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

# Add in the 2010 to 2014: http://www2.ntia.doc.gov/broadband-data

tempDir  <- tempdir()
lapply(files, function(x) unzip(x, exdir = tempDir))
files <- list.files(tempDir, pattern = "*.csv")

data  <- data.frame()
for (i in files) {
  file     <- paste(tempDir, i, sep = "/")
  inp      <- read_csv(file)
  tmp      <- substr(i, nchar(i) - 11, nchar(i) - 4)
  inp$year <- as.Date(paste0(1, tmp), format = "%d%b_%Y")
  cname    <- name <- sub(".csv", "", i)
  
  cat("Read:", i, "\trows: ", nrow(inp), " cols: ", ncol(inp), 
      "\n")
  
  data <- bind_rows(data, inp)
  rm(inp)
}
# The 2008 names have a different name.
# apply(data, 2, function(x) sum(is.na(x)))

miss <- is.na(data$rfc_per_1000_hhs)
data$rfc_per_1000_hhs[miss] <- data$rfhsc_per_1000_hhs[miss]

miss <- is.na(data$rfc_per_1000_hhs_btop)
data$rfc_per_1000_hhs_btop[miss] <- data$rfhsc_per_1000_hhs_btop[miss]

data$rfhsc_per_1000_hhs <- data$rfhsc_per_1000_hhs_btop <- NULL

write_csv(data, paste0(localDir, "/FCC_cty_08-13.csv"))

rm(list = ls())

print(paste0("Finished 0-FCC_08_13_cty at ", Sys.time()))

#http://www2.ntia.doc.gov/broadband-data