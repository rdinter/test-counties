# Robert Dinterman

print(paste0("Started 3-USDA_Evaluation_Prob_Loan at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)
library(ggplot2)
#library(glmx) # Care about heteroskedasity?

# Function
logitplot <- function(x) {
  temp <- data.frame(fit  = fitted(x),
                     val  = factor(x[["y"]], labels = c("None", "Loan")),
                     line = factor(x[["y"]],
                                   labels = c("solid", "dashed")))
  ggplot(temp, aes(x = fit, group = val, fill = val, linetype = val)) +
    geom_density(alpha = 0.5, size = 2) +
    theme_minimal(base_size = 36) + 
    #guides(fill = guide_legend(override.aes = list(colour = NULL))) +
    labs(x = "Probability of Loan", fill = "", linetype = "", y = "")
}

# Create a directory for the data
localDir <- "3-Basic_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")

# ---- Logits -------------------------------------------------------------
# Stated goals: underserved rural communities with fewer than 20,000
ploans <- glm(iloans ~ I(Prov_num < 3) + I(SUMBLKPOP < 20000) + ruc,
              family = binomial(link = "logit"),
              data = data, subset = time == "2000-12-31")
summary(ploans) # WELP, looks like that 20,000 rule is opposite

logitplot(ploans)

hploans <- hetglm(iloans ~ I(Prov_num < 3) + I(SUMBLKPOP < 20000) + ruc,
                  family = binomial(link = "logit"),
                  data = data, subset = time == "2000-12-31")
summary(hploans)

logitplot(hploans)

# ---- Accurate -----------------------------------------------------------
hploans1 <- hetglm(iloans ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                     I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
                family = binomial(link = "logit"),
                data = data, subset = time == "2000-12-31")
summary(hploans1)
logitplot(hploans1)


# ---- Pilot --------------------------------------------------------------

hppilot <- hetglm(ipilot ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                    I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
                  family = binomial(link = "logit"),
                  data = data, subset = time == "2000-12-31")
summary(hppilot)
logitplot(hppilot)

# ---- Farm Bill ----------------------------------------------------------

hpbip   <- hetglm(ibip1234 ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                    I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
                  family = binomial(link = "logit"),
                  data = data, subset = time == "2000-12-31")
summary(hpbip)
logitplot(hpbip)

# ---- Test ---------------------------------------------------------------

data$weights <- hploans1$fitted.values
data$iweight <- 1 / hploans1$fitted.values


# ---- Stargazer ----------------------------------------------------------
rm(hploans, hploans1, hppilot, hpbip)

ploans1 <- glm(iloans ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "logit"),
               data = data, subset = time == "2000-12-31")
summary(ploans1)
logitplot(ploans1)
ggsave(paste0(localDir, "/Logit_predictions.png"), width = 10, height = 7.5)

ppilot  <- glm(ipilot ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "logit"),
               data = data, subset = time == "2000-12-31")
summary(ppilot)
pbip    <- glm(ibip1234 ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "logit"),
               data = data, subset = time == "2000-12-31")
summary(pbip)
pbip2   <- glm(ibip1234 ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "logit"),
               data = data, subset = time == "2002-12-31")
summary(pbip2)

library(stargazer)
stargazer(ploans, ploans1, ppilot, pbip, pbip2,
          title = "Probability of Recveiving Loan (Logit)",
          out = paste0(localDir, "/Logit_loans.tex"))

ploans <- glm(iloans ~ I(Prov_num < 3) + I(SUMBLKPOP < 20000) + ruc,
              family = binomial(link = "probit"),
              data = data, subset = time == "2000-12-31")
summary(ploans) # WELP, looks like that 20,000 rule is opposite
ploans1 <- glm(iloans ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "probit"),
               data = data, subset = time == "2000-12-31")
summary(ploans1)
logitplot(ploans1)
ggsave(paste0(localDir, "/Probit_predictions.png"), width = 10, height = 7.5)

ppilot  <- glm(ipilot ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "probit"),
               data = data, subset = time == "2000-12-31")
summary(ppilot)
pbip    <- glm(ibip1234 ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "probit"),
               data = data, subset = time == "2000-12-31")
summary(pbip)
pbip2   <- glm(ibip1234 ~ I(Prov_num < 3) + Prov_num + log(SUMBLKPOP + 1) +
                 I(SUMBLKPOP < 20000) + ruc + log(est) + logAPay_R2 + tri,
               family = binomial(link = "probit"),
               data = data, subset = time == "2002-12-31")
summary(pbip2)

stargazer(ploans, ploans1, ppilot, pbip, pbip2,
          title = "Probability of Recveiving Loan (Probit)",
          out = paste0(localDir, "/Probit_loans.tex"))
rm(ploans, ploans1, ppilot, pbip, pbip2)
# ---- Auxiliary ----------------------------------------------------------


library(car)

data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)

poist <- glm(Prov_num ~ iloans + log(est) + log(Pop_IRS) + logAPay_R2 +
               tri + ruc + factor(time), family = poisson, data = data,
             weights = iweight)
summary(poist)

pois1 <- glm(Prov_num ~ iloans + ruc:iloans + log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data,
             weights = iweight)
summary(pois1)

sum(coef(pois1)[c("iloans", "rucadj", "iloans:rucadj")])
linearHypothesis(pois1, "1*iloans + 1*rucadj + 1*iloans:rucadj = 0")

sum(coef(pois1)[c("iloans", "rucnonadj", "iloans:rucnonadj")])
linearHypothesis(pois1, "1*iloans + 1*rucnonadj + 1*iloans:rucnonadj = 0")

pois2 <- glm(Prov_num ~ ipilot + icur + log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data,
             weights = iweight)
summary(pois2)

pois3 <- glm(Prov_num ~ ipilot + icur + ruc:ipilot + ruc:icur +
               log(est) + log(Pop_IRS) +
               logAPay_R2 + tri + ruc + poly(AREA_zcta,2) +
               I(Pop_IRS / AREA_cty) + I(est / AREA_zcta) +
               factor(time), family = poisson, data = data,
             weights = iweight)
summary(pois3)

sum(coef(pois3)[c("ipilot", "rucadj", "ipilot:rucadj")])
linearHypothesis(pois3, "1*ipilot + 1*rucadj + 1*ipilot:rucadj = 0")

sum(coef(pois3)[c("ipilot", "rucnonadj", "ipilot:rucnonadj")])
linearHypothesis(pois3, "1*ipilot + 1*rucnonadj + 1*ipilot:rucnonadj = 0")

sum(coef(pois3)[c("icur", "rucadj", "icur:rucadj")])
linearHypothesis(pois3, "1*icur + 1*rucadj + 1*icur:rucadj = 0")

sum(coef(pois3)[c("icur", "rucnonadj", "icur:rucnonadj")])
linearHypothesis(pois3, "1*icur + 1*rucnonadj + 1*icur:rucnonadj = 0")

stargazer(poist, pois1, pois2, pois3,
          title = "Poisson Weighted Regressions",
          out = paste0(localDir, "/Poisson_Weight.tex"))

# ---- Marginal Effects ...
mean(poist$coefficients["iloans"]*poist$fitted.values) # First model

mean(sum(coef(pois1)[c("iloans", "rucadj", "iloans:rucadj")])*
       pois1$fitted.values) # Second Model Rural Adjacent

mean(sum(coef(pois1)[c("iloans", "rucnonadj", "iloans:rucnonadj")])*
       pois1$fitted.values) # Second Model Rural Non-Adjacent

mean(coef(pois2)["ipilot"]*pois2$fitted.values) # Pilot model

mean(coef(pois3)["ipilot"]*pois3$fitted.values) # Pilot Metro

mean(sum(coef(pois3)[c("icur", "rucadj", "icur:rucadj")])*
       pois3$fitted.values) # Farm Bill Rural Adjacent

mean(sum(coef(pois3)[c("icur", "rucnonadj", "icur:rucnonadj")])*
       pois3$fitted.values) # Farm Bill Rural Non-Adjacent