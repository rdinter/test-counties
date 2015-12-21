# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_glmmPQL at ", Sys.time()))

# ---- Start --------------------------------------------------------------
# 
# library(dplyr)
# library(gstat)
# library(sp)
# library(spacetime)

# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)

# http://glmm.wikidot.com/faq
# GLMMs via MASS::glmmPQL
# This was done by using the functions “corSpatial” and “glmmPQL” available in
#  the packages “nlme” and “MASS” in R, respectively. The so-called penalized
#  quasi-likelihood (PQL) allow for fitting the variance-covariance-matrix to
#  the data, thus resulting in a spatial GLMM. 
# 
library(MASS)
library(nlme)

STdata <- subset(data, STATE == "MN")

system.time(
  sppois <- glmmPQL(Prov_num ~ iloans + log(est) + log(Pop_IRS), #+
                      #logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
                      #I(Pop_IRS / AREA_cty) + I(est / AREA_zcta),# + factor(time),
                    random = ~ 1 | factor(time),
                    family = quasipoisson, data = STdata,
                    correlation = corSpatial(form = ~ long + lat | factor(time),
                                             type = "exponential",
                                             metric = "euclidean",
                                             nugget = T))
)
