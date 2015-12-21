# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_Panel_Ordered_Probit at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(car)
library(dplyr)
library(pglm)

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

pdata <- pdata.frame(data, index = c("zip", "time"))

# ---- Panel --------------------------------------------------------------

# NC <- filter(data, STATE == "NC")

# Panel Poisson with pglm
ppanel1 <- pglm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
              tri + ruc, data = pdata,
            family = poisson, #method = "bfgs", print.level = 3,
            #index = c("zip", "time"),
            model = "pooling")
summary(ppanel1)

# Panel Poisson with pglm
ppanel2 <- pglm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
                  tri + ruc, data = pdata,
                family = poisson, #method = "bfgs", print.level = 3,
                #index = c("zip", "time"),
                effect = "time")
summary(ppanel2)

# Panel Poisson with pglm
ppanel3 <- pglm(round(Prov_num) ~ iloans + log(est) + log(Pop_IRS) + logINC +
                  tri + ruc, data = pdata,
                family = poisson, #method = "bfgs", print.level = 3,
                #index = c("zip", "time"),
                model = "pooling")
summary(ppanel3)



op1 <- pglm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC +
              tri + ruc, family = quasipoisson, data = pdata,
            #family = "poisson", #method = "bfgs", print.level = 3,
            #index = c("zip", "year"),
            model = "random")
summary(op1)

## Ordered probit model with Rchoice
pdata <- pdata.frame(data, index = c("zip", "year"))
oprobit <- Rchoice(as.numeric(Prov_ord) ~ I(loans>0) + log(est) + log(Pop_IRS) +
                     logINC + tri + factor(year), pdata,
                   family = ordinal("probit"), method = "bfgs",
                   #index = c("zip", "year"),
                   model = "random")
summary(oprobit)

# Panel Ordered Probit with pglm
op1 <- pglm(as.numeric(Prov_ord) ~ log(est) + log(Pop_IRS) +
             logINC + factor(year), data = pdata,
            family = ordinal("probit"), #method = "bfgs", print.level = 3,
            #index = c("zip", "year"),
            model = "random")
summary(op1)


print(paste0("Finished 4-USDA_Evaluation_Panel_Ordered_Probit at ", Sys.time()))
