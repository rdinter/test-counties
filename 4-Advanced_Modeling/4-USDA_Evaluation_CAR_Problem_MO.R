# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_CAR_Problem_MO at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(CARBayesST)
library(MCMCpack)

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)

# Minnesota
load("0-Data/Shapefiles/contigW-MO.Rda")
STdata <- subset(data, STATE == "MO")

# ---- Biannual -----------------------------------------------------------

pois <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 +
              tri + ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
              I(est / AREA_zcta), family = poisson, data = data)
summary(pois)

poist <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 +
               tri + ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
               I(est / AREA_zcta) + factor(time),
             family = poisson, data = data)
summary(poist)

# F Test
anova(pois, poist, test = "Chisq")
rm(pois, poist)


# ---- Aspatial Poisson ---------------------------------------------------

pois <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
              logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
              I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
            family = "poisson", data = STdata)
summary(pois)

poist <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = "poisson", data = STdata)
summary(poist)

# F Test
anova(pois, poist, test = "Chisq")
# rm(pois, poist)

# ---- Bayes Poisson ------------------------------------------------------

set.seed(324)
posterior <- MCMCpoisson(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
                           logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
                           I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
                         data = STdata, burnin = 1000, mcmc = 10000)
summary(posterior)

set.seed(324)
posteriort <- MCMCpoisson(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
                            logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
                            I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
                            factor(time),
                          data = STdata, burnin = 1000, mcmc = 10000)
summary(posteriort)
rm(posterior, posteriort)

# ---- Moran --------------------------------------------------------------

library(spdep)
STdata$poistr <- residuals(poist)

W <- mat2listw(weights)
set.seed(324)

times     <- unique(STdata$time)
nsim      <- 100
testmoran <- data.frame(time=NA, Statistic=NA, Pval=NA)
mcmoran   <- data.frame(time=NA, Statistic=NA, Pval=NA)

for (i in times){
  temp1 <- subset(STdata, time == i)
  j5    <- moran.test(temp1$poistr, W, zero.policy = T, randomisation = F)
  testmoran[which(times == i), 1] <- as.character(times[which(times == i)])
  testmoran[which(times == i), 2] <- j5$estimate["Moran I statistic"]
  testmoran[which(times == i), 3] <- j5$p.value
  
  #   j5 <- moran.mc(temp1$poistr, W, nsim, zero.policy = T)
  #   mcmoran[which(times == i), 1] <- as.character(times[which(times == i)])
  #   mcmoran[which(times == i), 2] <- j5$statistic
  #   mcmoran[which(times == i), 3] <- j5$p.value
  
}

knitr::kable(testmoran)
# mcmoran

# ---- ST.CARanova --------------------------------------------------------

set.seed(324)
model1 <- ST.CARanova(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
                        logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
                        I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
                      family = "poisson", data = STdata, W = weights,
                      burnin = 1000, n.sample = 10000, verbose = F)
model1
# Setting up the model
# Collecting 5000 samples
# |================================================================| 100%
# Summarising results
# finished in  108.7 seconds

# ---- Moran anova
STdata$anovar <- residuals(model1)

morananovar <- data.frame(time=NA, Statistic=NA, Pval=NA)

for (i in times){
  temp1 <- subset(STdata, time == i)
  j5    <- moran.test(temp1$anovar, W, zero.policy = T, randomisation = F)
  morananovar[which(times == i), 1] <- as.character(times[which(times == i)])
  morananovar[which(times == i), 2] <- j5$estimate["Moran I statistic"]
  morananovar[which(times == i), 3] <- j5$p.value
}

knitr::kable(morananovar)

# ---- ST.CARsepspatial ---------------------------------------------------

set.seed(324)
model2 <- ST.CARsepspatial(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
                             logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
                             I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
                           family = "poisson", data = STdata, W = weights,
                           burnin = 1000, n.sample = 10000, verbose = F)
model2
# Setting up the model
# Collecting 5000 samples
# |================================================================| 100%
# Summarising results
# finished in  116.8 seconds

# ---- Moran sepspatial
STdata$sepspatialr <- residuals(model2)

moransepspatialr <- data.frame(time=NA, Statistic=NA, Pval=NA)

for (i in times){
  temp1 <- subset(STdata, time == i)
  j5    <- moran.test(temp1$sepspatialr, W, zero.policy = T,
                      randomisation = F)
  moransepspatialr[which(times == i), 1] <-
    as.character(times[which(times == i)])
  moransepspatialr[which(times == i), 2] <-
    j5$estimate["Moran I statistic"]
  moransepspatialr[which(times == i), 3] <-
    j5$p.value
}

knitr::kable(moransepspatialr)


# ---- ST.CARar -----------------------------------------------------------

set.seed(324)
model3 <- ST.CARar(Prov_num ~ iloans + log(est) + log(Pop_IRS) +
                     logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
                     I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),
                   family = "poisson", data = STdata, W = weights,
                   burnin = 1000, n.sample = 10000, verbose = F)
model3
# Setting up the model
# Collecting 5000 samples
# |===============================================================| 100%
# Summarising results
# finished in  99.2 seconds

# ---- Moran ar
STdata$arr <- residuals(model3)

moranarr <- data.frame(time=NA, Statistic=NA, Pval=NA)

for (i in times){
  temp1 <- subset(STdata, time == i)
  j5    <- moran.test(temp1$arr, W, zero.policy = T, randomisation = F)
  moranarr[which(times == i), 1] <- as.character(times[which(times == i)])
  moranarr[which(times == i), 2] <- j5$estimate["Moran I statistic"]
  moranarr[which(times == i), 3] <- j5$p.value
}

knitr::kable(moranarr)


# save(model1, file = paste0(localDir, "/CARBayesNC.Rda"))
