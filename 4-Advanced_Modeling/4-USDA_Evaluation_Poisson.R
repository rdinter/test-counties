# Robert Dinterman
# http://glmm.wikidot.com/faq
# GLMMs via MASS::glmmPQL

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

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)
# data %>%
#   group_by(zip, year, STATE, ruc03, ruc, SUMBLKPOP) %>%
#   dplyr::select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
#                 logINC, ap_R, qp1_R, POV_ALL_P, roughness, slope, tri, AREA,
#                 Prov_alt, loans, ploans, biploans1234, iloans, ipilot, icur,
#                 long, lat) %>%
#   summarise_each(funs(mean)) -> pdata

# pdata <- pdata.frame(pdata, index = c("zip", "year"))

# ---- Biannual -----------------------------------------------------------

pois <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc +
              poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
            family = poisson, data = data)
summary(pois)

poist <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc +
               poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data)
summary(poist)

# F Test
anova(pois, poist, test = "Chisq")
rm(pois)

# ---- Quasi --------------------------------------------------------------

qpois  <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc +
                poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
                factor(time), family = quasipoisson, data = data)
summary(qpois)

library(MASS)
negb1 <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri +
               ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
               I(est / AREA_zcta) + 
               factor(time), family = negative.binomial(theta = 1), data = data)
summary(negb1)
negb  <- glm.nb(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri +
                  ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
                  I(est / AREA_zcta) + factor(time), data = data)
summary(negb)


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
ggsave(paste0(localDir, "/poist_resid.pdf"), width = 10, height = 7.5)
ggsave(paste0(localDir, "/poist_resid.png"), width = 10, height = 7.5)
rm(d, ggstate, ggzcta, pzcta, resid.plot)
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

#system.time(
  j6 <- variogram(poistr ~ 1, STpool, cutoff = 50000)
#)
# user   system  elapsed 
# 1953.772    0.274 1951.978 

plot(j6, main = "Pooled Variogram")
# ----
png(paste0(localDir, "/Pooled_Variogram.png"))
plot(j6, main = "Pooled Variogram")
dev.off()
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
#   fit.j6 <- fit.variogram(j6, vgm(0.3, "Exp", 1000, 0.3))
# )
# System is not fitting, which is likely to indicate that there is no
#  spatial relationship at this level. Spatial autocorrelation is not
#  a concern.

# system.time(
#   fit.j6.reml <- fit.variogram.reml(qpois1r ~ 1, STpool,
#                                     model = vgm(0.4, "Exp", 1000, 0.1))
# )


# http://r-video-tutorial.blogspot.com/2015/08/
#  spatio-temporal-kriging-in-r.html

# ---- VariogramST --------------------------------------------------------

#system.time(
  j5 <- variogramST(poistr ~ 1, STst, assumeRegular = T,
                    cutoff = 50000)
#)
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

# ---- Spatial ------------------------------------------------------------
# 
library(MASS)
library(spBayes)

# beta.starting <- coefficients(pois1)
# beta.tuning   <- t(chol(vcov(pois1)))

# Here posterior inference is based on three MCMC chains each of length 15,000.
#  The code to generate the first of these chains is given below.
n.batch      <- 300
batch.length <- 50
n.samples    <- n.batch * batch.length
# ydata <- subset(data, time == "2006-12-31")
ydata <- subset(data, STATE == "MN")

pois <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc +
              poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) + factor(time),
            family = "poisson", data = ydata)
beta.starting <- coefficients(pois)
beta.tuning   <- t(chol(vcov(pois)))

pois.sp.chain.1 <-
  spGLM(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc +
          poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) + factor(time),
        family = "poisson", data = ydata,
        coords = as.matrix(ydata[, c("long", "lat")]),
        starting = list(beta = beta.starting,
                        phi = 3/0.5,
                        sigma.sq = 1,w = 0),
        tuning = list(beta = beta.tuning, phi = 0.5,
                      sigma.sq = 0.1,w = 0.1),
        priors = list("beta.Flat",
                      phi.Unif = c(3/1, 3/0.1),
                      sigma.sq.IG = c(2, 1)),
        amcmc = list(n.batch = n.batch,
                     batch.length = batch.length,
                     accept.rate = 0.43),
        cov.model = "exponential")

samps <- mcmc.list(pois.sp.chain.1$p.beta.theta.samples)
plot(samps)
# 
# ##### Spatial GLM #####
# library(MASS)
# ## Generate some count data from each location
# n <- 50
# coords <- cbind(runif(n, 0, 1), runif(n, 0, 1))
# phi <- 3/0.5
# sigma.sq <- 2
# R <- exp(-phi * iDist(coords))
# w <- mvrnorm(1, rep(0, n), sigma.sq * R)
# beta.0 <- 0.1
# y <- rpois(n, exp(beta.0 + w))
# 
# ##First fit a simple non-spatial GLM:
# pois.nonsp <- glm(y ~ 1, family = "poisson")
# beta.starting <- coefficients(pois.nonsp)
# beta.tuning <- t(chol(vcov(pois.nonsp)))
# 
# ## Here posterior inference is based on three MCMC chains each of length 15,000. The code to generate the first of these chains is given below.
# n.batch <- 300
# batch.length <- 50
# n.samples <- n.batch * batch.length
# pois.sp.chain.1 <-
#   spGLM(y ~ 1,family = "poisson",coords = coords,
#         starting = list(beta = beta.starting,
#                         phi = 3/0.5,
#                         sigma.sq = 1,w = 0),
#         tuning = list(beta = 0.1, phi = 0.5,
#                       sigma.sq = 0.1,w = 0.1),
#         priors = list("beta.Flat",
#                       phi.Unif = c(3/1, 3/0.1),
#                       sigma.sq.IG = c(2, 1)),
#         amcmc = list(n.batch = n.batch,
#                      batch.length=batch.length,
#                      accept.rate = 0.43),
#         cov.model = "exponential")
# 
# samps <- mcmc.list(pois.sp.chain.1$p.beta.theta.samples)
# plot(samps)
# 
# ##print(gelman.diag(samps))
# ##gelman.plot(samps)
# burn.in <- 10000
# print(round(summary(window(samps, start = burn.in))$quantiles[,c(3, 1, 5)], 2))
# 
# samps <- as.matrix(window(samps, start = burn.in))
# w <- cbind(pois.sp.chain.1$p.w.samples[, burn.in:n.samples])
# beta.0.hat <- mean(samps[, "(Intercept)"])
# w.hat <- apply(w, 1, mean)
# y.hat <- exp(beta.0.hat + w.hat)
# 
# ## Map the predicted counts and associated standard errors
# par(mfrow = c(1, 2))
# surf <- mba.surf(cbind(coords, y), no.X = 100, no.Y = 100, extend = TRUE)$xyz.est
# image.plot(surf, main = "Observed counts")
# points(coords)
# surf <- mba.surf(cbind(coords, y.hat), no.X = 100, no.Y = 100, extend = TRUE)$xyz.est
# image.plot(surf, main = "Fitted counts")
# points(coords)
# http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0082142

# This was done by using the functions “corSpatial” and “glmmPQL” available in
#  the packages “nlme” and “MASS” in R, respectively. The so-called penalized
#  quasi-likelihood (PQL) allow for fitting the variance-covariance-matrix to
#  the data, thus resulting in a spatial GLMM. 
# 
# library(MASS)
# library(nlme)
# pdata$rprov <- round(pdata$Prov_num)
# 
# system.time(
#   sppois <- glmmPQL(rprov ~ iloans + est + Pop_IRS + logINC +
#                       tri + ruc,# + factor(year),
#                     random = ~ 1 | factor(year),
#                     family = quasipoisson, data = pdata,
#                     correlation = corSpatial(form = ~ long + lat | factor(year),
#                                              type = "exponential",
#                                              metric = "euclidean",
#                                              nugget = T))
# )
