# Robert Dinterman

print(paste0("Started 0-ACS-read-classes at ", Sys.time()))

library(dplyr)
library(readr)

# Create a directory for the data
localDir <- "0-Data/ACS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

allfiles <- list.files(data_source, pattern = ".*.txt$", full.names = T)
files    <- list.files(data_source, pattern = ".*[[:digit:]].txt$",
                       full.names = T)
files    <- subset(allfiles, !(allfiles %in% files)) # stratified files

begin <- c(1, 4, 7, 10, 13, 16, 46, 82, 91, 100, 108, 116, 124, 132, 140,
            148, 156, 164, 172, 180, 188, 196, 226, 262, 271, 280, 288,
            296, 304, 312, 320, 328, 336, 344, 352, 360, 368, 376, 384)

ends  <- c(3, 6, 9, 12, 14, 45, 80, 89, 98, 106, 114, 122, 130, 138, 146,
            154, 162, 170, 178, 186, 194, 225, 260, 269, 278, 286, 294,
            302, 310, 318, 326, 334, 342, 350, 358, 366, 374, 382, 390)
coln  <- c("statedfips", "countydfips", "stateofips", "countyofips", "CODE",
            "STATEd", "COUNTYd", "countydPop", "countydPop_moe", "nonmove",
            "nonmove_moe", "USmove", "USmove_moe", "movecounty",
            "movecounty_moe", "movestate", "movestate_moe", "moveUS",
            "moveUS_moe", "moveforeign", "moveforeign_moe",
            "STATEo", "COUNTYo", "countyoPop", "countyoPop_moe", "nonmoveo",
            "nonmoveo_moe", "USmoveo", "USmoveo_moe", "movecountyo",
            "movecountyo_moe", "movestateo", "movestateo_moe", "moveUSo",
            "moveUSo_moe", "movePR", "movePR_moe", "movewithin",
            "movewithin_moe")
pos   <- fwf_positions(begin, ends, coln)
type  <- "iiiiccciiiiiiiiiiiiiicciiiiiiiiiiiiiiii"

# Creates a column for the file that data are taken from
func1 <- function(x, pos = pos, type = type) {
  data <- read_fwf(x, col_positions = pos, col_types = type)
  data$file  <- basename(x)
  data$year1 <- 2000 + as.numeric(substr(gsub("[^[:digit:]]", "",
                                              basename(x)), 1, 2))
  data$year2 <- 2000 + as.numeric(substr(gsub("[^[:digit:]]", "",
                                              basename(x)), 3, 4))
  data$ofips <- 1000*data$stateofips + data$countyofips
  data$dfips <- 1000*data$statedfips + data$countydfips
  return(data)
}

ACS  <- lapply(files, function(x) func1(x, pos, type))
ACS  <- bind_rows(ACS)

# 2006-10
# Age Code:
#   01 = 1 to 4 years
# 02 = 5 to 17 years
# 03 = 18 to 19 years
# 04 = 20 to 24 years
# 05 = 25 to 29 years
# 06 = 30 to 34 years
# 07 = 35 to 39 years
# 08 = 40 to 44 years
# 09 = 45 to 49 years
# 10 = 50 to 54 years
# 11 = 55 to 59 years
# 12 = 60 to 64 years
# 13 = 65 to 69 years
# 14 = 70 to 74 years
# 15 = 75 years and over
# Sex Code:
#   01 = Male
# 02 = Female
# Race Code:
#   01 = White alone
# 02 = Black or African American alone
# 03 = Asian alone
# 04 = Other race alone or Two or more races
# Hispanic or Latino Origin:
#   01 = White alone, not Hispanic or Latino
# 02 = Not white alone, not Hispanic or Latino
# 03 = Hispanic or Latino

# 2007-11
# Educational Attainment Code:
#   (Population 25 years and over)
# 01 = Less than high school graduate
# 02 = High school graduate (includes equivalency)
# 03 = Some college or associate’s degree
# 04 = Bachelor’s degree
# 05 = Graduate or professional degree
# Household Income in the Past Year (In 2011 Inflation-Adjusted Dollars)
# Code:
#   (Population 1 year and over in households)
# 01 = Less than $10,000
# 02 = $10,000 to $14,999
# 03 = $15,000 to $24,999
# 04 = $25,000 to $34,999
# 05 = $35,000 to $49,999
# 06 = $50,000 to $74,999
# 07 = $75,000 to $99,999
# 08 = $100,000 to $149,999
# 09 = $150,000 or more
# Individual Income in the Past Year (In 2011 Inflation-Adjusted Dollars) Code:
#   (Population 16 years and over)
# 01 = No income
# 02 = $1 to $9,999 or loss
# 03 = $10,000 to $14,999
# 04 = $15,000 to $24,999
# 05 = $25,000 to $34,999
# 06 = $35,000 to $49,999
# 07 = $50,000 to $64,999
# 08 = $65,000 to $74,999
# 09 = $75,000 or more

# 2008-12
# Employment Status Code:
#   (Universe: Population 16 years and over)
# 01 = In labor force, employed civilian
# 02 = In labor force, unemployed
# 03 = In labor force, in Armed Forces
# 04 = Not in labor force
# Occupation Code:
#   (Universe: Population 16 years and over who last worked within the past 5
#    years)
# 01 = Management, business, science, and arts occupations
# 02 = Service occupations
# 03 = Sales and office occupations
# 04 = Natural resources, construction, and maintenance occupations
# 05 = Production, transportation, and material moving occupations
# 06 = Military specific occupations11
# Work Status Code:
#   (Universe: Population 16 years and over)
# 01 = Worked 50 to 52 weeks in the past 12 months and usually worked
# 35 or more hours per week
# 02 = Worked 50 to 52 weeks in the past 12 months and usually worked
# less than 35 hours per week
# 03 = Worked 1 to 49 weeks in the past 12 months and usually worked 35
# or more hours per week
# 04 = Worked 1 to 49 weeks in the past 12 months and usually worked
# less than 35 hours per week
# 05 = Last worked 1 to 5 years ago
# 06 = Last worked over 5 years ago or never worked

# 2009-13
# Characteristic Code
# 
# Ability to Speak English:
#   (Universe: Population 5 years and over)
# 01 = Speak only English
# 02 = Speak a language other than English, speak English “very well”
# 03 = Speak a language other than English, speak English less than “very well”
# 
# Place of Birth Code:
#   (Universe: Population 1 year and over)
# 01 = Same state* as current residence and residence 1 year ago
# 02 = Same state* as current residence, different state from residence 1 year ago (The latter may be a U.S. Island Area or foreign country)
# 03 = Different state* than current residence, same state as residence 1 year ago
# 04 = Different state* than current residence or residence 1 year ago (The latter may be a U.S. Island Area or foreign country)
# 05 = Born in U.S. Island Area
# 06 = Born in Germany
# 07 = Born in remainder of Europe
# 08 = Born in China (People’s Republic, Hong Kong, Macau, Paracel Islands, or Taiwan)
# 09 = Born in India
# 10 = Born in the Philippines
# 11 = Born in remainder of Asia
# 12 = Born in Northern America
# 13 = Born in Mexico
# 14 = Born in remainder of Central America
# 15 = Born in the Caribbean
# 16 = Born in South America
# 17 = Born in Africa
# 18 = Born in Oceania or At Sea
# * Includes the District of Columbia and Puerto Rico as state equivalents for place of birth
# 
# Years in United States (or Puerto Rico):
#   (Universe: Population 1 year and over)
# 01 = Born in the United States. (or Puerto Rico for those living in Puerto Rico)
# 02 = Entered the United States (or Puerto Rico) 5 years ago or less
# 03 = Entered the United States (or Puerto Rico) 6 to 15 years ago
# 04 = Entered the United States (or Puerto Rico) 16 years ago or more
