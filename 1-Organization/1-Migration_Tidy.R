# Robert Dinterman

# ---- Start --------------------------------------------------------------

print(paste0("Started 1-Migration_Tidy at ", Sys.time()))

library(dplyr)
library(maptools)
library(readr)
library(tidyr)

# Create a directory for the data
localDir <- "1-Organization/Migration"
if (!file.exists(localDir)) dir.create(localDir)

load("0-Data/IRS/inflows9213.Rda")
load("0-Data/IRS/outflows9213.Rda")
load("0-Data/Shapefiles/All_2010_county.Rda")

# ---- Clean --------------------------------------------------------------

# Need to make sure to change the -1 to NA in the flows data, then change
#  classification of values
nonmig <- allindata$State_Code_Origin == 63 & allindata$County_Code_Origin == 50
allindata %>%
  select(year, State_Code_Dest:Aggr_AGI) %>% 
  mutate(Return_Num = replace(Return_Num, Return_Num == -1 | is.na(Return_Num),
                              NA),
         Exmpt_Num = replace(Exmpt_Num, Exmpt_Num == -1 | is.na(Exmpt_Num),
                             NA),
         Aggr_AGI = replace(Aggr_AGI, is.na(Return_Num),
                            NA),
         # Total Migration
         County_Code_Origin = replace(County_Code_Origin,
                                      State_Code_Origin == 0, 0),
         State_Code_Origin = replace(State_Code_Origin,
                                     State_Code_Origin == 0, 96),
         
         # Non-migrants
         State_Code_Origin = replace(State_Code_Origin, nonmig,
                                     State_Code_Dest[nonmig]),
         County_Code_Origin = replace(County_Code_Origin, nonmig,
                                      County_Code_Dest[nonmig]),
         
         # Same State
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin %in% c(10, 20), 58),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin %in% c(10, 20), 0),
         # Different State
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin %in% c(10, 20), 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin %in% c(10, 20), 0),
         # Northeast
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin == 11, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin == 11, 1),
         # Midwest
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin == 12, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin == 12, 3),
         # South
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin == 13, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin == 13, 5),
         # West
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin == 14, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin == 14, 7),
         # Foreign Other
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin==63&
                                       County_Code_Origin == 15, 57),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin==63&
                                        County_Code_Origin == 15, 9)
  ) -> allin
# Next, need to add in summed foreign values
# NEED TO DEAL WITH THE -1 AND NA VALUES
temp <- allin %>% 
  filter(State_Code_Origin == 57, year < 1995) %>% 
  group_by(year, State_Code_Dest, County_Code_Dest) %>% 
  summarise_each(funs(sum(., na.rm = T)), Return_Num:Aggr_AGI)
temp$State_Code_Origin  <- 98
temp$County_Code_Origin <- 0
allin                   <- bind_rows(allin, temp)

# Finally, we need the US values of 97000 
temp <- allin %>% 
  select(year:County_Code_Origin, Return_Num:Aggr_AGI) %>% 
  filter(State_Code_Origin %in% c(96, 98), year < 1995) %>% 
  gather(key, value, Return_Num:Aggr_AGI) %>% 
  unite(temp, key, State_Code_Origin) %>% 
  spread(temp, value) %>% 
  mutate(Return_Num = ifelse(is.na(Return_Num_96) & is.na(Return_Num_98), NA,
                             ifelse(is.na(Return_Num_98), Return_Num_96,
                                    Return_Num_96 - Return_Num_98)),
         Exmpt_Num = ifelse(is.na(Exmpt_Num_96) & is.na(Exmpt_Num_98), NA,
                            ifelse(is.na(Exmpt_Num_98), Exmpt_Num_96,
                                   Exmpt_Num_96 - Exmpt_Num_98)),
         Aggr_AGI = ifelse(is.na(Aggr_AGI_96) & is.na(Aggr_AGI_98), NA,
                           ifelse(is.na(Aggr_AGI_98), Aggr_AGI_96,
                                  Aggr_AGI_96 - Aggr_AGI_98))) %>% 
  select(year:County_Code_Origin, Return_Num:Aggr_AGI)

temp$State_Code_Origin  <- 97
temp$County_Code_Origin <- 0
allin                   <- bind_rows(allin, temp)

allin$ofips <- 1000*allin$State_Code_Origin + allin$County_Code_Origin
allin$dfips <- 1000*allin$State_Code_Dest + allin$County_Code_Dest

# OUT DATA
nonmig <- alloutdata$State_Code_Dest == 63 & alloutdata$County_Code_Dest == 50
alloutdata %>%
  select(year, State_Code_Origin:Aggr_AGI) %>% 
  mutate(Return_Num = replace(Return_Num, Return_Num == -1 | is.na(Return_Num),
                              NA),
         Exmpt_Num = replace(Exmpt_Num, Exmpt_Num == -1 | is.na(Exmpt_Num),
                             NA),
         Aggr_AGI = replace(Aggr_AGI, is.na(Return_Num),
                            NA),
         # Total Migration
         County_Code_Dest = replace(County_Code_Dest,
                                    State_Code_Dest == 0, 0),
         State_Code_Dest = replace(State_Code_Dest,
                                   State_Code_Dest == 0, 96),
         
         # Non-migrants
         State_Code_Dest = replace(State_Code_Dest, nonmig,
                                   State_Code_Origin[nonmig]),
         County_Code_Dest = replace(County_Code_Dest, nonmig,
                                    County_Code_Origin[nonmig]),
         
         # Same State
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest %in% c(10, 20), 58),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest %in% c(10, 20), 0),
         # Different State
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest %in% c(10, 20), 59),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest %in% c(10, 20), 0),
         # Northeast
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest == 11, 59),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest == 11, 1),
         # Midwest
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest == 12, 59),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest == 12, 3),
         # South
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest == 13, 59),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest == 13, 5),
         # West
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest == 14, 59),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest == 14, 7),
         # Foreign Other
         State_Code_Dest = replace(State_Code_Dest, State_Code_Dest==63&
                                     County_Code_Dest == 15, 57),
         County_Code_Dest = replace(County_Code_Dest, State_Code_Dest==63&
                                      County_Code_Dest == 15, 9)
  ) -> allout
# Next, need to add in summed foreign values
# NEED TO DEAL WITH THE -1 AND NA VALUES
temp <- allout %>% 
  filter(State_Code_Dest == 57, year < 1995) %>% 
  group_by(year, State_Code_Origin, County_Code_Origin) %>% 
  summarise_each(funs(sum(., na.rm = T)), Return_Num:Aggr_AGI)
temp$State_Code_Dest  <- 98
temp$County_Code_Dest <- 0
allout                <- bind_rows(allout, temp)

# Finally, we need the US values of 97000 
temp <- allout %>% 
  select(year:County_Code_Dest, Return_Num:Aggr_AGI) %>% 
  filter(State_Code_Dest %in% c(96, 98), year < 1995) %>% 
  gather(key, value, Return_Num:Aggr_AGI) %>% 
  unite(temp, key, State_Code_Dest) %>% 
  spread(temp, value) %>% 
  mutate(Return_Num = ifelse(is.na(Return_Num_96) & is.na(Return_Num_98), NA,
                             ifelse(is.na(Return_Num_98), Return_Num_96,
                                    Return_Num_96 - Return_Num_98)),
         Exmpt_Num = ifelse(is.na(Exmpt_Num_96) & is.na(Exmpt_Num_98), NA,
                            ifelse(is.na(Exmpt_Num_98), Exmpt_Num_96,
                                   Exmpt_Num_96 - Exmpt_Num_98)),
         Aggr_AGI = ifelse(is.na(Aggr_AGI_96) & is.na(Aggr_AGI_98), NA,
                           ifelse(is.na(Aggr_AGI_98), Aggr_AGI_96,
                                  Aggr_AGI_96 - Aggr_AGI_98))) %>% 
  select(year:County_Code_Dest, Return_Num:Aggr_AGI)
temp$State_Code_Dest  <- 97
temp$County_Code_Dest <- 0
allout                <- bind_rows(allout, temp)

allout$ofips <- 1000*allout$State_Code_Origin + allout$County_Code_Origin
allout$dfips <- 1000*allout$State_Code_Dest + allout$County_Code_Dest

rm(allindata, alloutdata)

# ---- FIPS Issues --------------------------------------------------------

# Checks: when did: Yuma (4027), Broomfield (8014), Cibola (35006) begin;
# 30113 for yellowstone (1990)
trubs <- c("4027", "8014", "35006", "30113")
allin %>%
  filter(dfips %in% trubs) %>%
  xtabs(~dfips + year, data = .) # Broomfield not until 2002, checks out.

# AK mentions:
trubs <- c("2070", "2185", "2261", "2030", "2040", "2065", "2120", "2160",
           "2190", "2200", "2230", "2250", "2260",
           
           "2013", "2010", "2016", "2164", "2070", "2188", "2140", "2185",
           
           "2068", "2290", "2240", "2232", "2231", "2282",
           
           "2275", "2280", "2201", "2195", "2198", "2130", "2230", "2232",
           "2105",
           
           "2195", "2105", "2158", "2270")
allin %>%
  filter(dfips %in% trubs) %>%
  xtabs(~dfips + year, data = .)

# Next step is to fix any county issues ... new counties and merged counties!
# Need to consider how to do this ... likely just SUM but ignore NA ...
trubs <- c("51013", "51510", "51515", "51520", "51530", "51540", "51560",
           "51570", "51580", "51590", "51595", "51600", "51610", "51620",
           "51630", "51640", "51660", "51670", "51678", "51683", "51685",
           "51690", "51720", "51730", "51750", "51770", "51775", "51780",
           "51790", "51820", "51840")
allin %>%
  filter(dfips %in% trubs) %>%
  xtabs(~dfips + year, data = .)
allin %>%
  filter(ofips %in% trubs) %>%
  xtabs(~ofips + year, data = .)

allout %>% 
  filter(ofips %in% trubs) %>% 
  xtabs(~ofips + year, data = .)

source("1-Organization/1-Migration_functions.R")

allin <- allin %>% 
  mutate(dfips = fipchange(dfips), ofips = fipchange(ofips)) %>%
  group_by(year, dfips, ofips) %>%
  summarise_each(funs(sum(., na.rm = T)), Return_Num, Exmpt_Num, Aggr_AGI)
allin$Return_Num <- ifelse(allin$Return_Num == 0, NA, allin$Return_Num)
allin$Exmpt_Num  <- ifelse(is.na(allin$Return_Num), NA, allin$Exmpt_Num)
allin$Aggr_AGI   <- ifelse(is.na(allin$Return_Num), NA, allin$Aggr_AGI)

allout <- allout %>% 
  mutate(dfips = fipchange(dfips), ofips = fipchange(ofips)) %>%
  group_by(year, dfips, ofips) %>%
  summarise_each(funs(sum(., na.rm = T)), Return_Num, Exmpt_Num, Aggr_AGI)
allout$Return_Num <- ifelse(allout$Return_Num == 0, NA, allout$Return_Num)
allout$Exmpt_Num  <- ifelse(is.na(allout$Return_Num), NA, allout$Exmpt_Num)
allout$Aggr_AGI   <- ifelse(is.na(allout$Return_Num), NA, allout$Aggr_AGI)


# ---- Aggregate Migration ------------------------------------------------

# Two groups: one with only 96000 and the other with cty-cty (incl. 98000)

allintotal  <- allin %>% 
  filter(ofips == 96000, dfips < 57000, dfips %% 1000 != 0) %>% 
  rename(fips = dfips, IN_Return = Return_Num, IN_Exmpt = Exmpt_Num,
         IN_AGI = Aggr_AGI)

allouttotal <- allout %>% 
  filter(dfips == 96000, ofips < 57000, ofips %% 1000 != 0) %>% 
  rename(fips = ofips, OUT_Return = Return_Num, OUT_Exmpt = Exmpt_Num,
         OUT_AGI = Aggr_AGI)

aggdata <- full_join(allintotal, allouttotal)
aggdata <- aggdata %>% 
  select(-dfips, -ofips) %>% 
  mutate(NET_Return = IN_Return - OUT_Return,
         NET_Exmpt = IN_Exmpt - OUT_Exmpt,
         NET_AGI = IN_AGI - OUT_AGI)

save(aggdata, file = paste0(localDir, "/netmigration.Rda"))
write_csv(aggdata, paste0(localDir, "/netmigration.csv"))
rm(allintotal, allouttotal)

# ---- cty2cty ------------------------------------------------------------

incty <- allin %>% 
  filter(dfips %% 1000 != 0|dfips == 98000, dfips < 56999|dfips == 98000,
         ofips %% 1000 != 0|ofips == 98000, ofips < 56999|ofips == 98000) %>% 
  mutate(Return_Num = replace(Return_Num, is.na(Return_Num), -1),
         Exmpt_Num  = replace(Exmpt_Num, is.na(Exmpt_Num), -1),
         Aggr_AGI   = replace(Aggr_AGI, is.na(Aggr_AGI), -1)) %>% 
  rename(IN_Return = Return_Num, IN_Exmpt = Exmpt_Num, IN_AGI = Aggr_AGI)

outcty <- allout %>% 
  filter(dfips %% 1000 != 0|dfips == 98000, dfips < 56999|dfips == 98000,
         ofips %% 1000 != 0|ofips == 98000, ofips < 56999|ofips == 98000) %>% 
  mutate(Return_Num = replace(Return_Num, is.na(Return_Num), -1),
         Exmpt_Num  = replace(Exmpt_Num, is.na(Exmpt_Num), -1),
         Aggr_AGI   = replace(Aggr_AGI, is.na(Aggr_AGI), -1)) %>% 
  rename(OUT_Return = Return_Num, OUT_Exmpt = Exmpt_Num, OUT_AGI = Aggr_AGI)

data <- full_join(incty, outcty)

# ----

# Evaluate the matches of IN versus OUT
data %>% 
  group_by(year) %>% 
  summarise(Total = n(),
            Return = sum(IN_Return == OUT_Return, na.rm = T),
            Exmpt  = sum(IN_Exmpt == OUT_Exmpt, na.rm = T),
            AGI    = sum(IN_AGI == OUT_AGI, na.rm = T),
            Match  = paste0(round(100*Return / Total, 1), "%")) %>%
  knitr::kable()

data %>% 
  group_by(year) %>% 
  summarise(Total = n(),
            SupIN  = sum((IN_Return == -1 | is.na(IN_Return)) &
                           (!is.na(OUT_Return)), na.rm = T),
            SupOUT = sum((OUT_Return == -1 | is.na(OUT_Return)) &
                           (!is.na(IN_Return)), na.rm = T),
            BadMatch = paste0(round(100*(SupIN + SupOUT) / Total, 1),
                              "%")) %>%
  knitr::kable()

# ----

data <- data %>% 
  mutate(Return = ifelse(!is.na(IN_Return), IN_Return, OUT_Return),
         Exmpt  = ifelse(!is.na(IN_Exmpt), IN_Exmpt, OUT_Exmpt),
         AGI    = ifelse(!is.na(IN_AGI), IN_AGI, OUT_AGI))
temp <- data$Return == -1
ctycty <- data %>% 
  as.data.frame() %>% 
  select(year:ofips, Return:AGI) %>% 
  mutate(Return = replace(Return, temp, NA),
         Exmpt  = replace(Exmpt, temp, NA),
         AGI    = replace(AGI, temp, NA))

All <- subset(All, FIPS < 57000)

check <- ctycty$dfips %in% All$FIPS
unique(ctycty$dfips[!check])
# [1]  2195  2198  2230  2105  2275 98000

check <- All$FIPS %in% ctycty$dfips
unique(All$FIPS[!check])
# [1]  2000  2201  2232  2280 17000 18000 23000 26000 27000 36000 39000
# [12] 42000 53000 55000

coords        <- data.frame(coordinates(All))
names(coords) <- c("long", "lat")
coords$fips   <- as.numeric(row.names(coords))

ctycty <- ctycty %>% 
  left_join(coords, by = c("ofips" = "fips")) %>% 
  rename(long.o = long, lat.o = lat) %>% 
  left_join(coords, by = c("dfips" = "fips")) %>% 
  rename(long.d = long, lat.d = lat)

write_csv(ctycty, paste0(localDir, "/ctycty.csv"))
save(ctycty, file = paste0(localDir, "/ctycty.Rda"))

rm(allin, allout, coords, data, incty, outcty)
# ---- Controls -----------------------------------------------------------
load("0-Data/IRS/CTYPop.Rda") # Population, Households, Income for county

# Add in controls...

rm(list = ls())

print(paste0("Finished 1-Migration_Tidy at ", Sys.time()))