# Script information ------------------------------------------------------

# create FLStock from stock assessment output for pil.27.8c9a 

# Authors: Maxime Olmos (maxime.olmos@ifremer.fr)
# Date: 2023/11/15

# SCRIPT TO CONVERT STOCK SYNTHESIS 3 DATA (PRODUCED BY R PACKAGE R4SS) INTO AN FLSTOCK OBJECT

rm(list=ls())

########################## LOAD libraries ############################
library(FLCore)
library(r4ss)
getwd()


getwd()


##################### LOAD INPUT AND OUTPUT DATA FROM SS3 WITH R4SS #####################

dir.assess<-"model/run"
#setwd(dir.assess)
assess<-SS_output(dir = dir.assess,forecast=FALSE)
dados<-SS_readdat(paste(dir.assess,"/data.ss_new",sep=""), version = "3.24",verbose = TRUE, echoall = FALSE, section = NULL)
maxyear<-assess$endyr
assess$startyr<-2002
lastyr<-maxyear




########################## EXTRACT ASSESSMENT INPUTS ###################################

### WEIGHTS-AT-AGE AND MATURITY

assess$wtatage <- SS_readwtatage(file = paste0(dir.assess,"/wtatage.ss"), verbose = TRUE)
west<-assess$wtatage[assess$wtatage$Fleet==0 & assess$wtatage$Yr<=lastyr & assess$wtatage$Yr>=2002,-c(1:6)]
maturity<-assess$wtatage[assess$wtatage$Fleet==-2,]
maturity<-maturity[maturity$Yr<=lastyr,]
maturity<-maturity[maturity$Yr>=2002,]



maturity<-maturity[,-c(1:6)]
maturity<-maturity/west
maturity[,1]<-0

stock.wt=FLQuant(unname(as.matrix(t(west))),quant="age",units="kg")
dimnames(stock.wt)[[1]]=as.character(min(assess$agebins):max(assess$agebins))
dimnames(stock.wt)[[2]]=as.character(assess$startyr:(assess$endyr))

weca<-assess$wtatage[assess$wtatage$Fleet==-1,]
weca<-weca[weca$Yr<=lastyr,]
weca<-weca[weca$Yr>=2002,]
weca<-weca[,-c(1:6)]

landings.wt=FLQuant(unname(as.matrix(t(weca))),quant="age",units="kg")
dimnames(landings.wt)[[1]]=as.character(min(assess$agebins):max(assess$agebins))
dimnames(landings.wt)[[2]]=as.character(2002:(assess$endyr))



mat=FLQuant(unname(as.matrix(t(maturity))),quant="age")
dimnames(mat)[[1]]=as.character(min(assess$agebins):max(assess$agebins))
dimnames(mat)[[2]]=as.character(assess$startyr:(assess$endyr))



### LANDINGS, CATCH-AT-AGE,  M-AT-AGE


landings<-c(dados$catch[dados$catch$year %in% c(assess$startyr:(assess$endyr)),"Commercial_vessels"])

landings=FLQuant(unname(as.matrix(t(landings))),units="t",quant="age")
dimnames(landings)[[2]]=as.character(assess$startyr:(assess$endyr))

landings.n<-subset(dados$agecomp,FltSvy==1 & Yr<=assess$endyr,c("a0","a1","a2","a3","a4","a5","a6"))
landings.n<-rbind(landings.n)
landings.n<-rbind(landings.n,c(0,0,0,0,0,0,0)) ### no interim catch@age
landings.n=FLQuant(unname(t(landings.n)),quant="age",units="10^3")
dimnames(landings.n)[[2]]=as.character(assess$startyr:(assess$endyr))
dimnames(landings.n)[[1]]=as.character(min(assess$agebins):max(assess$agebins))


m<-matrix(rep(assess$endgrowth$M,length(assess$startyr:(assess$endyr))),byrow=F,nrow=7)

m=FLQuant(unname(as.matrix(m)),quant="age")
dimnames(m)[[2]]=as.character(assess$startyr:(assess$endyr))
dimnames(m)[[1]]=as.character(min(assess$agebins):max(assess$agebins))



########################## EXTRACT ASSESSMENT INPUTS ###################################
## SSB, REC, SELECTIVITY, F-AT-AGE, REFERENCE F, N-AT-AGE


ssb<-assess$timeseries[assess$timeseries$Era=="TIME" & assess$timeseries$Yr<=assess$endyr & assess$timeseries$Yr>=2002,c("Yr","Bio_smry")]



ssb=FLQuant(unname(t(as.matrix(ssb$Bio_smry))),units="t",quant="age")
dimnames(ssb)[[2]]=2002:lastyr


rec<-assess$timeseries[assess$timeseries$Era=="TIME" & assess$timeseries$Yr<assess$endyr & assess$timeseries$Yr>=2002,c("Yr","Recruit_0")]

rec=FLQuant(unname(t(as.matrix(rec$Recruit_0))),units="10^3",quant="age")
dimnames(rec)[[2]]=2002:(lastyr-1)



#### CALCULATE F-AT-AGE FROM APICAL F AND SELECTIVITY-AT-AGE

selectivity<-subset(assess$ageselex[assess$ageselex$Fleet==1 & assess$ageselex$Factor=="Asel2" & assess$ageselex$Yr %in% c(assess$startyr:(assess$endyr)),c("Yr","0","1","2","3","4","5","6") ])

colnames(selectivity)[1]<-"year"


linhas<-grep("F_",assess$derived_quants$Label)
linhas<-linhas[4:length(linhas)-1]

f.apical<-rbind(data.frame(f=assess$derived_quants[linhas,"Value"]),0)

f.apical$year<-2002:(assess$endyr)


f.apsel<-merge(f.apical,selectivity,all.x = T,by="year")


f<-f.apsel$f*f.apsel[,c("0","1","2","3","4","5","6")]
f$year<-f.apsel$year

harvest=FLQuant(unname(as.matrix(t(f[,-8]))),quant="age",units="f")
dimnames(harvest)[[2]]=as.character(assess$startyr:(assess$endyr))
dimnames(harvest)[[1]]=as.character(min(assess$agebins):max(assess$agebins))

refF<-apply(f[,c("2","3","4","5")],1,mean)


##########

natage=assess$natage[assess$natage$Era=="TIME" & assess$natage$`Beg/Mid`=="B" & assess$natage$Yr %in% 2002:lastyr,c("0","1","2","3","4","5","6"),]

stock.n=FLQuant(unname(as.matrix(t(natage))), quant='age', units='10^3')
dimnames(stock.n)[[2]]=as.character(assess$startyr:(assess$endyr))
dimnames(stock.n)[[1]]=as.character(min(assess$agebins):max(assess$agebins))


########################## OTHER FLQUANT OBJECTS NEEDED ################################  
harvest.spwn=FLQuant(matrix(0,ncol=dim(harvest)[2],nrow=dim(harvest)[1]),quant="age",units="f")
dimnames(harvest.spwn)[[1]]=as.character(min(assess$agebins):max(assess$agebins))
dimnames(harvest.spwn)[[2]]=as.character(assess$startyr:(assess$endyr))

m.spwn=harvest.spwn

stock=quantSums(stock.wt*stock.n)

catch.n=landings.n
units(catch.n)<-"10^3"
catch.wt=landings.wt
units(catch.wt)<-"kg"
catch=landings
units(catch)<-"t"
# 
discards.n<-matrix(rep(rep(0,7),length(assess$startyr:(assess$endyr))),byrow=F,nrow=7)
discards.n=FLQuant(unname(as.matrix(discards.n)),quant="age")
dimnames(discards.n)[[2]]=as.character(assess$startyr:(assess$endyr))
dimnames(discards.n)[[1]]=as.character(min(assess$agebins):max(assess$agebins))
# 
discards.wt<-discards.n
# 
discards=FLQuant(unname(rep(0,length(assess$startyr:(assess$endyr)))),units="t",quant="age")
dimnames(discards)[[2]]=as.character(assess$startyr:(assess$endyr))


pil.stock=FLStock(landings=landings)
pil.stock@landings.n<-landings.n
pil.stock@landings.wt<-landings.wt
pil.stock@discards<-discards
pil.stock@discards.n<-discards.n
pil.stock@discards.wt<-discards.wt
pil.stock@catch<-catch
pil.stock@catch.n<-catch.n
pil.stock@catch.wt<-catch.wt
pil.stock@stock<-stock
pil.stock@stock.n<-stock.n
pil.stock@stock.wt<-stock.wt
pil.stock@mat<-mat
pil.stock@m<-m
pil.stock@harvest<-harvest
pil.stock@harvest.spwn<-harvest.spwn
pil.stock@m.spwn<-m.spwn
pil.stock@name<-"SARDINE-BOB"
pil.stock@desc="BENCHMARK ASSESSMENT WITH DEPM IN 2020"
pil.stock@range["min"]<-0
pil.stock@range["max"]<-6
pil.stock@range["plusgroup"]<-6
pil.stock@range["minfbar"]<-2
pil.stock@range["maxfbar"]<-5

validObject(pil.stock)
summary(pil.stock)

#############################  CLEAN AND SAVE WORKSPACE #############################################

rm(list=ls(pat="har"))
rm(list=ls(pat="f"))
rm(list=ls(pat="cat"))
rm(list=ls(pat="lan"))
rm(list=ls(pat="we"))
rm(list=ls(pat="m"))
rm(list=ls(pat="li"))
rm(list=ls(pat="ass"))
rm(list=ls(pat="da"))
rm(list=ls(pat="disc"))
rm("rec","ssb","stock.n","stock","maxyear","stock.wt","selectivity","natage")
rm("rec","ssb","stock.n","stock","stock.wt","selectivity","natage")

save.image("output/toFLR/pil8abd.RData")

