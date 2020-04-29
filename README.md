# CoC Unemployment rate

This project creates a geographic crosswalk between 2013 U.S. Department of Housing and Urban Development (HUD) Continuum of Care (CoC) boundaries and 2010 U.S. Census Bureau geographies (Census tracts).

__Note: As of 4/28/2020, this code has not been fully tested and debugged__

Please bring any errors/questions/suggestions to the attention of this project's creator, Tom Byrne, at [tbyrne@bu.edu](tbyrne@bu.edu) 

## Project description 

Below we describe the main __outputs__ of this project, as well as its __data__ inputs and __programs__ used to create the __outputs__. 

## Outputs 
There are three main output files from this project: 
 
1. __tract_coc_match.csv__: This is a geographic crosswalk that matches each Census tract to a CoC. There is one row for each Census tract.  Note that not all Census tracts match to a CoC.

3. __coc_characteristics.csv__:  This is a file that includes a number of 
CoC-level characteristics for 2013 CoCs.  These include, unemployment rate, 
poverty rate, total population and total population in poverty for each CoC.  These files are based on tract level total population and total population in poverty estimates from the U.S. Census Bureau's American Community Survey 2009-2013 5-Year Estimates

There are also two intermediary output files:

1. __clipped_tract.shp__: This is a version of the U.S. Census Bureau TIGER/Line census tract boundary shapefile that is clipped to the HUD CoC boundary shapefile.  The reason for doing this is that the CoC shapefile is clipped to the shoreline, while the tract boundary file is not. As such, our approach for matching tracts to CoCs will incorrectly omit Census tracts if we do not first clip the tract boundaries.

2. __tract_characteristics.csv__: This file includes Census tract estimates of the tract characteristics (e.g. unemployment rate, poverty rate, etc.) from the U.S. Census Bureau's American Community Survey 2009-2013 5-Year Estimates. 

## Data
The above described outputs are created using the following inputs:

1. __CoC_GIS_NatlTerrDC_Shapefile_2013.shp__: A shapefile of the 2013 HUD CoC boundaries.  This file was obtained from [this HUD website](https://www.hudexchange.info/programs/coc/gis-tools/).  A zipped version of this file
is included in the data folder. 

2. __Tract_2010Census_DP1.shp__: The 2010 TIGER/Line Census tract shapefile.  This file was obtained from [this Census Bureau website](https://www.census.gov/geographies/mapping-files/2010/geo/tiger-data.htmlp).  This file is too large to store on Github but can be obtained at the link.

3. __2017_pit.csv__: The 2017 HUD Point-in-Time (PIT) count data.  This file was obtained from [this HUD website](https://www.hudexchange.info/resource/3031/pit-and-hic-data-since-2007/)

## Programs 

The outputs described above were created using data described above via the following programs:

1. __000_clip_tract_shapefile__: This program clips the TIGER/Line tract shapefile to the CoC boundary shapefile.  It produces the __clipped_tract.shp__ file.

2. __100_get_tract_characteristics__: This program uses the `tidycensus` package to pull Census tract charactersitics estimates directly from the U.S. Census Bureau's API. It produces the __tract_characteristics.csv__ output file 

3. __200_tract_coc_match__:  This program creates a geographic crosswalk between Census tracts and CoCs. To do this, it overlays tract centroid points (i.e. points representing the geographic center of each Census tract) onto CoC boundaries and matches each Census tract to the CoC into which its centroid falls. It produces the __tract_coc_match.csv__ output file 

4. __300_coc_characteristics__:  This program creates estimates of CoC level characteristics based on tract level data.  It does this based on the __tract_coc_match.csv__ file and produces the __coc_characteristics.csv__ shapefile

5. __400_run_all_pograms__:  This program runs simply calls each of the above programs in sequence. 

