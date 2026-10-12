# Script information ------------------------------------------------------

# generate the outputs from stock assessment for pil.27.8c9a 

# Authors: Max Olmos (maxime.olmos@ifremer.fr) adapted from Laura Wise (lwise@ipma.pt)

# Date: 2023/11/15

# Load packages -----------------------------------------------------------

library(icesTAF)
library(r4ss)
library(tidyverse)
library(lubridate)

# Setup and read in files -----------------------------------------------------

# set assessment year (interim year)

ass.yr <- lubridate::year(Sys.Date())

# directory with output files

dir.spaly <- file.path("model/run")

# directory to save plots and tables

res.plots <- file.path("output/run")

# read in ss3 files 
# list of all the runs. Each run is saved in a folder
proj.dir <- dir.spaly
run.list <- list.dirs(proj.dir, recursive=F, full.names=T)
run.list <- run.list[-1] # remove the Rproj folder
run.list<-proj.dir

DIR <- run.list[1]
out <- SS_output(dir.spaly, covar=T)

# Genere les sorties sous forme de pages HTML

SS_plots(out, png=TRUE, datplot=TRUE, aalresid=TRUE, forecast=TRUE, uncertainty=TRUE, printfolder="R_plots", dir=res.plots, sprtarg=0.40,btarg=0.4, minbthresh=-1)


# End of script -----------------------------------------------------------

rm(list=ls())




