# Robert Dinterman

# ERS Produced Variables

print(paste0("Started 0-ERS at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(readxl)
library(tidyr)
library(stringr)
source("0-Data/0-functions.R")

# Create a directory for the data
localDir   <- "0-Data/ERS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)


# ---- Creative Class -----------------------------------------------------

# http://www.ers.usda.gov/data-products/creative-class-county-codes.aspx
url <- paste0("http://www.ers.usda.gov/datafiles/",
              "Creative_Class_County_Codes/creativeclass.xls")
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file)

creative <- read_excel(file, skip = 2)
names(creative)   <- gsub(" ", "", names(creative))
names(creative)   <- gsub("[[:punct:]]", "", names(creative))
creative %>% select(fips = FIPS, 7:16) %>%
  gather(key, value, -fips) %>%
  mutate(year = as.numeric(gsub("[[:alpha:]]", "", key)),
         key = gsub("[[:digit:]]", "", key)) %>% 
  filter(grepl("number", key)) %>%
  spread(key, value) -> creative

# Problem with 51515, 51560, 51780:
creative <- fipssues(creative, 51019, c(51019, 51515))
creative <- fipssues(creative, 51005, c(51005, 51560))
creative <- fipssues(creative, 51083, c(51083, 51780))

# Add in 8014 as 8013:
broom <- creative %>% filter(fips == 8013) %>%
  mutate(fips = 8014, year = ifelse(year == 2000, 2002, NA))
creative %>% filter(fips != 8014) %>% bind_rows(broom) -> creative

creative$Creativeshare <- creative$Creativenumber / creative$Employednumber
creative$Bohemian      <- (creative$Creativenumber + creative$Artsnumber) /
                             creative$Employednumber

write_csv(creative, paste0(localDir, "/creative.csv"))
save(creative, file = paste0(localDir, "/creative.Rda"))



# ---- Slow ---------------------------------------------------------------

### Natural Amenities
url  <- "http://www4.ncsu.edu/~rdinter/docs/natamen.csv"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file)

nat          <- read_csv(file)
names(nat)   <- gsub(" ", ".", names(nat)) #Problem with read_csv names
names(nat)   <- gsub("-", ".", names(nat))
nat <- nat %>%
  mutate(climate = JAN.TEMP...Z + JAN.SUN...Z + JUL.TEMP...Z + JUL.HUM...Z,
         FIPS = ifelse(FIPS == 12025, 12086, FIPS)) %>%
  select(fips = FIPS, climate, MeanTempJan, MeanSunJan, MeanTempJul,
         MeanHumidJul, Topo, Water.area, Natamen = Scale) %>% distinct()

write_csv(nat, paste0(localDir, "/amenities.csv"))
save(nat, file = paste0(localDir, "/amenities.Rda"))


### Rural Urban Continuum Codes
url  <- paste0("http://www.ers.usda.gov/datafiles/",
               "RuralUrban_Continuum_Codes/ruralurbancodes2003.xls")
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file)

ruc1 <- read_excel(file)
ruc1 %>% select(fips = `FIPS Code`, ruc93 = `1993 Rural-urban Continuum Code`,
                ruc03 = `2003 Rural-urban Continuum Code`) %>%
  mutate(fips = as.numeric(fips)) -> ruc1

url  <- paste0("http://www.ers.usda.gov/datafiles/",
              "RuralUrban_Continuum_Codes/ruralurbancodes2013.xls")
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file)

ruc2 <- read_excel(file)
ruc2 %>% select(fips = FIPS, ruc13 = RUCC_2013) %>% 
  mutate(fips = as.numeric(fips)) -> ruc2
ruc  <- full_join(ruc1, ruc2)

ruc <- ruc %>%
  mutate(metro93 = ifelse(ruc93 < 4, "metro", "nonmetro"),
         metro03 = ifelse(ruc03 < 4, "metro", "nonmetro"),
         metro13 = ifelse(ruc13 < 4, "metro", "nonmetro"))

write_csv(ruc, paste0(localDir, "/rucontinuum.csv"))
save(ruc, file = paste0(localDir, "/rucontinuum.Rda"))


# ---- Combine All --------------------------------------------------------

ERS <- full_join(creative, nat)
ERS <- full_join(ERS, ruc)

write_csv(ERS, paste0(localDir, "/ERS.csv"))
save(ERS, file = paste0(localDir, "/ERS.Rda"))

rm(list = ls())

print(paste0("Finished 0-ERS at ", Sys.time()))
