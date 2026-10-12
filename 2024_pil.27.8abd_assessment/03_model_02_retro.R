# Script information ------------------------------------------------------

# run retrospective analysis for pil.27.8abd

# Authors: Maxime Olmos (maxime.olmos@ifremer.fr) adapted from Laura Wise (lwise@ipma.pt)

# Date: 2023/11/15

# Load packages -----------------------------------------------------------

library(r4ss)
library(icesTAF)
library(icesAdvice) 
# Run retrospective analysis ----------------------------------------------

# copy files to the retro directory ---------------------------------------
run_dir <- "./model/run"
retro_dir <- "./model/retro"

r4ss::copy_SS_inputs(dir.old = "./model/run", dir.new = retro_dir,overwrite = TRUE) # copy over the stock synthesis model

# copy ss3 to the retro directory ---------------------------------------

# Get model executable ----------------------------------------------------
icesTAF::cp("boot/software/SS3.exe", "model/retro")

# do retros from the current year to -5 -----------------------------------
# this creates and runs all the retros

# Biais Retrospectif et MOhn's rho
cp("model/run/", "model/retro")

SS_doRetro(masterdir="./model", oldsubdir="./run", newsubdir="./retro/retrospectives", years=0)
SS_doRetro(masterdir="./model", oldsubdir="./run", newsubdir="./retro/retrospectives", years=-1)
SS_doRetro(masterdir="./model", oldsubdir="./run", newsubdir="./retro/retrospectives", years=-2)
SS_doRetro(masterdir="./model", oldsubdir="./run", newsubdir="./retro/retrospectives", years=-3)
SS_doRetro(masterdir="./model", oldsubdir="./run", newsubdir="./retro/retrospectives", years=-4)
SS_doRetro(masterdir="./model", oldsubdir="./run", newsubdir="./retro/retrospectives", years=-5)

retroModels <- SSgetoutput(dirvec=file.path("./model/retro/retrospectives",paste("retro",0:-5,sep="")))
retroSummary <- SSsummarize(retroModels)
endyrvec <- retroSummary$endyrs + 0:-5
save(retroSummary, file=file.path("./model/retro/retrospectives","retroSummary.RData"))


# Indice Mohn's rho

out.mohn <- SSmohnsrho(retroSummary)
write.csv(data.frame(Value=unlist(out.mohn)), file=file.path("./model/retro/retrospectives","mohnsrho.csv"))

# compute Mohn's rho using icesAdvice library

out.mohn.ices <- NULL

# for SSB 

aux <- subset(retroSummary$SpawnBio, ! Label %in% c("SSB_Virgin","SSB_initial"))
rownames(aux) <- aux$Yr
colnames(aux) <- c("base", seq(-1, -5, by=-1),"Label", "Yr")
aux <- subset(aux, select=-c(Label,Yr))

for (i in 2:ncol(aux)){
  aux[rownames(aux) %in% seq(endyrvec[i]+1,rownames(aux)[dim(aux)[1]]), i] <- NA
}
# mohn(aux, details=T) # to see the relative biases per year
# mohn(aux, details=F) # only compute Mohn's rho

out.mohn.ices <- cbind(out.mohn.ices, ices_ssb=mohn(aux)) # it is the same as the Hurtado AFSC calculation

# for R. Remove estimates of intermediate year 

aux <- subset(retroSummary$recruits, ! Label %in% c("Recr_Virgin","Recr_initial"))
rownames(aux) <- aux$Yr
colnames(aux) <- c("base", seq(-1, -5, by=-1),"Label", "Yr")
aux <- subset(aux, select=-c(Label,Yr))

for (i in 1:ncol(aux)){
  aux[rownames(aux) %in% seq(endyrvec[i],rownames(aux)[dim(aux)[1]]), i] <- NA
}
aux <- aux[-dim(aux)[1],]

out.mohn.ices <- cbind(out.mohn.ices, ices_rec=mohn(aux)) # it is the same as the Hurtado AFSC calculation

# for F. Remove estimates of intermediate year

aux <- retroSummary$Fvalue
rownames(aux) <- aux$Yr
colnames(aux) <- c("base", seq(-1, -5, by=-1),"Label", "Yr")
aux <- subset(aux, select=-c(Label,Yr))

for (i in 1:ncol(aux)){
  aux[rownames(aux) %in% seq(endyrvec[i],rownames(aux)[dim(aux)[1]]), i] <- NA
}
aux <- aux[-dim(aux)[1],]

out.mohn.ices <- cbind(out.mohn.ices, ices_F=mohn(aux)) # it is the same as the Hurtado AFSC calculation

# see all results

out.mohn.ices

write.csv(out.mohn.ices, file=file.path("./model/retro/retrospectives","mohnsrho_ices.csv"))

getwd()
# End of script -----------------------------------------------------------



