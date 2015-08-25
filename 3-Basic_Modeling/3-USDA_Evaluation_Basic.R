# Robert Dinterman

print(paste0("Started 3-USDA_Evaluation_Basic at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(car)
library(dplyr)
library(lmtest)
library(plm)

##Double-clustering formula (Thompson, 2011)
vcovDC <- function(x, ...){
  vcovHC(x, cluster="group", ...) + vcovHC(x, cluster="time", ...) - 
    vcovHC(x, method="white1", ...)
  # http://stackoverflow.com/questions/8389843/
  #  double-clustered-standard-errors-for-panel-data  
}

# Create a directory for the data
localDir <- "3-Basic_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

# sink(paste0(localDir, "/3-USDA_Evaluation_Basic.txt"))


load("1-Organization/USDA_Evaluation/Final.Rda")

data %>%
  group_by(zip, year, STATE, ruc03, long, lat) %>%
  mutate(HHINC_IRS_R = AGI_IRS_R*1000 / HH_IRS,
         HHWAGE_IRS_R = Wages_IRS_R*1000 / HH_IRS) %>%
  select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
         ap_R, qp1_R, POV_ALL_P, roughness, slope, tri, AREA,
         loans, ploans, biploans1234) %>%
  summarise_each(funs(mean)) -> pdata
rm(data)

# Define some troublesome variables
pdata$logINC <- ifelse(pdata$HHINC_IRS_R < 1, 0, log(pdata$HHINC_IRS_R))
pdata$iloans <- 1*(pdata$loans > 0)
pdata$ipilot <- 1*(pdata$ploans > 0)
pdata$icur   <- 1*(pdata$biploans1234 > 0)
pdata$ruc    <- factor(pdata$ruc03)
levels(pdata$ruc) <- list("metro" = 1:3, "adj" = c(4,6,8),
                         "nonadj" = c(5,7,9))

pdata <- pdata.frame(pdata, index = c("zip", "year"))

#Extremely nonlinear in establishment and population
# http://www.princeton.edu/~otorres/Panel101R.pdf

# ---- Pooled -------------------------------------------------------------

pool1  <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri +
                ruc, pdata, model = "pooling")
summary(pool1)

# ---- Fixed --------------------------------------------------------------

p1  <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC,
           pdata, model = "within")
summary(p1)

p1t <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc,
           pdata, model = "within", effect = "time")
summary(p1t)

p12 <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC,
           pdata, model = "within", effect = "twoways")
summary(p12)

p1d <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC,
           pdata, model = "fd")
summary(p1d)

# ---- Between ------------------------------------------------------------

p1b  <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc,
            pdata, model = "between")
summary(p1b)


# ---- Random -------------------------------------------------------------

r1  <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc,
           pdata, model = "random")
summary(r1)

r1t <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc,
           pdata, model = "random", effect = "time")
summary(r1t)

r12 <- plm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC + tri + ruc,
           pdata, model = "random", effect = "twoways")
summary(r12)


# ---- Tests --------------------------------------------------------------
# Hausman
phtest(p1, r1)
phtest(p1t, r1t)
phtest(p12, r12)


# ---- Serial -------------------------------------------------------------
# Serial Dependence?
pbgtest(p1) 
pbgtest(p1t)
pbgtest(p12)

pbgtest(r1)
pbgtest(r1t)
pbgtest(r12)

# 
# coeftest(r1, vcovHC)
# coeftest(r1t, vcovHC)
# 
# 
# # LaGrange Multiplier Tests
# plmtest(p1, type = "bp", effect = "time")
# plmtest(p1, type = "bp", effect = "individual")
# plmtest(p1, type = "bp", effect = "twoways")
# 
# 
# pFtest(p1, p1t) # F-Test of year effects
# 
# 
# pFtest(p1, pool1)
# pFtest(p1t, pool1)
# pFtest(p12, pool1)
# 
# pFtest(p1b, p1)
# pFtest(p1b, p1t)
# 
# #DO NO RUN: pcdtest(p1t, test = c("lm")) # Cross-sectional dependence?
# 
# coeftest(p1,  vcov = function(x) vcovHC(x, cluster = "time", type = "HC1"))
# coeftest(p1t, vcov = function(x) vcovHC(x, cluster = "time", type = "HC1"))


# ---- Dynamic ------------------------------------------------------------

dpls <- plm(Prov_num ~ lag(Prov_num, 1) + iloans + log(est) + log(Pop_IRS) +
              logINC, pdata, model = "within", index = c("zip", "year"))
summary(dpls)

dp1 <- pgmm(Prov_num ~ lag(Prov_num, 1) + iloans + log(est) + log(Pop_IRS) +
              logINC | lag(Prov_num, 2:99) + tri, pdata,
            index = c("zip", "year"))
summary(dp1)

dp2 <- pgmm(Prov_num ~ lag(Prov_num, 1) + iloans + log(est) + log(Pop_IRS) +
              logINC | lag(Prov_num, 2:99) + tri, pdata, effect = "individual",
            index = c("zip", "year"))
summary(dp2)

# 
# dp1.fitted <- as.vector(dp1$fitted.values)
# dp1.resid  <- as.vector(unlist(dp1$residuals))
# plot(dp1.fitted, dp1.resid)
# 
# par(mfrow = c(1, 2))
# hist(dp1.fitted)
# hist(pdata$Prov_num)

#rm(list=ls())

print(paste0("Finished 3-USDA_Evaluation_Basic at ", Sys.time()))
# sink()