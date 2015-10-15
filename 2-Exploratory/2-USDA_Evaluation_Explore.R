# Robert Dinterman

print(paste0("Started 2-USDA_Evaluation_Explore at ", Sys.time()))

library(dplyr)
library(ggplot2)
library(tidyr)

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
  labs(x = "Number of Providers", y = "",
       title = "Broadband Providers by Zip Code \n Across Time")
ggsave(paste0(localDir, "/Providers_zip_time.png"), width = 10, height = 7.5)

# Plot for uptake
data %>%
  group_by(time) %>%
  summarise(Access = sum(Prov_num > 0) / n()) -> access
sc1 <- ggplot(access, aes(x = time, y = Access))
sc1 + stat_smooth() + theme_minimal() +
  labs(x = "Year", y = "Proportion with Broadband Access",
       title = "Zip Codes with Broadband Access")
ggsave(paste0(localDir, "/ZIP_no_bb_up.png"), width = 10, height = 7.5)

# Plot for no access
data %>%
  group_by(time) %>%
  summarise(Access = sum(Prov_num == 0) / n()) -> noaccess
sc2 <- ggplot(noaccess, aes(x = time, y = Access))
sc2 + stat_smooth() + theme_minimal() +
  labs(x = "Year", y = "Proportion without Broadband Access",
       title = "Zip Codes without Broadband Access")
ggsave(paste0(localDir, "/ZIP_no_bb_down.png"), width = 10, height = 7.5)

# When did the loans occur:
ltime <- data.frame(loan = c("Pilot", "Farm Bill"),
                    time = as.numeric(as.Date(c("2001-12-31", "2003-12-31"))),
                    year = c(2002, 2004),
                    disp = c("black", "red"))

data %>%
  group_by(year) %>%
  distinct(zip) %>%
  summarise(loans   = sum(loans),
            pilot   = sum(ploans),
            `Farm Bill` = sum(biploans1234)) -> ggloans
ggplot(ggloans, aes(x = year, y = loans)) + geom_line() + theme_minimal() +
  scale_y_continuous(breaks = seq(0, 3000, 500)) +
  geom_vline(xintercept=as.numeric(as.Date("2001-12-31")),
             color = "black", linetype = "longdash") +
  geom_vline(xintercept=as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash") +
  labs(x = "Loans Awarded", y = "",
       title = "USDA Loan Awards by Zip Code \n Across Time")
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
            TRI = mean(tri), TRISD = sd(tri),
            AREA = mean(AREA_zcta), AREASD = sd(AREA_zcta)) -> t5
ta <- bind_rows(t1, t3, t4)
ta <- arrange(ta, year, Category)
write.csv(ta, paste0(localDir, "/Zip_Stats.csv"), row.names = F)


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
all3$class <- "Farm Bill"
data %>%
  filter(!ipilot | !ibip1234) %>%
  select(zip, time, Prov_hist, est, emp_) %>%
  gather(key, value, Prov_hist, est, emp_) -> all4
all4$class <- "No Loan"
test <- bind_rows(all2, all3, all4)

ggplot(filter(test, key == "Prov_hist"),
       aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

ggplot(filter(test, key == "est"),
       aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

ggplot(filter(test, key == "emp_"),
       aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") + theme_minimal()

# facet_grid

ggplot(test,aes(x = time, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth", size = 2) +
  geom_vline(xintercept=as.numeric(as.Date("2001-12-31")),
             color = "black", linetype = "longdash") +
  geom_vline(xintercept=as.numeric(as.Date("2003-12-31")),
             color = "red", linetype = "longdash") +
  facet_grid(key~., scales = "free_y")
ggsave(paste0(localDir, "/Zip_attributes.png"), width = 10, height = 7.5)


# FIPS Data ---------------------------------------------------------------

data %>%
  group_by(year) %>%
  distinct(fips) %>%
  summarise(n = n(), PopIRS = mean(Pop_IRS), PopIRSSD = sd(Pop_IRS),
            PopPOV = mean(POP_POV), PopPOVSD = sd(POP_POV),
            HHInc = mean(MEDHHINC_R), HHIncSD = sd(MEDHHINC_R),
            HHIncIRS = mean(AGI_IRS_R*1000 / HH_IRS),
            HHIncIRSSD = sd(AGI_IRS_R*1000 / HH_IRS),
            Area_cty = mean(AREA_cty), AreaSD = sd(AREA_cty))

# Try this with a ggplot2 description...
fipdata <- data %>%
  group_by(fips, year) %>%
  summarise(n = n(), PopIRS = mean(Pop_IRS), PopPOV = mean(POP_POV),
         HHInc = mean(MEDHHINC_R), HHIncIRS = mean(AGI_IRS_R*1000 / HH_IRS),
         Area = mean(AREA_cty), Pilot = sum(ploans),
         `Farm Bill` = sum(biploans1234),
         Prov = sum(Prov_hist)/n, ipilot = !all(!ipilot),
         ibip1234 = !all(!ibip1234))

fipdata %>%
  filter(ipilot) %>%
  select(fips, year, PopIRS, HHIncIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, Prov) -> fipall2
fipall2$class <- "Pilot"
fipdata %>%
  filter(ibip1234) %>%
  select(fips, year, PopIRS, HHIncIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, Prov) -> fipall3
fipall3$class <- "Farm Bill"
fipdata %>%
  filter(!ipilot | !ibip1234) %>%
  select(fips, year, PopIRS, HHIncIRS, Prov) %>%
  gather(key, value, PopIRS, HHIncIRS, Prov) -> fipall4
fipall4$class <- "No Loan"
fipall <- bind_rows(fipall2, fipall3, fipall4)

# facet_grid

ggplot(fipall, aes(x = year, y = value, colour = class, group = class)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "smooth") +
  geom_vline(xintercept = 2002,
             color = "black", linetype = "longdash") +
  geom_vline(xintercept = 2004,
             color = "red", linetype = "longdash") +
  facet_grid(key~., scales = "free_y")


rm(list=ls())

print(paste0("Finished 2-USDA_Evaluation_Explore at ", Sys.time()))