# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_CARBayesST at ", Sys.time()))

# ---- Start --------------------------------------------------------------

# library(dplyr)
# library(gstat)
# library(sp)
# library(spacetime)

# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
# load("0-Data/Shapefiles/contigWzcta.Rda")
# load("0-Data/Shapefiles/contigW-MN.Rda")
load("0-Data/Shapefiles/contigW-NC.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)

# nonlink <- c(33040, 96763, 00085, 99546, 99547, 99638, 99591, 99660, 99630,
#              99553, 99583, 99661, 99747, 99615, 00195, 99901, 99926, 98110,
#              98303, 98070, 98333, 98040, 98250, 98261, 98281, 98262, 56711,
#              56741, 54850, 94130, 94501, 00057, 00061, 90704, 78597, 77982,
#              00116, 00120, 00119, 00121, 00122, 36528, 31327, 31527, 29451,
#              29482, 33924, 33957, 34217, 34228, 34242, 33706, 33715, 33149,
#              33109, 33042, 33043, 33050, 48138, 43438, 43436, 43456, 14072,
#              15225, 28465, 28480, 28520, 20625, 21634, 21824, 21866, 23066,
#              23440, 08226, 08260, 27960, 13640, 05440, 05463, 05474, 08008,
#              08203, 10044, 06390, 02807, 02835, 02872, 02713, 00159, 00157,
#              03854, 04013, 04017, 04019, 04050, 04108, 04109, 04549, 04576,
#              04848, 04570, 04852, 04625, 04635, 04645, 04646, 04685, 04851,
#              04853, 04863, 04611, 00158, 02554, 54246, 49757, 49775, 49782,
#              49726, 03589, 04462, 04737, 04741, 23336, 85341)
# data <- subset(data, !(ZIP %in% nonlink))
# STdata <- subset(data, STATE == "MN" & !(zip %in% c(56711,56741)))
STdata <- subset(data, STATE == "NC" &
                   !(zip %in% c(27960, 28465, 28480, 28520)))


library(CARBayesST)
set.seed(324)
model1 <- ST.CARar(Prov_num ~ log(est) + log(Pop_IRS) + logAPay_R2 + tri +
                     ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
                     I(est / AREA_zcta),
                   family = "poisson", data = STdata, W = weights,
                   burnin = 1000, n.sample = 5000)
model2 <- ST.CARlinear(Prov_num ~ log(est) + log(Pop_IRS) + logAPay_R2 + tri +
                     ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
                     I(est / AREA_zcta),
                   family = "poisson", data = STdata, W = weights,
                   burnin = 1000, n.sample = 5000)
model2
# Setting up the model
# Collecting 100 samples
# |=====================================================================| 100%
# Summarising results
# finished in  49722.7 seconds

save(model1, file = paste0(localDir, "/CARBayesNC.Rda"))


# STsp   <- SpatialPoints(cbind(unique(STdata$long), unique(STdata$lat)))
# raster::projection(STsp) <- CRS("+init=epsg:4326")
# STsp   <- spTransform(STsp,CRS("+init=epsg:3395"))
# 
# STtime <- as.Date(unique(as.character(STdata$year)), "%Y")
# 
# STst   <- STFDF(STsp, STtime, data.frame(STdata))
# 
# STpool <- SpatialPointsDataFrame(cbind(STdata$long, STdata$lat),
#                                  data.frame(STdata))
# raster::projection(STpool) <- CRS("+init=epsg:4326")
# STpool <- spTransform(STpool,CRS("+init=epsg:3395"))
