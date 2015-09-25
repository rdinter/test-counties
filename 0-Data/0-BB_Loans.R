# Robert Dinterman

# Broadband Loan Data from Ivan

print(paste0("Started 0-BB_Loans at ", Sys.time()))

options(scipen=999) #Turn off scientific notation for write.csv()
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(tidyr))

# Create a directory for the data
localDir <- "0-Data/BB_Loans"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# STEP FOR DOWNLOADING DATA?!?!?!

# Read in BB Loan Information

# Correct for this with... na.locf?

# Read in what Ivan has
pilot      <- read_csv(paste0(data_source, "/zippilotloans.csv"))
bbloan12   <- read_csv(paste0(data_source, "/zipBBLoans12.csv"))
bbloan1234 <- read_csv(paste0(data_source, "/zipBBLoans1234.csv"))

# Extend current data to 2008
pilot %>% rename(ploans = pilotnumloans) %>% select(-pilotloanyear) -> pilot

pilot.ex   <- expand.grid(zip = unique(pilot$zip), year = 2002:2008)
pilot.ex   <- left_join(pilot.ex, pilot)

bbloan.ex12  <- expand.grid(zip = unique(bbloan12$zip), year = 2007:2008)

bbloan12 %>% spread(loanyear12, numloans12) %>%
  mutate(n2004 = ifelse(is.na(`2004`), 0, `2004`),
         n2005 = ifelse(is.na(`2005`), 0 + n2004, n2004 + `2005`),
         n2006 = ifelse(is.na(`2006`), 0 + n2005, n2005 + `2006`)) %>%
  select(zip, n2004, n2005, n2006) %>%
  gather(year, biploans12, n2004:n2006) -> bbloan
bbloan$year <- as.numeric(gsub("n", "", bbloan$year))
bbloan %>% filter(year == 2006) %>% select(-year) %>%
  left_join(bbloan.ex12, .) %>%
  filter(year > 2006) %>% bind_rows(bbloan) -> bbloans12


bbloan.ex1234  <- expand.grid(zip = unique(bbloan1234$zip), year = 2007:2008)

bbloan1234 %>% spread(loanyear1234, numloans1234) %>%
  mutate(n2004 = ifelse(is.na(`2004`), 0, `2004`),
         n2005 = ifelse(is.na(`2005`), 0 + n2004, n2004 + `2005`),
         n2006 = ifelse(is.na(`2006`), 0 + n2005, n2005 + `2006`)) %>%
  select(zip, n2004, n2005, n2006) %>%
  gather(year, biploans1234, n2004:n2006) -> bbloan
bbloan$year <- as.numeric(gsub("n", "", bbloan$year))

bbloan %>% filter(year == 2006) %>% select(-year) %>%
  left_join(bbloan.ex1234, .) %>%
  filter(year > 2006) %>% bind_rows(bbloan) -> bbloans1234

bbloan.ex <- expand.grid(zip = unique(c(pilot.ex$zip, bbloans12$zip,
                                        bbloans1234$zip)), year = 2002:2008)

bbloan.ex <- left_join(bbloan.ex, pilot.ex)
bbloan.ex <- left_join(bbloan.ex, bbloans12)
bbloan.ex <- left_join(bbloan.ex, bbloans1234)

bbloan.ex$loans <- rowSums(select(bbloan.ex, ploans, biploans1234),
                           na.rm = T)

write_csv(bbloan.ex, path = paste0(localDir, "/BBLoans.csv"))
save(bbloan.ex, file = paste0(localDir, "/BBLoans.Rda"))

# Back to 1999 ------------------------------------------------------------

suppressMessages(library(zoo))

# Read in what Ivan has
pilot      <- read_csv(paste0(data_source, "/zippilotloans.csv"))
bbloan12   <- read_csv(paste0(data_source, "/zipBBLoans12.csv"))
bbloan1234 <- read_csv(paste0(data_source, "/zipBBLoans1234.csv"))

# Extend current data to 2008
pilot <- rename(pilot, ploans = pilotnumloans, year = pilotloanyear)

pilot.ex   <- expand.grid(zip = unique(pilot$zip), year = 1999:2008)
pilot.ex   <- left_join(pilot.ex, pilot)
pilot.ex %>%
  group_by(zip) %>%
  do(na.locf(.)) -> test

bbloan.ex12  <- expand.grid(zip = unique(bbloan12$zip), year = 1999:2008)

bbloan12 %>% spread(loanyear12, numloans12) %>%
  mutate(n2004 = ifelse(is.na(`2004`), 0, `2004`),
         n2005 = ifelse(is.na(`2005`), 0 + n2004, n2004 + `2005`),
         n2006 = ifelse(is.na(`2006`), 0 + n2005, n2005 + `2006`)) %>%
  select(zip, n2004, n2005, n2006) %>%
  gather(year, biploans12, n2004:n2006) -> bbloan
bbloan$year <- as.numeric(gsub("n", "", bbloan$year))
bbloan %>% filter(year == 2006) %>% select(-year) %>%
  left_join(bbloan.ex12, .) %>%
  filter(year > 2006) %>% bind_rows(bbloan) -> bbloans12


bbloan.ex1234  <- expand.grid(zip = unique(bbloan1234$zip), year = 1999:2008)

bbloan1234 %>% spread(loanyear1234, numloans1234) %>%
  mutate(n2004 = ifelse(is.na(`2004`), 0, `2004`),
         n2005 = ifelse(is.na(`2005`), 0 + n2004, n2004 + `2005`),
         n2006 = ifelse(is.na(`2006`), 0 + n2005, n2005 + `2006`)) %>%
  select(zip, n2004, n2005, n2006) %>%
  gather(year, biploans1234, n2004:n2006) -> bbloan
bbloan$year <- as.numeric(gsub("n", "", bbloan$year))

bbloan %>% filter(year == 2006) %>% select(-year) %>%
  left_join(bbloan.ex1234, .) %>%
  filter(year > 2006) %>% bind_rows(bbloan) -> bbloans1234

bbloan.ex <- expand.grid(zip = unique(c(pilot.ex$zip, bbloans12$zip,
                                        bbloans1234$zip)), year = 2002:2008)

bbloan.ex <- left_join(bbloan.ex, pilot.ex)
bbloan.ex <- left_join(bbloan.ex, bbloans12)
bbloan.ex <- left_join(bbloan.ex, bbloans1234)

bbloan.ex$loans <- rowSums(select(bbloan.ex, ploans, biploans1234),
                           na.rm = T)

rm(list = ls())

print(paste0("Finished 0-BB_Loans at ", Sys.time()))