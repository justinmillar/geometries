#' Creating Admin-0 (Country) boundaries shapefiles
#' 
#' Justin Millar
#' 2022-07-18
#' 
#' Purpose: Creating country-level boundary files from existing files. Starting 
#' from Admin1 files and using Admin2 to fill in gaps.

# Load libraries
library(fs)
library(sf)
library(rmapshaper)
library(tidyverse)

# Create folder(s)
dir_create("adm0")

# Get Admin1 JSON files
ad1_files <- dir_ls("adm1", recurse = T, glob = "*.json")

# Country names
ad1_ctys <- ad1_files %>% 
  str_remove("adm1/") %>% 
  str_remove("/adm1.json")

for(i in 1:length(ad1_files)){
  message(ad1_ctys[i])
  # Read in shapefile
  shp1 <- st_read(ad1_files[i], quiet = T)
  
  # Get boundary shapefile
  shp0 <- st_geometry(ms_dissolve(shp1))
  
  # Create Adm0 country folder
  cd <- path("adm0", ad1_ctys[i])
  dir_create(cd)
  
  # Save JSON
  st_write(shp0, path(cd, "adm0.json"), driver = "geoJSON")
  
  # Save Shapefile
  st_write(shp0, path(cd, "adm0.shp"), driver = "ESRI Shapefile")
  
  # Save RDS
  saveRDS(shp0, path(cd, "adm0.rds"))
}

# Repeat for Admin2

# Get Admin1 JSON files
ad2_files <- dir_ls("adm2", recurse = T, glob = "*.json")

# Country names
ad2_ctys <- ad2_files %>% 
  str_remove("adm2/") %>% 
  str_remove("/adm2.json")

# Don't repeat country that already have Admin1
ind <- which(!ad2_ctys %in% ad1_ctys)
ad2_ctys <- ad2_ctys[ind]
ad2_files <- ad2_files[ind]

for(i in 1:length(ad2_files)){
  message(ad2_ctys[i])
  # Read in shapefile
  shp1 <- st_read(ad2_files[i], quiet = T)
  
  # Get boundary shapefile
  shp0 <- st_geometry(ms_dissolve(shp0))
  
  # Create Adm0 country folder
  cd <- path("adm0", ad2_ctys[i])
  dir_create(cd)
  
  # Save JSON
  st_write(shp0, path(cd, "adm0.json"), driver = "geoJSON")
  
  # Save Shapefile
  st_write(shp0, path(cd, "adm0.shp"), driver = "ESRI Shapefile")
  
  # Save RDS
  saveRDS(shp0, path(cd, "adm0.rds"))
}
