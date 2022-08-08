#script to fix issues
library(fs)
library(tidyverse)
library(stringr)
library(stringi)
library(rmapshaper)
library(sf)

#loop through the adm2 folder to run the ascii fix

#shp_dir <- path("C:/Users/wsheahan/Box/Africa Data and Analytics for community case Management/ccm-africa/data", "shp", "Country-level")
shp_dir2 <- path("adm2")

ctys <- dir_ls(shp_dir2) %>% 
  str_remove(shp_dir2) %>% 
  str_remove("/")

get_dist_shps <- function(country, verbose = T) {
  
  if(verbose){message(country)}
  
  #read in shapefile and simplify
  dist_sf_country <- st_read(path(shp_dir2, country, "adm2.shp"), quiet = T) %>% 
    #dplyr::select(country = ADM0_EN, admin1 = ADM1_EN, admin2 = ADM2_EN) %>% 
    #dplyr::select(country = starts_with("ADM0_"), admin1 = starts_with("ADM1_"), admin2 = starts_with("ADM2_")) %>% 
    ms_simplify()
  
  #output
  return(dist_sf_country)
}

#run function over list to get all shp files
tictoc::tic()
shp_list <- map(ctys, safely(get_dist_shps))
#shp_list_prov <- map(ctys, safely(get_prov_shps))
tictoc::toc()

#get all results
res <- lapply(shp_list, "[[", 1)
lapply(res, names)

#Make new version to edit - adm2, excluding 9 and 31 because those are null
res2 <- res[-c(9, 31)]

ctys2 <- ctys[-c(9, 31)]

for (i in 1:length(ctys2)) {
  
  #print cty name
  print(ctys2[i])
  
  #fix country/adm2 fields for accents, etc.
  res2[[i]] <- res2[[i]] %>%
  mutate(ADM0 = stringi::stri_trans_general(ADM0, "Latin-ASCII"),
         ADM1 = stringi::stri_trans_general(ADM1, "Latin-ASCII"),
         ADM2 = stringi::stri_trans_general(ADM2, "Latin-ASCII")) %>%
  mutate(ADM0 = gsub(ADM0, pattern = "\\s*\\([^\\)]+\\)", replacement = "")) %>%
  mutate(ADM2 = gsub("/", "_", ADM2),
         ADM2 = gsub("#", "", ADM2),
         ADM2 = gsub("&", "and", ADM2),
         ADM1 = gsub("/", "_", ADM1),
         ADM1 = gsub("&", "and", ADM1)) 
  
  #write out new object to github folder
  #write out shp file object
  try(st_write(res2[[i]], 
            dsn = path("adm2/", ctys2[i], "adm2.shp"), append = FALSE))
  
  try(saveRDS(res2[[i]], 
            path("adm2/", ctys2[i], "adm2.RDS")))
  
  try(st_write(res2[[i]], 
            dsn = path("adm2/", ctys2[i], "adm2.json"), 
            driver = "GeoJSON", append = FALSE))
  
  
}

#Do the same thing but for ADM1
#need to get separate prv_shps I think
