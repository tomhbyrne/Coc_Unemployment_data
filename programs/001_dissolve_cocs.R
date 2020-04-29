################################################################################
# PROGRAM NAME:    001_dissolve_cocs
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To dissolve the CoC boundary shapefile. This is an intermediary 
#                  step to have just one polygon per coC making 
#                  tract to CoC matching easier 
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


# Set locatin for where new CoC shapefile will be saved
output_location <- "./output"


# Read in CoC boundaries
cocs <- readOGR("./data/CoC_GIS_NatlTerrDC_Shapefile_2013/FY13_CoC_national_bnd.shp", 
                "FY13_CoC_national_bnd")


# Dissolve coCs
lps13 <- coordinates(cocs13)
ID13 <- cut(lps13[,1], range(lps13[,1]), include.lowest = TRUE)
cocs_dissolve13 <- as(unionSpatialPolygons(cocs13, ID13), "SpatialPolygonsDataFrame")


# output new shapefile
writeOGR(obj = cocs_dissolve13, dsn = output_location, layer = "cocs_13",
         driver = "ESRI Shapefile")

