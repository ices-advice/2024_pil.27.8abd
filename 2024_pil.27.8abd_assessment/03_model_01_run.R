# Script information ------------------------------------------------------

# run stock assessment for pil.27.8abd
# settings: spaly

# Authors: Max Olmos (maxime.olmos@ifremer.fr) adapted from Laura Wise (lwise@ipma.pt)

# Date: 2023/11/15

# Load packages -----------------------------------------------------------

library(r4ss)

# Get input files --------------------------------------------------------

cp("boot/initial/data/sardine.dat", "model/run")
cp("boot/initial/data/sardine.ctl", "model/run")
cp("boot/initial/data/forecast.ss", "model/run")
cp("boot/initial/data/starter.ss", "model/run")
cp("boot/initial/data/wtatage.ss", "model/run")

# Get model executable ----------------------------------------------------
cp("boot/software/SS3.exe", "model/run")

# Save main directory
wd <- getwd()

# Run SS from r (need to change directory to run SSs)
setwd("model/run")

system("./SS3.exe")

setwd(wd)
 
#setwd(rprojroot::find_rstudio_root_file())

# End of script -----------------------------------------------------------



