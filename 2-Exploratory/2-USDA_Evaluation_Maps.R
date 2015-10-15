# Robert Dinterman

print(paste0("Started 2-USDA_Evaluation_Maps at ", Sys.time()))

library(dplyr)
library(ggplot2)
library(maptools)
library(tidyr)

# Create a directory for the data
localDir <- "2-Exploratory/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
load("0-Data/Shapefiles/All_2010_county.Rda")
load("0-Data/Shapefiles/state.Rda")
load("0-Data/ERS/ERS.Rda")

USA <- All[!(All$STATE %in% c("AK", "HI", "PR", "VI")), ]
rm(All)

data %>%
  filter(year == 2008, iloans) %>%
  select(zip, fips, long, lat, metro13, Pilot = ploans,
         `Farm Bill` = biploans1234, Any = loans) %>%
  gather(key, value, -zip, -fips, -long, -lat, -metro13) -> loans

ERS %>%
  filter(year > 1999) %>%
  select(fips, metro93, metro03, metro13) %>% 
  mutate_each(funs(as.factor), -fips) -> ERS
USA@data <- data.frame(USA@data, ERS[match(as.numeric(USA$FIPS), ERS$fips),])

data %>%
  filter(year == 2008) %>%
  group_by(fips) %>%
  summarise_each(funs(sum), ploans:loans) -> loansfips
USA@data <- data.frame(USA@data, loansfips[match(as.numeric(USA$FIPS),
                                                 loansfips$fips),])

#project for county data
aea.proj  <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-102
+x_0=180 +y_0=50 +ellps=GRS80 +datum=NAD83 +units=m"
#change projection of counties for nice plotting
# coordinates(loans) <- ~long+lat
# proj4string(loans) <- CRS("+proj=longlat +datum=WGS84")

library(rgdal)
loans[,c("long","lat")] <- project(as.matrix(loans[,c("long", "lat")]),
                                   aea.proj)
# ggloans <- spTransform(loans, CRS(aea.proj))
state            <- spTransform(state, CRS(aea.proj))
USA              <- spTransform(USA, CRS(aea.proj))

# ggloans     <- fortify(ggloans)
# ggloans$zip <- as.numeric(ggloans$id)
ggstate     <- fortify(state)
ggusa       <- fortify(USA)
ggusa$fips  <- as.numeric(ggusa$id)
ggusa       <- left_join(ggusa, USA@data)
ggusa       <- arrange(ggusa, order)

usa.plot <- ggplot(data = ggusa, aes(x = long, y = lat, group = group))

usa.plot + geom_polygon(aes(fill = metro03)) +
  geom_path(data = filter(ggusa, !is.na(metro03)), color = "grey", lwd = 0.1) +
  geom_path(data = ggstate, colour = "black", lwd = 0.25) +
  geom_jitter(data = filter(loans, key != "Any"), #size = value, 
             aes(long, lat, color = key, alpha = value^0.5, group = NULL)) +
  #coord_map("albers", lat0 = 29.5, lat1 = 37.5) +  
  scale_fill_manual("County Class",
                    values = c("metro" = "darkkhaki", "nonmetro" = "khaki"),
                    labels = c("Urban", "Rural"), na.value = "blue") +
  scale_colour_manual("Loan", values = c("Pilot" = "black", "Farm Bill" = "red"),
                      na.value = NA) +
  labs(x = "", y = "") +
  guides(colour = guide_legend(override.aes = list(size = 4)),
         size = FALSE, alpha = FALSE) +
  theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_blank(), panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(), panel.background = element_blank(),
        legend.position = c(0, 0), legend.justification = c(0, 0),
        legend.box = "vertical", legend.box.just = "bottom",
        legend.background = element_rect(fill = "transparent"))
ggsave(paste0(localDir, "/Loans_alpha.pdf"), width = 10, height = 7.5)
ggsave(paste0(localDir, "/Loans_alpha.png"), width = 10, height = 7.5)


usa.plot + geom_polygon(aes(fill = metro03)) +
  geom_path(data = filter(ggusa, !is.na(metro03)), color = "grey", lwd = 0.1) +
  geom_path(data = ggstate, colour = "black", lwd = 0.25) +
  geom_jitter(data = filter(loans, key != "Any"), #size = value, 
              aes(long, lat, color = key, size = value^0.5, group = NULL)) +
  #coord_map("albers", lat0 = 29.5, lat1 = 37.5) +  
  scale_fill_manual("County Class",
                    values = c("metro" = "darkkhaki", "nonmetro" = "khaki"),
                    labels = c("Urban", "Rural"), na.value = "blue") +
  scale_colour_manual("Loan", values = c("Pilot" = "black", "Farm Bill" = "red"),
                      na.value = NA) +
  labs(x = "", y = "") +
  guides(colour = guide_legend(override.aes = list(size = 4)),
         size = FALSE, alpha = FALSE) +
  theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_blank(), panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(), panel.background = element_blank(),
        legend.position = c(0, 0), legend.justification = c(0, 0),
        legend.box = "vertical", legend.box.just = "bottom",
        legend.background = element_rect(fill = "transparent"))
ggsave(paste0(localDir, "/Loans_size.pdf"), width = 10, height = 7.5)
ggsave(paste0(localDir, "/Loans_size.png"), width = 10, height = 7.5)


rm(list=ls())

print(paste0("Finished 2-USDA_Evaluation_Maps at ", Sys.time()))