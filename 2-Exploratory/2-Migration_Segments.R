# Robert Dinterman

# ---- Start --------------------------------------------------------------

print(paste0("Started 2-Migration_Segments at ", Sys.time()))

suppressMessages(library(dplyr))
suppressMessages(library(maptools))
suppressMessages(library(readr))
suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "2-Exploratory/Migration"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/Migration/ctycty.Rda")
load("0-Data/Shapefiles/All_2010_county.Rda")

All   <- subset(All, FIPS < 57000)

cty04 <- ctycty %>% 
  filter(year > 2003, !is.na(lat.d), !is.na(lat.o),
         !(floor(dfips / 1000) %in% c(2, 15)), # Remove AK and HI
         !(floor(ofips / 1000) %in% c(2, 15)),
         !(dfips == ofips)) %>% # Removes non-migrants
  group_by(dfips, ofips, long.d, lat.d, long.o, lat.o) %>% 
  summarise_each(funs(sum(., na.rm = T)), -year) %>% data.frame()

###################################################
# http://blogs.casa.ucl.ac.uk/category/r-spatial/
###################################################
library(ggplot2)
xquiet <- scale_x_continuous("", breaks = NULL)
yquiet <- scale_y_continuous("", breaks = NULL)
quiet  <- list(xquiet, yquiet)

ggplot(filter(cty04, ntile(Return, 100) > 75), aes(long.o, lat.o)) +
  geom_curve(aes(x = long.o, y = lat.o, xend = long.d, yend = lat.d,
                   size = Return), col = "white") +
  scale_alpha_continuous(range = c(0.03, 0.3)) +
  theme(panel.background = element_rect(fill = "black", colour = "black")) +
  quiet + coord_equal()
