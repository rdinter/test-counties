# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_Panel_Ordered_Probit at ", Sys.time()))

suppressMessages(library(car))
suppressMessages(library(dplyr))
suppressMessages(library(pglm))
suppressMessages(library(Rchoice))
# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")

data %>%
  group_by(zip, year, STATE) %>%
  mutate(HHINC_IRS_R = AGI_IRS_R*1000 / HH_IRS) %>%
  select(Prov_num, est, emp_, Pop_IRS, HHINC_IRS_R, POV_ALL_P,
         roughness, slope, tri, AREA, loans, ploans, biploans1234) %>%
  summarise_each(funs(mean)) -> data
data$logINC <- ifelse(data$HHINC_IRS_R < 1, 0, log(data$HHINC_IRS_R))
data$Prov_ord <- cut(data$Prov_num, breaks = c(0, 2, 3, 6, Inf),
                     #labels = c("None", "Suppressed", "Moderate", "Good",
                     #           "High", "Excellent"),
                     right = F)
data$iloans <- (data$loans > 0)*1

NC <- filter(data, STATE == "NC")

## Ordered probit model with Rchoice
pdata <- pdata.frame(data, index = c("zip", "year"))
oprobit <- Rchoice(as.numeric(Prov_ord) ~ I(loans>0) + log(est) + log(Pop_IRS) +
                     logINC + tri + factor(year), pdata,
                   family = ordinal("probit"), method = "bfgs",
                   #index = c("zip", "year"),
                   model = "random")
summary(oprobit)

# Panel Ordered Probit with pglm
# op1 <- pglm(as.numeric(Prov_ord) ~ log(est) + log(Pop_IRS) +
#              logINC + factor(year), data = pdata,
#             family = ordinal("probit"), #method = "bfgs", print.level = 3,
#             #index = c("zip", "year"),
#             model = "random")
# summary(op1)



print(paste0("Finished 4-USDA_Evaluation_Panel_Ordered_Probit at ", Sys.time()))
