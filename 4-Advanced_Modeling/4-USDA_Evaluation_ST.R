# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_ST at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)
library(gstat)
library(sp)
library(spacetime)

# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")

data$HHINC_IRS_R   <- data$AGI_IRS_R*1000 / data$HH_IRS
data$HHWAGE_IRS_R  <- data$Wages_IRS_R*1000 / data$HH_IRS
data$logINC <- ifelse(data$HHINC_IRS_R < 1, 0, log(data$HHINC_IRS_R))
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)
data$ruc    <- factor(data$ruc03)
levels(data$ruc) <- list("metro" = 1:3, "adj" = c(4,6,8),
                         "nonadj" = c(5,7,9))

data %>%
  group_by(zip, year, STATE, ruc03, ruc, SUMBLKPOP, long, lat) %>%
  dplyr::select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
                logINC, ap_R, qp1_R, POV_ALL_P, roughness, slope, tri, AREA,
                loans, ploans, biploans1234, iloans, ipilot, icur) %>%
  summarise_each(funs(mean)) -> pdata

sdata <- STFDF(SpatialPoints(cbind(unique(pdata$long), unique(pdata$lat))),
               as.Date(unique(as.character(pdata$year)), "%Y"),
               data.frame(pdata))
# variogramST(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
#               tri + ruc + factor(year), sdata)