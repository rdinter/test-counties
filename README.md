# test-counties
Organization:

* 0-Data/
    * `0-Data_Source.R` - script to download data and create `.csv` and `.Rda` files in an easy to read and uniform format.
    * Data_Source/ - most of this will be ignored via `.gitignore`.
        * RAW/
            *All downloaded files from the `0-Data_Source.R` script.
        * `Various_Names.csv`
        * `Various_Names.Rda`
    * `0-functions.R` - relevant functions for this subdirectory.
    * `.gitignore` - any large files will not be loaded to github.
* 1-Organization/
    * `1-Project_Tidy.R` - script to gather particular data
* 2-Exploratory/
    *`2-Project_Explore.R` - summary statistics, histograms, plots, maps, etc.
* 3-Basic_Modeling/
    *`3-Project_Basic.R` - basically OLS type of analysis to see what the data are doing.
* 4-Advanced_Modeling/
    *`4-Project_AdvancedXXX.R` - a more complex, and hopefully complete, way of modeling the data for the particular project.
* 5-Results/
    *`5-Project_Results.R` - the output to be used for said project.