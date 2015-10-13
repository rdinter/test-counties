#Robert Dinterman

# Poverty Estimates
# https://www.census.gov/did/www/saipe/data/statecounty/data/index.html

print(paste0("Started 0-Poverty at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(tidyr)
source("0-Data/0-functions.R")

# Create a directory for the data
localDir <- "0-Data/Poverty"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# .dat files up to 241
years <- c("89", "93", "95", "97", "98", "99")
year  <- c(1989, 1993, 1995, 1997, 1998, 1999)
urls  <- paste0("http://www.census.gov/did/www/saipe/downloads/estmod",
                years, "/est", years, "ALL.dat")
files <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

starts <- c(1, 4, 8, 17, 26, 35, 40, 45, 50, 59, 68, 77, 82, 87, 92, 101, 110,
            119, 124, 129, 134, 141, 148, 155, 163, 171, 179, 184, 189, 194,
            240)
ends   <- c(2, 6, 15, 24, 33, 38, 43, 48, 57, 66, 75, 80, 85, 90, 99, 108, 117,
            122, 127, 132, 139, 146, 153, 161, 169, 177, 182, 187, 192, 238,
            241)
cols   <- c("STFIP", "CTYFIP", "POV_ALL", "POV_ALL_L", "POV_ALL_U",
            "POV_ALL_P", "POV_ALL_P_L", "POV_ALL_P_U", "POV_0.17",
            "POV_0.17_L", "POV_0.17_U", "POV_0.17_P", "POV_0.17_P_L",
            "POV_0.17_P_U", "POV_5.17", "POV_5.17_L", "POV_5.17_U",
            "POV_5.17_P", "POV_5.17_P_L", "POV_5.17_P_U", "MEDHHINC",
            "MEDHHINC_L", "MEDHHINC_U", "x18", "x19", "x20", "x21", "x22",
            "x23", "Name", "ST")
pos <- fwf_positions(starts, ends, cols)
typ <- paste0(c(rep("d", 29), "cc"), collapse = "")

pov <- mapply(function(a, b) {
  data <- read_fwf(a, pos, typ)
  data$year <- b
  data$fips <- 1000*data$STFIP + data$CTYFIP
  return(data)
}, a = files, b = year, SIMPLIFY = F)
pv1 <- bind_rows(pov)


# .dat files up to 264
years <- c("00", "01", "02", "03")
year  <- 2000:2003
urls  <- paste0("http://www.census.gov/did/www/saipe/downloads/estmod",
                years, "/est", years, "ALL.dat")
files <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

starts <- c(1, 4, 8, 17, 26, 35, 40, 45, 50, 59, 68, 77, 82, 87, 92, 101, 110,
            119, 124, 129, 134, 141, 148, 155, 163, 171, 179, 184, 189, 194,
            240, 243)
ends   <- c(2, 6, 15, 24, 33, 38, 43, 48, 57, 66, 75, 80, 85, 90, 99, 108, 117,
            122, 127, 132, 139, 146, 153, 161, 169, 177, 182, 187, 192, 238,
            241, 264)
cols   <- c("STFIP", "CTYFIP", "POV_ALL", "POV_ALL_L", "POV_ALL_U",
            "POV_ALL_P", "POV_ALL_P_L", "POV_ALL_P_U", "POV_0.17",
            "POV_0.17_L", "POV_0.17_U", "POV_0.17_P", "POV_0.17_P_L",
            "POV_0.17_P_U", "POV_5.17", "POV_5.17_L", "POV_5.17_U",
            "POV_5.17_P", "POV_5.17_P_L", "POV_5.17_P_U", "MEDHHINC",
            "MEDHHINC_L", "MEDHHINC_U", "x18", "x19", "x20", "x21", "x22",
            "x23", "Name", "ST", "flag")
pos <- fwf_positions(starts, ends, cols)
typ <- paste0(c(rep("d", 29), "ccc"), collapse = "")

pov <- mapply(function(a, b) {
  data <- read_fwf(a, pos, typ)
  data$year <- b
  data$fips <- 1000*data$STFIP + data$CTYFIP
  return(data)
}, a = files, b = year, SIMPLIFY = F)
pv2 <- bind_rows(pov)

# in 2004 they transfer to .txt
years <- c("04", "05", "06", "07", "08", "09", "10", "11", "12", "13")
year  <- 2004:2013
urls  <- paste0("http://www.census.gov/did/www/saipe/downloads/estmod",
                years, "/est", years, "ALL.txt")
files <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}
# 2011 is lower case "all.txt" instead of capitalized ALL.txt
download.file(paste0("https://www.census.gov/did/www/saipe/downloads/",
                     "estmod11/est11all.txt"), files[8], method = "libcurl")

pov <- mapply(function(a, b) {
  data <- read_fwf(a, pos, typ)
  data$year <- b
  data$fips <- 1000*data$STFIP + data$CTYFIP
  return(data)
}, a = files, b = year, SIMPLIFY = F)
pv3 <- bind_rows(pov)

pov <- pv1 %>% bind_rows(pv2) %>% bind_rows(pv3) %>%
  distinct() %>% filter(!is.na(fips)) %>%
  select(year, fips, POV_ALL, POV_ALL_P, POV_0.17, POV_0.17_P, POV_5.17,
         POV_5.17_P, MEDHHINC) %>%
  mutate(POP_POV = round(POV_ALL/(POV_ALL_P/100)))

pov <- mutate(pov, fips = ifelse(fips == 12025, 12086, fips))

# Problem with 51515, 51560, 51780:
pov <- fipssuespov(pov, 51019, c(51019, 51515))
pov <- fipssuespov(pov, 51005, c(51005, 51560))
pov <- fipssuespov(pov, 51083, c(51083, 51780))

write_csv(pov, path =  paste0(localDir, "/pov.csv"))
save(pov, file = paste0(localDir, "/pov.Rda"))


rm(list = ls())

print(paste0("Finished 0-Poverty at ", Sys.time()))