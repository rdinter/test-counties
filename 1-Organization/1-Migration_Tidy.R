# Robert Dinterman

# ---- Start --------------------------------------------------------------

print(paste0("Started 1-Migration_Tidy at ", Sys.time()))

suppressMessages(library(dplyr))
suppressMessages(library(maptools))
suppressMessages(library(readr))
suppressMessages(library(tidyr))

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
allin <- bind_rows(allin, temp)

# Finally, we need the US values of 97000 
temp <- allin %>% 
  filter(State_Code_Origin %in% c(96, 98), year < 1995) %>% 
  group_by(year, State_Code_Dest, County_Code_Dest) %>%
  na.omit(Return_Num) %>% 
  summarise(Return_Num = Return_Num[State_Code_Origin == 96] -
              max(0, Return_Num[State_Code_Origin == 98]),
            Exmpt_Num = Exmpt_Num[State_Code_Origin == 96] -
              max(0, Exmpt_Num[State_Code_Origin == 98]),
            Aggr_AGI = Aggr_AGI[State_Code_Origin == 96] -
              max(0, Aggr_AGI[State_Code_Origin == 98]))
temp$State_Code_Origin  <- 97
temp$County_Code_Origin <- 0
allin <- bind_rows(allin, temp)

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
allout <- bind_rows(allout, temp)

# Finally, we need the US values of 97000 
temp <- allout %>% 
  filter(State_Code_Dest %in% c(96, 98), year < 1995) %>% 
  group_by(year, State_Code_Origin, County_Code_Origin) %>%
  na.omit(Return_Num) %>% 
  summarise(Return_Num = Return_Num[State_Code_Dest == 96] -
              max(0, Return_Num[State_Code_Dest == 98]),
            Exmpt_Num = Exmpt_Num[State_Code_Dest == 96] -
              max(0, Exmpt_Num[State_Code_Dest == 98]),
            Aggr_AGI = Aggr_AGI[State_Code_Dest == 96] -
              max(0, Aggr_AGI[State_Code_Dest == 98]))
temp$State_Code_Dest  <- 97
temp$County_Code_Dest <- 0
allout <- bind_rows(allout, temp)

allout$ofips <- 1000*allout$State_Code_Origin + allout$County_Code_Origin
allout$dfips <- 1000*allout$State_Code_Dest + allout$County_Code_Dest


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

# Think about how to aggregate all of them ... they need to be in long form
#  Do I take an average? Sure! 
 
###################################################
# http://blogs.casa.ucl.ac.uk/category/r-spatial/
###################################################

xquiet <- scale_x_continuous("", breaks = NULL)
yquiet <- scale_y_continuous("", breaks = NULL)
quiet  <- list(xquiet, yquiet)

ggplot(dest.xy[which(dest.xy$trips>10),], aes(oX, oY)) +
  geom_segment(aes(x = oX, y = oY, xend = dX, yend = dY, alpha = trips),
               col = "white") +
  scale_alpha_continuous(range = c(0.03, 0.3)) +
  theme(panel.background = element_rect(fill = "black", colour = "black")) +
  quiet +
  coord_equal()

# write_csv(DATA, paste0(localDir, "/Migration.csv"))
# save(DATA, file = paste0(localDir, "/Migration.Rda"))


# Merge all of the control variables needed in this setting! Likely as a
#  separate file and saved, but then as a totally massive freaking data.frame
#  with Ocontrols and Dcontrols

# write_csv(data, paste0(localDir, "/Final.csv"))
# save(data, file = paste0(localDir, "/Final.Rda"))

rm(list = ls())

print(paste0("Finished 1-Migration_Tidy at ", Sys.time()))
