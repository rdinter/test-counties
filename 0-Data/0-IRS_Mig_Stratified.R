#Robert Dinterman

print(paste0("Started 0-IRS_Mig_Stratified at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
library(dplyr)
library(readr)

# Create a directory for the data
localDir <- "0-Data/IRS"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

tempDir  <- tempfile()
# unlink(tempDir, recursive = T)

# http://www.irs.gov/uac/SOI-Tax-Stats-Migration-Data
url    <- "http://www.irs.gov/pub/irs-soi/"
year   <- c(1112, 1213, 1314)
urls   <- paste0(url, year, "inmigall.csv")
files  <- paste(data_source, basename(urls), sep = "/")
if (all(sapply(files, function(x) !file.exists(x)))) {
  mapply(download.file, url = urls, destfile = files, method = "libcurl")
}

dat <- lapply(files, function(x) {
  temp <- read_csv(x)
  temp$file <- basename(x)
  temp$year <- as.numeric(substr(basename(x), 1, 2)) + 2001
  return(temp)
  })

dat  <- bind_rows(dat)

# NOTE: AGI is reported in thousands of dollars.
# 1. STATEFIPS State FIPS Code
# 2. STATE State Abbreviation or Postal Code
# 3. STATE_NAME State Name
# 4. AGI_STUB Size of adjusted gross income
#     All AGI classes...........0
#     $1 under $10,000..........1
#     $10,000 under $25,000.....2
#     $25,000 under $50,000.....3
#     $50,000 under $75,000.....4
#     $75,000 under $100,000....5
#     $100,000 under $200,000...6
#     $200,000 or more..........7
# 5. TOTAL_N1_0 Total Returns - number of returns, all ages
# 6. TOTAL_N2_0 Total Returns – number of exemptions, all ages
# 7. TOTAL_AGI_0 Total Returns – adjusted gross income, all ages
# 8. TOTAL_N1_1 Total Returns - number of returns,
#  primary taxpayers under age 26
# 9. TOTAL_N2_1 Total Returns – number of exemptions,
#  primary taxpayers under age 26
# 10. TOTAL_AGI_1 Total Returns – adjusted gross income,
#  primary taxpayers under age 26
# 11. TOTAL_N1_2 Total Returns - number of returns,
#  primary taxpayers ages 26 under 35
# 12. TOTAL_N2_2 Total Returns – number of exemptions,
#  primary taxpayers ages 26 under 35
# 13. TOTAL_AGI_2 Total Returns – adjusted gross income,
#  primary taxpayers ages 26 under 35
# 14. TOTAL_N1_3 Total Returns - number of returns,
#  primary taxpayers ages 35 under 45
# 15. TOTAL_N2_3 Total Returns – number of exemptions,
#  primary taxpayers ages 35 under 45
# 16. TOTAL_AGI_3 Total Returns – adjusted gross income,
#  primary taxpayers ages 35 under 45
# 17. TOTAL_N1_4 Total Returns - number of returns,
#  primary taxpayers ages 45 under 55
# 18. TOTAL_N2_4 Total Returns – number of exemptions,
#  primary taxpayers ages 45 under 55
# 19. TOTAL_AGI_4 Total Returns – adjusted gross income,
#  primary taxpayers ages 45 under 55
# 20. TOTAL_N1_5 Total Returns - number of returns,
#  primary taxpayers ages 55 under 65
# 21. TOTAL_N2_5 Total Returns – number of exemptions,
#  primary taxpayers ages 55 under 65
# 22. TOTAL_AGI_5 Total Returns – adjusted gross income,
#  primary taxpayers ages 55 under 65
# 23. TOTAL_N1_6 Total Returns - number of returns,
#  primary taxpayers ages 65 and over
# 24. TOTAL_N2_6 Total Returns – number of exemptions,
#  primary taxpayers ages 65 and over
# 25. TOTAL_AGI_6 Total Returns – adjusted gross income,
#  primary taxpayers ages 65 and over
# 26. NONMIG_N1_0 Non-migrant Returns - number of returns, all ages
# 27. NONMIG_N2_0 Non-migrant Returns – number of exemptions, all ages
# 28. NONMIG_AGI_0 Non-migrant Returns – adjusted gross income, all ages
# 29. NONMIG_N1_1 Non-migrant Returns - number of returns,
#  primary taxpayers under age 26
# 30. NONMIG_N2_1 Non-migrant Returns – number of exemptions,
#  primary taxpayers under age 26
# 31. NONMIG_AGI_1 Non-migrant Returns – adjusted gross income,
#  primary taxpayers under age 26
# 32. NONMIG_N1_2 Non-migrant Returns - number of returns,
#  primary taxpayers ages 26 under 35
# 33. NONMIG_N2_2 Non-migrant Returns – number of exemptions,
#  primary taxpayers ages 26 under 35
# 34. NONMIG_AGI_2 Non-migrant Returns – adjusted gross income,
#  primary taxpayers ages 26 under 35
# 35. NONMIG_N1_3 Non-migrant Returns - number of returns,
#  primary taxpayers ages 35 under 45
# 36. NONMIG_N2_3 Non-migrant Returns – number of exemptions,
#  primary taxpayers ages 35 under 45
# 37. NONMIG_AGI_3 Non-migrant Returns – adjusted gross income,
#  primary taxpayers ages 35 under 45
# 38. NONMIG_N1_4 Non-migrant Returns - number of returns,
#  primary taxpayers ages 45 under 55
# 39. NONMIG_N2_4 Non-migrant Returns – number of exemptions,
#  primary taxpayers ages 45 under 55
# 40. NONMIG_AGI_4 Non-migrant Returns – adjusted gross income,
#  primary taxpayers ages 45 under 55
# 41. NONMIG_N1_5 Non-migrant Returns - number of returns,
#  primary taxpayers ages 55 under 65
# 42. NONMIG_N2_5 Non-migrant Returns – number of exemptions,
#  primary taxpayers ages 55 under 65
# 43. NONMIG_AGI_5 Non-migrant Returns – adjusted gross income,
#  primary taxpayers ages 55 under 65
# 44. NONMIG_N1_6 Non-migrant Returns - number of returns,
#  primary taxpayers ages 65 and over
# 45. NONMIG_N2_6 Non-migrant Returns – number of exemptions,
#  primary taxpayers ages 65 and over
# 46. NONMIG_AGI_6 Non-migrant Returns – adjusted gross income, 
#  primary taxpayers ages 65 and over
# 47. OUTFLOW_N1_0 Outflow Returns - number of returns, all ages
# 48. OUTFLOW_N2_0 Outflow Returns – number of exemptions, all ages
# 49. OUTFLOW_AGI_0 Outflow Returns – adjusted gross income, all ages
# 50. OUTFLOW_N1_1 Outflow Returns - number of returns,
#  primary taxpayers under age 26
# 51. OUTFLOW_N2_1 Outflow Returns – number of exemptions,
#  primary taxpayers under age 26
# 52. OUTFLOW_AGI_1 Outflow Returns – adjusted gross income,
#  primary taxpayers under age 26
# 53. OUTFLOW_N1_2 Outflow Returns - number of returns,
#  primary taxpayers ages 26 under 35
# 54. OUTFLOW_N2_2 Outflow Returns – number of exemptions,
#  primary taxpayers ages 26 under 35
# 55. OUTFLOW_AGI_2 Outflow Returns – adjusted gross income,
#  primary taxpayers ages 26 under 35
# 56. OUTFLOW_N1_3 Outflow Returns - number of returns,
#  primary taxpayers ages 35 under 45
# 57. OUTFLOW_N2_3 Outflow Returns – number of exemptions,
#  primary taxpayers ages 35 under 45
# 58. OUTFLOW_AGI_3 Outflow Returns – adjusted gross income,
#  primary taxpayers ages 35 under 45
# 59. OUTFLOW_N1_4 Outflow Returns - number of returns,
#  primary taxpayers ages 45 under 55
# 60. OUTFLOW_N2_4 Outflow Returns – number of exemptions,
#  primary taxpayers ages 45 under 55
# 61. OUTFLOW_AGI_4 Outflow Returns – adjusted gross income,
#  primary taxpayers ages 45 under 55
# 62. OUTFLOW_N1_5 Outflow Returns - number of returns,
#  primary taxpayers ages 55 under 65
# 63. OUTFLOW_N2_5 Outflow Returns – number of exemptions,
#  primary taxpayers ages 55 under 65
# 64. OUTFLOW_AGI_5 Outflow Returns – adjusted gross income,
#  primary taxpayers ages 55 under 65
# 65. OUTFLOW_N1_6 Outflow Returns - number of returns,
#  primary taxpayers ages 65 and over
# 66. OUTFLOW_N2_6 Outflow Returns – number of exemptions,
#  primary taxpayers ages 65 and over
# 67. OUTFLOW_AGI_6 Outflow Returns – adjusted gross income,
#  primary taxpayers ages 65 and over
# 68. INFLOW_N1_0 Inflow Returns - number of returns, all ages
# 69. INFLOW_N2_0 Inflow Returns – number of exemptions, all ages
# 70. INFLOW_AGI_0 Inflow Returns – adjusted gross income, all ages
# 71. INFLOW_N1_1 Inflow Returns - number of returns,
#  primary taxpayers under age 26
# 72. INFLOW_N2_1 Inflow Returns – number of exemptions,
#  primary taxpayers under age 26
# 73. INFLOW_AGI_1 Inflow Returns – adjusted gross income,
#  primary taxpayers under age 26
# 74. INFLOW_N1_2 Inflow Returns - number of returns,
#  primary taxpayers ages 26 under 35
# 75. INFLOW_N2_2 Inflow Returns – number of exemptions,
#  primary taxpayers ages 26 under 35
# 76. INFLOW_AGI_2 Inflow Returns – adjusted gross income,
#  primary taxpayers ages 26 under 35
# 77. INFLOW_N1_3 Inflow Returns - number of returns,
#  primary taxpayers ages 35 under 45
# 78. INFLOW_N2_3 Inflow Returns – number of exemptions,
#  primary taxpayers ages 35 under 45
# 79. INFLOW_AGI_3 Inflow Returns – adjusted gross income,
#  primary taxpayers ages 35 under 45
# 80. INFLOW_N1_4 Inflow Returns - number of returns,
#  primary taxpayers ages 45 under 55
# 81. INFLOW_N2_4 Inflow Returns – number of exemptions,
#  primary taxpayers ages 45 under 55
# 82. INFLOW_AGI_4 Inflow Returns – adjusted gross income,
#  primary taxpayers ages 45 under 55
# 83. INFLOW_N1_5 Inflow Returns - number of returns,
#  primary taxpayers ages 55 under 65
# 84. INFLOW_N2_5 Inflow Returns – number of exemptions,
#  primary taxpayers ages 55 under 65
# 85. INFLOW_AGI_5 Inflow Returns – adjusted gross income,
#  primary taxpayers ages 55 under 65
# 86. INFLOW_N1_6 Inflow Returns - number of returns,
#  primary taxpayers ages 65 and over
# 87. INFLOW_N2_6 Inflow Returns – number of exemptions,
#  primary taxpayers ages 65 and over
# 88. INFLOW_AGI_6 Inflow Returns – adjusted gross income,
#  primary taxpayers ages 65 and over
# 89. SAMEST_N1_0 Same State Returns - number of returns, all ages
# 90. SAMEST_N2_0 Same State Returns – number of exemptions, all ages
# 91. SAMEST_AGI_0 Same State Returns – adjusted gross income, all ages
# 92. SAMEST_N1_1 Same State Returns - number of returns,
#  primary taxpayers under age 26
# 93. SAMEST_N2_1 Same State Returns – number of exemptions,
#  primary taxpayers under age 26
# 94. SAMEST_AGI_1 Same State Returns – adjusted gross income,
#  primary taxpayers under age 26
# 95. SAMEST_N1_2 Same State Returns - number of returns,
#  primary taxpayers ages 26 under 35
# 96. SAMEST_N2_2 Same State Returns – number of exemptions,
#  primary taxpayers ages 26 under 35
# 97. SAMEST_AGI_2 Same State Returns – adjusted gross income,
#  primary taxpayers ages 26 under 35
# 98. SAMEST_N1_3 Same State Returns - number of returns,
#  primary taxpayers ages 35 under 45
# 99. SAMEST_N2_3 Same State Returns – number of exemptions,
#  primary taxpayers ages 35 under 45
# 100. SAMEST_AGI_3 Same State Returns – adjusted gross income,
#  primary taxpayers ages 35 under 45
# 101. SAMEST_N1_4 Same State Returns - number of returns,
#  primary taxpayers ages 45 under 55
# 102. SAMEST_N2_4 Same State Returns – number of exemptions,
#  primary taxpayers ages 45 under 55
# 103. SAMEST_AGI_4 Same State Returns – adjusted gross income,
#  primary taxpayers ages 45 under 55
# 104. SAMEST_N1_5 Same State Returns - number of returns,
#  primary taxpayers ages 55 under 65
# 105. SAMEST_N2_5 Same State Returns – number of exemptions,
#  primary taxpayers ages 55 under 65
# 106. SAMEST_AGI_5 Same State Returns – adjusted gross income,
#  primary taxpayers ages 55 under 65
# 107. SAMEST_N1_6 Same State Returns - number of returns,
#  primary taxpayers ages 65 and over
# 108. SAMEST_N2_6 Same State Returns – number of exemptions,
#  primary taxpayers ages 65 and over
# 109. SAMEST_AGI_6 Same State Returns – adjusted gross income,
#  primary taxpayers ages 65 and over

