# Robert Dinterman

print(paste0("Started 0-Shapefiles at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
# require(devtools)
# install_github("eblondel/cleangeo")
library(cleangeo)
library(maptools)
library(rgdal)

# Read in ZCTA Shapefiles -------------------------------------------------

localDir    <- "0-Data/Shapefiles"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# NEED TO FIGURE OUT WHERE TO HOST THESE ZIP FILES

unzip(paste0(localDir, "/zcta2004.zip"), exdir = data_source)
unzip(paste0(localDir, "/zctapoints2004.zip"), exdir = data_source)


zcta  <- readOGR(data_source, layer = "zcta2004")
zctap <- readOGR(data_source, layer = "zctapoints2004")

row.names(zcta)  <- as.character(zcta$ZIP)
zcta$POP2003     <- ifelse(zcta$POP2003 == -99, NA, zcta$POP2003)

zctap            <- zctap[!duplicated(zctap$ZIP), ]
row.names(zctap) <- as.character(zctap$ZIP)

# Clean-up Shapefile ------------------------------------------------------
# Used the following stackexchange for code:
# http://gis.stackexchange.com/questions/113964/fixing-orphaned-holes-in-r

# #get a report of geometry validity & issues for a sp spatial object
# sp            <- zcta
# report        <- clgeo_CollectionReport(sp)
# summary       <- clgeo_SummaryReport(report)
# issues        <- report[report$valid == FALSE,]
# #get suspicious features (indexes)
# nv            <- clgeo_SuspiciousFeatures(report)
# mysp          <- sp[nv,]
# #try to clean data
# mysp.clean    <- clgeo_Clean(mysp, print.log = TRUE)
# #check if they are still errors
# report.clean  <- clgeo_CollectionReport(mysp.clean)
# summary.clean <- clgeo_SummaryReport(report.clean)
# #Attempting a UnionSpatialPolygons based on the COUNTY field
# mysp.df       <- as(mysp, "data.frame")
# zipcol        <- mysp.df$ZIP
# mysp.diss     <- unionSpatialPolygons(mysp.clean, zipcol)

# zcta      <- clgeo_Clean(zcta, print.log = T)

zcta$ZIP  <- as.numeric(as.character(zcta$ZIP))
zctap$ZIP <- as.numeric(as.character(zctap$ZIP))

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
zcta      <- spTransform(zcta,CRS(aea.proj))
zctap     <- spTransform(zctap,CRS(aea.proj))

# Rename the area so that I know it is the zip code area
names(zcta)[5]  <- "AREA_zcta"
names(zctap)[5] <- "AREA_zctap"

save(zcta,  file = paste0(localDir, "/zcta2004.Rda"))
save(zctap, file = paste0(localDir, "/zctap2004.Rda"))


# State Map ---------------------------------------------------------------

tempDir     <- tempdir()

url  <- paste0("http://dds.cr.usgs.gov/pub/data/",
               "nationalatlas/countyp020_nt00009.tar.gz")
file <- paste(localDir, basename(url) ,sep = "/")
if (!file.exists(file)) download.file(url, file)
untar(file, exdir = tempDir)

# Raw File
all          <- readOGR(tempDir, "countyp020", p4s = "+proj=longlat")
all$FIPS     <- as.numeric(as.character(all$FIPS))
names(all)[8]<- "AREA_cty"

# Unmerged
usa          <- subset(all, FIPS < 57000)
usa          <- subset(usa, subset = !(STATE %in% c("AK", "HI")))
usa$remove   <- usa$FIPS - 1000*as.numeric(as.character(usa$STATE_FIPS))
usa          <- subset(usa, subset = remove != 0)

# Useful for States
state        <- unionSpatialPolygons(usa, usa$STATE)
state        <- SpatialPolygonsDataFrame(state,
                                         as.data.frame(row.names(state)),
                                         match.ID = F)

names(state)  <- "STATE"
state@data    <- data.frame(state@data,usa[match(state$STATE, usa$STATE), ])
state         <- state[order(state$STATE), ]
state         <- spTransform(state, CRS(aea.proj))

writeOGR(state, localDir, "state", "ESRI Shapefile", overwrite_layer = T)
save(state, file = paste0(localDir, "/state.Rda"))

# Useful for Counties
USA        <- unionSpatialPolygons(usa, usa$FIPS)
USA        <- SpatialPolygonsDataFrame(USA, as.data.frame(row.names(USA)),
                                       match.ID = F)
names(USA) <- "FIPS"
USA$FIPS   <- as.numeric(as.character(USA$FIPS))
USA@data   <- data.frame(USA@data,usa[match(USA$FIPS, usa$FIPS), ])
USA        <- USA[order(USA$FIPS), ]
USA        <- spTransform(USA, CRS(aea.proj))

writeOGR(USA, localDir, "Lower48_2010_county", "ESRI Shapefile",
         overwrite_layer = T)
save(USA, file = paste0(localDir, "/Lower48_2010_county.Rda"))


All        <- unionSpatialPolygons(all, all$FIPS)
All        <- SpatialPolygonsDataFrame(All, as.data.frame(row.names(All)),
                                       match.ID = F)
names(All) <- "FIPS"
All$FIPS   <- as.numeric(as.character(All$FIPS))
All@data   <- data.frame(All@data, all[match(All$FIPS, all$FIPS), ])
All        <- All[order(All$FIPS), ]
All        <- spTransform(All, CRS(aea.proj))

save(All, file = paste0(localDir, "/All_2010_county.Rda"))

rm(list = ls())

print(paste0("Finished 0-Shapefiles at ", Sys.time()))
