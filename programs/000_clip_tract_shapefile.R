################################################################################
# PROGRAM NAME:    000_clip_tract_shapefile
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To clip the Tiger Line tract boundary shapefile to the 
#                  HUD CoC boundary shapefile.  this is necessary b/c HUD
#                  CoC boundary shapefile is clipped to shoreline and tract
#                  boundary shapefile is not.  
################################################################################

 
library(data.table)
library(tigris)
library(stringr)
library(tidycensus)
library(sp)
library(rgdal)
library(dplyr)
library(tidyr)
library(maptools)
library(PBSmapping)
library(stringr)
library(sf)
library(rgeos)
library(car)
library(raster)

# Set output file location and output file name for later use

clipped_file <- "./output/clipped_tract_2010.rds"
output_location <- "./output"

################################################################################
#  Step 1: Read in necessary data
################################################################################

# CoC boundaries
cocs <- readOGR("./data/CoC_GIS_NatlTerrDC_Shapefile_2013/FY13_CoC_national_bnd.shp", 
                "FY13_CoC_national_bnd")

# Tract boundaries
tract <- readOGR("./data/Tract_2010Census_DP1/Tract_2010Census_DP1.shp", 
                 "Tract_2010Census_DP1")



# Set CRS for tract and CoCs files to  match that of Coc file
# we had to add in a projection system (UTM) to make the gbuffer function below work 
# but otherwise, CRS is taking form CoC file 

tract <- spTransform(tract, CRS("+proj=utm +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

cocs <- spTransform(cocs, CRS("+proj=utm +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))


################################################################################
#  Step 2: Dissolve CoC to get rid of individual CoC boundaries and to have
#  just one single boundary for all CoCs
################################################################################

lps <- coordinates(cocs)
ID <- cut(lps[,1], range(lps[,1]), include.lowest = TRUE)
cocs_dissolve <- unionSpatialPolygons(cocs, ID)


################################################################################
#  Step 3: Clip tract to CoC boundaries
################################################################################


# Use buffer of width 0 to avoid errors when using intersect function 
tract <- gBuffer(tract_x, byid = TRUE, width = 0)

clipped_tract <- raster::intersect(cocs_dissolve, tract)


save(clipped_tract, file = clipped_file)


writeOGR(obj = clipped_tract, dsn = output_location, layer = "clipped_tract_2010",
         driver = "ESRI Shapefile")

# remove all files
rm(list = ls())

