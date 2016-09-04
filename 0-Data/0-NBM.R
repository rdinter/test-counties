# Robert Dinterman

# Read in FCC Zip code files from 2008 to 2013

print(paste0("Started 0-NBM at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(tidyr)

# Create a directory for the data
localDir <- "0-Data/NBM"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# National Broadband Map from 2010 to 2014:
# http://www2.ntia.doc.gov/broadband-data

url   <- "http://www2.ntia.doc.gov/files/broadband-data/"
files <- c("SBDD-USA-Fall2010.zip", "All-NBM-CSV-December-2010.zip",
           "All-NBM-CSV-June-2011.zip", "All-NBM-CSV-December-2011.zip",
           "All-NBM-CSV-June-2012.zip", "All-NBM-CSV-December-2012.zip",
           "All-NBM-CSV-June-2013.zip", "All-NBM-CSV-December-2013.zip",
           "All-NBM-CSV-June-2014.zip")
urls  <- paste0(url, files)
files <- paste(data_source, files, sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

temp_dir <- tempdir()
# unlink(temp_dir, recursive = T)

# These generally have _another_ .zip file within them
# lapply(files, function(x) unzip(x, exdir = temp_dir))
# files    <- list.files(temp_dir, pattern = "*.csv", full.names = T)

names(j5) <- tolower(names(j5))
j6 <- j5 %>% 
  mutate(fips = substr(fullfipsid, 1, 5)) %>% 
  mutate_each(funs(factor), transtech:uploadspeed)

levels(j6$transtech) <- c("10" =	"Asymmetric xDSL",
                          "20" = "Symmetric xDSL",
                          "30" = "Other Copper Wire",
                          "40" = "Cable Modem - DOCSIS 3.0 Down",
                          "41" = "Cable Model - Other",
                          "50" = "Optical Carrier/Fiber to the End User",
                          "60" = "Satellite",
                          "70" = "Terrestrial Fixed - Unlicensed",
                          "71" = "Terrestrial Fixed - Licensed",
                          "80" = "Terrestrial Mobile Wireless",
                          "90" = "Electric Power Line",
                          "0"  = "All Other" )
levels(j6$maxaddown) <- levels(j6$maxadup) <- levels(j6$typicdown) <-
  levels(j6$typicup) <- levels(j6$downloadspeed) <- levels(j6$uploadspeed) <-
  c("0"  = "No data",
    "1"  = "Less than 200 kbps",
    "2"  = "Greater than 200 kbps and less than 768 kbps",
    "3"  = "Greater than 768 kbps and less than 1.5 mbps",
    "4"  = "Greater than 1.5 mbps and less than 3 mbps",
    "5"  = "Greater than 3 mbps and less than 6 mbps",
    "6"  = "Greater than 6 mbps and less than 10 mbps",
    "7"  = "Greater than 10 mbps and less than 25 mbps",
    "8"  = "Greater than 25 mbps and less than 50 mbps",
    "9"  = "Greater than 50 mbps and less than 100 mbps",
    "10" = "Greater than 100 mbps and less than 1 gbps",
    "11" = "Greater than 1 gbps")

# ###########Provider Type###########
# 
# Code	Description
# 
# 1	Broadband provider as described in the NOFA
# 
# 2	Reseller
# 
# 3	Other
# 
# 
# 
# ###########EndUserCategory###########
# 
# Code	Description
# 
# 1	Residential
# 
# 2	Government
# 
# 3	Small Business
# 
# 4	Medium or Large Enterprise
# 
# 5	Other
# 
# 
# 
# ###########Spectrum###########
# 
# Code	Description
# 
# 9	Unknown.  Did not provide
# 
# 1	Cellular spectrum (824-849 MHz; 869-894) used to provide service
# 
# 2	700 MHz spectrum (698-758 MHz; 775-788 MHz; 775-788 MHz) used to provide service
# 
# 3	Broadband Personal Communications Services spectrum (1850-1915 MHz; 1930-1995) used to provide service
# 
# 4	Advanced Wireless Services spectrum (1710-1755 MHz; 2100-2155) used to provide service
# 
# 5	Broadband Radio Service/Educational Broadband Service spectrum (2496-2690 MHz) used to provide service
# 
# 6	is Unlicensed (including broadcast television "white spaces" ) spectrum Used to provide service
# 
# 7	Specialized Mobile Radio Service (SMR) (817-824 MHz; 862-869 MHz; 896-901 MHz; 935-940 MHz)
# 
# 8	Wireless Communications Service (WCS) spectrum (2305-2320 MHz; 2345-2360 MHz), 3650-3700 MHz
# 
# 9	Satellite (L-band, Big LEO, Little LEO, 2 GHz)1is Cellular spectrum (824-849 MHz; 869-894) used to provide service
# 10	Other licensed spectrum



# ###########CAICAT###########
# 
# 
# 
# Code	Description
# 
# 1 	School - K through 12
# 
# 2 	Library
# 
# 3 	Medical/healthcare
# 
# 4 	Public safety
# 
# 5 	University, college, other post-secondary
# 
# 6 	Other community support - government
# 
# 7 	Other community support - nongovernmental
saveRDS(nbm, paste0(localDir, "/NBM.rds"))
# write_csv(nbm, paste0(localDir, "/NBM.csv"))

rm(list = ls())

print(paste0("Finished 0-NBM at ", Sys.time()))
