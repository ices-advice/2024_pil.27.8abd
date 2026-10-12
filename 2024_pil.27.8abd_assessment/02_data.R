# Script information ------------------------------------------------------

# Read assessment data (after the bootstrap procedure) and write TAF data tables

# Before running the script in folder ./bootst/initial/data we have: 
#         forecast.ss 
#         sardine.ctl
#         sardine.dat
#         starter.ss
#         wtatage.ss
#         and other files needed later
# After running the script in folder ./data we have:
#         inputData.RData with r4ss input object and TAF .csv data tables:
#         natmort, catage, catch, natage_idx_b1plus, ntotal_idx_b1plus,
#         survey_DEPM, survey_recruits, waca, west, fecundity, maturity

# Authors: Max Olmos (maxime.olmos@ifremer.fr) - big inspiration from Laura Wise (lwise@ipma.pt)

# Date: 14/11/2023

# Load libraries ----------------------------------------------------------

library(icesTAF)
library(r4ss)

# Working directory and folders -------------------------------------------

# check working directory

getwd()

# create data folder using the function mkdir in icesTAF

mkdir("data")

# Read data ---------------------------------------------------------------

# read input files
inputs_data <- SS_readdat("boot/initial/data/sardine.dat", verbose = TRUE, version= "3.24")
inputs_ctl <- SS_readctl("boot/initial/data/sardine.ctl", verbose = TRUE, version= "3.24",datlist = "boot/initial/data/sardine.dat")


# Prepare TAF tables ------------------------------------------------------

# natural maturity table
natmort <- inputs_ctl$natM

# historical numbers at age in the catch table :fisheries
catage <- subset(inputs_data$agecomp,FltSvy==1 & Yr>=(inputs_data$styr) & Yr<(inputs_data$endyr),c("Yr","a0","a1","a2","a3","a4","a5","a6"))

# catch in tonnes : fisherie
catch <- subset(inputs_data$catch, year>=(inputs_data$styr), c('year','Commercial_vessels'))

# numbers at age in the acoustic survey 
natage_idx <- subset(inputs_data$agecomp,FltSvy==2 & Yr%in% inputs_data$styr:inputs_data$endyr,c("Yr","a0","a1","a2","a3","a4","a5","a6"))

# total numbers in the acoustic survey 
ntotal_idx <- subset(inputs_data$CPUE,index==2,c("year","obs"))

# ssb estimated in the DEPM survey (biomass)
survey_DEPM <- subset(inputs_data$CPUE,index==4,c("year","obs"))

# total numbers in eggs count
survey_eggs <- subset(inputs_data$CPUE,index==3,c("year","obs"))

# weight at age in the catch : pelgas
wtatage <- SS_readwtatage(file = "boot/initial/data/wtatage.ss", verbose = TRUE)
waca <- subset(wtatage, Fleet=="-1" & Yr %in% inputs_data$styr:inputs_data$endyr,c("Yr","0","1","2","3","4","5","6"))

# weight at age in the stock: pelgas
west <- subset(wtatage, Fleet=="0" & Yr %in% inputs_data$styr:inputs_data$endyr,c("Yr","0","1","2","3","4","5","6"))

# fecundity
fecundity <- subset(wtatage, Fleet=="-2" & Yr %in% inputs_data$styr:inputs_data$endyr,c("Yr","0","1","2","3","4","5","6"))

# maturity
maturity <- fecundity/west



# Write TAF tables in data folder -----------------------------------------

write.taf(list(natmort=natmort, catage = catage, catch = catch, 
               natage_idxs = natage_idx, ntotal_idx = ntotal_idx,
               survey_DEPM = survey_DEPM, survey_eggs = survey_eggs,
               waca = waca, west = west, fecundity = fecundity, maturity = maturity),dir="./data")

# Save data in RData file  -----------------------------------------

save.image("./data/inputData.RData")

# Script info -------------------------------------------------------------

sessionInfo()

# End of script -----------------------------------------------------------

rm(list=ls())
