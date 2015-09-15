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

# Need to make sure to change the -1 to NA in the flows data ...

allindata %>%
  mutate(Return_Num_ = replace(Return_Num, Return_Num == -1 | is.na(Return_Num),
                               NA),
         Exmpt_Num_ = replace(Exmpt_Num, Exmpt_Num == -1 | is.na(Exmpt_Num),
                              NA),
         Aggr_AGI_ = replace(Aggr_AGI, Aggr_AGI == -1 | is.na(Aggr_AGI),
                             NA),
         STFIP_o = replace(State_Code_Origin, State_Code_Origin == 0, 96),
         CTYFIP_o = replace(County_Code_Origin, State_Code_Origin == 0, 0),
         
         
         STFIP_o = replace(STFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin %in% c(10, 20), 97),
         CTYFIP_o = replace(CTYFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin %in% c(10, 20), 1),
         
         STFIP_o = replace(STFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin == 11, 59),
         CTYFIP_o = replace(CTYFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin == 11, 1),
         
         STFIP_o = replace(STFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin == 12, 59),
         CTYFIP_o = replace(CTYFIP_o, State_Code_Origin == 63 &
                              County_Code_Origin == 12, 3),
         
         STFIP_o = replace(STFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin == 13, 59),
         CTYFIP_o = replace(CTYFIP_o, State_Code_Origin == 63 &
                              County_Code_Origin == 13, 5),
         
         STFIP_o = replace(STFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin == 14, 59),
         CTYFIP_o = replace(CTYFIP_o, State_Code_Origin == 63 &
                              County_Code_Origin == 14, 7),
         
         STFIP_o = replace(STFIP_o, State_Code_Origin == 63 &
                             County_Code_Origin == 50, State_Code_Dest),
         CTYFIP_o = replace(CTYFIP_o, State_Code_Origin == 63 &
                              County_Code_Origin == 50, County_Code_Dest)
         
         ) -> allin

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
