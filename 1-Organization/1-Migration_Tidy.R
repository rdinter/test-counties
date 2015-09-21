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

# ---- NEXT ---------------------------------------------------------------

# Need to make sure to change the -1 to NA in the flows data, then change
#  classification of values
nonmig <- allindata$State_Code_Origin == 63 & allindata$County_Code_Origin == 50
allindata %>%
  mutate(Return_Num_ = replace(Return_Num, Return_Num == -1 | is.na(Return_Num),
                               NA),
         Exmpt_Num_ = replace(Exmpt_Num, Exmpt_Num == -1 | is.na(Exmpt_Num),
                              NA),
         Aggr_AGI_ = replace(Aggr_AGI, Aggr_AGI == -1 | is.na(Aggr_AGI),
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
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin %in% c(10, 20), 58),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin %in% c(10, 20), 0),
         # Different State
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin %in% c(10, 20), 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                              County_Code_Origin %in% c(10, 20), 0),
         # Northeast
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin == 11, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin == 11, 1),
         # Midwest
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin == 12, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                              County_Code_Origin == 12, 3),
         # South
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin == 13, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                              County_Code_Origin == 13, 5),
         # West
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin == 14, 59),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                              County_Code_Origin == 14, 7),
         # Foreign Other
         State_Code_Origin = replace(State_Code_Origin, State_Code_Origin == 63 &
                             County_Code_Origin == 15, 57),
         County_Code_Origin = replace(County_Code_Origin, State_Code_Origin == 63 &
                              County_Code_Origin == 15, 9)
         ) -> allin
# Next, need to add in summed foreign values
allin %>% 
  filter(State_Code_Origin == 57, year < 1995) %>% 
  group_by(year, State_Code_Dest, County_Code_Dest) %>% 
  summarise_each(funs(sum), Return_Num:Aggr_AGI, Return_Num_:Aggr_AGI_) -> temp
temp$State_Code_Origin  <- 98
temp$County_Code_Origin <- 0
allin <- bind_rows(allin, temp)

# # Finally, we need the US values of 97000 
# allin %>% 
#   filter(State_Code_Origin %in% c(96, 98) |
#            (State_Code_Origin == 97 & County_Code_Origin == 0)) %>% 
#   group_by(year, State_Code_Dest, County_Code_Dest) %>%
#   summarise(n = n()) -> j5


alloutdata %>%
  mutate(Return_Num_ = replace(Return_Num, Return_Num == -1 | is.na(Return_Num),
                               NA),
         Exmpt_Num_ = replace(Exmpt_Num, Exmpt_Num == -1 | is.na(Exmpt_Num),
                              NA),
         Aggr_AGI_ = replace(Aggr_AGI, Aggr_AGI == -1 | is.na(Aggr_AGI),
                             NA)) -> allout

# Next step is to fix any county issues ... new counties and merged counties!

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
