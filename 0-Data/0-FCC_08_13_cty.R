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

# https://www.fcc.gov/general/form-477-county-data-internet-access-services
# https://www.fcc.gov/sites/default/files/county_map_dec2014.zip
url   <- "http://www.fcc.gov/Bureaus/Common_Carrier/Reports/FCC-State_Link/IAD/"
files <- c("csv_dec_2008_county.zip", "csv_countydata_june_2009.zip",
           "csv_countydata_dec_2009.zip", "csv_countydata_june_2010.zip",
           "csv_countydata_dec_2010.zip", "csv_countydata_june_2011.zip",
           "csv_countydata_dec_2011.zip", "csv_countydata_june_2012.zip",
           "csv_countydata_dec_2012.zip", "csv_countydata_june_2013.zip",
           "csv_countydata_dec_2013.zip", "county_map_dec2014.zip")
urls  <- paste0(url, files)
files <- paste(data_source, files, sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

tempDir  <- tempdir()
lapply(files, function(x) unzip(x, exdir = tempDir))
files    <- list.files(tempDir, pattern = "*.csv", full.names = T)

fcc_sapply <- sapply(files, function(x){
  inp      <- read_csv(x)
  tmp      <- substr(x, nchar(x) - 11, nchar(x) - 4)
  inp$date <- as.Date(paste0(1, tmp), format = "%d%b_%Y")
  cname    <- name <- sub(".csv", "", x)
  return(inp)
  })
fcc <- bind_rows(fcc_sapply)

fcc <- fcc %>% 
  mutate(rfc_per_1000_hhs = coalesce(rfc_per_1000_hhs, rfhsc_per_1000_hhs),
         rfc_per_1000_hhs_btop = coalesce(rfc_per_1000_hhs_btop, 
                                          rfhsc_per_1000_hhs_btop)) %>% 
  select(-rfhsc_per_1000_hhs, -rfhsc_per_1000_hhs_btop)

saveRDS(fcc, paste0(localDir, "/FCC_cty_08-13.rds"))
write_csv(fcc, paste0(localDir, "/FCC_cty_08-13.csv"))

rm(list = ls())

print(paste0("Finished 0-FCC_08_13_cty at ", Sys.time()))
