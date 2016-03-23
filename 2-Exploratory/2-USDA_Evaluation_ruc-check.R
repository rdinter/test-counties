# Robert Dinterman
# A quick check of shares across the Rural-Urban Continuum
library(dplyr)
load("~/count/0-Data/IRS/CTYPop.Rda")
load("~/count/0-Data/ERS/ERS.Rda")
ERS$ruc          <- factor(ERS$ruc03)
levels(ERS$ruc)  <- list("metro" = 1:3, "adj" = c(4,6,8), "nonadj" = c(5,7,9))
j5 <- ERS %>%
  filter(year == 2000) %>%
  select(fips, ruc) %>%
  left_join(IRS_POP, .)
# Look at annualized nubmers across the RUC codes
j5 %>%
  filter(year %in% 1999:2008) %>%
  group_by(ruc) %>%
  summarise(n = n()/10, tot = sum(Pop_IRS, na.rm = T)/10,
            avg = mean(Pop_IRS, na.rm = T)/10,
            tot_agi = sum(AGI_IRS, na.rm = T)/10,
            avg_agi = mean(AGI_IRS, na.rm = T)/10)
# NA will be Total US population plus some fudge factor of a county w/o ruc code