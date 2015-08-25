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
  data   <- data[c(8:nrow(data)), c(1:9)]
  return(data)
}
read.excel2 <- function(file){
  data   <- read.xls(file)
  data   <- data[c(4:nrow(data)), c(1:9)]
  return(data)
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
for (i in files){  
  unzip(i, exdir = tempDir)
  j5     <- list.files(paste0(tempDir))
  j6     <- list.files(paste0(tempDir, "/", j5))
  j5i    <- list.files(paste0(tempDir, "/", j5, "/", j6[1]))
  j5o    <- list.files(paste0(tempDir, "/", j5, "/", j6[2]))
  namesi <- c("State_Code_Dest", "County_Code_Dest", "State_Code_Origin",
              "County_Code_Origin", "State_Abbrv", "County_Name", "Return_Num",
              "Exmpt_Num", "Aggr_AGI")
  indata <- data.frame()
  for (j in j5i){
    file   <- paste0(tempDir, "/", j5[1], "/", j6[1], "/", j)
    
    data <- read.excel2(file)
    #data <- tryCatch(read.excel1(file), error = function(e){
    # read.excel2(file)
    #})
    
    data[,c(1:4,7:9)] <- lapply(data[,c(1:4,7:9)],
                                function(x){ # Sometimes characters in values
                                  as.numeric(
                                    gsub(",", "", 
                                         gsub("[A-z]", "", x)))
                                })
    data[,c(5:6)]     <- lapply(data[,c(5:6)], function(x){as.character(x)})
    names(data)       <- namesi
    data$year  <- as.numeric(substr(basename(i), 1, 4))
    data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
    data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
    indata     <- bind_rows(indata, data)
    
    print(paste0("Finished ", basename(j), " at ", Sys.time()))
    
  }
  bfile <- gsub('.{4}$', '', basename(i))
  write_csv(indata, paste0(localDir, "/", bfile,"i.csv"))
  
  
  nameso <- c("State_Code_Origin", "County_Code_Origin", "State_Code_Dest",
              "County_Code_Dest", "State_Abbrv", "County_Name", "Return_Num",
              "Exmpt_Num", "Aggr_AGI")
  outdata <- data.frame()
  for (j in j5o){
    file   <- paste0(tempDir, "/", j5[1], "/", j6[2], "/", j)
    
    data <- read.excel2(file)
    #data <- tryCatch(read.excel1(file), error = function(e){
    # read.excel2(file)
    #})
    
    data[,c(1:4,7:9)] <- lapply(data[,c(1:4,7:9)],
                                function(x){ # Sometimes characters in values
                                  as.numeric(
                                    gsub(",", "", 
                                         gsub("[A-z]", "", x)))
                                })
    data[,c(5:6)]     <- lapply(data[,c(5:6)], function(x){as.character(x)})
    names(data)       <- nameso
    data$year   <- as.numeric(substr(basename(i), 1, 4))
    data$ofips  <- data$State_Code_Origin*1000 + data$County_Code_Origin
    data$dfips  <- data$State_Code_Dest*1000   + data$County_Code_Dest
    outdata     <- rbind(outdata, data)
    
    print(paste0("Finished ", basename(j), " at ", Sys.time()))
  }  
  write_csv(outdata, paste0(localDir, "/", bfile,"o.csv"))
  
  unlink(tempDir, recursive = T)
  allindata  <- bind_rows(allindata, indata)
  alloutdata <- bind_rows(alloutdata, outdata)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
}
write_csv(allindata, paste0(localDir, "/inflows9204.csv"))
write_csv(alloutdata, paste0(localDir, "/outflows9204.csv"))

rm(allindata, alloutdata)

# Data from 2004 to 2010
inflows  <- c("countyinflow0405.csv", "countyinflow0506.csv",
              "countyinflow0607.csv", "countyinflow0708.csv",
              "countyinflow0809.csv", "countyinflow0910.csv",
              "countyinflow1011.csv")
indata   <- data.frame()
for (i in inflows){
  file       <- paste0(data_source, "/", i)
  if (!file.exists(file)) (download.file(paste0(url, i), file))
  data       <- read_csv(file)
  data$year  <- 1999 + as.numeric(substr(i, nchar(i) - 5, nchar(i) - 4))
  data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
  data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
  indata     <- bind_rows(indata, data)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
  
}
write_csv(indata, paste0(localDir, "/inflows0410.csv"))

outflows <- c("countyoutflow0405.csv", "countyoutflow0506.csv",
              "countyoutflow0607.csv", "countyoutflow0708.csv",
              "countyoutflow0809.csv", "countyoutflow0910.csv",
              "countyoutflow1011.csv")
outdata  <- data.frame()
for (i in outflows){
  file       <- paste0(data_source, "/", i)
  if (!file.exists(file)) (download.file(paste0(url, i),file))
  data       <- read_csv(file)
  data$year  <- 1999 + as.numeric(substr(i, nchar(i) - 5, nchar(i) - 4))
  data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
  data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
  outdata    <- bind_rows(outdata, data)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
  
}
write_csv(outdata, paste0(localDir, "/outflows0410.csv"))

# Data from 2011 to 2012
inflows  <- c("countyinflow1112.csv", "countyinflow1213.csv")
indata   <- data.frame()
for (i in inflows){
  file       <- paste0(data_source, "/", i)
  if (!file.exists(file)) (download.file(paste0(url, i), file))
  data       <- read_csv(file, col_names = c("State_Code_Dest",
                                             "County_Code_Dest",
                                             "State_Code_Origin",
                                             "County_Code_Origin",
                                             "State_Abbrv", "County_Name",
                                             "Return_Num", "Exmpt_Num",
                                             "Aggr_AGI"), skip = 1)
  data$year  <- 1999 + as.numeric(substr(i, nchar(i) - 5, nchar(i) - 4))
  data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
  data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
  indata     <- bind_rows(indata, data)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
  
}
write_csv(indata, paste0(localDir, "/inflows1113.csv"))

outflows <- c("countyoutflow1112.csv", "countyoutflow1213.csv")
outdata  <- data.frame()
for (i in outflows){
  file       <- paste0(data_source, "/", i)
  if (!file.exists(file)) (download.file(paste0(url, i),file))
  data       <- read_csv(file, col_names = c("State_Code_Origin",
                                             "County_Code_Origin",
                                             "State_Code_Dest",
                                             "County_Code_Dest", "State_Abbrv",
                                             "County_Name", "Return_Num",
                                             "Exmpt_Num", "Aggr_AGI"), skip = 1)
  data$year  <- 1999 + as.numeric(substr(i, nchar(i) - 5, nchar(i) - 4))
  data$ofips <- data$State_Code_Origin*1000 + data$County_Code_Origin
  data$dfips <- data$State_Code_Dest*1000   + data$County_Code_Dest
  outdata    <- bind_rows(outdata, data)
  print(paste0("Finished ", basename(i), " at ", Sys.time()))
  
}
write_csv(outdata, paste0(localDir, "/outflows1113.csv"))

rm(data, indata, outdata)

print(paste0("Finished 0-IRS_Mig at ", Sys.time()))