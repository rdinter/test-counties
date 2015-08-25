# Robert Dinterman

# Zip Code Cross, this will take a substantial amount of time.

print(paste0("Started 0-Zip_Code_Cross at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(sp))

# Create a directory for the data
localDir   <- "0-Data/Zip_Code_Cross"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)


url <- paste0("http://mcdc.missouri.edu/data/",
              "corrlst/Zip_to_ZCTA_crosswalk_2010_JSI.csv")
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file)
zipcross <- read_csv(file, col_types = "iccci", skip = 1,
                     col_names = c("ZIP", "ZIPType", "CityName",
                                   "StateAbbr", "ZCTA_USE"))
zipcross <- filter(zipcross, !is.na(ZCTA_USE))

write_csv(zipcross, paste0(localDir, "/zipcross2010.csv"))
save(zipcross, file = paste0(localDir, "/zipcross2010.Rda"))

# http://www.census.gov/geo/maps-data/data/gazetteer2000.html
url <-  paste0("http://www2.census.gov/geo/docs/",
               "maps-data/data/gazetteer/zcta5.zip")
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file)
unzip(file, exdir = data_source)

pos <- fwf_positions(c(1, 3, 67, 76, 85, 99, 113, 125, 137, 147),
                     c(2, 66, 75, 84, 98, 112, 124, 136, 146, 157),
                     c("ST", "ZCTA", "POP", "HH", "LandArea",
                       "WaterArea", "LandArea2", "WaterArea2",
                       "LAT", "LONG"))
zcta2000 <- read_fwf(paste0(data_source, "/zcta5.txt"), pos)

# There are XX and HH which refer to national parks and water
zcta2000$ZCTA <- gsub("5-Digit ZCTA", "", zcta2000$ZCTA)
zcta2000$ZCTA <- gsub("part", "", zcta2000$ZCTA) #inidcates need to aggregate
zcta2000$ZCTA <- gsub("[[:punct:]]", "", zcta2000$ZCTA)
zcta2000$ZCTA <- as.numeric(zcta2000$ZCTA)
zcta2000 <- zcta2000 %>% group_by(ZCTA) %>%
  summarise(POP = sum(POP, na.rm = T), HH = sum(HH, na.rm = T),
            LandArea = sum(LandArea, na.rm = T),
            WaterArea = sum(WaterArea, na.rm = T),
            LandArea2 = sum(LandArea2, na.rm = T),
            WaterArea2 = sum(WaterArea2, na.rm = T),
            LAT = mean(LAT, na.rm = T), LONG = mean(LONG, na.rm = T))

write_csv(zcta2000, paste0(localDir, "/zcta2000.csv"))
save(zcta2000, file = paste0(localDir, "/zcta2000.Rda"))

zctap2000 <- as.data.frame(zcta2000)
coordinates(zctap2000) <- zctap2000[, c("LONG", "LAT")]
proj4string(zctap2000) <- "+proj=longlat"
aea.proj  <- "+proj=longlat"

# aea.proj  <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-100
#               +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m"
#  http://www.remotesensing.org/geotiff/proj_list/albers_equal_area_conic.html
#  +proj=aea   +lat_1=Latitude of first standard parallel
#              +lat_2=Latitude of second standard parallel
#              +lat_0=Latitude of false origin 
#              +lon_0=Longitude of false origin
#              +x_0=Easting of false origin
#              +y_0=Northing of false origin
zctap2000 <- spTransform(zctap2000,CRS(aea.proj))

zctap2000 <- zctap2000[!is.na(zctap2000$ZCTA),]

row.names(zctap2000) <- as.character(zctap2000$ZCTA)


save(zctap2000, file = paste0(localDir, "/zctap2000.Rda"))

rm(list=ls())

print(paste0("Finished 0-Zip_Code_Cross at ", Sys.time()))
