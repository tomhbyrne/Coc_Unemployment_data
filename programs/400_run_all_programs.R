################################################################################
# PROGRAM NAME:    500_run_all_programs
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To run all files used in matching HUD Coc geographies to 
#                  Census tracts and counties 
################################################################################

source("./programs/000_clip_tract_shapefile.R")
source("./programs/100_get_tract_characteristics.R")
source("./programs/200_tract_coc_match.R")
source("./programs/300_coc_characteristics.R")
