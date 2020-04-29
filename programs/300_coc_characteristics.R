################################################################################
# PROGRAM NAME:    300_coc_characteristics
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.ed)
# PROGRAM PURPOSE: To  aggregate tract level ACS characteristics  up into CoC 
#                  level measures by summing or taking population weighted average
################################################################################

library(dplyr)
library(tidyr)
library(stringr)
library(readxl)
library(purrr)

# Set name of file to be output at end of script

# Set name of file to be output at end of script
output_file <- "./output/coc_characteristics.csv"
# 
################################################################################
#  Step 1: Read in and clean necessary data
################################################################################

# 1) Previously created tract-CoC match

coc_tract <- read.csv("./output/tract_coc_match.csv", stringsAsFactors =  FALSE)

# Add leading zero to GEOID

coc_tract$GEOID <- str_pad(coc_tract$tract_fips, 11, pad = "0")

# 2) Previously created tract-level characteristics file

tract_chars <- read.csv("./output/tract_characteristics.csv")

# Add leading zero to GEOID

tract_chars$GEOID <- str_pad(tract_chars$GEOID, 11, pad = "0")


################################################################################
#  Step 2:  Aggregate tract level data into CoC characteristics
################################################################################


coc_chars <- tract_chars %>%
  mutate(acs_year = factor(acs_year)) %>%
  #get rid of margin of error colum
  dplyr::select(-moe) %>%
  # Reshape from wide to long
  spread(variable, estimate) %>%
  left_join(., coc_tract, by = "GEOID" ) %>%
  mutate(extreme_pov_pop = extreme_pov1 + extreme_pov2 + extreme_pov3 + 
           extreme_pov4 + extreme_pov5 + extreme_pov6 + 
           extreme_pov7 + extreme_pov8 + extreme_pov9 + 
           extreme_pov10,
         
         rent_burdened = rent_30p1 + rent_30p2 + rent_30p3 + rent_30p4 + 
           rent_30p5 ,
         
         hh_inc = median_hh_income * total_population,
         
         labor_force = rowSums(dplyr::select(., starts_with("l_force"))),
         
         unemp =   rowSums(dplyr::select(., starts_with("unemp")))) %>%
  group_by(coc_number, coc_name, acs_year) %>%
  summarize(total_population = sum(total_population, na.rm = T),
            total_pop_in_poverty = sum(total_pop_in_poverty, na.rm = T),
            pov_universe = sum(pov_universe, na.rm = T),
            total_housing_units = sum(total_housing_units, na.rm = T),
            total_vacant_housing_units = sum(total_vacant_housing_units, na.rm = T),
            pop_in_renter_occ_units = sum(pop_in_renter_occ_units, na.rm = T),
            renter_hh = sum(renter_hh, na.rm = T),
            rent_pop_universe = sum( rent_pop_universe, na.rm = T),
            extreme_pov_pop = sum(extreme_pov_pop, na.rm = T),
            rent_burdened = sum(rent_burdened, na.rm = T),
            hh_inc = sum(hh_inc, na.rm = T),
            in_labor_force = sum(labor_force, na.rm = T),
            unemployed = sum(unemp, na.rm = T)
  ) %>%
  ungroup() %>%
  mutate(median_hh_income = hh_inc / total_population,
         pct_vacant = total_vacant_housing_units / total_housing_units * 100,
         pct_poverty = total_pop_in_poverty / pov_universe * 100,
         pct_extreme_pov = extreme_pov_pop / pov_universe *100,
         pct_renters = pop_in_renter_occ_units / rent_pop_universe * 100,
         pct_rent_burdened = rent_burdened / renter_hh * 100,
         unemp_rate = unemployed / in_labor_force * 100,
         year = substr(acs_year, 6, 10)) %>%
  dplyr::select(coc_number, coc_name, year, median_hh_income, pct_vacant, pct_extreme_pov, pct_renters, pct_rent_burdened, total_population, 
                total_pop_in_poverty, pct_poverty, unemp_rate) %>%
  # Get rid of obs with missing CoCs
  filter(!(is.na(coc_number)))



################################################################################
#  Step 3: Output file
################################################################################
write.csv(coc_chars, file = output_file, row.names = FALSE)

# remove all files
rm(list = ls())
