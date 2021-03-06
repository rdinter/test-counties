# Robert Dinterman

# ---- Start --------------------------------------------------------------

print(paste0("Started 2-USDA_Evaluation_Figures at ", Sys.time()))

library(dplyr)
library(ggplot2)
library(scales)
library(stargazer)
library(tidyr)

# Create a directory for the data
localDir <- "2-Exploratory/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
# ----
cor(data$AREA_zcta, data$est) # Relationship between area and establishments.
# ---- Zip time -----------------------------------------------------------
hp <- ggplot(data, aes(x = Prov_hist)) + geom_histogram() +
  coord_cartesian(xlim = c(0, 15)) 
hp + facet_wrap(~ time) + theme_minimal() +
  scale_x_discrete(breaks = c(5, 10, 15)) +
  labs(x = "Number of Providers", y = "")#,
#title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Providers_zip_time.png"), width = 10, height = 7.5)

# ---- Zip time alt -------------------------------------------------------

hp <- ggplot(data, aes(x = Prov_alt)) + geom_histogram() +
  coord_cartesian(xlim = c(0, 15)) 
hp + facet_wrap(~ time) + theme_minimal() +
  scale_x_discrete(breaks = c(5, 10, 15)) +
  labs(x = "Number of Providers", y = "")#,
#title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Providers_zip_time_alt.png"),
       width = 10, height = 7.5)


# ---- ZIP Differences ----------------------------------------------------

zdat <- data %>% arrange(zip, time) %>% group_by(zip) %>% 
  mutate(prov_diff = c(Prov_num[1], diff(Prov_num)))
hp <- ggplot(zdat, aes(x = prov_diff)) + geom_histogram(bins=25)
hp + facet_wrap(~ time) + theme_minimal() +
  labs(x = "Change in Number of Providers", y = "")#,
#title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Prov_change_unadj.png"), width = 10, height = 7.5)

hp + facet_wrap(~ time) + theme_minimal() +
  coord_cartesian(ylim = c(0,6000)) +
  labs(x = "Change in Number of Providers", y = "")#,
#title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Prov_change_adj.png"), width = 10, height = 7.5)



# ---- Zip Uptake ---------------------------------------------------------
data %>%
  group_by(time) %>%
  summarise(Access = sum(Prov_num > 0) / n()) -> access
sc1 <- ggplot(access, aes(x = time, y = Access))
sc1 + stat_smooth() + theme_minimal() +
  labs(x = "Year", y = "Proportion with Broadband Access")#,
#title = "Zip Codes with Broadband Access")
ggsave(paste0(localDir, "/ZIP_no_bb_up.png"), width = 10, height = 7.5)


# ---- Zip Downtake -------------------------------------------------------
data %>%
  group_by(time) %>%
  summarise(Access = sum(Prov_num == 0) / n()) -> noaccess
sc2 <- ggplot(noaccess, aes(x = time, y = Access))
sc2 + stat_smooth() + theme_minimal() +
  labs(x = "Year", y = "Proportion without Broadband Access")#,
#title = "Zip Codes without Broadband Access")
ggsave(paste0(localDir, "/ZIP_no_bb_down.png"), width = 10, height = 7.5)

data$class <- ifelse(data$iloans, "Loan", "None")
data$class <- ifelse(data$ipilot, "Pilot", data$class)
data$class <- ifelse(data$ibip1234, "Farm Bill", data$class)
data$class <- factor(data$class, levels = c("None", "Pilot", "Farm Bill"))
data$Access <- 1*(data$Prov_num != 0)

j5 <- ggplot(data, aes(x = time, y = 1-Access, color = class, group = class)) +
  stat_smooth(size = 2) +
  labs(x = "Year", y = "Proportion without Broadband Access") +
  guides(color = guide_legend(title = "Loan Type")) +
  theme_minimal() +
  theme(legend.position = "bottom",
        strip.text.y = element_text(size = 10, face = "bold"))
ggsave(paste0(localDir, "/ZIP_no_bb_down_class.png"), j5, width = 10, height = 7.5)

j5 + geom_vline(xintercept = as.numeric(as.Date("2001-12-31")),
                color = "black", linetype = "longdash") +
  geom_vline(xintercept = as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash")
ggsave(paste0(localDir, "/ZIP_no_bb_down_class-loans.png"),
       width = 10, height = 7.5)


# ---- Loan Time ----------------------------------------------------------
# When did the loans occur:
ltime <- data.frame(loan = c("Pilot", "Farm Bill"),
                    time = as.numeric(as.Date(c("2001-12-31", "2003-12-31"))),
                    year = c(2002, 2004),
                    disp = c("black", "red"))

data %>%
  group_by(time) %>%
  distinct(zip) %>%
  summarise(loans   = sum(loans),
            pilot   = sum(ploans),
            `Farm Bill` = sum(biploans1234)) -> ggloans
ggplot(ggloans, aes(x = time, y = loans)) + geom_line() + theme_minimal() +
  scale_y_continuous(breaks = seq(0, 3000, 500)) +
  geom_vline(xintercept = as.numeric(as.Date("2001-12-31")),
             color = "black", linetype = "longdash") +
  geom_vline(xintercept = as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash") +
  labs(x = "", y = "Cumulative ZIP Codes Awarded Loans")#,
#title = "USDA Loans by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Loan_award_time.png"), width = 10, height = 7.5)

# # A Barplot of loans by year?
# ggplot(mtc, aes(x = factor(gear))) + geom_bar(stat = "bin")


# ---- Zip Attributes -----------------------------------------------------
# Summary for all across time ... ? But these are ZIPS not FIPS
data %>%
  group_by(year) %>%
  distinct(zip) %>%
  summarise(Category = "All ZIPs", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            Pay = mean(APay_R2), PaySD = sd(APay_R2),
            TRI = mean(tri), TRISD = sd(tri),
            AREA = mean(AREA_zcta), AREASD = sd(AREA_zcta)) -> t1
# Any Loans
data %>%
  group_by(year) %>%
  filter(ipilot | ibip1234) %>%
  distinct(zip) %>%
  summarise(Category = "Any", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            Pay = mean(APay_R2), PaySD = sd(APay_R2),
            TRI = mean(tri), TRISD = sd(tri),
            AREA = mean(AREA_zcta), AREASD = sd(AREA_zcta)) -> t2
# "Farm Bill Loans"
data %>%
  group_by(year) %>%
  filter(ibip1234) %>%
  distinct(zip) %>%
  summarise(Category = "Farm Bill", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            Pay = mean(APay_R2), PaySD = sd(APay_R2),
            TRI = mean(tri), TRISD = sd(tri),
            AREA = mean(AREA_zcta), AREASD = sd(AREA_zcta)) -> t3
# Pilot Loans
data %>%
  group_by(year) %>%
  filter(ipilot) %>%
  distinct(zip) %>%
  summarise(Category = "Pilot", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            Pay = mean(APay_R2), PaySD = sd(APay_R2),
            TRI = mean(tri), TRISD = sd(tri),
            AREA = mean(AREA_zcta), AREASD = sd(AREA_zcta)) -> t4
# No Loans
data %>%
  group_by(year) %>%
  filter(!ipilot | !ibip1234) %>%
  distinct(zip) %>%
  summarise(Category = "ZNo Loans", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            Pay = mean(APay_R2), PaySD = sd(APay_R2),
            TRI = mean(tri), TRISD = sd(tri),
            AREA = mean(AREA_zcta), AREASD = sd(AREA_zcta)) -> t5
ta  <- bind_rows(t1, t3, t4)
ta  <- arrange(ta, year, Category)

ziptab <- function(ta){
  pta <- data.frame(year = as.character(ta$year))
  pta <- cbind(pta, sapply(ta[,2:15], function(x)
    prettyNum(x, big.mark = ",", digits = 3, drop0trailing = T)))
  
  pta$Providers      <- paste0(pta$Prov, " (", pta$ProvSD, ")")
  pta$Establishments <- paste0(pta$Est, " (", pta$EstSD, ")")
  pta$Employed       <- paste0(pta$Emp, " (", pta$EmpSD, ")")
  pta$Pay            <- paste0("$", pta$Pay, " ($", pta$PaySD, ")")
  pta$TRI            <- paste0(pta$TRI, " (", pta$TRISD, ")")
  pta$AREA           <- paste0(pta$AREA, " (", pta$AREASD, ")")
  pta <- select(pta, year:n, Providers, Establishments, Employed, Pay, TRI, AREA)
  
  return(pta)
}


ziptab2 <- function(ta){
  pta <- data.frame(year = as.character(ta$year))
  pta <- cbind(pta, sapply(ta[, 4:15], function(x)
    prettyNum(x, big.mark = ",", digits = 3, drop0trailing = T)))
  
  pta$Providers      <- paste0(pta$Prov, " (", pta$ProvSD, ")")
  pta$Establishments <- paste0(pta$Est, " (", pta$EstSD, ")")
  pta$Employed       <- paste0(pta$Emp, " (", pta$EmpSD, ")")
  pta$Pay            <- paste0("$", pta$Pay, " ($", pta$PaySD, ")")
  pta$TRI            <- paste0(pta$TRI, " (", pta$TRISD, ")")
  pta$AREA           <- paste0(pta$AREA, " (", pta$AREASD, ")")
  pta <- select(pta, year, Providers, Establishments, Employed, Pay, TRI, AREA)
  
  return(pta)
}

pta <- ziptab(ta)

write.csv(pta, paste0(localDir, "/ZIP_Stats.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/ZIP_Stats.tex"))

# All ZIPS
pta <- ziptab2(t1)
write.csv(pta, paste0(localDir, "/ZIP_Stats_All.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/ZIP_Stats_All.tex"))
# Farm Bill
pta <- ziptab2(t3)
write.csv(pta, paste0(localDir, "/ZIP_Stats_FB.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/ZIP_Stats_FB.tex"))
# Pilot
pta <- ziptab2(t4)
write.csv(pta, paste0(localDir, "/ZIP_Stats_Pilot.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/ZIP_Stats_Pilot.tex"))


# ---- Zip Attributes Graph -----------------------------------------------
data %>%
  select(zip, time, Prov_hist, est, emp_, APay_R2) %>%
  gather(key, value, Prov_hist, est, emp_, APay_R2) -> all
all$class <- "all"
# ipilot, ibip12, ibip1234, iloans
data %>%
  filter(iloans) %>%
  select(zip, time, Prov_hist, est, emp_, APay_R2) %>%
  gather(key, value, Prov_hist, est, emp_, APay_R2) -> all1
all1$class <- "Any Loan"
data %>%
  filter(ipilot) %>%
  select(zip, time, Prov_hist, est, emp_, APay_R2) %>%
  gather(key, value, Prov_hist, est, emp_, APay_R2) -> all2
all2$class <- "Pilot"
data %>%
  filter(ibip1234) %>%
  select(zip, time, Prov_hist, est, emp_, APay_R2) %>%
  gather(key, value, Prov_hist, est, emp_, APay_R2) -> all3
all3$class <- "Farm Bill"
data %>%
  filter(!ipilot | !ibip1234) %>%
  select(zip, time, Prov_hist, est, emp_, APay_R2) %>%
  gather(key, value, Prov_hist, est, emp_, APay_R2) -> all4
all4$class <- "No Loan"
test <- bind_rows(all2, all3, all4)

test$class <- factor(test$class, levels = c("No Loan", "Pilot", "Farm Bill"),
                     labels = c("None", "Pilot", "Farm Bill"))
levels(test$key) <- c("Providers", "Establishments", "Employed", "Annual Pay")
test$key <- factor(test$key, levels=rev(levels(test$key)))

# ggplot(filter(test, key == "Providers"),
#        aes(x = time, y = value, colour = class, group = class)) +
#   stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()
# 
# ggplot(filter(test, key == "Establishments"),
#        aes(x = time, y = value, colour = class, group = class)) +
#   stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()
# 
# ggplot(filter(test, key == "Employed"),
#        aes(x = time, y = value, colour = class, group = class)) +
#   stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

ggplot(test,aes(x = time, y = value, color = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth", size = 2) +
  geom_vline(xintercept = as.numeric(as.Date("2001-12-31")),
             color = "black", linetype = "longdash") +
  geom_vline(xintercept = as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash") +
  facet_grid(key ~ ., scales = "free_y") + labs(x = "", y = "") +
  scale_y_continuous(labels = comma) +
  guides(color = guide_legend(title = "Loan Type")) +
  theme_minimal() +
  theme(legend.position = "bottom",
        strip.text.y = element_text(size = 10, face = "bold"))
ggsave(paste0(localDir, "/Zip_attributes.png"), width = 10, height = 7.5)

rm(access, all, all1, all2, all3, all4, test)

# ---- FIP Data -----------------------------------------------------------
# data %>%
#   group_by(year) %>%
#   distinct(fips) %>%
#   summarise(n = n(), PopIRS = mean(Pop_IRS), PopIRSSD = sd(Pop_IRS),
#             PopPOV = mean(POP_POV), PopPOVSD = sd(POP_POV),
#             HHInc = mean(MEDHHINC_R), HHIncSD = sd(MEDHHINC_R),
#             HHIncIRS = mean(AGI_IRS_R*1000 / HH_IRS),
#             HHIncIRSSD = sd(AGI_IRS_R*1000 / HH_IRS),
#             HHWageIRS = mean(Wages_IRS_R*1000 / HH_IRS),
#             HHWageIRSSD = sd(Wages_IRS_R*1000 / HH_IRS),
#             Area_cty = mean(AREA_cty), AreaSD = sd(AREA_cty)) %>% View

# Try this with a ggplot2 description...
fipdata <- data %>%
  group_by(fips, year, time) %>%
  summarise(n = n(), PopIRS = mean(Pop_IRS), PopPOV = mean(POP_POV),
            HHInc = mean(MEDHHINC_R), HHIncIRS = mean(AGI_IRS_R*1000 / HH_IRS),
            HHWageIRS = mean(Wages_IRS_R*1000 / HH_IRS), Area = mean(AREA_cty),
            Pilot = sum(ploans), `Farm Bill` = sum(biploans1234), 
            Prov = weighted.mean(Prov_hist, SUMBLKPOP + 1),
            ipilot = !all(!ipilot), ibip1234 = !all(!ibip1234),
            iloans = !all(!iloans))

# # KKLR Check:
# library(knitr)
# fipdata %>% group_by(year, iloans) %>%
#   summarise(n = n(), Pop_IRS = mean(PopIRS), Pop_IRS_sd = sd(PopIRS),
#             Pop_POV = mean(PopPOV), Pop_POV_sd = sd(PopPOV),
#             HHInc_IRS = mean(HHIncIRS), HHInc_IRS_sd = sd(HHIncIRS),
#             MEDInc = mean(HHInc), MEDInc_sd = sd(HHInc)) %>% kable

# ---- FIP Attributes -----------------------------------------------------
# All
fipdata %>%
  group_by(year) %>%
  distinct(fips) %>%
  summarise(Category = "All", n = n(),
            Provm = mean(Prov), ProvSD = sd(Prov),
            PopIRSm = mean(PopIRS), PopIRSSD = sd(PopIRS),
            HHIncIRSm = mean(HHIncIRS), HHIncIRSSD = sd(HHIncIRS),
            HHWageIRSm = mean(HHWageIRS), HHWageIRSSD = sd(HHWageIRS)) -> t1
# "Farm Bill Loans"
fipdata %>%
  group_by(year) %>%
  filter(ibip1234) %>%
  distinct(fips) %>%
  summarise(Category = "Farm Bill", n = n(),
            Provm = mean(Prov), ProvSD = sd(Prov),
            PopIRSm = mean(PopIRS), PopIRSSD = sd(PopIRS),
            HHIncIRSm = mean(HHIncIRS), HHIncIRSSD = sd(HHIncIRS),
            HHWageIRSm = mean(HHWageIRS), HHWageIRSSD = sd(HHWageIRS)) -> t3
# Pilot Loans
fipdata %>%
  group_by(year) %>%
  filter(ipilot) %>%
  distinct(fips) %>%
  summarise(Category = "Pilot", n = n(),
            Provm = mean(Prov), ProvSD = sd(Prov),
            PopIRSm = mean(PopIRS), PopIRSSD = sd(PopIRS),
            HHIncIRSm = mean(HHIncIRS), HHIncIRSSD = sd(HHIncIRS),
            HHWageIRSm = mean(HHWageIRS), HHWageIRSSD = sd(HHWageIRS)) -> t4
ta <- bind_rows(t1, t3, t4)
ta <- arrange(ta, year, Category)

fiptable <- function(ta){
  pta <- data.frame(year = as.character(ta$year))
  pta <- cbind(pta, sapply(ta[,2:11], function(x)
    prettyNum(x, big.mark = ",", digits = 3, drop0trailing = T)))
  pta
  pta$Providers  <- paste0(pta$Provm, " (", pta$ProvSD, ")")
  pta$Population <- paste0(pta$PopIRSm, " (", pta$PopIRSSD, ")")
  pta$Income     <- paste0("$", pta$HHIncIRSm, " ($", pta$HHIncIRSSD, ")")
  pta$Wages      <- paste0("$", pta$HHWageIRSm, " ($", pta$HHWageIRSSD, ")")
  pta <- select(pta, year:n, Providers, Population, Income, Wages)
  
  return(pta)
}

fiptable2 <- function(ta){
  pta <- data.frame(year = as.character(ta$year))
  pta <- cbind(pta, sapply(ta[, 4:11], function(x)
    prettyNum(x, big.mark = ",", digits = 3, drop0trailing = T)))
  pta
  pta$Providers  <- paste0(pta$Provm, " (", pta$ProvSD, ")")
  pta$Population <- paste0(pta$PopIRSm, " (", pta$PopIRSSD, ")")
  pta$Income     <- paste0("$", pta$HHIncIRSm, " ($", pta$HHIncIRSSD, ")")
  pta$Wages      <- paste0("$", pta$HHWageIRSm, " ($", pta$HHWageIRSSD, ")")
  pta <- select(pta, year, Providers, Population, Income, Wages)
  
  return(pta)
}

pta <- fiptable(ta)
write.csv(pta, paste0(localDir, "/Fips_Stats.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/Fips_Stats.tex"))

# All
pta <- fiptable2(t1)
write.csv(pta, paste0(localDir, "/Fips_Stats_All.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/Fips_Stats_All.tex"))
# Farm Bill
pta <- fiptable2(t3)
write.csv(pta, paste0(localDir, "/Fips_Stats_FB.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/Fips_Stats_FB.tex"))
# Pilot
pta <- fiptable2(t4)
write.csv(pta, paste0(localDir, "/Fips_Stats_Pilot.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F,
          out = paste0(localDir, "/Fips_Stats_Pilot.tex"))

# ---- FIP Attributes Graph -----------------------------------------------
fipdata %>%
  filter(ipilot) %>%
  select(fips, time, PopIRS, HHIncIRS, HHWageIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, HHWageIRS, Prov) -> fipall2
fipall2$class <- "Pilot"
fipdata %>%
  filter(ibip1234) %>%
  select(fips, time, PopIRS, HHIncIRS, HHWageIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, HHWageIRS, Prov) -> fipall3
fipall3$class <- "Farm Bill"
fipdata %>%
  filter(!ipilot | !ibip1234) %>%
  select(fips, time, PopIRS, HHIncIRS, HHWageIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, HHWageIRS, Prov) -> fipall4
fipall4$class <- "No Loan"
fipall <- bind_rows(fipall2, fipall3, fipall4)

fipall$class <- factor(fipall$class, levels=c("No Loan", "Pilot", "Farm Bill"),
                       labels = c("None", "Pilot", "Farm Bill"))
levels(fipall$key) <- c("Population", "Mean Income", "Mean Wages", "Providers")

ggplot(fipall, aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth", size = 2) +
  geom_vline(xintercept = as.numeric(as.Date("2001-12-31")),
             color = "black", linetype = "longdash") +
  geom_vline(xintercept = as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash") +
  facet_grid(key~., scales = "free_y") + labs(x = "", y = "") +
  scale_y_continuous(labels = comma) +
  guides(color = guide_legend(title = "Loan Type")) +
  theme_minimal() + 
  theme(legend.position = "bottom",
        strip.text.y = element_text(size = 10, face = "bold"))
ggsave(paste0(localDir, "/Fips_attributes.png"), width = 10, height = 7.5)


# ---- RUC ----------------------------------------------------------------
data$ruc    <- factor(data$ruc03)
levels(data$ruc) <- list("Urban" = 1:3, "Rural-Adjacent" = c(4,6,8),
                         "Rural-Nonadjacent" = c(5,7,9))
data$loantype <- ifelse(data$iloans, "YES", "NONE")
data$loantype <- ifelse(data$ipilot, "PILOT", data$loantype)
data$loantype <- ifelse(data$ibip1234, "FARM BILL", data$loantype)
data$loantype <- factor(data$loantype,
                        levels = c("NONE", "PILOT", "FARM BILL"))


data %>% 
  select(zip, time, ruc, loantype, Prov_num, fips, SUMBLKPOP) %>% 
  gather(key, value, Prov_num) -> RUC

RUC$zero <- ifelse(RUC$value == 0, 1, 0)


# ---- RUC tables ---------------------------------------------------------

RUC %>%
  group_by(loantype, time) %>%
  summarise(tots = format(sum(zero, na.rm = T), big.mark = ","),
            per = sprintf("(%.1f%%)", 100*sum(zero, na.rm = T) / n())) %>% 
  unite(temp, tots, per, sep = " ") %>% 
  spread(loantype, temp) -> temp
temp$time <- as.character(temp$time)
knitr::kable(temp, caption = "ZIP Codes Without Access")
write.csv(temp, paste0(localDir, "/ZIP_loan_time.csv"), row.names = F)
stargazer(temp, summary = F, rownames = F,
          out = paste0(localDir, "/ZIP_loan_time.tex"))

# RUC %>%
#   group_by(loantype, time) %>%
#   summarise(value = sprintf("%.1f %%", 100*sum(zero, na.rm = T) / n())) %>% 
#   spread(loantype, value) %>% 
#   knitr::kable(caption = "Percent Zip Codes Without Access")
# ----
# RUC %>% 
#   group_by(ruc) %>% 
#   summarise(`FARM BILL`=sprintf("%.1f %%",100*sum(loantype=="FARM BILL")/n()),
#             NONE   = sprintf("%.1f %%",100*sum(loantype == "NONE")/n()),
#             PILOT  = sprintf("%.1f %%",100*sum(loantype == "PILOT")/n())) %>% 
#   knitr::kable(caption = "")

RUC %>% 
  group_by(loantype) %>% 
  summarise(Metro = sprintf("%.1f %%", 100*sum(ruc == "Urban") / n()),
            `Rural Adjacent` = sprintf("%.1f %%",
                                       100*sum(ruc == "Rural-Adjacent") / n()),
            `Rural Non-Adjacent` = sprintf("%.1f %%",
                                           100*sum(ruc == "Rural-Nonadjacent") /
                                             n())) -> temp
knitr::kable(temp, caption = "County Class by Loan Type")
write.csv(temp, paste0(localDir, "/Fips_class_loan.csv"), row.names = F)
stargazer(temp, summary = F, rownames = F,
          out = paste0(localDir, "/Fips_class_loan.tex"))

# ---- RUC graph ----------------------------------------------------------
temp <- RUC %>%
  group_by(time, fips, ruc) %>%
  summarise(Prov = weighted.mean(value, SUMBLKPOP + 1))

ggplot(temp, aes(x = time, y = Prov, colour = ruc, group = ruc)) +
  stat_smooth(size = 2) +
  geom_vline(xintercept = as.numeric(as.Date("2001-12-31")),
             color = "black", linetype = "longdash") +
  geom_vline(xintercept = as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash") +
  scale_y_continuous(labels = comma) +
  guides(color = guide_legend(title = "County Class")) +
  theme_minimal() + labs(x = "", y = "Mean Number of Providers") +
  theme(legend.position = "bottom",
        strip.text.y = element_text(size = 20, face = "bold"))
ggsave(paste0(localDir, "/Providers_zip_time_RUC.png"),
       width = 10, height = 7.5)

# ----
rm(list=ls())

print(paste0("Finished 2-USDA_Evaluation_Figures at ", Sys.time()))