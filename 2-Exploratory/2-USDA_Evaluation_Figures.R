# Robert Dinterman

print(paste0("Started 2-USDA_Evaluation_Figures at ", Sys.time()))

suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(scales))
suppressMessages(library(stargazer))
suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "2-Exploratory/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")

# Uniform distribution for the suppressed providers
set.seed(324) # Done for pretty histograms
data$Prov_hist <- ifelse(data$Prov_num == 2,
                         runif(sum(data$Prov_num == 2),1,3),
                         data$Prov_num)

hp <- ggplot(data, aes(x = Prov_hist)) + geom_histogram() +
  coord_cartesian(xlim = c(0, 15)) 
hp + facet_wrap(~ time) + theme_minimal() +
  scale_x_discrete(breaks = c(5, 10, 15)) +
  labs(x = "Number of Providers", y = "")#,
       #title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Providers_zip_time.png"), width = 10, height = 7.5)

# Plot for uptake
data %>%
  group_by(time) %>%
  summarise(Access = sum(Prov_num > 0) / n()) -> access
sc1 <- ggplot(access, aes(x = time, y = Access))
sc1 + stat_smooth() + theme_minimal() +
  labs(x = "Year", y = "Proportion with Broadband Access")#,
       #title = "Zip Codes with Broadband Access")
ggsave(paste0(localDir, "/ZIP_no_bb_up.png"), width = 10, height = 7.5)

# Plot for no access
data %>%
  group_by(time) %>%
  summarise(Access = sum(Prov_num == 0) / n()) -> noaccess
sc2 <- ggplot(noaccess, aes(x = time, y = Access))
sc2 + stat_smooth() + theme_minimal() +
  labs(x = "Year", y = "Proportion without Broadband Access")#,
       #title = "Zip Codes without Broadband Access")
ggsave(paste0(localDir, "/ZIP_no_bb_down.png"), width = 10, height = 7.5)

# When did the loans occur:
ltime <- data.frame(loan = c("Pilot", "Current"),
                    time = as.numeric(as.Date(c("2001-12-31", "2003-12-31"))),
                    year = c(2002, 2004),
                    disp = c("black", "red"))

data %>%
  group_by(year) %>%
  distinct(zip) %>%
  summarise(loans   = sum(loans),
            pilot   = sum(ploans),
            current = sum(biploans1234)) -> ggloans
ggplot(ggloans, aes(x = year, y = loans)) + geom_line() + theme_minimal() +
  scale_y_continuous(breaks = seq(0, 3000, 500)) +
  geom_vline(xintercept = 2002, color = "black", linetype = "longdash") +
  geom_vline(xintercept = 2004, color = "red", linetype = "longdash") +
  labs(x = "", y = "Cumulative Loans Awarded")#,
       #title = "USDA Loans by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Loan_award_time.png"), width = 10, height = 7.5)

# # A Barplot of loans by year?
# ggplot(mtc, aes(x = factor(gear))) + geom_bar(stat = "bin")


# Summary for all across time ... ? But these are ZIPS not FIPS -----------

data %>%
  group_by(year) %>%
  distinct(zip) %>%
  summarise(Category = "All Zips", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            TRI = mean(tri), TRISD = sd(tri)) -> t1
# Any Loans
data %>%
  group_by(year) %>%
  filter(ipilot | ibip1234) %>%
  distinct(zip) %>%
  summarise(Category = "Any", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            TRI = mean(tri), TRISD = sd(tri)) -> t2
# "Current Loans"
data %>%
  group_by(year) %>%
  filter(ibip1234) %>%
  distinct(zip) %>%
  summarise(Category = "Current", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            TRI = mean(tri), TRISD = sd(tri)) -> t3
# Pilot Loans
data %>%
  group_by(year) %>%
  filter(ipilot) %>%
  distinct(zip) %>%
  summarise(Category = "Pilot", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            TRI = mean(tri), TRISD = sd(tri)) -> t4
# No Loans
data %>%
  group_by(year) %>%
  filter(!ipilot | !ibip1234) %>%
  distinct(zip) %>%
  summarise(Category = "ZNo Loans", n = n(),
            Prov = mean(Prov_num), ProvSD = sd(Prov_num),
            Est = mean(est), EstSD = sd(est),
            Emp = mean(emp_), EmpSD = sd(emp_),
            TRI = mean(tri), TRISD = sd(tri)) -> t5
ta  <- bind_rows(t1, t3, t4)
ta  <- arrange(ta, year, Category)
pta <- data.frame(year = as.character(ta$year))
pta <- cbind(pta, sapply(ta[,2:11], function(x)
  prettyNum(x, big.mark = ",", digits = 3, drop0trailing = T)))
pta

pta$Providers <- paste0(pta$Prov, " (", pta$ProvSD, ")")
pta$Establishments <- paste0(pta$Est, " (", pta$EstSD, ")")
pta$Employed <- paste0(pta$Emp, " (", pta$EmpSD, ")")
pta$TRI <- paste0(pta$TRI, " (", pta$TRISD, ")")
pta <- select(pta, year:n, Providers, Establishments, Employed, TRI)

write.csv(pta, paste0(localDir, "/Zip_Stats.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F)

# Try this with a ggplot2 description... ----------------------------------

data %>%
  select(zip, time, Prov_hist, est, emp_) %>%
  gather(key, value, Prov_hist, est, emp_) -> all
all$class <- "all"
# ipilot, ibip12, ibip1234, iloans
data %>%
  filter(iloans) %>%
  select(zip, time, Prov_hist, est, emp_) %>%
  gather(key, value, Prov_hist, est, emp_) -> all1
all1$class <- "Any Loan"
data %>%
  filter(ipilot) %>%
  select(zip, time, Prov_hist, est, emp_) %>%
  gather(key, value, Prov_hist, est, emp_) -> all2
all2$class <- "Pilot"
data %>%
  filter(ibip1234) %>%
  select(zip, time, Prov_hist, est, emp_) %>%
  gather(key, value, Prov_hist, est, emp_) -> all3
all3$class <- "Current"
data %>%
  filter(!ipilot | !ibip1234) %>%
  select(zip, time, Prov_hist, est, emp_) %>%
  gather(key, value, Prov_hist, est, emp_) -> all4
all4$class <- "No Loan"
test <- bind_rows(all2, all3, all4)

test$class <- factor(test$class, levels = c("No Loan", "Pilot", "Current"),
                     labels = c("None", "Pilot", "Current"))
levels(test$key) <- c("Providers", "Establishments", "Employed")
test$key <- factor(test$key, levels=rev(levels(test$key)))

ggplot(filter(test, key == "Providers"),
       aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

ggplot(filter(test, key == "Establishments"),
       aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

ggplot(filter(test, key == "Employed"),
       aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

# facet_grid

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
# FIPS Data ---------------------------------------------------------------

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
#             Area = mean(AREA), AreaSD = sd(AREA)) %>% View

# Try this with a ggplot2 description...
fipdata <- data %>%
  group_by(fips, year) %>%
  summarise(n = n(), PopIRS = mean(Pop_IRS), PopPOV = mean(POP_POV),
         HHInc = mean(MEDHHINC_R), HHIncIRS = mean(AGI_IRS_R*1000 / HH_IRS),
         HHWageIRS = mean(Wages_IRS_R*1000 / HH_IRS), Area = mean(AREA),
         Pilot = sum(ploans), Current = sum(biploans1234), 
         Prov = sum(Prov_hist)/n, ipilot = !all(!ipilot),
         ibip1234 = !all(!ibip1234), iloans = !all(!iloans))

# # KKLR Check:
# library(knitr)
# fipdata %>% group_by(year, iloans) %>%
#   summarise(n = n(), Pop_IRS = mean(PopIRS), Pop_IRS_sd = sd(PopIRS),
#             Pop_POV = mean(PopPOV), Pop_POV_sd = sd(PopPOV),
#             HHInc_IRS = mean(HHIncIRS), HHInc_IRS_sd = sd(HHIncIRS),
#             MEDInc = mean(HHInc), MEDInc_sd = sd(HHInc)) %>% kable

# All
fipdata %>%
  group_by(year) %>%
  distinct(fips) %>%
  summarise(Category = "All", n = n(),
            Provm = mean(Prov), ProvSD = sd(Prov),
            PopIRSm = mean(PopIRS), PopIRSSD = sd(PopIRS),
            HHIncIRSm = mean(HHIncIRS), HHIncIRSSD = sd(HHIncIRS),
            HHWageIRSm = mean(HHWageIRS), HHWageIRSSD = sd(HHWageIRS)) -> t1
# "Current Loans"
fipdata %>%
  group_by(year) %>%
  filter(ibip1234) %>%
  distinct(fips) %>%
  summarise(Category = "Current", n = n(),
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
pta <- data.frame(year = as.character(ta$year))
pta <- cbind(pta, sapply(ta[,2:11], function(x)
  prettyNum(x, big.mark = ",", digits = 3, drop0trailing = T)))
pta
pta$Providers <- paste0(pta$Provm, " (", pta$ProvSD, ")")
pta$Population <- paste0(pta$PopIRSm, " (", pta$PopIRSSD, ")")
pta$Income <- paste0(pta$HHIncIRSm, " (", pta$HHIncIRSSD, ")")
pta$Wages <- paste0(pta$HHWageIRSm, " (", pta$HHWageIRSSD, ")")
pta <- select(pta, year:n, Providers, Population, Income, Wages)
write.csv(pta, paste0(localDir, "/Fips_Stats.csv"), row.names = F)
stargazer(pta, summary = F, rownames = F)


fipdata %>%
  filter(ipilot) %>%
  select(fips, year, PopIRS, HHIncIRS, HHWageIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, HHWageIRS, Prov) -> fipall2
fipall2$class <- "Pilot"
fipdata %>%
  filter(ibip1234) %>%
  select(fips, year, PopIRS, HHIncIRS, HHWageIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, HHWageIRS, Prov) -> fipall3
fipall3$class <- "Current"
fipdata %>%
  filter(!ipilot | !ibip1234) %>%
  select(fips, year, PopIRS, HHIncIRS, HHWageIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, HHWageIRS, Prov) -> fipall4
fipall4$class <- "No Loan"
fipall <- bind_rows(fipall2, fipall3, fipall4)


fipall$class <- factor(fipall$class, levels = c("No Loan", "Pilot", "Current"),
                       labels = c("None", "Pilot", "Current"))
levels(fipall$key) <- c("Population", "Mean Income", "Mean Wages", "Providers")

# facet_grid

ggplot(fipall, aes(x = year, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth", size = 2) +
  geom_vline(xintercept = 2002, color = "black", linetype = "longdash") +
  geom_vline(xintercept = 2004, color = "red", linetype = "longdash") +
  facet_grid(key~., scales = "free_y") + labs(x = "", y = "") +
  scale_y_continuous(labels = comma) +
  guides(color = guide_legend(title = "Loan Type")) +
  theme_minimal() + 
  theme(legend.position = "bottom",
        strip.text.y = element_text(size = 10, face = "bold"))
ggsave(paste0(localDir, "/Fips_attributes.png"), width = 10, height = 7.5)


rm(list=ls())

print(paste0("Finished 2-USDA_Evaluation_Figures at ", Sys.time()))