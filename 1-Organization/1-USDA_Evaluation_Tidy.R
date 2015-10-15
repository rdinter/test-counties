# Robert Dinterman

print(paste0("Started 1-USDA_Evaluation_Tidy at ", Sys.time()))

library(dplyr)
library(maptools)
library(readr)
library(tidyr)

# Create a directory for the data
localDir <- "1-Organization/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("0-Data/FCC/FCClong.Rda")
load("0-Data/Shapefiles/zcta2004.Rda")
load("0-Data/Shapefiles/zctap2004.Rda")

zipfind <- function(x, y) {
  x1    <- unique(x)
  y1    <- unique(y)
  check <- x1 %in% y1
  found <- sum(check)
  miss  <- sum(!check)
  total <- length(x1)
  return(list(found   = found,
              missing = miss,
              total   = total,
              percent = miss/total))
}

# # Figure out the missing values:
zipfind(FCC$zip, zcta$ZIP)
zipfind(FCC$zip, zctap$ZIP)

fcczip <- unique(FCC$zip)

check <- zcta$ZIP %in% fcczip
fcemp <- zcta[!check,]
plot(fcemp) # We are missing 146 ZCTA values for FCC data.

# check1 <- data$zip %in% zcta$ZIP
# # 29950 found, but 483 missing
# 
# miss <- data$zip[!check1]
# 
# check2 <- zctap$ZIP %in% miss
# # 108 found, but 41405 missing
# 
# bucket <- zctap[check2,] %over% zcta
# bucket$zctap <- zctap@data[check2, "ZIP"]
# check1 <- data$zip %in% bucket$ZIP
# check2 <- data$zip %in% bucket$zcta
# # Difference here isn't worth the time

load("0-Data/BB_Loans/BBLoans.Rda")


lzips  <- unique(bbloan.ex$zip)

goodloans <- (lzips %in% FCC$zip) & (lzips %in% zcta$ZIP) &
  (lzips %in% zctap$ZIP)
# 1689 good zip codes that match in all 3 ... 609 are not OK

badzips <- lzips[!goodloans] #609
# 
# check1  <- (badzips %in% data$ZIP) & (badzips %in% zcta$ZIP)
# # 0 loan zips are in FCC AND shape
# 
# check2  <- (badzips %in% data$ZIP) & (badzips %in% zctap$ZIP)
# # 6 loans are in FCC and ZCTAP
# 
# check3  <- (badzips %in% data$ZIP) &
#   !(badzips %in% zcta$ZIP) & !(badzips %in% zctap$ZIP)
# # 26 in FCC but not in ZCTA or ZCTAP ... screwed
# 
# check4 <- (badzips %in% zcta$ZIP)
# # 0 ... WELP.

check5 <- (badzips %in% zctap$ZIP)
# 539 are in the ZCTA points!

# Really the only things I can do are to take the loans from lat-long and
#  then aggregate them up to the ZCTA level

correct <- zctap$ZIP %in% badzips
bucket  <- zctap[correct,] %over% zcta
bucket$zctap <- zctap@data[correct, "ZIP"]
bucket  <- select(bucket, ZIP_agg = ZIP, zip = zctap)

loans <- left_join(bbloan.ex, bucket)
loans$ZIP_agg <- ifelse(is.na(loans$ZIP_agg), loans$zip, loans$ZIP_agg)
# Combine the zctap loans with the zcta loans so zcta is our reference set
loans %>%
  group_by(ZIP_agg, year) %>%
  summarise(ploans = sum(ploans, na.rm = T),
            biploans12 = sum(biploans12, na.rm = T),
            biploans1234 = sum(biploans1234, na.rm = T),
            loans = sum(loans, na.rm = T)) %>%
  rename(zip = ZIP_agg) -> loans

load("0-Data/Shapefiles/All_2010_county.Rda")
# Remove the 0 fips
rem <- All$FIPS %% 1000 == 0
All <- All[!rem,]

# Figure out which FIPS is associated with these zip codes
# Address fips problems with 51515, 51560, 51780
fips1       <- zcta %over% All
fips1       <- select(fips1, fips1 = FIPS)
fips1$zip   <- zcta$ZIP
fips1$fips1 <- ifelse(fips1$fips1 == 51515, 51019, fips1$fips1)
fips1$fips1 <- ifelse(fips1$fips1 == 51560, 51005, fips1$fips1)
fips1$fips1 <- ifelse(fips1$fips1 == 51780, 51083, fips1$fips1)

ind   <- is.na(fips1$fips1)
fips1 <- fips1[!ind, ]
# View(zcta[ind,]) #NEED TO FIND THE CLOSEST TO THESE ZIPS
j5    <- zcta[ind,]

library(rgeos)
j6 <- gDistance(j5, All, byid = T)
j5 <- data.frame(zip   = as.numeric(colnames(j6)),
                 fips1 = as.numeric(row.names(j6)[apply(j6, 2, which.min)]))
fips1 <- bind_rows(fips1, j5)

fips2       <- zctap %over% All
fips2       <- select(fips2, fips2 = FIPS)
fips2$zip   <- zctap$ZIP
fips2$fips2 <- ifelse(fips2$fips2 == 51515, 51019, fips2$fips2)
fips2$fips2 <- ifelse(fips2$fips2 == 51560, 51005, fips2$fips2)
fips2$fips2 <- ifelse(fips2$fips2 == 51780, 51083, fips2$fips2)

ind   <- is.na(fips2$fips2)
fips2 <- fips2[!ind, ]
# View(zctap[ind,]) # NEED TO FIND THE CLOSEST TO THESE ZIPS
j5  <- zctap[ind,]

j6 <- gDistance(j5, All, byid = T)
j5 <- data.frame(zip   = as.numeric(colnames(j6)),
                 fips2 = as.numeric(row.names(j6)[apply(j6, 2, which.min)]))
fips2 <- bind_rows(fips2, j5)

fips      <- full_join(fips1, fips2)
fips$fips <- ifelse(is.na(fips$fips2), fips$fips1, fips$fips2)

aloans <- left_join(loans, fips)

write_csv(aloans, paste0(localDir, "/aBBLoans.csv")) #good loans

check <- unique(loans$zip) %in% FCC$zip
zipfind(loans$zip, FCC$zip)
# We got 44 zip code loans that don't match up...damn.

FCC$year  <- as.numeric(format(FCC$time, "%Y"))
FCC$month <- as.numeric(format(FCC$time, "%m"))

bband <- left_join(FCC, loans)
bband <- left_join(bband, fips)

# Remove NAs from loans
bband %>%
  mutate(ploans       = ifelse(is.na(ploans), 0, ploans),
         biploans12   = ifelse(is.na(biploans12), 0, biploans12),
         biploans1234 = ifelse(is.na(biploans1234), 0, biploans1234),
         loans        = ifelse(is.na(loans), 0, loans)) -> bband

write_csv(bband, paste0(localDir, "/broadbandmain.csv"))
save(bband, file = paste0(localDir, "/broadbandmain.Rda"))
rm(badzips, check, check5, correct, goodloans, lzips, FCC, bucket,
   bbloan.ex, fips, fips1, fips2, loans, zctap)

# Adding ------------------------------------------------------------------

zcta$zip <- zcta$ZIP
zipfind(bband$zip, zcta$zip)
zipfind(zcta$zip, bband$zip)
zcta@data %>%
  select(-STATE) %>%
  inner_join(bband) -> data

# Add in the coordinates
coords        <- as.data.frame(coordinates(zcta))
names(coords) <- c("long", "lat")
coords$zip    <- as.numeric(row.names(coords))
data          <- left_join(data, coords)

# Add in the county area
data          <- left_join(data, All@data[, c("FIPS", "AREA_cty", "PERIMETER")],
                           by = c("fips" = "FIPS"))
rm(All)

load("0-Data/ZBP/ZBPfull.Rda")

zbp <- filter(zbpfull, year > 1998, year < 2009)
rm(zbpfull)
zbp %>% group_by(year) %>% summarise(n())

zipfind(data$zip, zbp$zip)

data <- inner_join(data, zbp)
rm(zbp)

load("0-Data/CBP/CBPfull.Rda")

cbp <- cbpfull %>%
  filter(year > 1998, year < 2009) %>%
  rename(emp_fips = emp, qp1_fips = qp1, ap_fips = ap,
         est_fips = est, emp_fips_ = emp_)
rm(cbpfull)
cbp %>% group_by(year) %>% summarise(n())

data <- inner_join(data, cbp)
rm(cbp)

load("0-Data/Terrain/terrainzip.Rda")

zipfind(terraind$zip, data$ZIP)
zipfind(data$ZIP, terraind$zip)

data <- data %>% left_join(terraind) %>% arrange(year, month, zip)
rm(terraind)

# Get rid of values that do not have terrain (AK and HI)
data <- filter(data, !is.na(tri))

load("0-Data/Poverty/pov.Rda")

# Broomfield correction
data$fips <- ifelse(data$year < 2002 & data$fips == 8014, 8013, data$fips)

zipfind(data$fips, pov$fips)
data <- left_join(data, pov)
rm(pov)

load("0-Data/IRS/CTYPop.Rda")

zipfind(data$fips, IRS_POP$fips)
data <- left_join(data, IRS_POP)
rm(IRS_POP)

data$Dividends_IRS <- ifelse(is.na(data$Dividends_IRS), 0, data$Dividends_IRS)
data$Interest_IRS  <- ifelse(is.na(data$Interest_IRS), 0, data$Interest_IRS)

load("0-Data/ERS/ERS.Rda")

ERS %>%
  filter(year > 1999) %>%
  select(fips, ruc03, ruc13, metro03, metro13) -> ERS
zipfind(data$fips, ERS$fips)
data <- left_join(data, ERS)
rm(ERS)

load("0-Data/CPI/CPI.Rda")
data <- left_join(data, CPI) # CPI in 1999 is 166.583
rm(CPI)

# CPI in 1999 is 166.583, adjusting nominal variables:
data %>%
  mutate(MEDHHINC_R      = MEDHHINC*166.583 / CPI,
         AGI_IRS_R       = AGI_IRS*166.583 / CPI,
         Wages_IRS_R     = Wages_IRS*166.583 / CPI,
         Dividends_IRS_R = Dividends_IRS*166.583 / CPI,
         Interest_IRS_R  = Interest_IRS*166.583 / CPI,
         ap_R            = ap*166.583 / CPI,
         qp1_R           = qp1*166.583 / CPI) -> data

# Indicators for Loans at some point in time....
data %>%
  filter(year == 2008) %>%
  mutate(ipilot = ploans > 0, ibip12 = biploans12 > 0,
         ibip1234 = biploans1234 > 0, iloans = loans > 0) %>%
  select(zip, ipilot, ibip12, ibip1234, iloans) %>%
  left_join(data, .) -> data

# Data are not consistent across time, we need to drop ZIPs that do not
# appear in all years:
temp <- table(data$zip)
keep <- temp[temp == 18] #only keep zips that appear 18 times.
data <- filter(data, zip %in% as.numeric(names(keep)))

write_csv(data, paste0(localDir, "/Final.csv"))
save(data, file = paste0(localDir, "/Final.Rda"))

rm(list=ls())

print(paste0("Finished 1-USDA_Evaluation_Tidy at ", Sys.time()))
