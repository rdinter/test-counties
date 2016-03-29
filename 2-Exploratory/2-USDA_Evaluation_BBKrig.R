# Robert Dinterman

# Plot a smoothed version of broadband deployment rates.

# http://spatial.ly/2013/12/introduction-spatial-data-ggplot2/
# http://www.kevjohnson.org/making-maps-in-r-part-2/

print(paste0("Started 2-USDA_Evaluation_Maps at ", Sys.time()))

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

# 
# #Create grid of prediction points:
# sp              <- coordinates(data)
# sp1             <- seq(min(sp[,1]) - 1, max(sp[,1]) + 1, length = 1000)
# sp2             <- seq(min(sp[,2]) - 1, max(sp[,2]) + 1, length = 1000)
# sp              <- expand.grid(sp1, sp2)
# 
# names(sp)       <- c("long", "lat")
# coordinates(sp) <- ~ long + lat
# proj4string(sp) <- proj4string(state)
# 
# inUS            <- sp %over% state
# sp              <- sp[!is.na(inUS[,1]), ]

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
  krig.year <- by(data, data$year, function(x) {
    coordinates(x)    <- ~ long + lat
    proj4string(x)    <- proj4string(sp)
    # HERE is the part where I go in parallel
    temp <- do.call("rbind", parLapply(cl, newdlst, function(lst) 
      krige(Prov_num ~ 1, x, lst)))
    temp <- spTransform(temp, CRS(aea.proj))
    dtemp <- as.data.frame(temp)
    dtemp[,c("long", "lat")] <- coordinates(temp)
    dtemp$year <- mean(x$year)
    return(dtemp)
  })
)
saveRDS(krig.year, paste0(localDir, "/kirg.rds"))
j5 <- bind_rows(krig.year)
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
library(viridis)
ggstate <- fortify(state)
j5$pred <- cut(j5$var1.pred, breaks = c(0, 2, 3, 5.5, 7.5, 10, Inf),
               labels = c("None", "Suppressed", "Moderate", "Good",
                          "High", "Excellent"), right = F)
p <- ggplot(filter(j5, year != 1999), aes(x = long, y = lat)) +
  geom_point(aes(color = pred), size = 1)

p + facet_wrap(~year) + 
  geom_path(data = ggstate, aes(x = long, y = lat, group = group),
            color = "black", lwd = 0.25) +
  #scale_color_brewer("", palette = "PuRd") +
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
        # strip.background = element_blank(),
        plot.background = element_rect(fill = "transparent",colour = NA))

ggsave(paste0(localDir, "/BBKrig_diffsize_vir.pdf"), width = 10, height = 7.5)
ggsave(paste0(localDir, "/BBKrig_diffsize_vir.png"), width = 10, height = 7.5)
# 
# for (i in unique(j5$year)){
#   p <- ggplot(filter(j5, year == i), aes(x = long, y = lat)) +
#     geom_point(aes(color = pred), size = 1) + 
#     geom_path(data = ggstate, aes(x = long, y = lat, group = group),
#               color = "black", lwd = 0.25) +
#     scale_color_brewer("", palette = "PuRd") +
#     labs(x = "", y = "") +
#     guides(colour = guide_legend(override.aes = list(shape = 15, size = 10))) +
#     theme(axis.ticks = element_blank(), axis.text.y = element_blank(),
#           axis.text.x = element_blank(), panel.grid.minor = element_blank(),
#           panel.grid.major = element_blank(),
#           panel.background = element_blank(),
#           legend.position = "bottom", legend.direction = "horizontal",
#           legend.background = element_rect(fill = "transparent"),
#           legend.key = element_blank())
#   
#   ggsave(paste0(localDir, "/BBKrig_", i, ".png"), p,  width = 1, height = .75)
# }


#devtools::install_github("dgrtwo/gganimate")
library(gganimate)
p <- ggplot(j5, aes(x = long, y = lat, frame = year, color = pred)) +
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
gg_animate(p, paste0(localDir, "/BBKrig_vir.gif"))


# rm(list = ls())

print(paste0("Finished 2-USDA_Evaluation_Maps at ", Sys.time()))
