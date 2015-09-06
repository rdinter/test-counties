#Robert Dinterman, NCSU Economics PhD Student

print(paste0("Started 0-IRS_Pop at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(readr))
source("0-Data/0-functions.R")


# Create a directory for the data
localDir <- "0-Data/IRS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

tempDir  <- tempfile()
unlink(tempDir, recursive = T)

#####
# IRS Population Data for 1989 to 2009
#http://www.irs.gov/uac/SOI-Tax-Stats-County-Data

url    <- "http://www.irs.gov/file_source/pub/irs-soi/"
years  <- 1989:2009

urls   <- paste0(url, years, "countyincome.zip")
files  <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files)
}

# Documentation changes in 1997...added "Gross rents" and "Total money income"
alldata  <- data.frame()

for (i in files){
  unlink(tempDir, recursive = T)
  unzip(i, exdir = tempDir)
  
  # some .zip do not have folders
  xlscheck <- list.files(tempDir, pattern = "\\.xls$", full.names = T)
  
  if (length(xlscheck) == 0){
    j5        <- list.dirs(tempDir, recursive = F)
    
    xlscheck2 <- list.files(j5, pattern = "\\.xls$") #check if 2007 messes up
    if (length(xlscheck2) == 0){
      j5.    <- list.dirs(j5, recursive = F)
      j6     <- list.files(j5., pattern = "\\.xls$", full.names = T)
    } else{
      j6     <- list.files(j5, pattern = "\\.xls$", full.names = T)
    }
    
  } else { # if .zip contains xls files in main folder...
    j5 <- NULL
    j6 <- xlscheck
  }
  
  ydata <- data.frame()
  for (j in j6){
    data   <- read.POP1(j)
    
    data[,c(1:2, 4:9)] <- lapply(data[,c(1:2, 4:9)],
                                 function(x){ # Sometimes characters in values
                                   as.numeric(
                                     gsub(",", "", 
                                          gsub("[A-z]", "", x)))
                                 })
    data[, 3]     <- sapply(data[, 3], function(x){as.character(x)})
    year          <- as.numeric(substr(basename(i), 1, 4))
    data$year     <- year
    
    # PROBLEM, in 1989 IRS defines Cali STFIPS as 90, but it's 6
    #  further...sometimes the State fips is NA when it shouldn't be
    st <- median(data$STFIPS, na.rm = T)
    data$STFIPS[is.na(data$STFIPS)]   <- st
    data$CTYFIPS[is.na(data$CTYFIPS)] <- 0
    if (st == 90) {
      data$fips <- 6000 + data$CTYFIPS
    }    else{
      data$fips <- st*1000 + data$CTYFIPS
    }
    
    ind    <- apply(data, 1, function(x) all(is.na(x)))
    data   <- data[!ind, ]
    ydata  <- bind_rows(ydata, data)
    
    print(paste0("Finished ", basename(j), " at ", Sys.time()))
  }
  bfile <- gsub('.{4}$', '', basename(i))
  ydata <- ydata[!is.na(ydata$County_Name), ]  #Remove the pesky NAs
  # Remove duplicates
  dupes <- duplicated(ydata)
  ydata <- ydata[!dupes, ]
  
  # Add in total
  add   <- ((ydata$fips %% 1000) == 0)
  addt  <- apply(ydata[add, c(4:9)], 2, function(x) sum(x, na.rm = T))
  add   <- c(0, 0, NA, addt, year, 0)
  names(add) <- names(ydata)
  
  ydata <- bind_rows(ydata, as.data.frame(t(add)))
  
  ydata$County_Name[ydata$fips == 0] <- "Total" #Correct for NA name
  
  write_csv(ydata, paste0(data_source, "/", bfile,".csv"))
  
  alldata  <- bind_rows(alldata, ydata)
  
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
}
# Issue with a few counties being messed up, leave it be
# alldata[!complete.cases(alldata),]
# alldata <- alldata[complete.cases(alldata),]

# write_csv(alldata, paste0(localDir, "/countyincome8909.csv"))


# Data from 2010 to 2012
years  <- 2010:2012
urls   <- paste0(url, years, "countydata.zip")
files  <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files)
}


tdata <- data.frame()
for (i in files){
  unlink(tempDir, recursive = T)
  unzip(i, exdir = tempDir)
  j5     <- list.files(tempDir, pattern = "*noagi.csv", full.names = T)
  # The 2010 and 2011 are .csv but 2012 is .xls
  if (length(j5) == 0){
    j5     <- list.files(tempDir, pattern = "*all.xls", full.names = T)
    data   <- read_excel(j5, skip = 5)
    data   <- data[, c(1, 3, 4, 5, 10, 12, 14, 18, 16)]
  } else{
    data   <- read_csv(j5)
    data   <- data[, c("STATEFIPS", "COUNTYFIPS", "COUNTYNAME", "N1", "N2",
                       "A00100", "A00200", "A00600", "A00300")]
  }
  
  names(data) <- c("STFIPS", "CTYFIPS", "County_Name", "Return_Num",
                   "Exmpt_Num", "Aggr_AGI", "Wages", "Dividends", "Interest")
  
  year      <- as.numeric(substr(basename(i), 1, 4))
  data$year <- year
  data$fips <- data$STFIPS*1000 + data$CTYFIPS
  
  # Add in total
  add   <- ((data$fips %% 1000) == 0)
  addt  <- apply(data[add, c(4:9)], 2, function(x) sum(x, na.rm = T))
  add   <- c(0, 0, NA, addt, year, 0)
  names(add) <- names(data)
  
  # 2012 already has a total...
  if (year != 2012)  data    <- bind_rows(data, as.data.frame(t(add)))
  
  tdata   <- bind_rows(tdata, data)
  
  tdata$County_Name[tdata$fips == 0] <- "Total" #Correct for NA name
  
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
}
# Remove NAs
tdata   <- tdata[!is.na(tdata$STFIPS),]

IRS_POP <- bind_rows(alldata, tdata)
rm(alldata, data, tdata, ydata)

IRS_POP <- filter(IRS_POP, !is.na(Return_Num), !is.na(Exmpt_Num))

IRS_POP %>% filter(fips == 11000, year == 2012) %>%
  mutate(fips = 11001, CTYFIPS = 1) %>% bind_rows(IRS_POP) -> IRS_POP

IRS_POP$fips <- ifelse(IRS_POP$fips == 12025, 12086, IRS_POP$fips)
ind          <- IRS_POP == -1 & !is.na(IRS_POP) # Turn suppressed into NA
IRS_POP[ind] <- NA
rm(ind)

# Add in state totals...?

IRS_POP %>%
  filter(fips %% 1000 != 0) %>%
  group_by(year, STFIPS) %>%
  summarise(CTYFIPS = 0, Return_Num = sum(Return_Num, na.rm = T),
            Exmpt_Num = sum(Exmpt_Num, na.rm = T),
            Aggr_AGI = sum(Aggr_AGI, na.rm = T),
            Wages = sum(Wages, na.rm = T),
            Dividends = sum(Dividends, na.rm = T),
            Interest = sum(Interest, na.rm = T)) -> states
states$fips        <- 1000*states$STFIPS
states$County_Name <- "State Total"

IRS_POP %>%
  filter(fips %% 1000 != 0) %>%
  bind_rows(states) -> IRS_POP

IRS_POP <- select(IRS_POP, fips, year, Pop_IRS = Exmpt_Num,
                  HH_IRS = Return_Num, AGI_IRS = Aggr_AGI, Wages_IRS = Wages,
                  Dividends_IRS = Dividends, Interest_IRS = Interest)

# Problem with 51515, 51560, 51780:
IRS_POP <- fipssues(IRS_POP, 51019, c(51019, 51515))
IRS_POP <- fipssues(IRS_POP, 51005, c(51005, 51560))
IRS_POP <- fipssues(IRS_POP, 51083, c(51083, 51780))


write_csv(IRS_POP, paste0(localDir, "/countyincome8912.csv"))
save(IRS_POP, file = paste0(localDir, "/CTYPop.Rda"))

rm(list = ls())

print(paste0("Finished 0-IRS_Pop at ", Sys.time()))