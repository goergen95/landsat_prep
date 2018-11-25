libs <- c("raster",
          "rgdal",
          "getSpatialData",
          "link2GI")

lapply(libs, require, character.only = TRUE)



if(Sys.info()["sysname"] == "Windows"){
  filepath_base = "~/lsat/"
} else {
  filepath_base = "~/lsat"
}

project_folders = c("data/", 
                    "data/raw/", "data/lsr/","data/dem/", "data/pyhton/","data/grass/", 
                    "data/tmp/", 
                    "run/", "log/", "landsat_prep/src/","landsat_prep/doc/","data/river/")

envrmt = initProj(projRootDir = filepath_base, GRASSlocation = "data/grass/",
                  projFolders = project_folders, path_prefix = "path_", 
                  global = FALSE)

rasterOptions(tmpdir = envrmt$path_data_tmp)

source("~/lsat/landsat_prep/src/checkDates.R")