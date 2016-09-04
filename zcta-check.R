# Robert Dinterman
# Check to see the overlap in ZCTAs to Counties.

load("0-Data/Shapefiles/zcta2004.Rda")

zcta <- subset(zcta, !(STATE %in% c("AK", "HI")))

# Clean-up Shapefile ------------------------------------------------------
# Used the following stackexchange for code:
# http://gis.stackexchange.com/questions/113964/fixing-orphaned-holes-in-r
library(cleangeo)

# #get a report of geometry validity & issues for a sp spatial object
# sp            <- zcta
# report        <- clgeo_CollectionReport(sp)
# summary       <- clgeo_SummaryReport(report)
# issues        <- report[report$valid == FALSE,]
# 
# #get suspicious features (indexes)
# nv            <- clgeo_SuspiciousFeatures(report)
# mysp          <- sp[nv,]
# 
# #try to clean data
# mysp.clean    <- clgeo_Clean(mysp)
# 
# #check if they are still errors
# report.clean  <- clgeo_CollectionReport(mysp.clean)
# summary.clean <- clgeo_SummaryReport(report.clean)
# 
# #Attempting a UnionSpatialPolygons based on the COUNTY field
# mysp.df       <- as(mysp, "data.frame")
# zipcol        <- mysp.df$ZIP
# mysp.diss     <- unionSpatialPolygons(mysp.clean, zipcol)

zcta      <- clgeo_Clean(zcta)


load("0-Data/Shapefiles/Lower48_2010_county.Rda")

library(rgeos)

overlap <- gIntersects(zcta, USA, byid = T)

zcta_laps <- colSums(overlap)
fips_zips <- rowSums(overlap)

table(zcta_laps)
table(fips_zips)

zcta$overlaps <- zcta_laps
zcta_s <- subset(zcta, overlaps > 1)
