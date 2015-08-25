plm.qq <- function(plmobj){
  require(ggplot2)
  y <- plmobj$model[,1] #dependent var
  e <- scale(plmobj$residuals)
  
  yy <- quantile(y, c(0.25, 0.75))
  xx <- qnorm(c(0.25, 0.75))
  slope <- diff(yy) / diff(xx)
  int <- yy[1L] - slope * xx[1L]
  
  d <- data.frame(resids = e)
  
  ggplot(d, aes(sample = resids)) + stat_qq() +
    geom_abline(slope = slope, intercept = int)
  
}

ggnorm.year <- function(res, year){
  require(ggplot2)
  
  
}

#####################################################################################
# Q-Q plot in ggplot2
# taken from http://stackoverflow.com/questions/4357031/qqnorm-and-qqline-in-ggplot2
#####################################################################################
#https://gist.github.com/meren/4485081
require(ggplot2)

vec <- Hg$AMT # whateer

y <- quantile(vec[!is.na(vec)], c(0.25, 0.75))
x <- qnorm(c(0.25, 0.75))
slope <- diff(y)/diff(x)
int <- y[1L] - slope * x[1L]

d <- data.frame(resids = vec)

ggplot(d, aes(sample = resids)) + stat_qq() + geom_abline(slope = slope, intercept = int)
