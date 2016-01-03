# Robert Dinterman

print(paste0("Started 0-ACS-read at ", Sys.time()))

library(dplyr)
library(readr)

# Create a directory for the data
localDir <- "0-Data/ACS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

files    <- list.files(data_source, pattern = ".*[[:digit:]].txt$",
                       full.names = T)

begin <- c(1, 4, 7, 10, 14, 44, 80, 89, 98, 106, 114, 122, 130, 138, 146,
           154, 162, 170, 178, 186, 194, 224, 260, 269, 278, 286, 294,
           302, 310, 318, 326, 334, 342, 350, 358, 366, 374, 382)
ends  <- c(3, 6, 9, 12, 43, 78, 87, 96, 104, 112, 120, 128, 136, 144, 152,
           160, 168, 176, 184, 192, 223, 258, 267, 276, 284, 292, 300,
           308, 316, 324, 332, 340, 348, 356, 364, 372, 380, 388)
coln  <- c("statedfips", "countydfips", "stateofips", "countyofips", 
           "STATEd", "COUNTYd", "countydPop", "countydPop_moe", "nonmove",
           "nonmove_moe", "USmove", "USmove_moe", "movecounty", 
           "movecounty_moe", "movestate", "movestate_moe", "moveUS",
           "moveUS_moe", "moveforeign", "moveforeign_moe", 
           "STATEo", "COUNTYo", "countyoPop", "countyoPop_moe", "nonmoveo",
           "nonmoveo_moe", "USmoveo", "USmoveo_moe", "movecountyo",
           "movecountyo_moe", "movestateo", "movestateo_moe", "moveUSo",
           "moveUSo_moe", "movePR", "movePR_moe", "movewithin",
           "movewithin_moe")
pos   <- fwf_positions(begin , ends, coln)
type  <- "iiiicciiiiiiiiiiiiiicciiiiiiiiiiiiiiii"

# Creates a column for the file that data are taken from
func1 <- function(x, pos = pos, type = type) {
  data <- read_fwf(x, col_positions = pos, col_types = type)
  data$file  <- basename(x)
  data$year1 <- 2000 + as.numeric(substr(gsub("[^[:digit:]]", "",
                                              basename(x)), 1, 2))
  data$year2 <- 2000 + as.numeric(substr(gsub("[^[:digit:]]", "",
                                              basename(x)), 3, 4))
  data$ofips <- 1000*data$stateofips + data$countyofips
  data$dfips <- 1000*data$statedfips + data$countydfips
  return(data)
}

ACS  <- lapply(files, function(x) func1(x, pos, type))
ACS  <- bind_rows(ACS)

# Gross -> take current county and accumulate the following variables

# TO DO -------------------------------------------------------------------

# 1. create year var
# 2. clean up unnecessary fips and moe etc.
# 3. change codes to factors in ACS2 that are relevant
# 4. save files as .Rda and .csv
