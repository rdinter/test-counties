#Robert Dinterman

# Download files using RCurl (because of https issues)
bdown <- function(url, folder){
  require(RCurl, quietly = T)
  file <- paste(folder, basename(url), sep = "/")
  
  if (!file.exists(file)){
    f <- CFILE(file, mode = "wb")
    a <- curlPerform(url = url, writedata = f@ref,
                     noprogress = FALSE)
    close(f)
    return(a)
  } else print("File Already Exists!")
}

zipdata <- function(file, tempDir, year){
  unlink(tempDir, recursive = T)
  
  unzip(file, exdir = tempDir)
  file       <- list.files(tempDir, pattern = "\\.txt$", full.names = T)
  rdata      <- read_csv(file)
  
  names(rdata) <- tolower(names(rdata))
  rdata$year <- year
  
  return(rdata)
}

#Problem for excel files with "us" from 1998.99 until 2001.2
read.POP1 <- function(file){
  require(readxl, quietly = T)
  coln   <- c("STFIPS", "CTYFIPS", "County_Name", "Return_Num", "Exmpt_Num",
              "Aggr_AGI", "Wages", "Dividends", "Interest")
  
  # Alaska in 97 is missing a column and MA 2001 is F-d
  probs <- c("ALASKA97ci.xls", "Kentucky01ci.xls", "MASSACHUSETTS01ci.xls")
  if (!(basename(file) %in% probs)){
    data   <- read_excel(file)
    
    check1 <- grep("code", data[, 1], ignore.case = T)
    check2 <- grep("code", data[, 2], ignore.case = T)
    
    if (is.na(check1[1])) data <- data[c((check2[1] + 1):nrow(data)), c(2:10)]
    else                  data <- data[c((check1[1] + 1):nrow(data)), c(1:9)]
    
    ind    <- apply(data, 1, function(x) all(is.na(x)))
    data   <- data[ !ind, ]
    names(data) <- coln
  } else if (basename(file) == probs[1]){ #for Alaska 97
    data   <- read_excel(file)
    check1 <- grep("code", data[, 1], ignore.case = T)
    data   <- cbind(data[c((check1[1] + 1):nrow(data)), c(1:2)], NA,
                    data[c((check1[1] + 1):nrow(data)), c(3:8)])
    ind    <- apply(data, 1, function(x) all(is.na(x)))
    data   <- data[!ind, ]
    names(data) <- coln
    data$County_Name <- "AK Replace"
  } else if (basename(file) == probs[2]){ #for KY 01
    data   <- read_excel(file)
    check1 <- grep("code", data[, 1], ignore.case = T)
    data1  <- data[c((check1[1] + 1)), c(1:9)]
    data2  <- data[c((check1[1] + 2):nrow(data)), c(1:9)]
    names(data1) <- names(data2) <- coln
    
    # Correct:
    data1$Interest  = as.character(sum(as.numeric(data2$Interest)))
    
    data   <- bind_rows(data1, data2)
    
    ind    <- apply(data, 1, function(x) all(is.na(x)))
    data   <- data[ !ind, ]
  } else if (basename(file) == probs[3]){ #for MA 01
    data   <- read_excel(file)
    check1 <- grep("code", data[, 1], ignore.case = T)
    data1  <- data[c((check1[1] + 1)), c(1:9)]
    data2  <- data[c((check1[1] + 2):nrow(data)), c(1:9)]
    names(data1) <- names(data2) <- coln
    
    # Correct:
    data1$County_Name = "Total"
    data1$Return_Num  = as.character(sum(as.numeric(data2$Return_Num)))
    
    data   <- bind_rows(data1, data2)
    
    ind    <- apply(data, 1, function(x) all(is.na(x)))
    data   <- data[!ind, ] 
  }
  return(data)
}

# read.POP2 <- function(file){
#   coln   <- c("STFIPS", "CTYFIPS", "County_Name", "Return_Num", "Exmpt_Num",
#               "Aggr_AGI", "Wages", "Dividends", "Interest")
#   data   <- read.xls(file)
#   data   <- data[c(5:nrow(data)), c(1:9)]
#   ind    <- apply(data, 1, function(x) all(is.na(x)))
#   data   <- data[ !ind, ]
#   names(data) <- coln
#   return(data)
# }


# Function for fips issues ------------------------------------------------


fipssues <- function(data, fip, fiplace){
  data %>% filter(fips %in% fiplace) %>% group_by(year) %>%
    summarise_each(funs(sum), -fips) -> correct
  correct$fips <- fip
  data %>% filter(!(fips %in% fiplace)) %>%
    bind_rows(correct) -> data
  
  return(data)
}
fipssuesmean <- function(data, fip, fiplace){
  correct <- data %>% filter(fips %in% fiplace) %>% group_by(year) %>%
    summarise_each(funs(sum), -fips)
  correct$fips <- fip
  data %>% filter(!(fips %in% fiplace)) %>%
    bind_rows(correct) -> data
  
  return(data)
}
fipssuespov <- function(data, fip, fiplace){
  correct <- data %>% filter(fips %in% fiplace) %>% group_by(year) %>%
    summarise(POV_ALL = sum(POV_ALL, na.rm = T),
              POV_ALL_P = mean(POV_ALL_P, na.rm = T),
              POV_0.17 = sum(POV_0.17, na.rm = T),
              POV_0.17_P = mean(POV_0.17_P, na.rm = T),
              POV_5.17 = sum(POV_5.17, na.rm = T),
              POV_5.17_P = mean(POV_5.17_P, na.rm = T),
              MEDHHINC = mean(MEDHHINC, na.rm = T),
              POP_POV = sum(POP_POV, na.rm = T))
  correct$fips <- fip
  data %>% filter(!(fips %in% fiplace)) %>%
    bind_rows(correct) -> data
  
  return(data)
}

# Function for fips issues for CBP
fipssues1 <- function(data, fip, fiplace){
  data %>% filter(fips %in% fiplace) %>% group_by(year, sic, naics) %>%
    summarise_each(funs(sum), -fips, -empflag) -> correct
  correct$fips <- fip
  data %>% filter(!(fips %in% fiplace)) %>%
    bind_rows(correct) -> data
  
  return(data)
}
fipssues2 <- function(data, fip, fiplace){
  data %>% filter(fips %in% fiplace) %>% group_by(year, naics) %>%
    summarise_each(funs(sum), -fips, -empflag, -(emp_nf:ap_nf)) -> correct
  correct$fips <- fip
  data %>% filter(!(fips %in% fiplace)) %>%
    bind_rows(correct) -> data
  
  return(data)
}