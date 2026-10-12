# Script information ------------------------------------------------------

# Title: Stock assessment and short term forecast for pil.27.8abd (WGHANSA 2022)
#        4) Extract results of interest, write TAF output tables

# Before running the script in folder data we have: 
#         folders with the assessment run and the retros
# After running the script in folder model we have: 
#         folders with the corresponding outputs (including reference points)

# Authors: Max Olmos (maxime.olmos@ifremer.fr) adapted from Laura Wise (lwise@ipma.pt)

# Date: 2023/11/15

# Load libraries ----------------------------------------------------------

library(icesTAF)

# Working directory and folders -------------------------------------------

# check working directory

getwd()

# create output folder and sub-folders using the function mkdir from icesTAF

mkdir("output")
mkdir("output/run")
mkdir("output/retro")
mkdir("output/toFLR")
mkdir("output/stf")

# Outputs from stock assessment -------------------------------------------

source("04_output_01_run.R")

# Outputs from retro ------------------------------------------------------

source("04_output_02_retro.R")

# Outputs: create FLR objects ---------------------------------------------

source("04_output_03_toFLR.R")

# Outputs from stf --------------------------------------------------------

source("04_output_04_stf.R")

# Session info ------------------------------------------------------------

sessionInfo()

# End of script -----------------------------------------------------------

rm(list = ls())