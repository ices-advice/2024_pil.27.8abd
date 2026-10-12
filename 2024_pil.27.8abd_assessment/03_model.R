# Script information ------------------------------------------------------

# Run stock assessment and retrospective 

# Before running the script in folder data we have: 
#         natmort.csv
#         catage.csv
#         catch.csv
#         natage_idx.csv
#         ntotal_idx.csv
#         survey_DEPM.csv
#         survey_recruits.csv
#         waca.csv
#         west.csv
#         fecundity.csv
#         maturity.csv
# After running the script in folder model we have: 
#         folders with the assessment run and the retros

# Authors: Max Olmos (maxime.olmos@ifremer.fr) adapted from Laura Wise (lwise@ipma.pt)

# Date: 2023/11/15

# Load libraries ----------------------------------------------------------

library(icesTAF)

# Working directory and folders -------------------------------------------

# check working directory

getwd()

# create model folder and subfolders using the function mkdir from icesTAF

mkdir("model")
mkdir("model/run")
mkdir("model/retro")

# Run script for stock assessment -----------------------------------------

source("03_model_01_run.R")

# Run script for retro ----------------------------------------------------

source("03_model_02_retro.R")

# Session info ------------------------------------------------------------

sessionInfo()

# End of script -----------------------------------------------------------

rm(list=ls())

