#Robert Dinterman, NCSU Economics PhD Student

print(paste0("Started 0-IRS_Mig at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(gdata))
suppressMessages(library(readxl))
suppressMessages(library(readr))


#Problem for excel files with "us" from 1998.99 until 2001.2
read.excel1 <- function(file){
  data   <- read_excel(file)
  data   <- data[, c(1:9)]
  #data   <- data[c(8:nrow(data)), c(1:9)]
  return(data)
}
read.excel2 <- function(file){
  data   <- read.xls(file)
  data   <- data[c(4:nrow(data)), c(1:9)]
  return(data)
}
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
# Create a directory for the data
localDir <- "0-Data/IRS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

tempDir  <- tempdir()
# unlink(tempDir, recursive = T)

#####
# IRS Migration Data for 1992 to 2004
#http://www.irs.gov/uac/SOI-Tax-Stats-Migration-Data

url    <- "http://www.irs.gov/file_source/pub/irs-soi/"
year   <- 1992:2003 #the 90 to 92 data are in text files
urls   <- paste0(url, year, "to", year + 1, "countymigration.zip")
files  <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}


allindata  <- data.frame()
alloutdata <- data.frame()

namesi <- c("State_Code_Dest", "County_Code_Dest", "State_Code_Origin",
            "County_Code_Origin", "State_Abbrv", "County_Name", "Return_Num",
            "Exmpt_Num", "Aggr_AGI")
nameso <- c("State_Code_Origin", "County_Code_Origin", "State_Code_Dest",
            "County_Code_Dest", "State_Abbrv", "County_Name", "Return_Num",
            "Exmpt_Num", "Aggr_AGI")

for (i in files){  
  unzip(i, exdir = tempDir)
  j5  <- list.dirs(tempDir)
  j5i <- list.files(j5[grepl("Inflow", j5)], full.names = T)
  j5o <- list.files(j5[grepl("Outflow", j5)], full.names = T)
  
  indata <- sapply(j5i, function(x){
    data <- tryCatch(read.excel1(x), error = function(e){
      read.excel2(x)
    })
    
    data[,c(1:4,7:9)] <- lapply(data[,c(1:4,7:9)],
                                function(xx){ # Sometimes characters in values
                                  as.numeric(
                                    gsub(",", "", 
                                         gsub("[A-z]", "", xx)))
                                })
    data[,c(5:6)]     <- lapply(data[,c(5:6)], function(xx){as.character(xx)})
    names(data)       <- namesi
    
    data <- filter(data, !is.na(State_Code_Dest))
    data$State_Code_Dest <- Mode(data$State_Code_Dest)
    # data$year  <- as.numeric(substr(basename(x), 1, 4))
    data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
    data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
    data
  }, simplify = F, USE.NAMES = T)
  indata <- bind_rows(indata)
  indata$year <- as.numeric(substr(basename(i), 1, 4))
  
  bfile <- gsub('.{4}$', '', basename(i))
  # write_csv(indata, paste0(localDir, "/", bfile,"i.csv"))
  
  
  outdata <- sapply(j5o, function(x){
    data <- tryCatch(read.excel1(x), error = function(e){
      read.excel2(x)
    })
    
    data[,c(1:4,7:9)] <- lapply(data[,c(1:4,7:9)],
                                function(xx){ # Sometimes characters in values
                                  as.numeric(
                                    gsub(",", "", 
                                         gsub("[A-z]", "", xx)))
                                })
    data[,c(5:6)]     <- lapply(data[,c(5:6)], function(xx){as.character(xx)})
    names(data)       <- nameso
    
    data <- filter(data, !is.na(State_Code_Origin))
    data$State_Code_Origin <- Mode(data$State_Code_Origin)
    # data$year   <- as.numeric(substr(basename(i), 1, 4))
    data$ofips  <- data$State_Code_Origin*1000 + data$County_Code_Origin
    data$dfips  <- data$State_Code_Dest*1000   + data$County_Code_Dest
    data
  }, simplify = F, USE.NAMES = T)
  outdata <- bind_rows(outdata)
  outdata$year <- as.numeric(substr(basename(i), 1, 4))
  
  # write_csv(outdata, paste0(localDir, "/", bfile,"o.csv"))
  
  unlink(tempDir, recursive = T)
  allindata  <- bind_rows(allindata, indata)
  alloutdata <- bind_rows(alloutdata, outdata)
  rm(indata, outdata)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
}
write_csv(allindata, paste0(localDir, "/inflows9203.csv"))
write_csv(alloutdata, paste0(localDir, "/outflows9203.csv"))


# ---- Data from 2004 to 2012 ---------------------------------------------

inflows  <- c("countyinflow0405.csv", "countyinflow0506.csv",
              "countyinflow0607.csv", "countyinflow0708.csv",
              "countyinflow0809.csv", "countyinflow0910.csv",
              "countyinflow1011.csv", "countyinflow1112.csv",
              "countyinflow1213.csv")

indata   <- sapply(inflows, function(x){
  file       <- paste0(data_source, "/", x)
  if (!file.exists(file)) (download.file(paste0(url, x), file))
  data       <- read_csv(file, col_names = c("State_Code_Dest",
                                             "County_Code_Dest",
                                             "State_Code_Origin",
                                             "County_Code_Origin",
                                             "State_Abbrv", "County_Name",
                                             "Return_Num", "Exmpt_Num",
                                             "Aggr_AGI"), skip = 1)
  data$year  <- 1999 + as.numeric(substr(x, nchar(x) - 5, nchar(x) - 4))
  data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
  data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
  filter(data, !is.na(State_Code_Dest))
}, simplify = F, USE.NAMES = T)

allin <- bind_rows(indata)

write_csv(allin, paste0(localDir, "/inflows0413.csv"))

outflows <- c("countyoutflow0405.csv", "countyoutflow0506.csv",
              "countyoutflow0607.csv", "countyoutflow0708.csv",
              "countyoutflow0809.csv", "countyoutflow0910.csv",
              "countyoutflow1011.csv", "countyoutflow1112.csv",
              "countyoutflow1213.csv")
outdata  <- sapply(inflows, function(x){
  file       <- paste0(data_source, "/", x)
  if (!file.exists(file)) (download.file(paste0(url, x), file))
  data       <- read_csv(file, col_names = c("State_Code_Origin",
                                             "County_Code_Origin",
                                             "State_Code_Dest",
                                             "County_Code_Dest", "State_Abbrv",
                                             "County_Name", "Return_Num",
                                             "Exmpt_Num", "Aggr_AGI"), skip = 1)
  data$year  <- 1999 + as.numeric(substr(x, nchar(x) - 5, nchar(x) - 4))
  data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
  data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
  filter(data, !is.na(State_Code_Origin))
}, simplify = F, USE.NAMES = T)

allout <- bind_rows(outdata)

write_csv(allout, paste0(localDir, "/outflows0413.csv"))

rm(indata, outdata)

allindata  <- bind_rows(allindata, allin)
alloutdata <- bind_rows(alloutdata, allout)

save(allindata,  file = paste0(localDir, "/inflows9213.Rda"))
save(alloutdata, file = paste0(localDir, "/outflows9213.Rda"))

rm(list = ls())

print(paste0("Finished 0-IRS_Mig at ", Sys.time()))
