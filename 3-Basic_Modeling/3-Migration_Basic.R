# Robert Dinterman

print(paste0("Started 3-Migration_Basic at ", Sys.time()))

# ---- Start --------------------------------------------------------------

# Create a directory for the data
localDir <- "3-Basic_Modeling/Migration"
if (!file.exists(localDir)) dir.create(localDir)

# sink(paste0(localDir, "/3-Migration_Basic.txt"))

load("1-Organization/Migration/Aggctydata.Rda")

ctydata$unemprate <- ctydata$Unemp / (ctydata$Unemp + ctydata$Emp)
basic <- subset(ctydata, year == 2008)


# --- Aspatial ------------------------------------------------------------

reg0 <- lm(NET_Exmpt ~ DAMAGE_PROPERTY + Pop_IRS + unemprate + Natamen +
             factor(year), ctydata)

reg1 <- lm(NET_Exmpt ~ DAMAGE_PROPERTY + Pop_IRS + unemprate + Natamen, basic)


# --- Poisson -------------------------------------------------------------

pois <- glm(OUT_Exmpt ~DAMAGE_PROPERTY + Pop_IRS + unemprate + Natamen, 
            #  factor(year),
            family = poisson(link = "log"), data = basic)
