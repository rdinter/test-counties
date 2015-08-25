#Robert Dinterman

# Population Age Estimates

print(paste0("Started 0-Population_Census at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(stringr))
suppressMessages(library(tidyr))
source("0-Data/0-functions.R")


# Create a directory for the data
localDir <- "0-Data/Population_Census"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)


# Data from 1980 to 1990 --------------------------------------------------

# http://www.census.gov/popest/data/historical/1980s/county.html

years <- as.character(1980:1989)
urls  <- paste0("http://www.census.gov/popest/data/counties/",
                "asrh/1980s/tables/PE-02-", years, ".csv")
files <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

vars <- c("year", "fips", "RaceSex", "Age1", "Age2", "Age3", "Age4", "Age5",
          "Age6", "Age7", "Age8", "Age9", "Age10", "Age11", "Age12", "Age13",
          "Age14", "Age15", "Age16", "Age17", "Age18")
data <- sapply(files, function(x) read_csv(x, vars, skip = 7), simplify = F)
data %>% bind_rows() %>% gather(Age, POP, -(year:RaceSex)) %>%
  mutate(Age = as.numeric(str_extract(Age, "[[:digit:]]+"))) -> data
data %>% group_by(year, fips) %>%
  summarise(Total = sum(POP), Under5 = sum(POP[Age == 1]),
            Under20 = sum(POP[Age < 5]),
            From20.64 = sum(POP[(Age >= 5) & (Age < 14)]),
            Over65 = sum(POP[Age >= 14]) ) -> data80
rm(data)

# Data from 1990 to 2000 --------------------------------------------------

# Share from 1990 to 2000
# http://www.census.gov/popest/data/counties/asrh/1990s/CO-99-09.html
# http://www.census.gov/popest/data/intercensal/st-co/characteristics.html
url  <- paste0("http://www.census.gov/popest/data/",
               "intercensal/st-co/files/STCH-Intercensal_layout.txt")
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

years <- as.character(1990:1999)
urls  <- paste0("http://www.census.gov/popest/data/intercensal/",
                "st-co/tables/STCH-Intercensal/STCH-icen", years, ".txt")
files <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

pos <- fwf_widths(c(2, 7, 3, 2, 2, 7),
                  c("Year", "fips", "Age", "RaceSex", "Ethnic", "POP"))
data <- sapply(files, function(x) read_fwf(x, pos, "iiiiii"), simplify = F)
data <- bind_rows(data)
data$year <- 1900 + data$Year

data %>% group_by(year, fips) %>%
  summarise(Total = sum(POP), Under5 = sum(POP[Age == 1]),
            Under20 = sum(POP[Age < 5]),
            From20.64 = sum(POP[(Age >= 5) & (Age < 14)]),
            Over65 = sum(POP[Age >= 14]) ) -> data90
rm(data)

# Data from 2000 to 2010 --------------------------------------------------

# http://www.census.gov/popest/data/intercensal/county/county2010.html
# Share from 2000 to 2010
## documentation
url <- paste0("http://www.census.gov/popest/data/",
              "intercensal/county/files/CO-EST00INT-AGESEX-5YR.pdf")
file     <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

## data
url <- paste0("http://www.census.gov/popest/data/",
              "intercensal/county/files/CO-EST00INT-AGESEX-5YR.csv")
file     <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

data <- read_csv(file)
data$fips <- 1000*data$STATE + data$COUNTY
data %>% filter(SEX != 0, AGEGRP != 0) %>%
  gather(year, POP, POPESTIMATE2000:POPESTIMATE2009) %>%
  mutate(year = as.numeric(str_extract(year, "[[:digit:]]+")),
         POP = ifelse(is.na(POP), 0, POP)) %>%
  select(year, fips, SEX, Age = AGEGRP, POP) -> data

data %>% group_by(year, fips) %>%
  summarise(Total = sum(POP), Under5 = sum(POP[Age == 1]),
            Under20 = sum(POP[Age < 5]),
            From20.64 = sum(POP[(Age >= 5) & (Age < 14)]),
            Over65 = sum(POP[Age >= 14]) ) -> data00
rm(data)

# Data from 2010 to 2014 --------------------------------------------------

## documentation
url <- paste0("http://www.census.gov/popest/data/",
              "counties/asrh/2014/files/CC-EST2014-ALLDATA.pdf")
file     <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

## data
url <- paste0("http://www.census.gov/popest/data/",
              "counties/asrh/2014/files/CC-EST2014-ALLDATA.csv")
file     <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")

data <- read_csv(file)
data$fips <- 1000*data$STATE + data$COUNTY
data %>% filter(AGEGRP != 0, YEAR > 2) %>%
  select(YEAR, fips, Age = AGEGRP, POP = TOT_POP) %>%
  group_by(YEAR, fips) %>%
  summarise(Total = sum(POP), Under5 = sum(POP[Age == 1]),
            Under20 = sum(POP[Age < 5]),
            From20.64 = sum(POP[(Age >= 5) & (Age < 14)]),
            Over65 = sum(POP[Age >= 14]) ) -> data14
year <- factor(data14$YEAR, labels = c(2010, 2011, 2012, 2013, 2014))
data14$year <- as.numeric(as.character(year))
data14$YEAR <- NULL
rm(data)

# The Merge (and fips corrections) ----------------------------------------

# > unique(data80$fips[!check]) #NOT IN 1990
#  2231 12025 30113 51780
# > unique(data80$fips[!check]) #NOT IN 2000
#  2201  2231  2280 12025 30113 51560 51780
# > unique(data80$fips[!check]) #NOT IN 2014
#  2201  2231  2280 12025 30113 51515 51560 51780

# > unique(data90$fips[!check]) # NOT in 1980
#  2068  2232  2282 12086
# > unique(data90$fips[!check]) # NOT in 2000
#  2201  2232  2280 51560
# > unique(data90$fips[!check]) # NOT in 2014
#  2201  2232  2280 51515 51560

# > unique(data00$fips[!check]) # NOT in 1980
#  2068  2105  2195  2198  2230  2275  2282  8014 12086
# > unique(data00$fips[!check]) # NOT in 1990
#  2105 2195 2198 2230 2275 8014
# > unique(data00$fips[!check]) # NOT in 2014
#  51515

# > unique(data14$fips[!check]) # NOT in 1980
#  2068  2105  2195  2198  2230  2275  2282  8014 12086
# > unique(data14$fips[!check]) # NOT in 1990
#  2105 2195 2198 2230 2275 8014
# > unique(data14$fips[!check]) # NOT in 2000
# numeric(0)

data80$fips <- ifelse(data80$fips == 12025, 12086, data80$fips)

data80 <- fipssues(data80, 30031, c(30031, 30113))
data80 <- fipssues(data80, 51083, c(51083, 51780))
data80 <- fipssues(data80, 51005, c(51005, 51560))
data80 <- fipssues(data80, 51019, c(51019, 51515))

data90 <- fipssues(data90, 51005, c(51005, 51560))
data90 <- fipssues(data90, 51019, c(51019, 51515))

data00 <- fipssues(data00, 51019, c(51019, 51515))

# going to ignore the Alaska issues
POP <- data80 %>% bind_rows(data90) %>% bind_rows(data00) %>% bind_rows(data14)

# Add in state totals
# POP %>% mutate(st = floor(fips/1000)*1000) %>%
#   group_by(year, st) %>% summarise_each(funs(sum), -fips) %>%
#   select(year, fips = st, Total, Under5, Under20, From20.64, Over65) %>%
#   bind_rows(POP) -> states

write_csv(POP, path =  paste0(localDir, "/POP.csv"))
save(POP, file = paste0(localDir, "/POP.Rda"))


rm(list = ls())

print(paste0("Finished 0-Population_Census at ", Sys.time()))