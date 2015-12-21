# Robert Dinterman
# http://glmm.wikidot.com/faq
# GLMMs via MASS::glmmPQL

print(paste0("Started 4-USDA_Evaluation_OpenBUGS at ", Sys.time()))

# ---- Start --------------------------------------------------------------

library(dplyr)
library(gstat)
library(sp)
library(spacetime)

# suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "4-Advanced_Modeling/USDA_Evaluation"
if (!file.exists(localDir)) dir.create(localDir)

load("1-Organization/USDA_Evaluation/Final.Rda")
data$iloans <- 1*(data$loans > 0)
data$ipilot <- 1*(data$ploans > 0)
data$icur   <- 1*(data$biploans1234 > 0)

# http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2870863/
# 
# The following WinBUGS code presents the general syntax for fitting the
# Gaussian process spatiotemporal Poisson regression model used in this paper.
# The code below involves two continuous covariates, x1 and x2, but can be
# modified appropriately for different kinds of covariates. The variable n
# denotes the number of regions and J denotes the number of sampling dates,
# which are stored in the vector t1. The hyper-parameters, ak and ck, are
# specified by the user and typically μ0 is set equal to the 0 vector.

model{
  for (i in 1:n){
    for (j in 1:J){
      y[i,j] ~ dpois(mu[i,j])
      log(mu[i,j]) <- beta0 + b[i] + W[i,j] + beta1*x1[i,j] + beta2*x2[i,j]
    }
  }
  b[i:n] ~car.normal(ajd[], weights[], num[], taub)
  
  for (i in 1:n){
    for (k in 1:J){
      sigma[j,k] <- theta1*exp(-theta2*abs(t1[j] - t1[k]))
    }
  }
  precision[1:J, 1:J] <- inverse(sigma[1:J, 1:J])
  theta1 ~ dunif(a1, c1)
  theta2 ~ dunif(a2, c2)
  beta0 ~ dnorm(a3, c3)
  beta1 ~ dnorm(a4, c4)
  beta2 ~ dnorm(a5, c5)
  taub ~ dunif(a6, c6)
}
