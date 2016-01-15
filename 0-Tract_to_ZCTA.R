# Robert Dinterman

# Census Tract to ZIP Codes:
# https://www.census.gov/geo/maps-data/data/zcta_rel_download.html

print(paste0("Started 0-Tract_to_ZCTA at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
# library(dplyr)
# library(readr)
# library(tidyr)

# Create a directory for the data
localDir <- "0-Data/Tract"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

url<-"http://www2.census.gov/geo/docs/maps-data/data/rel/zcta_tract_rel_10.txt"
files <- paste(data_source, basename(url), sep = "/")
if (!file.exists(files)) download.file(url, files, method = "libcurl")

zctatract <- read.csv(files)

url<-"http://www2.census.gov/geo/docs/maps-data/data/rel/trf_txt/us2010trf.txt"
files <- paste(data_source, basename(url), sep = "/")
if (!file.exists(files)) download.file(url, files, method = "libcurl")

zctatime <- read.csv(files, header = F)
names(zctatime) <- c("STATE00", "COUNTY00", "TRACT00", "GEOID00", "POP00",
                     "HU00", "PART00", "AREA00", "AREALAND00", "STATE10",
                     "COUNTY10", "TRACT10", "GEOID10", "POP10", "HU10",
                     "PART10", "AREA10", "AREALAND10", "AREAPT", "AREALANDPT",
                     "AREAPCT00PT", "ARELANDPCT00PT", "AREAPCT10PT",
                     "AREALANDPCT10PT", "POP10PT", "POPPCT00", "POPPCT10",
                     "HU10PT", "HUPCT00", "HUPCT10")

check <- zctatime$GEOID10 %in% zctatract$GEOID

load("0-Data/FCC/FCClong.Rda")
fccmain <- subset(FCC, time == "2008-06-30")

# What census tracts match up with my "main" FCC data
check1 <- fccmain$zip %in% zctatract$ZCTA5
sum(!check1) # Apparently missing 591 ZIPs, or about 2% of observations

# Word of caution: there are multiple tracts to a ZIP. Solution is to take the
# highest value of all tracts in said ZIP to be consistent with previous data.


fcctract  <- read.csv("0-Data/FCC/FCC_tract_08-13.csv")
subfcc <- subset(fcctract, year == "2008-12-01")

check <- zctatract$GEOID %in% subfcc$tract_fips

check <- subfcc$tract_fips %in% zctatract$GEOID
