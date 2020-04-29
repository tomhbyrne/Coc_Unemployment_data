################################################################################
# PROGRAM NAME:    100_tract_population
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To pull tract characteristic 
#                  estimates and other community characteristics
#                  from American Community Survey 5-year estimates
################################################################################

library(tidycensus)
library(tidyr)
library(dplyr) 
library(purrr)

# Set name of files to be output at the end of the script
tract_chars_file <- "./output/tract_characteristics.csv"



################################################################################
#  Step 1: Set input parameters
################################################################################

# Need to add your own Census API key below
census_api_key("22c3b2e2538dd22d66c03c745f011d4fa1bc5bcf")
# Create vector for all states in US
us <- unique(fips_codes$state)[1:51]
# Create years for which you want to get ACS data,
# this is the end year of 5-year ACS estimates (i.e. 
# 2013, will give you the 2009-2013 ACS estimates)

years <- 2013

################################################################################
#  Step 2: Pull ACS data
################################################################################

# This is a function that has a nested function within it. The nested function 
# that starts with map_df basically says to get all ACS data for all counties 
# in the states included in the "us" vector. We can then use lapply to apply 
# the main function (get_all_acs) to all years for which we want ACS data (i.e.
# all years in the "years" vector)
get_all_acs <- function(y) { 
  map_df(us, function(x) {
    get_acs(geography = "tract", 
            year = y, 
            variables = c(total_population = "B01003_001",
                          median_hh_income = "B19013_001",
                          pov_universe = "B17024_001",
                          extreme_pov1 = "B17024_003",
                          extreme_pov2 = "B17024_016",
                          extreme_pov3 = "B17024_029",
                          extreme_pov4 = "B17024_042",
                          extreme_pov5 = "B17024_055",
                          extreme_pov6 = "B17024_068",
                          extreme_pov7 = "B17024_081",
                          extreme_pov8 = "B17024_094",
                          extreme_pov9 = "B17024_107",
                          extreme_pov10 = "B17024_120",
                          total_pop_in_poverty = "B17001_002",
                          poverty_pop_universe = "B17001_001",
                          total_housing_units = "B25002_001",
                          total_vacant_housing_units = "B25002_003",
                          pop_in_renter_occ_units = "B25008_003",
                          rent_pop_universe = "B25008_001",
                          renter_hh  = "B25106_024",
                          rent_30p1 = "B25106_028",
                          rent_30p2 = "B25106_032",
                          rent_30p3 = "B25106_036",
                          rent_30p4 = "B25106_040",
                          rent_30p5 = "B25106_044",
                          
                          l_force1  = "B23001_006",
                          l_force2  = "B23001_013",
                          l_force3  = "B23001_020",
                          l_force4  = "B23001_027",
                          l_force5  = "B23001_034",
                          l_force6  = "B23001_041",
                          l_force7  = "B23001_048",
                          l_force8  = "B23001_055",
                          l_force9  = "B23001_062",
                          l_force10  = "B23001_069",
                          l_force11  = "B23001_074",
                          l_force12  = "B23001_079",
                          l_force13  = "B23001_084",
                          
                          l_force14  = "B23001_092",
                          l_force15  = "B23001_099",
                          l_force16  = "B23001_106",
                          l_force17  = "B23001_113",
                          l_force18 = "B23001_120",
                          l_force19  = "B23001_127",
                          l_force20 = "B23001_134",
                          l_force21  = "B23001_141",
                          l_force22  = "B23001_148",
                          l_force23  = "B23001_155",
                          l_force24  = "B23001_160",
                          l_force25  = "B23001_165",
                          l_force26  = "B23001_170",
                          
                          unemp1 = "B23001_008",
                          unemp2 = "B23001_015",
                          unemp3 = "B23001_022",
                          unemp4 = "B23001_029",
                          unemp5 = "B23001_036",
                          unemp6 = "B23001_043",
                          unemp7 = "B23001_050",
                          unemp8 = "B23001_057",
                          unemp9 = "B23001_064",
                          unemp10 = "B23001_071",
                          unemp11 = "B23001_076",
                          unemp12 = "B23001_081",
                          unemp13 = "B23001_086",
                          
                          unemp14 = "B23001_094",
                          unemp15 = "B23001_101",
                          unemp16 = "B23001_108",
                          unemp17 = "B23001_115",
                          unemp18 = "B23001_122",
                          unemp19 = "B23001_129",
                          unemp20 = "B23001_136",
                          unemp21 = "B23001_143",
                          unemp22 = "B23001_150",
                          unemp23 = "B23001_157",
                          unemp24 = "B23001_162",
                          unemp25 = "B23001_167",
                          unemp26 = "B23001_172"
            ),
            survey = "acs5", 
            state = x)
  })
}

# Use lapply to apply the function to all years
# This will return a list and so we will need to turn
# it into a data frame below
all_acs <- lapply(years, get_all_acs)


# Use lapply to apply the function to all years  This will return a list and 
# so we will need to turn it into a data frame below
all_acs <- lapply(years, get_all_acs)

all_acs_frame <- bind_rows(all_acs, .id = "acs_year") %>%
  mutate(acs_year = factor(acs_year, 
                       labels = years))

################################################################################
#  Step 3: Output file
################################################################################

# Output files 

write.csv(all_acs_frame, file = tract_chars_file, row.names = FALSE)

# remove all files
rm(list = ls())
