# Robert Dinterman

# BEA Regional Economics API:
# http://www.bea.gov/API/bea_web_service_api_user_guide.htm

print(paste0("Started 0-BEA_API at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(jsonlite)
library(pbapply)
library(RCurl)
library(tidyr)
## The following file assigns my BEA API key to the variable "bea.api.key"
source("0-Data/api_keys.R")

# Create a directory for the data
localDir <- "0-Data/BEA"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

url  <- "http://www.bea.gov/api/_pdf/bea_web_service_api_user_guide.pdf"
file <- paste(data_source, basename(url), sep = "/")
if (!file.exists(file)) download.file(url, file, method = "libcurl")


api.url <- "http://www.bea.gov/api/data/?"

# GetDataSetList – retrieves a list of the datasets currently offered.
# Required Parameters: UserID, Method
# Optional Parameters: ResultFormat
# http://www.bea.gov/api/data?
#  &UserID=Your-36Character-Key
#  &method=GETDATASETLIST
#  &ResultFormat=JSON&

listings <- paste0(api.url,
                  "&UserID=", bea.api.key,
                  "&method=GetDataSetList",
                  "&ResultFormat=JSON&")
url      <- getURL(listings)
json     <- fromJSON(url)
listings <- json$BEAAPI$Results$Dataset

# GetParameterList – retrieves a list of the parameters (required and optional)
#  for a particular dataset.
# Required Parameters: UserID, Method, DatasetName
# Optional Parameters: ResultFormat
# http://www.bea.gov/api/data?
#  &UserID=56174F35-5640-4701-BA46-A70268111201
#  &method=GetParameterList
#  &datasetname=RegionalData&

GetParameterList <- function(datasetname){
  temp <-paste0(api.url,
                "&UserID=", bea.api.key,
                "&method=GetParameterList",
                "&datasetname=", datasetname, "&")
  parm.list <- pblapply(temp, function(x){
    url  <- getURL(x)
    json <- fromJSON(url)
    return(json$BEAAPI$Results$Parameter)
  })
  names(parm.list) <- datasetname
  return(parm.list)
}

# GetParameterValues – retrieves a list of the valid values for a particular
#  parameter.
# Required Parameters: UserID, Method, DatasetName, ParameterName
# Optional Parameters: ResultFormat
# http://bea.gov/api/data?
#  &UserID=48684B35-5640-4701-AF46-A70268111201
#  &method=GetParameterValues
#  &datasetname=RegionalData
#  &ParameterName=keycode&

GetParameterValues <- function(datasetname, parm.list){
  temp <- paste0(api.url,
         "&UserID=", bea.api.key,
         "&method=GetParameterValues",
         "&datasetname=", datasetname,
         "&ParameterName=", parm.list[[datasetname]][["ParameterName"]], "&")
  parm.vals <- pblapply(temp, function(x){
    json <- fromJSON(getURL(x))
    return(json$BEAAPI$Results$ParamValue)
  })
  names(parm.vals) <- parm.list[[datasetname]][["ParameterName"]]
  return(parm.vals)
}

# GetData - Every data retrieval request requires the UserID, Method, and
#  DatasetName parameters. Each dataset has a defined set of parameters – some
#  required and others optional. Each dataset returns different results that are
#  documented in appendices to this document. 
# Required Parameters: UserID, Method, DatasetName, additional required
#  parameters (depending on the dataset)
# Optional Parameters: ResultFormat, additional optional parameters
#  (depending on the dataset)
# http://www.bea.gov/api/data?
#  &UserID=56174F35-5640-4701-BA46-A70268111201
#  &method=GetData
#  &datasetname=RegionalData
#  &KeyCode=PCPI_CI
#  &GeoFIPS=STATE
#  &Year=2009 (could also use ALL)
#  &ResultFormat=XML&
#Note that the GeoFIPS parameter could have been “COUNTY” for all counties, or
# a list of individual state or county GeoFIPS codes. Also, multiple years could
# have been requested by providing them in a comma-separated list.

GetData <- function(datasetname, keycode, geofips, year){
  temp <- paste0(api.url,
                 "&UserID=", bea.api.key,
                 "&method=GetData",
                 "&datasetname=", datasetname,
                 "&KeyCode=", keycode,
                 "&GeoFIPS=", geofips,
                 "&Year=", year,
                 "&ResultFormat=JSON&")
  data <- pblapply(temp, function(x){
    json <- fromJSON(getURL(x))
    return(json$BEAAPI$Results$Data)
  })
  data <- bind_rows(data)
  return(data)
}

GetData2 <- function(datasetname, keycode, geofips, year){
  temp <- paste0(api.url,
                 "&UserID=", bea.api.key,
                 "&method=GetData",
                 "&datasetname=", datasetname,
                 "&KeyCode=", keycode,
                 "&GeoFIPS=", geofips,
                 "&Year=", year,
                 "&ResultFormat=JSON&")
  data <- vector(mode = "list", length = length(temp))
  
  data_source_json <- paste0(data_source, "/", datasetname)
  if (!file.exists(data_source_json)) dir.create(data_source_json)
  
  for (i in 1:length(temp)){
    ## Display a message so I can see the progress
    message("Downloading ", keycode[i], ", is ", i, " of ", length(temp),
            " at ", Sys.time())
    
    url  <- getURL(temp[i])
    # url  <- readLines(temp[i])
    
    json <- tryCatch(fromJSON(url),
                  error = function(e){
                    "error"
                  })
    if (json == "error"){
      message("Error at ", keycode[i], ", retrying ...")
      Sys.sleep(10) # wait ten seconds
      json <- tryCatch(fromJSON(url),
                       error = function(e){
                         "error"
                       })
    }
    if (json == "error"){
      message(keycode[i], "failed at ", Sys.time())
      data[[i]]      <- data.frame(GeoFips = NA, GeoName = NA,
                                   Code = keycode[i],
                                   TimePeriod = NA, CL_UNIT = NA,
                                   UNIT_MULT = NA, DataValue = NA)
      names(data)[i] <- paste0("ERROR", keycode[i])
    } else{
      tdata          <- json$BEAAPI$Results$Data
      tdata <- tryCatch(
        tdata %>% distinct(GeoFips, TimePeriod) %>% 
          mutate(GeoFips = as.numeric(GeoFips),
                 DataValue = as.numeric(DataValue)),
        error = function(e){
          data.frame(GeoFips = NA, GeoName = NA,
                     Code = keycode[i],
                     TimePeriod = NA, CL_UNIT = NA,
                     UNIT_MULT = NA, DataValue = NA)
        }
      )
      
      data[[i]]      <- tdata
      names(data)[i] <- keycode[i]
      
      if (nrow(tdata) > 1){
        save(tdata, file = paste0(data_source_json, "/", keycode[i], ".Rda"))
      } else {
        save(tdata, file = paste0(data_source_json, "/Error_",
                                  keycode[i], ".Rda"))
      }
      
    }
    
    Sys.sleep(runif(1, 0.05, 0.5)) #a random pause
  }
  # data <- bind_rows(data)
  return(data)
}

parmslist <- GetParameterList(listings$DatasetName)
parmsval  <- GetParameterValues("RegionalData", parmslist)


RegionalData <- GetData2("RegionalData", parmsval$KeyCode$KeyCode,
                        "COUNTY", "ALL")

errors <- names(RegionalData)[grepl("ERROR", names(RegionalData))]
errors <- gsub("ERROR", "", errors)

# Need to convert to numeric for some values ... quick diagnostic checks
# RegionalData %>%
#   bind_rows() %>%
#   spread(Code, DataValue) -> data

write_csv(RegionalData, paste0(localDir, "/RegionalData.csv"))
save(RegionalData, file = paste0(localDir, "/RegionalData.Rda"))



# ---- Regional Income Data -----------------------------------------------


parmslist <- GetParameterList(listings$DatasetName)
parmsval  <- GetParameterValues("RegionalIncome", parmslist)


GetDataIncome <- function(datasetname, tablename, linecode, geofips, year){
  temp <- paste0(api.url,
                 "&UserID=", bea.api.key,
                 "&method=GetData",
                 "&datasetname=", datasetname,
                 "&TableName=", tablename,
                 "&LineCode=", linecode,
                 "&GeoFIPS=", geofips,
                 "&Year=", year,
                 "&ResultFormat=JSON&")
  data <- vector(mode = "list", length = length(temp))
  for (i in 1:length(temp)){
    ## Display a message so I can see the progress
    message("Downloading ", keycode[i], ", is ", i, " of ", length(temp),
            " at ", Sys.time())
    
    url  <- getURL(temp[i])
    # url  <- readLines(temp[i])
    
    json <- tryCatch(fromJSON(url),
                     error = function(e){
                       "error"
                     })
    if (json == "error"){
      message("Error at ", keycode[i], ", retrying ...")
      Sys.sleep(10) # wait ten seconds
      json <- tryCatch(fromJSON(url),
                       error = function(e){
                         "error"
                       })
    }
    if (json == "error"){
      message(keycode[i], "failed at ", Sys.time())
      data[[i]]      <- data.frame(GeoFips = NA, GeoName = NA,
                                   Code = keycode[i],
                                   TimePeriod = NA, CL_UNIT = NA,
                                   UNIT_MULT = NA, DataValue = NA)
      names(data)[i] <- paste0("ERROR", keycode[i])
    } else{
      tdata          <- json$BEAAPI$Results$Data
      tdata %>% distinct(GeoFips, TimePeriod) %>% 
        mutate(GeoFips = as.numeric(GeoFips),
               TimePeriod = as.numeric(TimePeriod),
               DataValue = as.numeric(DataValue)) -> tdata
      
      data[[i]]      <- tdata
      names(data)[i] <- keycode[i]
    }
    
    Sys.sleep(runif(1, 0.05, 0.5)) #a random pause
  }
  # data <- bind_rows(data)
  return(data)
}

RegionalIncome <- GetDataIncome("RegionalIncome", parmsval$KeyCode$KeyCode,
                         "COUNTY", "ALL")
# Need to convert to numeric for some values ... quick diagnostic checks

write_csv(RegionalData, paste0(localDir, "/RegionalData.csv"))
save(RegionalData, file = paste0(localDir, "/RegionalData.Rda"))

rm(list = ls())

print(paste0("Finished 0-BEA_API at ", Sys.time()))