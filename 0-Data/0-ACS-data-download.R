# Robert Dinterman

print(paste0("Started 0-ACS-data-download at ", Sys.time()))

# Create a directory for the data
localDir <- "0-Data/ACS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

base <- "https://www.census.gov/hhes/migration/files/acs/county-to-county/"

# ---- 2005 to 2009 5-year estimate ---------------------------------------

# https://www.census.gov/hhes/migration/data/acs/
#  county_to_county_mig_2005_to_2009.html

url <- paste0(base, "County_to_County_Mig_Working_Paper.pdf")
download.file(url, destfile = paste(localDir, basename(url), sep = "/"),
              method = "libcurl")

url <- paste0(base, "CtyxCty_US.txt")
download.file(url, destfile = paste0(data_source, "/ACS_05-09.txt"),
              method = "libcurl")

# ---- 2006 to 2010 5-year estimates --------------------------------------

basel <- paste0(base, "2006-2010/")

url <- paste0(basel, "2006-2010%20Migration%20Flows%20Documentation.pdf")
download.file(url, destfile = paste(localDir, basename(url), sep = "/"),
              method = "libcurl")

temp <- c("CtyxCty_US.txt", "CtyxCty_sex_US.txt", "CtyxCty_age_US.txt",
          "CtyxCty_race_US.txt", "CtyxCty_hisp_US.txt")
urls <- paste0(basel, temp)

files <- gsub("CtyxCty_US", "ACS_06-10", temp)
files <- gsub("CtyxCty", "ACS_06-10", files)
files <- paste(data_source, files, sep = "/")

if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

# ---- 2007 to 2011 5-year estimates --------------------------------------

basel <- paste0(base, "2007-2011/")

url <- paste0(basel, "2007-2011%20Migration%20Flows%20Documentation.pdf")
download.file(url, destfile = paste(localDir, basename(url), sep = "/"),
              method = "libcurl")

temp <- c("CtyxCty_US.txt", "CtyxCty_schl_US.txt",
          "CtyxCty_ahinc_US.txt", "CtyxCty_apinc_US.txt")
urls <- paste0(basel, temp)

files <- gsub("CtyxCty_US", "ACS_07-11", temp)
files <- gsub("CtyxCty", "ACS_07-11", files)
files <- paste(data_source, files, sep = "/")

if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

# ---- 2008 to 2012 5-year estimates --------------------------------------

basel <- paste0(base, "2008-2012/")

url <- paste0(basel, "2008-2012%20Migration%20Flows%20Documentation.pdf")
download.file(url, destfile = paste(localDir, basename(url), sep = "/"),
              method = "libcurl")

temp <- c("CtyxCty_US.txt", "CtyxCty_esr_US.txt",
          "CtyxCty_occ_US.txt", "CtyxCty_wks_US.txt")
urls <- paste0(basel, temp)

files <- gsub("CtyxCty_US", "ACS_08-12", temp)
files <- gsub("CtyxCty", "ACS_08-12", files)
files <- paste(data_source, files, sep = "/")

if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

# ---- 2009 to 2013 5-year estimates --------------------------------------

basel <- paste0(base, "2009-2013/")

url  <- paste0(basel, "2009-2013%20Migration%20Flows%20Documentation.pdf")
download.file(url, destfile = paste(localDir, basename(url), sep = "/"),
              method = "libcurl")

temp <- c("CtyxCty_US.txt", "CtyxCty_engr_US.txt",
          "CtyxCty_pobr_US.txt", "CtyxCty_years_US.txt")
urls <- paste0(basel, temp)

files <- gsub("CtyxCty_US", "ACS_09-13", temp)
files <- gsub("CtyxCty", "ACS_09-13", files)
files <- paste(data_source, files, sep = "/")

if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}


rm(list = ls())

print(paste0("Finished 0-ACS-data-download at ", Sys.time()))