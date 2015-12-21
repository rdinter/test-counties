# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_Poisson at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)
library(gstat)
library(sp)
library(spacetime)

# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

sink(paste0(localDir, "/4-USDA_Evaluation_Poisson.txt"))

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)
# data %>%
#   group_by(zip, year, STATE, ruc03, ruc, SUMBLKPOP) %>%
#   dplyr::select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
#                 logAPay_R2, ap_R, qp1_R, POV_ALL_P, roughness, slope, tri, AREA,
#                 Prov_alt, loans, ploans, biploans1234, iloans, ipilot, icur,
#                 long, lat) %>%
#   summarise_each(funs(mean)) -> pdata

# pdata <- pdata.frame(pdata, index = c("zip", "year"))

# ---- Biannual -----------------------------------------------------------

pois <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri + ruc +
              poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
            family = poisson, data = data)
summary(pois)

poist <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri + ruc +
               poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data)
summary(poist)

# F Test
anova(pois, poist, test = "Chisq")
# rm(pois)

# ---- Quasi --------------------------------------------------------------

qpois <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri + ruc +
               poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = quasipoisson, data = data)
summary(qpois)

# ---- Negative Binomial --------------------------------------------------
library(MASS)
negb <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri + ruc +
              poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
              factor(time), family = negative.binomial(theta = 1), data = data)
summary(negb)
# negb2 <- glm.nb(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri + ruc +
#               poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
#               factor(time), data = data)
# summary(negb2)

# ----
library(stargazer)
stargazer(poist, qpois, negb,
          title = "Poisson Regressions",
          out = paste0(localDir, "/Poisson.tex"))
# ----
png(paste0(localDir, "/QQpois.png"))
qqnorm(residuals(poist, type="deviance"),
       main = "Poisson with Time Fixed Effects Q-Q Plot")
qqline(residuals(poist, type="deviance"), col = 2, lwd = 2, lty = 2)
dev.off()

# ---- RUC and Loan -------------------------------------------------------

library(car)
pois1 <- glm(Prov_num ~ iloans + ruc:iloans + log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data)
summary(pois1)

sum(coef(pois1)[c("iloans", "rucadj", "iloans:rucadj")])
linearHypothesis(pois1, "1*iloans + 1*rucadj + 1*iloans:rucadj = 0")

sum(coef(pois1)[c("iloans", "rucnonadj", "iloans:rucnonadj")])
linearHypothesis(pois1, "1*iloans + 1*rucnonadj + 1*iloans:rucnonadj = 0")

pois2 <- glm(Prov_num ~ ipilot + icur + log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data)
summary(pois2)

pois3 <- glm(Prov_num ~ ipilot + icur + ruc:ipilot + ruc:icur +
               log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data)
summary(pois3)

sum(coef(pois3)[c("ipilot", "rucadj", "ipilot:rucadj")])
linearHypothesis(pois3, "1*ipilot + 1*rucadj + 1*ipilot:rucadj = 0")

sum(coef(pois3)[c("ipilot", "rucnonadj", "ipilot:rucnonadj")])
linearHypothesis(pois3, "1*ipilot + 1*rucnonadj + 1*ipilot:rucnonadj = 0")

sum(coef(pois3)[c("icur", "rucadj", "icur:rucadj")])
linearHypothesis(pois3, "1*icur + 1*rucadj + 1*icur:rucadj = 0")

sum(coef(pois3)[c("icur", "rucnonadj", "icur:rucnonadj")])
linearHypothesis(pois3, "1*icur + 1*rucnonadj + 1*icur:rucnonadj = 0")

stargazer(poist, pois1, pois2, pois3,
          title = "Poisson Auxiliary Regressions",
          out = paste0(localDir, "/Poisson_Aux.tex"))

sink()

# ---- Marginal Effects ...
mean(poist$coefficients["iloans"]*poist$fitted.values) # First model

mean(sum(coef(pois1)[c("iloans", "rucadj", "iloans:rucadj")])*
       pois1$fitted.values) # Second Model Rural Adjacent

mean(sum(coef(pois1)[c("iloans", "rucnonadj", "iloans:rucnonadj")])*
       pois1$fitted.values) # Second Model Rural Non-Adjacent

mean(coef(pois2)["ipilot"]*pois2$fitted.values) # Pilot model

mean(coef(pois3)["ipilot"]*pois3$fitted.values) # Pilot Metro

mean(sum(coef(pois3)[c("icur", "rucadj", "icur:rucadj")])*
       pois3$fitted.values) # Farm Bill Rural Adjacent

mean(sum(coef(pois3)[c("icur", "rucnonadj", "icur:rucnonadj")])*
       pois3$fitted.values) # Farm Bill Rural Non-Adjacent


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
data$poistr <- residuals(poist)
# data$qpoisr <- residuals(qpois)
# data$negbr  <- residuals(negb)

d   <- dplyr::select(data, poistr, year, zip) %>%
  group_by(year, zip) %>% 
  summarise_each(funs(mean))
dx  <- split(d$poistr, d$year)
dxx <- do.call(cbind, dx)
knitr::kable(cor(dxx), digits = 3)

# ---- Spresid ------------------------------------------------------------

ggzcta     <- fortify(zcta)
ggzcta$zip <- as.numeric(ggzcta$id)
ggstate    <- fortify(state)

d %>%
  left_join(ggzcta) %>%
  arrange(order) -> pzcta

resid.plot <- ggplot(data = pzcta, aes(x = long, y = lat, group = group))

resid.plot + geom_polygon(aes(fill = poistr)) + facet_wrap(~year) +
  geom_path(data = ggstate, colour = "black", lwd = 0.25) +
  scale_fill_gradient2() + labs(x = "", y = "", main = "Quasi-Poisson") +
  theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_blank(), panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(), panel.background = element_blank(),
        legend.position = c(0.7, 0), legend.justification = c(0, 0),
        legend.direction = "horizontal", legend.box.just = "bottom",
        legend.background = element_rect(fill = "transparent"))
# ggsave(paste0(localDir, "/poist_resid.pdf"), width = 10, height = 7.5)
ggsave(paste0(localDir, "/poist_resid.png"), width = 10, height = 7.5)
rm(d, ggstate, ggzcta, pzcta, resid.plot)


# ---- Moran --------------------------------------------------------------

# Need to add in a Moran's I test across each time period for residuals
# Steps: 1 - subset the data; 2 - create list to store values; 3 - loop
library(spdep)
zcta <- subset(zcta,zcta$ObjectID %in% data$ObjectID)
zcta <- zcta[order(zcta$ZIP),]
weights <- poly2nb(zcta)
W <- nb2listw(weights, zero.policy = T)

set.seed(324)

times     <- unique(data$time)
nsim      <- 100
testmoran <- data.frame(time=NA, Stat=NA, Pval=NA)
mcmoran   <- data.frame(time=NA, Stat=NA, Pval=NA)

for (i in times){
  temp1 <- subset(data, time == i)
  j5    <- moran.test(temp1$poistr, W, zero.policy = T)
  testmoran[which(times == i), 1] <- as.character(times[which(times == i)])
  testmoran[which(times == i), 2] <- j5$estimate["Moran I statistic"]
  testmoran[which(times == i), 3] <- j5$p.value
  
  j5 <- moran.mc(temp1$poistr, W, nsim, zero.policy = T)
  mcmoran[which(times == i), 1] <- as.character(times[which(times == i)])
  mcmoran[which(times == i), 2] <- j5$statistic
  mcmoran[which(times == i), 3] <- j5$p.value
  
}

testmoran
mcmoran

stargazer(as.matrix(testmoran), title = "Moran's I Test",
          out = paste0(localDir, "/MoranI.tex"))

# ---- Variogram ----------------------------------------------------------

# STdata <- filter(pdata, STATE == "TX")
STdata <- data

STsp   <- SpatialPoints(STdata[STdata$time == "1999-12-31", c("long", "lat")])
raster::projection(STsp) <- CRS("+init=epsg:4326")
STsp   <- spTransform(STsp,CRS("+init=epsg:3395"))

STtime <- unique(STdata$time)

STst <- STFDF(STsp, STtime, data.frame(STdata))

STpool <- SpatialPointsDataFrame(cbind(STdata$long, STdata$lat),
                                 data.frame(STdata))
raster::projection(STpool) <- CRS("+init=epsg:4326")
STpool   <- spTransform(STpool,CRS("+init=epsg:3395"))

system.time(
  j6 <- variogram(poistr ~ 1, STpool, cutoff = 50000)
)
# user   system  elapsed 
# 2089.969    0.640 2088.834 

plot(j6, main = "Pooled Variogram")
# ----
png(paste0(localDir, "/Pooled_Variogram.png"))
plot(j6)
dev.off()
# ----

system.time(
  fit.j6 <- fit.variogram(j6, vgm(0.3, "Exp", 1000, 0.3))
)
# System is not fitting, which is likely to indicate that there is no
#  spatial relationship at this level. Spatial autocorrelation is not
#  a concern.

# ----
j6 <- list()
temp <- unique(STpool$time)
for (i in (1:length(temp))){
  SThuh <- subset(STpool, time == temp[i])
  j5    <- variogram(poistr ~ 1, SThuh, cutoff = 50000)
  
  j6[[paste(i)]] <- list(j5)
  
  print(plot(j5, main = paste0(temp[i]), ylim = c(0, 1)))
}

# system.time(
#   fit.j6.reml <- fit.variogram.gls(poistr ~ 1, STpool,
#                                     model = vgm(0.4, "Exp", 1000, 0.1))
# )


# http://r-video-tutorial.blogspot.com/2015/08/
#  spatio-temporal-kriging-in-r.html

# ---- VariogramST --------------------------------------------------------

system.time(
  j5 <- variogramST(poistr ~ 1, STst, assumeRegular = T,
                    cutoff = 50000)
)
# |===============================================================| 100%
# user   system  elapsed 
# 1907.235    0.341 1905.142 

plot(j5, map = F)
plot(j5)
plot(j5, wireframe = T)
# ----
png(paste0(localDir, "/ST_Variogram_lags.png"))
plot(j5, map = F)
dev.off()
png(paste0(localDir, "/ST_Variogram_map.png"))
plot(j5)
dev.off()
png(paste0(localDir, "/ST_Variogram_wireframe.png"))
plot(j5, wireframe = T)
dev.off()

