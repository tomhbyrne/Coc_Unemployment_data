################################################################################
# PROGRAM NAME:    200_tract_coc_match
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.ed)
# PROGRAM PURPOSE: To conduct geospatial match of 2010 Census tracts and 2013 HUD 
#                  Continuums of Care (CoCs) based on tract centroid points
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
library(sf)
library(nngeo)
library(readxl)
library(purrr)

# Set name of file to be output at end of script

tract_coc_output <- "./output/tract_coc_match.csv"

################################################################################
#  Step 1: Read in necessary data
################################################################################

#     1) Tract shapefile
#     2) CoC shapefile
#     3) 2018 PIT data
#     4) Tract population 


# 1) Tigerline tract shapefile from Census (clipped to CoC boundaries)


tract <- readOGR(dsn = "./output", layer = "clipped_tract_2010")

# also read in non-clipped file to add clipped tracts (i.e. those tracts that
# are not part of a CoC later)

tract_no_clip <-  readOGR("./data/Tract_2010Census_DP1/Tract_2010Census_DP1.shp", 
                          "Tract_2010Census_DP1")

tract_no_clip_df <- tract_no_clip@data[c("GEOID", "NAMELSAD", "ALAND", "AWATER")] 

# 2)  CoC shapefiles from HUD

cocs13 <- readOGR("./data/CoC_GIS_NatlTerrDC_Shapefile_2013/FY13_CoC_national_bnd.shp", 
                   "FY13_CoC_national_bnd")



################################################################################
#  Step 2:Convert tract shapefile to points for matching with CoCs 
################################################################################

# We will use a handy function (gCentroidWithin) for extracting polygon centroid 
# points accouting for when centroid falls outside of polygon (e.g. if polygon is 
# moon shaped)  The function is taken from a Stackoverflowpost: 
# https://stackoverflow.com/questions/44327994/calculate-centroid-within-inside-a-spatialpolygon

set.seed(3456)
gCentroidWithin <- function(pol) {
  require(rgeos)

  pol$.tmpID <- 1:length(pol)
  # initially create centroid points with gCentroid
  initialCents <- gCentroid(pol, byid = T)
  
  # add data of the polygons to the centroids
  centsDF <- SpatialPointsDataFrame(initialCents, pol@data)
  centsDF$isCentroid <- TRUE
  
  # check whether the centroids are actually INSIDE their polygon
  centsInOwnPoly <- sapply(1:length(pol), function(x) {
    gIntersects(pol[x,], centsDF[x, ])
  })
  # substitue outside centroids with points INSIDE the polygon
  newPoints <- SpatialPointsDataFrame(gPointOnSurface(pol[!centsInOwnPoly, ], 
                                                      byid = T), 
                                      pol@data[!centsInOwnPoly,])
  newPoints$isCentroid <- FALSE
  centsDF <- rbind(centsDF[centsInOwnPoly,], newPoints)
  
  # order the points like their polygon counterpart based on `.tmpID`
  centsDF <- centsDF[order(centsDF$.tmpID),]
  
  # remove `.tmpID` column
  centsDF@data <- centsDF@data[, - which(names(centsDF@data) == ".tmpID")]
  
  cat(paste(length(pol), "polygons;", sum(centsInOwnPoly), "actual centroids;", 
            sum(!centsInOwnPoly), "Points corrected \n"))
  
  return(centsDF)
}


tract_centroids <- gCentroidWithin(tract)

# Convert to dataframe
tract_centroids_final <- as.data.frame(tract_centroids)

coordinates(tract_centroids_final) <- c("x", "y")

# Assign coordinate reference system (CRS) to shapefile to match CoC CRS 

proj4string(tract_centroids_final) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

################################################################################
#  Step 3:  Match tract centroids to Cocs in which they are located
################################################################################
tr_coc13 <- over(tract_centroids_final, cocs13)

# Extract data frame from points polygon
tract_df <- data.frame(tract_centroids_final@data)

# Add tract IDS to CoC-tract dataset and get rid of unnecessary colums
# Create a flag for CoCs that are in the HUD shapelie

tract_coc_join13 <- cbind(tr_coc13, tract_df) %>%
  dplyr::select(-c(Shape_Length, isCentroid, INTPTLON, INTPTLAT,  ALAND, AWATER)) %>%
  mutate(in_shapefile = "Yes")

################################################################################
#  Step 4: Add in tracts that were clipped out when clipping tracts to CoC 
#   boundaries and add in tract characteristics from American Community Survey
################################################################################

non_clipped_tracts <- data.frame(GEOID = tract_no_clip@data$GEOID)

tract_coc_final <- full_join(tract_coc_join13, non_clipped_tracts, by = "GEOID")



# Rename columns
names(tract_coc_final) <- c("coc_number", 
                            "coc_name", 
                            "tract_fips")


################################################################################
#  Step 5:  Output file 
################################################################################
write.csv(tract_coc_final, file = tract_coc_output, row.names = FALSE)

# remove all files
rm(list = ls())
