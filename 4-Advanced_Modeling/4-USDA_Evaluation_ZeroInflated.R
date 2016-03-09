# Robert Dinterman

print(paste0("Started 4-USDA_Evaluation_ZeroInflated at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)
library(Formula)
library(ggplot2)

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans   <- 1*(data$loans > 0)
data$ipilot   <- 1*(data$ploans > 0)
data$icur     <- 1*(data$biploans1234 > 0)
data$prov_sup <- ifelse(data$Prov_num - 3 < 0, 0, data$Prov_num - 3)
data %>%
  group_by(zip, year, STATE, ruc03, ruc, SUMBLKPOP) %>%
  dplyr::select(Prov_num, emp:emp_, Pop_IRS, HHINC_IRS_R, HHWAGE_IRS_R,
                logINC, ap_R, qp1_R, POV_ALL_P, roughness, slope, tri,
                AREA_cty, AREA_zcta, Prov_alt, loans, ploans, biploans1234,
                iloans, ipilot, icur, long, lat, prov_sup, logAPay_R2) %>%
  summarise_each(funs(mean)) -> pdata

# pdata$Prov_alt <- round(pdata$Prov_alt)
# pdata$Prov_num <- round(pdata$Prov_num)
# pdata$prov_sup <- round(pdata$prov_sup)
# pdata <- pdata.frame(pdata, index = c("zip", "year"))

# ---- ZIP Plots ----------------------------------------------------------

hp <- ggplot(data, aes(x = prov_sup)) + geom_histogram(bins = 29)
hp + facet_wrap(~ time) + theme_minimal() +
  coord_cartesian(xlim = c(0, 20)) +
  scale_x_discrete(breaks = c(2, 7, 12), labels = c("5", "10", "15")) +
  labs(x = "Number of Providers", y = "")#,
#title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Suppressed_Prov_ZIP_time_raw.png"),
       width = 10, height = 7.5)

hp + facet_wrap(~ time) + theme_minimal() +
  coord_cartesian(xlim = c(0, 20), ylim = c(0,5000)) +
  scale_x_discrete(breaks = c(2, 7, 12), labels = c("5", "10", "15")) +
  labs(x = "Number of Providers", y = "")#,
#title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Suppressed_Prov_ZIP_time_adj.png"),
       width = 10, height = 7.5)

# ---- Biannual -----------------------------------------------------------

base_form <- Formula(prov_sup ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 +
                       tri + ruc)
time_form <- update(base_form, ~ . + factor(time))

poisx  <- glm(base_form, family = poisson, data = data, subset = STATE == "CO")
summary(poisx)

pois   <- glm(base_form, family = poisson, data = data)
summary(pois)

poistx <- glm(time_form, family = poisson, data = data, subset = STATE == "CO")
summary(poistx)

poist  <- glm(time_form, family = poisson, data = data)
summary(poist)



# ---- Zero-Inflated ------------------------------------------------------

library(pscl)

data$dtime <- data$time < "2005-06-30"
zinf_form  <- Formula(prov_sup ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 +
                        tri + ruc | POV_ALL_P + tri + factor(time))
zinft_form <- Formula(prov_sup ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 +
                        tri + ruc | POV_ALL_P + tri + factor(time))


zpoisx  <- zeroinfl(zinf_form, dist = "poisson", data = data,
                    subset = STATE == "CO")
summary(zpoisx)

zpois   <- zeroinfl(zinf_form, dist = "poisson", data = data)
summary(zpois)

zpoistx <- zeroinfl(zinft_form, dist = "poisson", data = data,
                    subset = STATE == "CO")
summary(zpoistx)

zpoist  <- zeroinfl(zinft_form, dist = "poisson", data = data)
summary(zpoist)


# m2 <- zeroinfl(prov_sup ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri +
#                  ruc + factor(time), | POV_ALL_P + factor(time),
#                dist = "poisson", data = data)

# m2 <- zeroinfl(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 + tri +
#                  ruc + poly(AREA_zcta,2) + I(Pop_IRS / AREA_cty) +
#                  I(est / AREA_zcta) + factor(time) |
#                  tri + log(est) + log(Pop_IRS) + logAPay_R2 + factor(time),
#                dist = "poisson", data = data)