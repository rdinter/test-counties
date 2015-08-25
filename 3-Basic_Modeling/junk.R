library(MASS)
poisprov <- fitdistr(round(pdata$Prov_num), densfun = "Poisson")

library(car)
qqp(round(pdata$Prov_num), "pois", poisprov$estimate)

nbinom <- fitdistr(round(pdata$Prov_num), "Negative Binomial")
qqp(round(pdata$Prov_num), "nbinom", size = nbinom$estimate[[1]],
    mu = nbinom$estimate[[2]])