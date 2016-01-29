# 0-Data

* 0-Data/
    * `0-Data_Source.R` - script to download data and create `.csv` and `.Rda` files in an easy to read and uniform format.
    * Data_Source/ - most of this will be ignored via `.gitignore`.
        * RAW/
            * All downloaded files from the `0-Data_Source.R` script.
            * Some data cannot be downloaded and must be hosted elsewhere. They will also be in this folder for local use.
        * `Various_Names.csv`
        * `Various_Names.Rda`
    * `0-functions.R` - relevant functions for this sub-directory.
    * `.gitignore` - any large files will not be loaded to GitHub.

## Data Collected:

So far, the data sources that have been collected here range from X to Y ...

* `ACS` - [American Community Survey](https://www.census.gov/hhes/migration/data/acs/county-to-county.html) - ACS uses a series of monthly samples to produce estimates. Estimates for geographies of population 65,000 or greater are published annually using these monthly samples. Three years of monthly samples are needed to publish estimates for geographies of 20,000 or greater and five years for smaller geographies. The 5-year dataset is used for the county-to-county migration flows since many counties have a population less than 20,000. The first 5-year ACS dataset covers the years 2005 through 2009. NOTE: can be extended to the micro-sample of 1 years, but not done yet.
    * 2005--2009 (No Characteristics).
    * 2006-2010 5-year ACS  (Crossed by Age, Sex, Race, or Hispanic or Latino Origin).
    * 2007-2011 5-year ACS  (Crossed by Educational Attainment, Household Income, or Individual Income).
    * 2008-2012 5-year ACS  (Crossed by Employment Status, Occupation, or Work Status).
    * 2009-2013 5-year ACS  (Crossed by Ability to Speak English, Place of Birth, Years in the United States).
* `BB_Loans` - [USDA Broadband Loans](http://www.rd.usda.gov/) - data are from Ivan and possibly not available on the web anywhere. Unsure at the moment.
* `CBP` - [County Business Patterns](https://www.census.gov/econ/cbp/download/) - data at the County level for total establishments, employment, annual payroll, quarterly payroll at the end of 1st quarter, and number of establishments in bins for number of employees across 1-4, 5-9, 10-19, 20-49, 50-99, 100-249, 250-499, 500-999, and 1000+ employees. From 1986 to 1997, these are further broken down by SIC industry classification. From 1998 and beyond, the classifications are through NAICS.
    * Suppression issues for employees and payroll arise when it is potentially the case that a firm can be identified due to an overly dominant firm or few number of firms. This is a problem when the industry classifications are narrow in scope and/or are for a small county. The total establishments and bin of number of employees are unaffected by suppression.
    * I have imputed values for employees and payroll based upon a regression of known employees/payroll on the number of firms in employee bins. The coefficients from the known employee bins are then used on the suppressed values of employees/payroll and adjusted for common sense values (ie an empflag variable identifies a range of employees that the industry-county combination has and I ensure all imputed values lie within this range).
* `CPI` - [Consumer Price Index](https://research.stlouisfed.org/fred2/series/CPIAUCSL/downloaddata) - downloaded from FRED, but data are through BLS.
* `ERS` - [USDA Economic Research Service](http://www.ers.usda.gov/data-products/) - utilizes creative class, natural amenities, and rural-urban continuum code data.
* `FCC` - [Federal Communications Commission](https://transition.fcc.gov/wcb/iatd/comp.html) - data from 1999 to 2008 at the ZIP code level for number of providers; some of which needed to be converted manually from PDF to .csv and has been uploaded. From 2008 until 2013, data are available at the County and Census Tract level of number of providers and percentage of subscribers as well as a revised broadband definition. Further, data on Competitive Local Exchange Carriers (CLECs) are available from 2000 to 2008; some had to be converted from PDF to .csv and are uploaded.
* `Govt` - [Census Bureau](http://www.census.gov/govs/local/historical_data_1992.html) - "Federal, State, & Local Governments" (Census of Governments) termed as Fiscal. Data currently are from 1992, 1997, and 2002 at the county level with a select few variables: property, sales, income, corporate, and death taxes. Further, Parks and Recreation expenses.
    * Other data can be gleaned from here, on the To-Do list.
* `IRS` - [Interneal Revenue Service](http://www.irs.gov/uac/SOI-Tax-Stats-County-Data)- county data. From 1989 to 2013 data on population, households, AGI, Wages, Dividends, and Interest at the county level through IRS return data. Further, there are migration county-to-county data available from 1992 to 2013 which includes flows of population, households, and AGI.
* `LAU` - [Local Area Unemployment](http://www.bls.gov/lau/) and [updated](http://www.bls.gov/bls/ftp_migration_crosswalk.htm) - county level data from 1990 to 2014 of annual employeed and unemployeed. Can easily determine the unemployment rate through these counts.
* `NOAA` - [National Oceanic and Atmospheric Administration](https://www.ncdc.noaa.gov/stormevents/ftp.jsp) - Storm Events Database which documents property damage and deaths due to storms at the county level going back to 1950.
* `Population_Census` - [Census Bureau](http://www.census.gov/popest/data/historical/1980s/county.html) and [here](http://www.census.gov/popest/data/counties/asrh/1990s/CO-99-09.html) - age distribution from the Census at the county level. Data are 1980, 1990, 2000, and 2010. Under 5, Under 20, From 20 to 64, Over 65.
* `Poverty` - [Small Area Income and Poverty Estimates](https://www.census.gov/did/www/saipe/data/statecounty/data/index.html) - county level data from 1989 to 2013 from Census Bureau with median household income, population in poverty, percent in poverty, and poverty across aged 0 to 17 and 5 to 17.
* `Shapefiles` - ArcGIS from NC State library: ZCTA shapefile from 2004. Also a county shapefile from the national atlas.
* `Terrain` - using raster package on Shapefiles.
* `ZBP` - [County Business Patterns at the ZIP level](https://www.census.gov/econ/cbp/download/) - same procedure as with the `CBP` data except the ZIP code level data do not stratify by SIC or NAICS classification.
* `ZIP_Cross` - [Census Gazetteer](http://www.census.gov/geo/maps-data/data/gazetteer2000.html) and [Missouri Census Data Center](http://mcdc.missouri.edu/data/) - a link for ZIP codes to FIPS codes.

## To Do list:

Here are the missing ones or ones I need to find, generally at the county level ...

1. ~~NOAA Storm~~
2. Wage rate (QCEW ? na.)
3. Education
4. NORSIS, locally stored.
5. Home Prices? Zillow or Trulia are possible but not complete for US.
6. BEA - GDP - this utilizes an API and is a work in progress.
7. Housing Permits, locally stored.
8. Gov't / Tax Rates ? http://www.census.gov/govs/ ? extend the Census of Governments for 2007 and 2012.
9. Regional Price Index, unsure of existence.
10. [Commuting Zone Data](http://www.ers.usda.gov/data-products/commuting-zones-and-labor-market-areas.aspx)
    * Also the [PIZA Measures](http://www.ers.usda.gov/data-products/population-interaction-zones-for-agriculture-(piza).aspx) - population interaction zones for agriculture.
11. Extend [FCC data](http://www2.ntia.doc.gov/broadband-data) beyond 2013. Should be an API somewhere.
12. [0-Crime-JSON.R](https://github.com/maliabadi/ucr-json) I am unsure how to classify this at the moment...
13. [IRS ZIP Code data](https://www.irs.gov/uac/SOI-Tax-Stats-Individual-Income-Tax-Statistics-ZIP-Code-Data-(SOI)) from 1998 to 2013 but the data structures are all different. Files are in .xls class and by State. Lots of suppression issues, this may take some time to sort out.
14. `MSA` - [Metropolitan Statistical Area](http://www.nber.org/data/cbsa-msa-fips-ssa-county-crosswalk.html) - needs work.
15. `QCEW` - [Quarterly Census of Employment and Wages](http://www.bls.gov/cew/datatoc.htm) - needs an update to dplyr!
16. [ACS data](https://www.census.gov/hhes/migration/data/acs/county_to_county_mig_2007_to_2011.html) has a [Public Use Microdata Survey](https://www.census.gov/programs-surveys/acs/technical-documentation/pums.html) is an area I need to look into for the migration data. The [2012 5 year stats](http://www2.census.gov/acs2012_5yr/pums/) are available and appear to be in a SQL-like format?