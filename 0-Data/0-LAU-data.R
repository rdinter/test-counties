#Robert Dinterman

#######
# Local Area Unemployment 1990 to 2014
# http://www.bls.gov/lau/
# Update bls website: http://www.bls.gov/bls/ftp_migration_crosswalk.htm

print(paste0("Started 0-LAU-data at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)
library(stringr)
library(tidyr)

year1    <- 1976 #actually, they do not have county estimates before 1990.
year2    <- 2014
localDir <- "0-Data/LAU"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

url       <- "http://download.bls.gov/pub/time.series/la/"

download.file(paste0(url,"la.txt"), paste0(localDir, "/la.txt"))
download.file(paste0(url,"/la.area"), paste0(localDir, "/la.area"))
download.file(paste0(url,"/la.area_type"), paste0(localDir, "/la.area_type"))


states <- c("10.Arkansas", "11.California", "12.Colorado", "13.Connecticut",
            "14.Delaware", "15.DC", "16.Florida", "17.Georgia", "18.Hawaii",
            "19.Idaho", "20.Illinois", "21.Indiana", "22.Iowa", "23.Kansas",
            "24.Kentucky", "25.Louisiana", "26.Maine", "27.Maryland",
            "28.Massachusetts", "29.Michigan", "30.Minnesota",
            "31.Mississippi", "32.Missouri", "33.Montana", "34.Nebraska",
            "35.Nevada", "36.NewHampshire", "37.NewJersey", "38.NewMexico",
            "39.NewYork", "40.NorthCarolina", "41.NorthDakota", "42.Ohio",
            "43.Oklahoma", "44.Oregon", "45.Pennsylvania", "47.RhodeIsland",
            "48.SouthCarolina", "49.SouthDakota", "50.Tennessee", "51.Texas",
            "52.Utah", "53.Vermont", "54.Virginia", "56.Washington",
            "57.WestVirginia", "58.Wisconsin", "59.Wyoming", "7.Alabama",
            "8.Alaska", "9.Arizona")
urls  <- paste0(url, "la.data.", states)
files <- paste(data_source, basename(urls), sep = "/")

if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

cross      <- read_tsv(paste0(localDir, "/la.area"), skip = 1, col_names = F,
                       col_types = "ccccccc")
cross %>% mutate(series_id = X2, LAUS = str_sub(X2, 2, 8),
                 fips = as.numeric(str_sub(X2, 3, 7))) %>%
  filter(X1 == "F") %>% #this subsets by county
  select(series_id, LAUS, fips) -> cross

datacollect <- function(file){
  data <- read_tsv(file, col_types = "ciccc")
  
  data %>% mutate(value = as.numeric(value)) %>%
    filter(year >= year1, year <= year2, period == "M13",
           str_sub(series_id, 4, 18) %in% cross$series_id,
           str_sub(series_id, 19, 20) %in% c("04", "05")) %>%
    mutate(LAUS = str_sub(series_id, 5, 11),
           var = factor(str_sub(series_id, 19, 20),
                        labels = c("Unemp", "Emp"))) %>%
    select(LAUS, year, value, var) %>% left_join(cross) %>%
    select(year, fips, var, value) -> data
  return(data)
}
data <- lapply(files, datacollect)

data %>% bind_rows() %>%
  spread(var, value) -> unemp

write_csv(unemp, paste0(localDir, "/LAUnemp.csv"))
save(unemp, file = paste0(localDir, "/LAUnemp.RData"))


rm(list = ls())

print(paste0("Finished 0-LAU-data at ", Sys.time()))
