# ------------------------------------------------------------------------
# Script information ------------------------------------------------------

# Title: Stock assessment and short term forecast for pil.27.abd (WGHANSA 2023)
#        1) TAF bootstrap procedure to set up required data and software

# See also: https://github.com/ices-taf/doc/wiki/Creating-a-TAF-analysis 
# Adapted from Laura Wise Repo https://github.com/ices-taf/2022_pil.27.8c9a_assessment
# Author: Max Olmos (maxime.olmos@ifremer.fr) 

# Date: 2022/11/18
# -------------------------------------------------------------------------


# Load libraries ----------------------------------------------------------

library(icesTAF)
library(here)

# Check the working directory ---------------------------------------------

getwd()

# Create repository and R project -----------------------------------------

# Clone the github repository created by ICES secretariat
# The cloned repository is in D:/GitHUB/ices-taf/2022_pil.27.8c9a_assessment
# Create an R project in that folder

# Make the skeleton -------------------------------------------------------

# create initial directories and R scripts for a new TAF analysis
# 2022_pil.27.8c9a_assessment    
# ¦--bootstrap   
# ¦   --initial 
# ¦       --data
# ¦--data.R      
# ¦--model.R     
# ¦--output.R    
# °--report.R    

taf.skeleton()

# Upload initial data -----------------------------------------------------

# Include data in the folder: 2022_pil.27.8c9a_assessment\bootstrap\initial\data 
# Include all five input files needed to run Stock Synthesis
# It can be done by-hand or copying it using the following command:

ass_2024_file <- "model/run/"

# # Starter file
file.copy(from=paste0(ass_2024_file,"starter.ss"),
           to="./boot/initial/data/starter.ss", overwrite=T)
# Control file
file.copy(from=paste0(ass_2024_file,"sardine.ctl"),
           to="./boot/initial/data/sardine.ctl", overwrite=T)
 
# Data file
file.copy(from=paste0(ass_2024_file,"sardine.dat"),
          to="./boot/initial/data/sardine.dat", overwrite=T)

# Weight at age file
file.copy(from=paste0(ass_2024_file,"wtatage.ss"),
          to="./boot/initial/data/wtatage.ss", overwrite=T)

# Forecast file
file.copy(from=paste0(ass_2024_file,"forecast.ss"),
          to="./boot/initial/data/forecast.ss", overwrite=T)

# Document data and create the data.bib file ------------------------------

# use function draft.data() to create the data.bib file
# ?draft.data
draft.data() 

# NOTE that the columns of the csv files should be separated by comma (",")

# data for stock assessment (5 different file)

draft.data(originator="WGHANSA", 
           year=2024, 
           title="Forecast input file", 
           period="2000-2024",
           source="file",
           data.files=c("forecast.ss"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)


draft.data(originator="WGHANSA", 
           year=2024, 
           title="Starter input file", 
           period="2000-2024",
           source="file",
           data.files=c("starter.ss"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)

draft.data(originator="WGHANSA", 
           year=2024, 
           title="Control input file", 
           period="2000-2024",
           source="file",
           data.files=c("sardine.ctl"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)

draft.data(originator="WGHANSA", 
           year=2024, 
           title="Data input file", 
           period="2000-2024",
           source="file",
           data.files=c("sardine.dat"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)

draft.data(originator="WGHANSA", 
           year=2024, 
           title="Weight at age input file", 
           period="2000-2024",
           source="file",
           data.files=c("wtatage.ss"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)

# data with stock assessment results from previous year

# draft.data(originator="WGHANSA", 
#            year=2022, 
#            title="ICES summary table for pil.27.8c9a from WGHANSA 2021", 
#            period="1978-2021",
#            source="file",
#            data.files=c("Table_summary.csv"), 
#            data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
#            file="bootstrap/data.bib",
#            append=T)

# table with ss3 Model structure

# draft.data(originator="WGHANSA", 
#            year=2022, 
#            title="Summary table of Model structure", 
#            source="file",
#            data.files=c("ss3ModelStructure.csv"), 
#            data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
#            file="boot/data.bib",
#            append=T)

# table with Data input description

# draft.data(originator="WGHANSA", 
#            year=2022, 
#            title="Data input description table", 
#            source="file",
#            data.files=c("DataInputTable.csv"), 
#            data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
#            file="bootstrap/data.bib",
#            append=T)

# ICES section 8 for sardine ()

draft.data(originator="WGHANSA", 
           title="ICES TAF Word template for report automation", 
           source="file",
           data.files=c("sec_06_template.docx"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)

# ICES csl file to format references 

draft.data(originator="WGHANSA", 
           title="ICES cls file", 
           source="file",
           data.files=c("ices-journal-of-marine-science.csl"), 
           data.scripts=NULL, # we need to set this to NULL or it will automatically take all the files with extension .R
           file="boot/data.bib",
           append=T)

# Sardine (Sardina pilchardus) downloaded from internet ---------------
# 
# draft.data(originator = "Gervais et Boulart",
#            title = "Image sardine (Sardina pilchardus)",
#            period = FALSE,
#            source = "https://upload.wikimedia.org/wikipedia/commons/7/78/Sardina_pilchardus_Gervais.jpg",
#            data.files = "Sardina_pilchardus_Gervais.jpg",
#            data.scripts = NULL,
#            file = "bootstrap/data.bib", 
#            append=T)

# reference points
# draft.data(originator = "IBPIS 2021",
#            title = "Reference points for Iberian sardine",
#            period = FALSE,
#            source = "file",
#            data.files = "pil278c9a_refPoints.R",
#            data.scripts = NULL,
#            file = "bootstrap/data.bib", 
#            append=T)

# Upload software ---------------------------------------------------------

# create the folder "2022_pil.27.8ABD_assessment\bootstrap\initial\software"

if (!dir.exists("boot/initial/software")){
  dir.create("boot/initial/software")
}

# # copy the SS3 executable file to the folder "2022_pil.27.8ABD_assessment\boot\initial\software"
# 
file.copy(from= paste0(ass_2024_file, "SS3.exe"),
          to="./boot/initial/software/SS3.exe",
          overwrite=T) # SS3 executable for windows


# Document software and create the software.bib file ----------------------

# use function draft.software to create the software.bib file

# ?draft.software

# document the SS3 model

draft.software(package=c("boot/initial/software/SS3.exe"), 
               author = "Richard D. Methot Jr., Chantel R. Wetzel, Ian G. Taylor, Kathryn L. Doering, Kelli F. Johnson", 
               year = 2022, 
               title = "SS3 executable (for Windows)",
               version = "3.24",
               source = NULL, 
               file = "boot/software.bib", 
               append = FALSE)


# Process the data.bib and software.bib metafiles -------------------------

# the function taf.bootstrap() processes:
#   the data.bib file and creates/copies all the data files into the folder "bootstrap/data"
#   and 
#   the software.bib file and creates/copies the software into the folder bootstrap/software
# ?taf.bootstrap

# apply taf.bootstrap

taf.bootstrap(taf=TRUE)

# Session info ------------------------------------------------------------

sessionInfo()

# End of script -----------------------------------------------------------

