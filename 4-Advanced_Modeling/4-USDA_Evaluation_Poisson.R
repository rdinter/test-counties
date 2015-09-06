# Robert Dinterman
# http://glmm.wikidot.com/faq
# GLMMs via MASS::glmmPQL

print(paste0("Started 4-USDA_Evaluation_Poisson at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)

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
  group_by(zip, year, STATE, ruc03, ruc, SUMBLKPOP) %>%
  dplyr::select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
                logINC, ap_R, qp1_R, POV_ALL_P, roughness, slope, tri, AREA,
                loans, ploans, biploans1234, iloans, ipilot, icur, long, lat) %>%
  summarise_each(funs(mean)) -> pdata

# pdata <- pdata.frame(pdata, index = c("zip", "year"))


# Annual ------------------------------------------------------------------

pois1  <- glm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
                tri + ruc + as.numeric(year), family = poisson, data = pdata)
summary(pois1)

qpois1  <- glm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
                 tri + ruc + as.numeric(year),
               family = quasipoisson, data = pdata)
summary(qpois1)


# ---- Residuals ----------------------------------------------------------

library(ggplot2)
library(sp)
load("0-Data/Shapefiles/zcta2004.Rda")
load("0-Data/Shapefiles/state.Rda")
#project for county data
aea.proj  <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-102
+x_0=180 +y_0=50 +ellps=GRS80 +datum=NAD83 +units=m"
zcta  <- spTransform(zcta, CRS(aea.proj))
state <- spTransform(state, CRS(aea.proj))

## Need to merge the residuals to data ...
pdata$pois1r  <- residuals(pois1)
pdata$qpois1r <- residuals(qpois1)

d   <- dplyr::select(pdata, pois1r, qpois1r, year)
# dx  <- split(d$pois1r, d$year)
# dxx <- do.call(cbind, dx)
# kable(cor(dxx))

# ---- Spresid ------------------------------------------------------------

ggzcta     <- fortify(zcta)
ggzcta$zip <- as.numeric(ggzcta$id)
ggstate    <- fortify(state)

dplyr::select(pdata, zip, year, pois1r, qpois1r) %>%
  left_join(ggzcta) %>%
  arrange(order) -> pzcta

resid.plot <- ggplot(data = pzcta, aes(x = long, y = lat, group = group))

resid.plot + geom_polygon(aes(fill = pois1r)) + facet_wrap(~year) +
  geom_path(data = ggstate, colour = "black", lwd = 0.25) +
  scale_fill_gradient2() + labs(x = "", y = "", main = "Quasi-Poisson") +
  theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_blank(), panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(), panel.background = element_blank(),
        legend.position = c(0.7, 0), legend.justification = c(0, 0),
        legend.direction = "horizontal", legend.box.just = "bottom",
        legend.background = element_rect(fill = "transparent"))

library(gstat)
library(sp)
library(spacetime)

# STdata <- filter(pdata, STATE == "TX")
STdata <- pdata

STsp   <- SpatialPoints(cbind(unique(STdata$long), unique(STdata$lat)))
raster::projection(STsp) <- CRS("+init=epsg:4326")
STsp   <- spTransform(STsp,CRS("+init=epsg:3395"))

STtime <- as.Date(unique(as.character(STdata$year)), "%Y")

STst <- STFDF(STsp, STtime, data.frame(STdata))

STpool <- SpatialPointsDataFrame(cbind(STdata$long, STdata$lat),
                                 data.frame(STdata))
raster::projection(STpool) <- CRS("+init=epsg:4326")
STpool   <- spTransform(STpool,CRS("+init=epsg:3395"))

j6 <- list()
for (i in unique(STpool$year)){
  SThuh <- subset(STpool, year == i)
  j5    <- variogram(qpois1r ~ 1, SThuh, cutoff = 50000)
  
  j6[[paste(i)]] <- list(j5)
  
  print(plot(j5, main = paste(i), ylim = c(0, 1)))
}

system.time(
  j6 <- variogram(qpois1r ~ 1, SThuh, cutoff = 50000)
)

plot(j6)

# http://r-video-tutorial.blogspot.com/2015/08/spatio-temporal-kriging-in-r.html

system.time(
  j5 <- variogramST(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC +
                      tri + ruc + factor(year), STst, assumeRegular = T,
                    cutoff = 50000)
)

# ---- Spatial ------------------------------------------------------------
# http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0082142

# This was done by using the functions “corSpatial” and “glmmPQL” available in
#  the packages “nlme” and “MASS” in R, respectively. The so-called penalized
#  quasi-likelihood (PQL) allow for fitting the variance-covariance-matrix to
#  the data, thus resulting in a spatial GLMM. 

# library(MASS)
# library(nlme)
# pdata$rprov <- round(pdata$Prov_num)
# sppois <- glmmPQL(rprov ~ iloans + est + Pop_IRS + logINC +
#                     tri + ruc,# + factor(year),
#                   fixed = ~ 1 | factor(year),
#                   family = poisson, data = filter(pdata, STATE == "MN"),
#                   correlation = corSpatial(form = ~ long + lat | factor(year),
#                                            type = "exponential",
#                                            metric = "euclidean"))