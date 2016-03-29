# Robert Dinterman

# Plot a smoothed version of broadband deployment rates.

# http://spatial.ly/2013/12/introduction-spatial-data-ggplot2/
# http://www.kevjohnson.org/making-maps-in-r-part-2/

print(paste0("Started 2-USDA_Evaluation_Maps-time at ", Sys.time()))

source("2-Exploratory/2-functions.R")
library(dplyr)
library(ggplot2)
library(gstat)
library(sp)
library(RColorBrewer)

# Create a directory for the data
localDir <- "2-Exploratory/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
load("0-Data/Shapefiles/All_2010_county.Rda")
load("0-Data/Shapefiles/state.Rda")

coordinates(data) <- data[, c("long", "lat")]
proj4string(data) <- proj4string(state)

ncell <- 77777
sp    <- spsample(state, ncell, "random")

library(parallel)

nclus <- detectCores() - 1
clus  <- c(rep("localhost", nclus))

# set up cluster and data
cl <- makeCluster(clus, type = "SOCK")
clusterEvalQ(cl, library(gstat))
clusterExport(cl, list("data", "sp"))

# split prediction locations:
splt    <- rep(1:nclus, each = ceiling(ncell/nclus), length.out = ncell)
newdlst <- lapply(as.list(1:nclus), function(w) sp[splt == w, ])

# with cluster:
aea.proj  <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-100
+x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m"

system.time(
  krig.time <- by(data, data$time, function(x) {
    coordinates(x)    <- ~ long + lat
    proj4string(x)    <- proj4string(sp)
    # HERE is the part where I go in parallel
    temp <- do.call("rbind", parLapply(cl, newdlst, function(lst) 
      krige(Prov_num ~ 1, x, lst)))
    temp <- spTransform(temp, CRS(aea.proj))
    dtemp <- as.data.frame(temp)
    dtemp[,c("long", "lat")] <- coordinates(temp)
    dtemp$time <- mean(x$time)
    return(dtemp)
  })
)
saveRDS(krig.time, paste0(localDir, "/kirg-time.rds"))
j5 <- bind_rows(krig.time)
stopCluster(cl)

# # Krige Time
# aea.proj  <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-100
# +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m"
# 
# # samp <- data[sample(row.names(data), 1000), ]
# system.time(
#   krig.year <- by(data, data$year,
#                 function(x) {
#                   coordinates(x)    <- ~ long + lat
#                   proj4string(x)    <- proj4string(sp)
#                   temp              <- krige(Prov_num ~ 1, x, sp)
#                   temp <- spTransform(temp, CRS(aea.proj))
#                   dtemp <- as.data.frame(temp)
#                   dtemp[,c("long", "lat")] <- coordinates(temp)
#                   dtemp$year <- mean(x$year)
#                   return(dtemp)
#                   })
# )
# j5 <- bind_rows(krig.year)
# all.equal(j5, j6)

# data  <- spTransform(data, CRS(aea.proj))
# sp    <- spTransform(sp, CRS(aea.proj))
state <- spTransform(state, CRS(aea.proj))

# LOOK INTO CHANGING THE COLOR??

ggstate <- fortify(state)
j5$pred <- cut(j5$var1.pred, breaks = c(0, 2, 3, 5.5, 7.5, 10, Inf),
               labels = c("None", "Suppressed", "Moderate", "Good",
                          "High", "Excellent"), right = F)

#devtools::install_github("dgrtwo/gganimate")
library(gganimate)
library(viridis)
p <- ggplot(j5, aes(x = long, y = lat, frame = time, color = pred)) +
  geom_point(size = 1) + 
  geom_path(data = ggstate, aes(x = long, y = lat, group = group, frame = NA),
            color = "black", lwd = 0.25) +
  scale_color_viridis(name = "", option = "C", discrete = T) +
  labs(x = "", y = "") +
  guides(colour = guide_legend(nrow = 1, 
                               override.aes = list(shape = 15, size = 10))) +
  theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_blank(), panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_blank(),
        legend.position = "bottom", legend.direction = "horizontal",
        legend.background = element_rect(fill = "transparent"),
        legend.key = element_blank(),
        plot.background = element_rect(fill = "transparent",colour = NA))
gg_animate(p, paste0(localDir, "/BBKrig-time.gif"))


# rm(list = ls())

print(paste0("Finished 2-USDA_Evaluation_Maps-time at ", Sys.time()))
