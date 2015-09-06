#Robert Dinterman

# County Business Patterns
# https://www.census.gov/econ/cbp/download/
# BEWARE: From 1986 to 1997, classification uses SIC. 1998+ is NAICS

# ---- Start --------------------------------------------------------------

print(paste0("Started 0-CBP at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(readr))
source("0-Data/0-functions.R")

# Create a directory for the data
localDir    <- "0-Data/CBP"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

tempDir  <- tempdir()

# Get layout files for data
urls <- paste0("https://www.census.gov/econ/cbp/download/full_layout/",
               c("County_Layout.txt", "County_Layout_SIC.txt"))
lapply(urls, function(x) bdown(url = x, folder = data_source))

urls <- paste0("https://www.census.gov/econ/cbp/download/",
               c("sic86.txt", "sic87.txt", "sic88_97.txt", "naics.txt"))
lapply(urls, function(x) bdown(url = x, folder = data_source))



# ---- CBP Data from 1986 to 2001 -----------------------------------------
years  <- c(as.character(86:99), "00", "01")
url    <- "ftp://ftp.census.gov/Econ2001_And_Earlier/CBP_CSV/"
urls   <- paste0(url, "cbp", years, "co.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))

files  <- paste(data_source, basename(urls), sep = "/")
year   <- 1986:2001
cbp8601<- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
                 y = year, SIMPLIFY = F, USE.NAMES = T)

cbp8601<- bind_rows(cbp8601)

cbp8601 %>%
  filter(fipstate == 11) %>%
  mutate(fipscty = 1, fips = 11001) %>%
  bind_rows(cbp8601) -> cbp8601

cbp8601 %>% mutate(fipscty = ifelse(fipscty == 999, 0, fipscty),
                   fips = 1000*fipstate + fipscty,
                   fips = ifelse(fips == 12025, 12086, fips)) %>%
  select(year, fips, naics, sic:n1000_4) -> cbp8601

cbp8601 <- fipssues1(cbp8601, 51083, c(51083, 51780))
cbp8601 <- fipssues1(cbp8601, 51005, c(51005, 51560))
cbp8601 <- fipssues1(cbp8601, 51019, c(51019, 51515))

write_csv(cbp8601, path = paste0(localDir, "/CBP86-01.csv"))
save(cbp8601, file = paste0(localDir, "/CBP86-01.Rda"))
#rm(cbp8601)


# ---- CBP Data from 2002 to 2013 -----------------------------------------
years  <- as.character(2002:2013)
url    <- "ftp://ftp.census.gov/econ"
urls   <- paste0(url, years, "/CBP_CSV/cbp",
                 substr(years, 3, 4), "co.zip")
lapply(urls, function(x) bdown(url = x, folder = data_source))

files   <- paste(data_source, basename(urls), sep = "/")
year    <- 2002:2013
cbp0213 <- mapply(function(x, y) zipdata(x, tempDir, y), x = files,
                  y = year, SIMPLIFY = F, USE.NAMES = T)

cbp0213 <- bind_rows(cbp0213)

cbp0213 %>%
  filter(fipstate == 11) %>%
  mutate(fipscty = 1, fips = 11001) %>%
  bind_rows(cbp0213) -> cbp0213

cbp0213 %>% mutate(fipscty = ifelse(fipscty == 999, 0, fipscty),
                   fips = 1000*fipstate + fipscty,
                   fips = ifelse(fips == 12025, 12086, fips)) %>%
  select(year, fips, naics:n1000_4, emp_nf:ap_nf) -> cbp0213

cbp0213 <- fipssues2(cbp0213, 51083, c(51083, 51780))
cbp0213 <- fipssues2(cbp0213, 51005, c(51005, 51560))
cbp0213 <- fipssues2(cbp0213, 51019, c(51019, 51515))

write_csv(cbp0213, path = paste0(localDir, "/CBP02-13.csv"))
save(cbp0213, file = paste0(localDir, "/CBP02-13.Rda"))


# ---- Combine all the CBP data -------------------------------------------
cbp <- bind_rows(cbp8601, cbp0213)
rm(cbp8601, cbp0213)

write_csv(cbp, path = paste0(localDir, "/CBP86-13.csv"))
save(cbp, file = paste0(localDir, "/CBP86-13.Rda"))

rm(list = ls())

print(paste0("Finished 0-CBP at ", Sys.time()))