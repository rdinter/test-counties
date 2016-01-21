# test-counties


## Organization:

The main theme behind this repository is to have an easy to access data-source that can be easily accessed for multiple projects. The `Project` is the identifier for various ideas, research interests, modeling exercises, etc. As this becomes more populated with Projects, I will give a short description for each.

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
* 1-Organization/
    * `1-Project_Tidy.R` - script to gather particular data
    * Project/
        * Properly formatted and gathered data for further analysis.
* 2-Exploratory/
    * `2-Project_Explore.R` - summary statistics, histograms, plots, maps, etc.
    * Project/
        * Various plots, figures, tables, and maps saved. Not all are valuable or finished.
* 3-Basic_Modeling/
    * `3-Project_Basic_XXX.R` - basically OLS type of analysis to see what the data are doing.
    * Project/
        * Saved results, although some of these may never be of use for the final product.
* 4-Advanced_Modeling/
    * `4-Project_Advanced_XXX.R` - a more complex, and hopefully complete, way of modeling the data for the particular project.
    * Project/
        * Various ideas for solving the problem of interest.
* 5-Results/
    * `5-Project_Results.R` - the output to be used for said project.
    * Project/
        * Finished results.

## Projects
At the moment, the following `Projects` within this repository are:

1. `USDA_Evaluation` - 
2. `Migration` - 
3. `Breweries` - 

## Packages Needed
Do need to install the [cleangeo](https://github.com/eblondel/cleangeo) package in order to correct for shapefile issues from [Emmanuel Blondel's Github](https://github.com/eblondel) with:

```R
# install.packages("devtools")
devtools::install_github("eblondel/cleangeo")
library(cleangeo)
```

Further, other packages needed include: `dplyr`, `ggplot2`, `jsonlite`, `maptools`, `pbapply`, `raster`, `RCurl`, `readr`, `readxl`, `rgdal`, `spdep`, `stringr`, `tidyr`.

# Various To-Do Items:

This is still currently a work in progress. At the moment, here are a few things I know that I will eventually need to tackle:

1. Hosting various datasets (BB loans, FCC data, etc.) on a site so that R scripts are automated.
2. Delve into the BEA API and sort through their various data. Document this as well.
3. Convert Matlab code (for origin-destination models and potentially dynamic spatial ordered probit) to R scripts.

<!--
# Cheat Sheet
Plain text
End a line with two spaces to start a new paragraph.  
*italics* and _italics_  
**bold** and __bold__  
superscript^2^  
~~strikethrough~~  
[link](www.rstudio.com)  

# Header 1  
## Header 2  
### Header 3  
#### Header 4  
##### Header 5  
###### Header 6  

endash: --  
emdash: ---  
ellipsis: ...  
inline equation: $A = \pi*r^{2}$  
image: ![](RStudioSmall.png)  
horizontal rule (or slide break):

***

> block quote

* unordered list
* item 2
  + sub-item 1
  + sub-item 2

1. ordered list
2. item 2
  + sub-item 1
  + sub-item 2

Table Header  | Second Header
------------- |-------------
Table Cell    | Cell 2
Cell 3        | Cell 4

| Tables   |      Are      |  Cool |
|----------|:-------------:|------:|
| col 1 is |  left-aligned | $1600 |
| col 2 is |    centered   |   $12 |
| col 3 is | right-aligned |    $1 |
-->