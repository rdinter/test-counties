# Robert Dinterman

print(paste0("Started 3-USDA_Evaluation_Prob_Loan at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(glmx) # Care about heteroskedasity?


# suppressMessages(library(tidyr))

# Function
logitplot <- function(x) {
  temp <- data.frame(fit = fitted(x),
                     val = factor(x[["y"]], labels = c("None", "Loan")))
  ggplot(temp, aes(x = fit, group = val, color = val)) + geom_density() +
    theme_minimal() + labs(color = "", x = "Probability of Loan")
}

# Create a directory for the data
localDir <- "3-Basic_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)
# ---- Logits -------------------------------------------------------------
# Stated goals: underserved rural communities with fewer than 20,000
ploans <- glm(iloans ~ I(Prov_alt < 2) + I(SUMBLKPOP < 20000) + ruc,
              family = binomial(link = "logit"),
              data = data, subset = time == "2000-12-31")
summary(ploans) # WELP, looks like that 20,000 rule is opposite

logitplot(ploans)

hploans <- hetglm(iloans ~ I(Prov_alt < 2) + I(SUMBLKPOP < 20000) + ruc,
                  family = binomial(link = "logit"),
                  data = data, subset = time == "2000-12-31")
summary(hploans)

logitplot(hploans)

# ---- Accurate -----------------------------------------------------------

# ploans1 <- glm(iloans ~ I(Prov_alt < 2) + Prov_alt + log(SUMBLKPOP + 1) +
#                  I(SUMBLKPOP < 20000) + ruc + log(est) + logINC + tri,
#               family = binomial(link = "logit"),
#               data = data, subset = time == "2000-12-31")
# summary(ploans1)
# logitplot(ploans1)

hploans1 <- hetglm(iloans ~ I(Prov_alt < 2) + Prov_alt + log(SUMBLKPOP + 1) +
                     I(SUMBLKPOP < 20000) + ruc + log(est) + logINC + tri,
                family = binomial(link = "logit"),
                data = data, subset = time == "2000-12-31")
summary(hploans1)
logitplot(hploans1)


# ---- Pilot --------------------------------------------------------------

hppilot <- hetglm(ipilot ~ I(Prov_alt < 2) + Prov_alt + log(SUMBLKPOP + 1) +
                    I(SUMBLKPOP < 20000) + ruc + log(est) + logINC + tri,
                  family = binomial(link = "logit"),
                  data = data, subset = time == "2000-12-31")
summary(hppilot)
logitplot(hppilot)

# ---- Farm Bill ----------------------------------------------------------

hpbip   <- hetglm(ibip1234 ~ I(Prov_alt < 2) + Prov_alt + log(SUMBLKPOP + 1) +
                    I(SUMBLKPOP < 20000) + ruc + log(est) + logINC + tri,
                  family = binomial(link = "logit"),
                  data = data, subset = time == "2000-12-31")
summary(hpbip)
logitplot(hpbip)

# ---- Test ---------------------------------------------------------------

data$weights <- hploans1$fitted.values
data$iweight <- 1 / hploans1$fitted.values
poist <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logINC +
               tri + ruc + factor(time), family = poisson, data = data,
             weights = weights)
summary(poist)