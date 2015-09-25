# Robert Dinterman

print(paste0("Started 3-USDA_Evaluation_Poisson at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)

# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "3-Basic_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")

data$Prov_alt <- ifelse(data$Prov_num == 2, 1, data$Prov_num)
data$Prov_alt <- ifelse(data$Prov_alt > 2, data$Prov_alt - 2, data$Prov_alt)


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
         Prov_alt, loans, ploans, biploans1234, iloans, ipilot, icur,
         long, lat) %>%
  summarise_each(funs(mean)) -> pdata

# pdata <- pdata.frame(pdata, index = c("zip", "year"))

# ---- Biannual -----------------------------------------------------------

pois   <- glm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) +
                logINC + tri + ruc, family = poisson, data = data)
summary(pois)

poist  <- glm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) +
                logINC + tri + factor(year) + ruc, family = poisson,
              data = data)
summary(poist)

# F Test
anova(pois, poist, test = "Chisq")

# png(paste0(localDir, "/PoissonDiagnostics_biannual.png"),
#     width=6, height=6, units='in', res=300)
# layout(matrix(1:4, ncol = 2))
# plot(poist, ask = F)
# dev.off()
# 
# rm(data)


# ---- Annual -------------------------------------------------------------
rm(pois, poist)
pois1  <- glm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
                tri + ruc + factor(year), family = poisson, data = pdata)
summary(pois1)
# png(paste0(localDir, "/PoissonDiagnostics_yearlog.png"),
#     width=6, height=6, units='in', res=300)
# layout(matrix(1:4, ncol = 2))
# plot(pois1, ask = F)
# dev.off()

qpois1  <- glm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
                 tri + ruc + factor(year), family = quasipoisson, data = pdata)
summary(qpois1)
# png(paste0(localDir, "/QPoissonDiagnostics_yearlog.png"),
#     width=6, height=6, units='in', res=300)
# layout(matrix(1:4, ncol = 2))
# plot(qpois1, ask = F)
# dev.off()
# 
# library(MASS)
# negb1  <- glm.nb(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
#                    tri + ruc + factor(year), data = pdata)
# summary(negb1)
# png(paste0(localDir, "/NegBDiagnostics_yearlog.png"),
#     width=6, height=6, units='in', res=300)
# layout(matrix(1:4, ncol = 2))
# plot(negb1, ask = F)
# dev.off()


# pois2 <- glm(round(Prov_num) ~ iloans + est + Pop_IRS + HHINC_IRS_R + tri +
#                ruc + factor(year), family = poisson, data = pdata)
# summary(pois2)
# png(paste0(localDir, "/PoissonDiagnostics_year.png"),
#     width=6, height=6, units='in', res=300)
# layout(matrix(1:4, ncol = 2))
# plot(pois2, ask = F)
# dev.off()


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

# resid.plot + geom_polygon(aes(fill = pois1r)) + facet_wrap(~year) +
#   geom_path(data = ggstate, colour = "black", lwd = 0.25) +
#   scale_fill_gradient2() + labs(x = "", y = "", main = "Poisson") +
#   theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
#         axis.text.x = element_blank(), panel.grid.minor=element_blank(),
#         panel.grid.major=element_blank(), panel.background = element_blank(),
#         legend.position = c(0.7, 0), legend.justification = c(0, 0),
#         legend.direction = "horizontal", legend.box.just = "bottom",
#         legend.background = element_rect(fill = "transparent"))
# ggsave(paste0(localDir, "/pois1_resid.pdf"), width = 10, height = 7.5)
# ggsave(paste0(localDir, "/pois1_resid.png"), width = 10, height = 7.5)

resid.plot + geom_polygon(aes(fill = qpois1r)) + facet_wrap(~year) +
  geom_path(data = ggstate, colour = "black", lwd = 0.25) +
  scale_fill_gradient2() + labs(x = "", y = "", main = "Quasi-Poisson") +
  theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_blank(), panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(), panel.background = element_blank(),
        legend.position = c(0.7, 0), legend.justification = c(0, 0),
        legend.direction = "horizontal", legend.box.just = "bottom",
        legend.background = element_rect(fill = "transparent"))
# ggsave(paste0(localDir, "/pois2_resid.pdf"), width = 10, height = 7.5)
# ggsave(paste0(localDir, "/pois2_resid.png"), width = 10, height = 7.5)

# ---- Bayesian Methods -------------------------------------------------------
# 
# library("MCMCpack")
# system.time(
#   posterior <- MCMCpoisson(round(Prov_num) ~ I(loans > 0) + log(est) +
#                              log(Pop_IRS) + log(WAGE_IRS_R) + tri +
#                              factor(year) + metro03,  data = data)
#   )
# png(paste0(localDir, "/PoissonDiagnostics_MCMC.png"),
#     width=6, height=6, units='in', res=300)
# layout(matrix(1:4, ncol = 2))
# plot(posterior, ask = F)
# dev.off()
# summary(posterior)

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