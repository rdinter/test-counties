#Robert Dinterman

# Terrain, this will take a substantial amount of time.

print(paste0("Started 0-Terrain at ", Sys.time()))

library(raster)
library(readr)
library(rgdal)

# Create a directory for the data
localDir   <- "0-Data/Terrain"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# Zip Code Elevation
load("0-Data/Shapefiles/zcta2004.Rda")

## Get elevation data
elevation <- getData("alt", country = "USA", path = data_source)
# elevation is a list of different rasters, only use the first one because the
#  contiguous US is first and the rest are AK, islands, HI

x <- terrain(elevation[[1]], c("slope", "aspect", "TPI", "TRI", "roughness"))
plot(x)
cellStats(x, mean)

terraind       <- extract(x, zcta, fun = mean, na.rm = T, weights = T, df = T)
terraind$ID    <- getSpPPolygonsIDSlots(zcta)
terraind$zip   <- as.numeric(terraind$ID)

write_csv(terraind, paste0(localDir, "/terrainzip.csv"))
save(terraind, file = paste0(localDir, "/terrainzip.Rda"))

load("0-Data/Shapefiles/Lower48_2010_county.Rda")

terraind       <- extract(x, USA, fun = mean, na.rm = T, weights = T, df = T)
terraind$ID    <- getSpPPolygonsIDSlots(USA)
terraind$zip   <- as.numeric(terraind$ID)

write_csv(terraind, paste0(localDir, "/terrain.csv"))
save(terraind, file = paste0(localDir, "/terrain.Rda"))


rm(list = ls())

print(paste0("Finished 0-Terrain at ", Sys.time()))