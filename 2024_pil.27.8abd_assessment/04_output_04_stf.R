# Script information ------------------------------------------------------

# run short term forecast (stf) for pil.27.8abd

# Authors: Max Olmos adapted from Laura Wise

# Date: 2023/11/18

# load libraries ----------------------------------------------------------
rm(list=ls())
library(icesTAF)
library(FLCore)
library(FLash)

#-----------------------------------------------------
# STF for Sardine 8abd
#-----------------------------------------------------


source("C:/Users/molmos/Documents/02_ONGOING_WORKING_GROUPS/1_WGHANSAS/2023/WGHANSA_2/PREPARATION/WGHANSA2023/WGHANSA2023/r_scripts/fwd.R")
source("C:/Users/molmos/Documents/02_ONGOING_WORKING_GROUPS/1_WGHANSAS/2023/WGHANSA_2/PREPARATION/WGHANSA2023/WGHANSA2023/r_scripts/proj.R")
opt_rec<-"" #output suffix

#######
getwd()

interim_catch <-19.398  # set to -1 to use fsq instead

#######
getwd()
# Loading FLR object
load("./output/toFLR/pil8abd.RData")	
pila.stock<-pil.stock   # archived pil.stock
yeara <- c(as.numeric((pil.stock@range['minyear'])):as.numeric((pil.stock@range['maxyear'])))
age <- c(0:6)
year<-yeara[1]:yeara[length(yeara)-1]
years<-year


# Trimming is necessary to assessment year-1
pil_st<-trim(pil.stock,year=years)
pil.stock<-pil_st

# Set reference point here 
Btrigger<-78.7
Bpa<-78.7
Blim<-56.300
fpa<-0.453
flim<-0.757
fp05<-0.453 #not used 
fmsy_unconstr<-0.453
fmsy<-fp05


# Preparing projections

## -- Set years projection -- ##
# The projection will run from intermediate year to user defined final year
final_year <- year[length(year)]+2
start_year <- year[length(year)]+1
cast_years <- as.numeric(range(pil.stock)[("maxyear")]+1) : final_year
no_cast_years <- length(cast_years)

# Set FLSTOCK object for the projections 
# The default 3 year average goes in projection
pil_cast <- stf(pil.stock, nyears = 3)

## -- The stock-recruitment relationship -- ##
geomean_rec <- exp(mean(log(rec(pil.stock) )))  # or GM for the full times series
sr_geomean <- list(model="mean", params=FLPar(a = geomean_rec))
pil_bh <- sr_geomean 


# -- F?s scenarios -- ##
# 1.F status_quo -> Fbar n-year geometric mean 
f_years <- 3 # e.g. 3-year average
pil_cast_interm <- stf(pil.stock, nyears = 1)
stock.n(pil_cast_interm)[1,as.character(start_year)]<-geomean_rec 


# Running intermediate year
fsq   <- exp(mean(log(fbar(pil.stock)[,(length(year) - f_years + 1):length(year)])))    # Fsq
flast <- as.numeric(fbar(pil.stock)[,length(year)])					# F last year



# ####################
if (interim_catch == -1) {
  interm_ctrl_target <- data.frame(year = start_year, quantity = "f", val = fsq) 
  print ("FSQ assumtion...")
} else {
  interm_ctrl_target <- data.frame(year = start_year, quantity = "catch", val = interim_catch)
  print ("Catch assumption...")
}
#####################

ctrl_f <- fwdControl(interm_ctrl_target)
pil_cast_fwd <- fwd(pil_cast_interm, ctrl = ctrl_f, sr = pil_bh)
pil_cast <- stf(pil_cast_fwd, nyears = 2)
cast_years<-cast_years+1

# Setting Year+1 scenarios  
fseq<-seq(0,3,by=0.0005)  #range of F values to explore
no_scenarios <- 7+ length(fseq)
fbar_scenarios <- matrix(NA, ncol=no_cast_years, nrow=no_scenarios)
dimnames(fbar_scenarios) <- list(scenario = 1:no_scenarios, year = cast_years)
fbar_scenarios[1,] <- fmsy	# MSY approach
fbar_scenarios[2,] <- 0  	# closure
fbar_scenarios[3,] <- fpa  	# fpa
fbar_scenarios[4,] <- flim  	# flim
fbar_scenarios[5,] <- fsq  	# fsq
fbar_scenarios[6,] <- fsq  	# fsq
fbar_scenarios[7,] <- flast  	# f from last year of assessment 
fbar_scenarios[8:(7+length(fseq)),] <- fseq
cast_det <- list()


## -- Running Management Scenarios -- ##
for (scenario in 1:nrow(fbar_scenarios)) {
  ctrl_target <- data.frame(year = cast_years, quantity = "f", val = fbar_scenarios[scenario,])
  ctrl_f <- fwdControl(ctrl_target)
  # projection with no variability
  pil_cast_fwd <- fwd(pil_cast, ctrl = ctrl_f, sr = pil_bh)
  # Fill results
  cast_det[[scenario]] <- pil_cast_fwd
}



########## FIRST TABLE : ASSUMPTION ##########

recrut_ass_year<- sr_geomean
ssb_interim<-sum(cast_det[[3]]@mat[,length(year)+1]*cast_det[[3]]@stock.n[,length(year)+1]*cast_det[[3]]@stock.wt[,length(year)+1])
ssb_mean<-NULL
for (i in 1:length(year)) {
  ssb_mean[i]<-sum(pil.stock@mat[,i]*pil.stock@stock.wt[,i]*pil.stock@stock.n[,i])
}
mean_ssb<-mean(ssb_mean)
mean_f<-mean(fbar(pil.stock))  # 2-5


########## BIG OPTION TABLE ###################
list_ssb1<-NULL
list_ssb2<-NULL
list_F1<-NULL 
list_F2<-NULL 
list_catch1<-NULL 
list_catch2<-NULL 
list_Ft1<-NULL 
list_Ft2<-NULL 
list_ssb<-NULL
for (z in 1:nrow(fbar_scenarios)) {
  list_ssb1[z]<-sum(cast_det[[z]]@mat[,length(year)+2]*cast_det[[z]]@stock.n[,length(year)+2]*cast_det[[z]]@stock.wt[,length(year)+2])
  list_ssb2[z]<-sum(cast_det[[z]]@mat[,length(year)+3]*cast_det[[z]]@stock.n[,length(year)+3]*cast_det[[z]]@stock.wt[,length(year)+3])
  list_F1[z]<-as.numeric(fbar(cast_det[[z]])[,length(year)+2]) 
  list_F2[z]<-as.numeric(fbar(cast_det[[z]])[,length(year)+3])
  list_catch1[z]<-as.numeric(cast_det[[z]]@catch[,length(year)+2])
  list_catch2[z]<-as.numeric(cast_det[[z]]@catch[,length(year)+3])
  list_Ft1[z]<-as.numeric(fbar(cast_det[[z]])[,length(year)+2])
  list_Ft2[z]<-as.numeric(fbar(cast_det[[z]])[,length(year)+3])
}
ssb1<-list_ssb1[1]
last_catch<-as.numeric(pil.stock@catch[,length(year)])
list_ssb<-(list_ssb2-list_ssb1)/list_ssb1*100
list_cat<-(list_catch1-last_catch)/last_catch*100
obj<-data.frame(Catch=list_catch1,Ft1=list_Ft1,SSB2=list_ssb2,changessb=list_ssb,changecatch=list_cat)

# Interpolation for in between values
SSBvsF<-approxfun(obj$Ft1,obj$SSB2)
CatchvsF<-approxfun(obj$Ft1,obj$Catch)
CSSBvsF<-approxfun(obj$Ft1,obj$changessb)
CCatvsF<-approxfun(obj$Ft1,obj$changecatch)
FvsSSB<-approxfun(obj$SSB2,obj$Ft1)
CatchvsSSB<-approxfun(obj$SSB2,obj$Catch)
CSSBvsSSB<-approxfun(obj$SSB2,obj$changessb)
CCatvsSSB<-approxfun(obj$SSB2,obj$changecatch)




#### Building ICES catch option table ####
FINAL<-NULL    # closest match for F and SSB targets in big table
FINAL2<-NULL   # interpolated output for F and SSB targets


## Target is a F value
F<-0
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-"F=0"
FINAL<-rbind(FINAL,c(tit,ext))
FINAL2<-rbind(FINAL2,c(tit,ext))


F<-fpa
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-"F=Fpa"
FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsF(F),Ft1=F,SSB2=SSBvsF(F),changessb=CSSBvsF(F),changecatch=CCatvsF(F))
FINAL2<-rbind(FINAL2,c(tit,ext2))


F<-flim
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-"F=Flim"
FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsF(F),Ft1=F,SSB2=SSBvsF(F),changessb=CSSBvsF(F),changecatch=CCatvsF(F))
FINAL2<-rbind(FINAL2,c(tit,ext2))


F<-fsq
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-"F=Fsq"
FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsF(F),Ft1=F,SSB2=SSBvsF(F),changessb=CSSBvsF(F),changecatch=CCatvsF(F))
FINAL2<-rbind(FINAL2,c(tit,ext2))


F<-as.numeric(fbar(pil_cast_interm)[,length((fbar(pil_cast_interm)))]) #Fbar
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-paste("F=F",start_year,sep="")
FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsF(F),Ft1=F,SSB2=SSBvsF(F),changessb=CSSBvsF(F),changecatch=CCatvsF(F))
FINAL2<-rbind(FINAL2,c(tit,ext2))


## Target is now SSB ##
B<-Blim
lin<-which(abs(obj["SSB2"]-B)==min(abs(obj["SSB2"]-B)))
ext<-obj[lin[1],]	
tit<-paste("SSB",start_year+1,"=Blim",sep="")
#	FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsSSB(B),Ft1=FvsSSB(B),SSB2=B,changessb=CSSBvsSSB(B),changecatch=CCatvsSSB(B))
FINAL2<-rbind(FINAL2,c(tit,ext2))
FINAL<-rbind(FINAL,c(tit,ext2))

B<-Bpa
lin<-which(abs(obj["SSB2"]-B)==min(abs(obj["SSB2"]-B)))
ext<-obj[lin[1],]
tit<-paste("SSB",start_year+1,"=Bpa",sep="")
#	FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsSSB(B),Ft1=FvsSSB(B),SSB2=B,changessb=CSSBvsSSB(B),changecatch=CCatvsSSB(B))
FINAL2<-rbind(FINAL2,c(tit,ext2))
FINAL<-rbind(FINAL,c(tit,ext2))

## Target is back to a F value ##
F<-fmsy * ssb1/Btrigger
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-paste("F=Fmsy*SSB",start_year+1,"/Btrigger",sep="")
FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsF(F),Ft1=F,SSB2=SSBvsF(F),changessb=CSSBvsF(F),changecatch=CCatvsF(F))
FINAL2<-rbind(FINAL2,c(tit,ext2))

F<-fmsy 
lin<-which(abs(obj["Ft1"]-F)==min(abs(obj["Ft1"]-F)))
ext<-obj[lin[1],]
tit<-"F=Fmsy"
FINAL<-rbind(FINAL,c(tit,ext))
ext2<-data.frame(Catch=CatchvsF(F),Ft1=F,SSB2=SSBvsF(F),changessb=CSSBvsF(F),changecatch=CCatvsF(F))
FINAL2<-rbind(FINAL2,c(tit,ext2))





### Formatting ###
BASIS<-NULL
colnames(FINAL)[1]<-"Basis"
colnames(FINAL)[2]<-paste("Total Catch (",year[length(year)]+2,")",sep="")
colnames(FINAL)[3]<-paste("Ftotal (",year[length(year)]+2,")",sep="")
colnames(FINAL)[4]<-paste("SSB (",year[length(year)]+3,")",sep="")
colnames(FINAL)[5]<-paste("SSB change (",year[length(year)]+3," rel. to ",year[length(year)]+2,")",sep="")

BASIS<-data.frame(Variable=paste("Fbar",as.numeric(range(pil.stock,"minfbar")),"-",as.numeric(range(pil.stock,"maxfbar")),"(",year[length(year)]+1,")",sep="") , Value= as.numeric(fbar(pil_cast_interm)[,length((fbar(pil_cast_interm)))])) 
BASIS<-rbind(BASIS,data.frame(Variable=paste("SSB(",year[length(year)]+2,")",sep="") , Value=ssb1) )
BASIS<-rbind(BASIS,data.frame(Variable=paste("Recr(",year[length(year)]+1,")",sep="") , Value=geomean_rec) )
BASIS<-rbind(BASIS,data.frame(Variable=paste("Catch(",year[length(year)]+1,")",sep="") , Value=as.numeric(cast_det[[1]]@landings[,length(year)+1])))
BASIS<-rbind(BASIS,data.frame(Variable=paste("Catch(",year[length(year)],")",sep="") , Value=as.numeric(pil.stock@catch[,length(year)])))
BASIS<-rbind(BASIS,data.frame(Variable="Average SSB (for cat 2)", Value=mean_ssb))
BASIS<-rbind(BASIS,data.frame(Variable="Average Fbar (for cat 2)", Value=mean_f))


summass<-data.frame(year=yeara,ssb=as.numeric(ssb(pila.stock)), recr=as.numeric(rec(pila.stock)), f=as.numeric(fbar(pila.stock))) 
summass[summass$year==start_year,]$recr<-geomean_rec
summass[summass$year==start_year,]$f<-as.numeric(fbar(pil_cast_interm)[,length((fbar(pil_cast_interm)))])


write.table(file=paste("./output/stf/basis_",year[length(year)]+1,"_",opt_rec,".txt",sep=""),BASIS,sep=";")
write.table(file=paste("./output/stf/catch_table_",year[length(year)]+1,"_",opt_rec,".txt",sep=""),FINAL,sep=";") 
write.table(file=paste("./output/stf/summary_assessment_",year[length(year)]+1,"_",opt_rec,".txt",sep=""),summass,sep=";") 


# End of script -----------------------------------------------------------
rm(list = ls())



