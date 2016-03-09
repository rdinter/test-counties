load("0-Data/Shapefiles/zcta2004.Rda")
load("1-Organization/USDA_Evaluation/Final.Rda")

localDir    <- "0-Data/Shapefiles"
data_source <- paste0(localDir, "/Raw")
if (!file.exists(localDir)) dir.create(localDir)
if (!file.exists(data_source)) dir.create(data_source)

# ---- Colorado -----------------------------------------------------------

STdata <- subset(data, STATE == "CO")

CO     <- zcta$ObjectID %in% STdata$ObjectID
COzcta <- CO[order(CO$ZIP),]

library(spdep)
weights            <- poly2nb(COzcta)
summary(weights)
weights            <- nb2mat(weights, style = "B", zero.policy = T)
colnames(weights)  <- row.names(weights)

save(weights, file = paste0(localDir, "/contigW-CO.Rda"))



# ---- North Carolina -----------------------------------------------------


STdata <- subset(data, STATE == "NC")

NC <- zcta$ObjectID %in% STdata$ObjectID
NCzcta <- subset(zcta, NC & !(ZIP %in% c(27960, 28465, 28480, 28520)))
NCzcta <- NCzcta[order(NCzcta$ZIP),]

weights            <- poly2nb(NCzcta)
summary(weights)
weights            <- nb2mat(weights, style = "B", zero.policy = T)
colnames(weights)  <- row.names(weights)

save(weights, file = paste0(localDir, "/contigW-NC.Rda"))
# ---- Minnesota ----------------------------------------------------------

STdata <- subset(data, STATE == "MN")

MN <- zcta$ObjectID %in% STdata$ObjectID
MNzcta <- subset(zcta, MN & !(ZIP %in% c(56711,56741)))
MNzcta <- MNzcta[order(MNzcta$ZIP),]

weights            <- poly2nb(MNzcta)
summary(weights)
weights            <- nb2mat(weights, style = "B", zero.policy = T)
colnames(weights)  <- row.names(weights)

save(weights, file = paste0(localDir, "/contigW-MN.Rda"))

# ---- Missouri -----------------------------------------------------------

STdata <- subset(data, STATE == "MO")

MO <- zcta$ObjectID %in% STdata$ObjectID
MOzcta <- subset(zcta, MO)
MOzcta <- MOzcta[order(MOzcta$ZIP),]

weights            <- poly2nb(MOzcta)
summary(weights)
weights            <- nb2mat(weights, style = "B", zero.policy = T)
colnames(weights)  <- row.names(weights)

save(weights, file = paste0(localDir, "/contigW-MO.Rda"))

# ---- Texas --------------------------------------------------------------

STdata <- subset(data, STATE == "TX")

TX <- zcta$ObjectID %in% STdata$ObjectID
TXzcta <- subset(zcta, TX & !(ZIP %in% c(77982, 78597)))
TXzcta <- TXzcta[order(TXzcta$ZIP),]

weights            <- poly2nb(TXzcta)
summary(weights)
weights            <- nb2mat(weights, style = "B", zero.policy = T)
colnames(weights)  <- row.names(weights)

save(weights, file = paste0(localDir, "/contigW-TX.Rda"))

# ---- All ----------------------------------------------------------------


# All of them, remove the nonlinks
nonlink <- c(33040, 96763, 00085, 99546, 99547, 99638, 99591, 99660, 99630,
             99553, 99583, 99661, 99747, 99615, 00195, 99901, 99926, 98110,
             98303, 98070, 98333, 98040, 98250, 98261, 98281, 98262, 56711,
             56741, 54850, 94130, 94501, 00057, 00061, 90704, 78597, 77982,
             00116, 00120, 00119, 00121, 00122, 36528, 31327, 31527, 29451,
             29482, 33924, 33957, 34217, 34228, 34242, 33706, 33715, 33149,
             33109, 33042, 33043, 33050, 48138, 43438, 43436, 43456, 14072,
             15225, 28465, 28480, 28520, 20625, 21634, 21824, 21866, 23066,
             23440, 08226, 08260, 27960, 13640, 05440, 05463, 05474, 08008,
             08203, 10044, 06390, 02807, 02835, 02872, 02713, 00159, 00157,
             03854, 04013, 04017, 04019, 04050, 04108, 04109, 04549, 04576,
             04848, 04570, 04852, 04625, 04635, 04645, 04646, 04685, 04851,
             04853, 04863, 04611, 00158, 02554, 54246, 49757, 49775, 49782,
             49726, 03589, 04462, 04737, 04741, 23336, 85341)
zcta <- subset(zcta,zcta$ObjectID %in% data$ObjectID & !(ZIP %in% nonlink))
zcta <- zcta[order(zcta$ZIP),]

weights            <- poly2nb(zcta)
summary(weights)
weights            <- nb2mat(weights, style = "B", zero.policy = T)
colnames(weights)  <- row.names(weights)

save(weights, file = paste0(localDir, "/contigWzcta.Rda"))
