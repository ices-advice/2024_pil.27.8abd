# Script information ------------------------------------------------------

# generate outputs from retrospective analysis for pil.27.8c9a 

# Authors: Laura Wise (lwise@ipma.pt)
# Date: 2022/12/02

# load libraries ----------------------------------------------------------

library(icesTAF)
library(icesAdvice)
library(tidyverse)
library(reshape)

# retro's directories

retro_dir <- "model/retro"
plot_dir <- "output/retro"

# set assessment year (interim year)
load(file=file.path("./model/retro/retrospectives","retroSummary.RData"))

ass.yr <- lubridate::year(Sys.Date())
endyrvec <- retroSummary$endyrs + 0:-5

SSplotComparisons(retroSummary, endyrvec=endyrvec, legendlabels=paste("Data",0:-5,"years"), subplots = c(2))
savePlot(file.path("output","retro","plotretros_series_biom.png"),type="png")

SSplotComparisons(retroSummary, endyrvec=endyrvec, legendlabels=paste("Data",0:-5,"years"), subplots = c(8))
savePlot(file.path("output","retro","plotretros_series_F.png"),type="png")

SSplotComparisons(retroSummary, endyrvec=endyrvec, legendlabels=paste("Data",0:-5,"years"), subplots = c(10))
savePlot(file.path("output","retro","plotretros_series_Rec.png"),type="png")




# Comparer 2 graphes
library(r4ss)
getwd()
DIR1 <- "C:/Users/molmos/Documents/01_GIT/WORKING_GROUPS/WGHANSA/2023/2023_pil.27.8abd_assessment/model/run"
DIR2 <- "C:/Users/molmos/Documents/01_GIT/WORKING_GROUPS/WGHANSA/2024/2024_pil.27.8abd_assessment/model/run"
out1 <- SS_output(DIR1, covar=T)
out2 <- SS_output(DIR2, covar=T)
msummary <- SSsummarize(list(out1,out2))
labels <- c("2023","2024")
i<-2024
SSplotComparisons(msummary,legendlabels=labels,
                  endyr=i,indexQdigits=2,
                  plotdir="C:/Users/molmos/Documents/01_GIT/WORKING_GROUPS/WGHANSA/2024/2024_pil.27.8abd_assessment/output/retro",print=T)
getwd()



# End of script -----------------------------------------------------------

rm(list=ls())
