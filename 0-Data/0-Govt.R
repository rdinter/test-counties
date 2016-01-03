#Robert Dinterman

# Government Fiscal
# http://www.census.gov/govs/
# http://www.census.gov/govs/local/historical_data_1992.html

print(paste0("Started 0-Govt at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(tidyr)

# Create a directory for the data
localDir <- "0-Data/Govt"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

url <- "http://www2.census.gov/govs/local/estimatetechdoc1992.pdf"
file <- paste(localDir, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

url <- "http://www2.census.gov/govs/local/estimatetechdoc1997.pdf"
file <- paste(localDir, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

url <- "http://www2.census.gov/govs/local/estimatetechdoc2002.pdf"
file <- paste(localDir, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

url <- "http://www2.census.gov/govs/local/92censuscountyarea.zip"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")
unzip(file, exdir = data_source)

url <- "http://www2.census.gov/govs/local/92countyareadirectory.zip"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")
unzip(file, exdir = data_source)

url  <-"http://www2.census.gov/govs/local/97censuscountyarea.zip"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")
unzip(file, exdir = data_source)

url <- "http://www2.census.gov/govs/local/97countyareadirectory.txt"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

url <- "http://www2.census.gov/govs/local/02countyarea.zip"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")
unzip(file, exdir = data_source)

url <- "http://www2.census.gov/govs/local/02countyareagid.zip"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")
unzip(file, exdir = data_source)

# 1992
# pos    <- c(2, 4, -8, 3, 12, 2, 2, 2)
# fiscal <- read.fwf(paste0(data_source, "/92CensusCountyArea.txt"),
#                    widths = pos)

fiscal92  <- read_table(paste0(data_source, "/92CensusCountyArea.txt"),
                        col_names = F)

fiscal92 %>%
  mutate(id = as.numeric(X1)*1000 + as.numeric(X2),
         X7 = substr(X4, nchar(X4) - 1, nchar(X4)),
         X6 = substr(X4, nchar(X4) - 3, nchar(X4) - 2),
         X5 = substr(X4, nchar(X4) - 5, nchar(X4) - 4),
         Value = as.numeric(substr(X4, 1, nchar(X4) - 6))*1000,
         year  = 1900 + as.numeric(X5)) %>%
  select(year, id, X3, Value) %>%
  spread(X3, Value) -> fiscal92


# pos <- c(2, 4, -103, 5, 20)
# hh  <- read.fwf(paste0(data_source, "/92CensusCountyAreaDirectory.txt"),
#                 widths = pos)
# pos <- fwf_widths(c(2, 4, 103, 5, 20))
# hh  <- read_fwf(paste0(data_source, "/92CensusCountyAreaDirectory.txt"),
#                 col_positions = pos)
hh92 <- read_table(paste0(data_source, "/92CensusCountyAreaDirectory.txt"),
                   col_names = F)

hh92 %>%
  mutate(id = as.numeric(X1)*1000 + as.numeric(X2), fips = as.numeric(X4),
         pop = X5) %>%
  select(fips, pop, id) -> hh92

fiscal92 <- left_join(hh92, fiscal92)
fiscal92[is.na(fiscal92)] <- 0

# Correct Miami Dade
fiscal92$fips <- ifelse(fiscal92$fips == 12025, 12086, fiscal92$fips)

ny  <- fiscal92$fips == 36061 #new york five buroughs
re1 <- fiscal92$fips == 36005
re2 <- fiscal92$fips == 36047
re3 <- fiscal92$fips == 36081
re4 <- fiscal92$fips == 36085

# Let's do a weighted average for all of the boroughs:
holder <- colSums(fiscal92[ny|re1|re2|re3|re4, -(1:4)]) / 
  sum(fiscal92[ny|re1|re2|re3|re4, "pop"])
fiscal92[ny,-(1:4)]  <- holder * as.numeric(fiscal92[ny, "pop"])
fiscal92[re1,-(1:4)] <- holder * as.numeric(fiscal92[re1, "pop"])
fiscal92[re2,-(1:4)] <- holder * as.numeric(fiscal92[re2, "pop"])
fiscal92[re3,-(1:4)] <- holder * as.numeric(fiscal92[re3, "pop"])
fiscal92[re4,-(1:4)] <- holder * as.numeric(fiscal92[re4, "pop"])

#PICK OFF VARIABLES OF INTEREST INTO A SEPARATE MATRIX AND DELETE
fiscal92 <- select(fiscal92,  year = year, fips = fips, pop = pop, id = id,
                   proptax = T01, salestax = T09, indincometax = T40,
                   corptax = T41, deathtax = T50, PRcharges = A61,
                   PRcurop = E61, PRconstruc = F61, PRcapoutlay = G61,
                   PRequip = K61, PRgovtostate = L61)
fiscal92 %>% group_by(fips) %>%
  summarise_each(funs(sum), -id, -year) -> fiscal92
fiscal92$year <- 1992

write_csv(fiscal92, path = paste0(localDir, "/fiscal92.csv"))
save(fiscal92, file = paste0(localDir, "/fiscal92.Rda"))


# 1997 --------------------------------------------------------------------

fiscal97  <- read_table(paste0(data_source, "/97CensusCountyArea.txt"),
                        col_names = F)
fiscal97 %>%
  mutate(id = as.numeric(X1),
         X7 = substr(X3, nchar(X3) - 1, nchar(X3)),
         X6 = substr(X3, nchar(X3) - 3, nchar(X3) - 2),
         X5 = substr(X3, nchar(X3) - 5, nchar(X3) - 4),
         Value = as.numeric(substr(X3, 1, nchar(X3) - 6))*1000,
         year = 1900 + as.numeric(X5)) %>%
  select(year, id, X2, Value) %>%
  spread(X2, Value) -> fiscal97

pos  <- fwf_widths(c(2, 3, 30, 2, 4, 10, 2, 3),
                   c("STCODE" ,"CTYCODE", "COUNTY", "STATE",
                     "YEAR", "POPULATION", "STFIPS" ,"CTYFIPS"))
hh97 <- read_fwf(paste0(data_source, "/97countyareadirectory.txt"),
                 col_positions = pos)

hh97 %>%
  mutate(id = as.numeric(STCODE)*1000 + as.numeric(CTYCODE),
         fips = as.numeric(STFIPS)*1000 + as.numeric(CTYFIPS),
         pop = POPULATION) %>%
  select(fips, pop, id) -> hh97

fiscal97 <- left_join(hh97, fiscal97)
fiscal97$year[is.na(fiscal97$year)] <- 1997
fiscal97[is.na(fiscal97)]           <- 0

ny  <- fiscal97$fips == 36061 #new york five buroughs
re1 <- fiscal97$fips == 36005
re2 <- fiscal97$fips == 36047
re3 <- fiscal97$fips == 36081
re4 <- fiscal97$fips == 36085

# Let's do a weighted average for all of the boroughs:
holder <- colSums(fiscal97[ny|re1|re2|re3|re4, -(1:4)]) / 
  sum(fiscal97[ny|re1|re2|re3|re4, "pop"])
fiscal97[ny,-(1:4)]  <- holder * as.numeric(fiscal97[ny, "pop"])
fiscal97[re1,-(1:4)] <- holder * as.numeric(fiscal97[re1, "pop"])
fiscal97[re2,-(1:4)] <- holder * as.numeric(fiscal97[re2, "pop"])
fiscal97[re3,-(1:4)] <- holder * as.numeric(fiscal97[re3, "pop"])
fiscal97[re4,-(1:4)] <- holder * as.numeric(fiscal97[re4, "pop"])

#PICK OFF VARIABLES OF INTEREST INTO A SEPARATE MATRIX AND DELETE
fiscal97 <- select(fiscal97,  year = year, fips = fips, pop = pop, id = id,
                   proptax = T01, salestax = T09, indincometax = T40,
                   corptax = T41, deathtax = T50, PRcharges = A61,
                   PRcurop = E61, PRconstruc = F61, PRcapoutlay = G61,
                   PRequip = K61, PRgovtostate = L61)
fiscal97 %>% group_by(fips) %>%
  summarise_each(funs(sum), -id, -year) -> fiscal97
fiscal97$year <- 1997

write_csv(fiscal97, path =  paste0(localDir, "/fiscal97.csv"))
save(fiscal97, file = paste0(localDir, "/fiscal97.Rda"))

# 2002 --------------------------------------------------------------------

fiscal02  <- read_table(paste0(data_source, "/2002_Census_State_County.txt"),
                        col_names = F)
fiscal02 %>%
  mutate(id = as.numeric(X1)*1000 + as.numeric(X2),
         X7 = substr(X4, nchar(X4) - 1, nchar(X4)),
         X6 = substr(X4, nchar(X4) - 5, nchar(X4) - 2),
         Value = as.numeric(substr(X4, 1, nchar(X4) - 6))*1000,
         year = as.numeric(X6)) %>%
  select(year, id, X3, Value) %>%
  spread(X3, Value) -> fiscal02

pos  <- fwf_widths(c(2, 3, 30, 2, 4, 10, 2, 3),
                   c("STCODE" ,"CTYCODE", "COUNTY", "STATE",
                     "YEAR", "POPULATION", "STFIPS" ,"CTYFIPS"))
hh02 <- read_fwf(paste0(data_source, "/02countyareagid.txt"),
                 col_positions = pos)

hh02 %>%
  mutate(id = as.numeric(STCODE)*1000 + as.numeric(CTYCODE),
         fips = as.numeric(STFIPS)*1000 + as.numeric(CTYFIPS),
         pop = POPULATION) %>%
  select(fips, pop, id) -> hh02

fiscal02 <- left_join(hh02, fiscal02)
fiscal02[is.na(fiscal02)]           <- 0

#Missing the five buroughs, use distribution from 1997 for 2002
place      <- fiscal97[ny|re1|re2|re3|re4, 1:4]
place$pop  <- place$pop / sum(place$pop)
place$year <- 2002

ny         <- fiscal02$fips == 36061

holder     <- round(place$pop %*% as.matrix(fiscal02[ny, -(1:4)]), 0)
place$pop  <- round(place$pop * fiscal02$pop[ny], 0)
place      <- bind_cols(place, as.data.frame(holder))

fiscal02 %>% filter(fips != 36061) %>% bind_rows(place) -> fiscal02

#PICK OFF VARIABLES OF INTEREST INTO A SEPARATE MATRIX AND DELETE
fiscal02 <- select(fiscal02, year = year, fips = fips, pop = pop, id = id,
                   proptax = T01, salestax = T09, indincometax = T40,
                   corptax = T41, deathtax = T50, PRcharges = A61,
                   PRcurop = E61, PRconstruc = F61, PRcapoutlay = G61,
                   PRequip = K61, PRgovtostate = L61)
fiscal02 %>% group_by(fips) %>%
  summarise_each(funs(sum), -id, -year) -> fiscal02
fiscal02$year <- 2002

write_csv(fiscal02, path =  paste0(localDir, "/fiscal02.csv"))
save(fiscal02, file = paste0(localDir, "/fiscal02.Rda"))

fiscal <- bind_rows(fiscal92, fiscal97, fiscal02)

write_csv(fiscal, path = paste0(localDir, "/fiscal.csv"))
save(fiscal, file = paste0(localDir, "/fiscal.RData"))


rm(list = ls())

print(paste0("Finished 0-Govt at ", Sys.time()))