# Robert Dinterman

print(paste0("Started 1-USDA_Evaluation_Stata_Export at ", Sys.time()))

library(dplyr)

# Create a directory for the data
localDir <- "1-Organization/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")

data %>%
  group_by(zip, year, STATE, fips, ruc03, metro03, long, lat, CPI) %>%
  mutate(HHINC_IRS_R = AGI_IRS_R*1000 / HH_IRS,
         HHWAGE_IRS_R = Wages_IRS_R*1000 / HH_IRS) %>%
  select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
         ap_R, qp1_R, POV_ALL_P, roughness, slope, tri, AREA_cty, AREA_zcta,
         loans, ploans, biploans1234) %>%
  summarise_each(funs(mean)) -> data
data$logINC <- ifelse(data$HHINC_IRS_R < 1, 0, log(data$HHINC_IRS_R))
data$Prov_ord <- cut(data$Prov_num, breaks = c(0, 2, 3, 5.5, 7.5, 10, Inf),
                     labels = c("None", "Suppressed", "Moderate", "Good",
                                "High", "Excellent"), right = F)
data$iloans     <- (data$loans > 0)*1
data$ipilot     <- (data$ploans > 0)*1
data$ibip       <- (data$biploans1234 > 0)*1

data$logest     <- log(data$est)
data$logemp_    <- log(data$emp_ + 1)
data$logPop_IRS <- log(data$Pop_IRS)
data$logHHWage  <- log(data$HHWAGE_IRS_R)

data$logap_R    <- log(data$ap_R + 1)
data$logemp     <- log(data$emp + 1)
data$logqp1_R   <- log(data$qp1_R + 1)

data$ruc         <- factor(data$ruc03)
levels(data$ruc) <- list("metro" = 1:3, "adj" = c(4,6,8),
                         "nonadj" = c(5,7,9))


# export data frame to Stata binary format 
library(foreign)
library(readr)
write.dta(data, paste0(localDir, "/Stata_USDA_Eval.dta"))
write_csv(data, paste0(localDir, "/Stata_USDA_Eval.csv"))

rm(list = ls())

print(paste0("Finished 1-USDA_Evaluation_Stata_Export at ", Sys.time()))
