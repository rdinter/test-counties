# Robert Dinterman


# Check -------------------------------------------------------------------
#https://gist.github.com/leoniedu/233956
plot.heat <- function(tmp, state.map, z, title = NULL, breaks = NULL,
                      cex.legend = 1, bw = .2, col.vec = NULL, main = NULL,
                      plot.legend = T, ...) {
  if (is.factor(tmp@data[,z])) {
    tmp@data$zCat <- tmp@data[,z]
  }   else {
    tmp@data$zCat <- cut(tmp@data[,z], breaks, include.lowest=TRUE)
  }
  cutpoints     <- levels(tmp@data$zCat)
  
  if (is.null(col.vec)) col.vec <- heat.colors(length(levels(tmp@data$zCat)))
  
  cutpointsColors       <- col.vec
  levels(tmp@data$zCat) <- cutpointsColors
  cols                  <- as.character(tmp$zCat)
  ##cols <- "white"
  plot(tmp, lwd = bw, axes = F, las = 1, #border = cols, 
       col = as.character(tmp@data$zCat), main = main, ...)
  if (!is.null(state.map)) {
    plot(state.map, add = T, lwd = 1, border = "black")
  }
  if (plot.legend) legend("bottomleft", cutpoints, fill = cutpointsColors,
                          bty = "n", title = title, cex = cex.legend)
}

# # Plot for our broadband zip codes
# plot.krig <- function(tmp, state.map, z, title = NULL, breaks = NULL,
#                       cex.legend = 1, bw = .2, col.vec = NULL, main = NULL,
#                       plot.legend = T, ...) {
#   if (is.factor(tmp@data[,z])) {
#     tmp@data$zCat <- tmp@data[,z]
#   }   else {
#     tmp@data$zCat <- cut(tmp@data[,z], breaks, include.lowest=TRUE)
#   }
#   cutpoints     <- levels(tmp@data$zCat)
#   
#   if (is.null(col.vec)) col.vec <- heat.colors(length(levels(tmp@data$zCat)))
#   
#   cutpointsColors       <- col.vec
#   levels(tmp@data$zCat) <- cutpointsColors
#   cols                  <- as.character(tmp$zCat)
#   ##cols <- "white"
#   plot(tmp, lwd = bw, axes = F, las = 1, #border = cols, 
#        col = as.character(tmp@data$zCat), main = main, ...)
#   if (!is.null(state.map)) {
#     plot(state.map, add = T, lwd = 1, border = "black")
#   }
#   if (plot.legend) legend("bottomleft", cutpoints, fill = cutpointsColors,
#                           bty = "n", title = title, cex = cex.legend)
# }

#Plot with z as levels
bblevels <- function(x) {
  level  <- c("none", "none", "low" ,"low" ,"low", "low", "low", #7
              "medium", "medium", "medium", "medium", "medium", #12
              "high", "high", "high", "high", "high", "high", "high", #19
              "excellent", "excellent", "excellent", "excellent", #23
              "excellent", "excellent", "excellent", "excellent", #27
              "excellent", "excellent","excellent", "excellent")
  levels(x) <- level
  x
}

##merge sp objects with data
merge.sp <- function(tmp, data, by = "uf") {
  by.loc   <- match(by, names(data))
  by.data  <- data[, by.loc]
  data     <- data[, -by.loc]
  tmp@data <- data.frame(tmp@data, data[match(tmp@data[,by], by.data),]
  )
  tmp
}
