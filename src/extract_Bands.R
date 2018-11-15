#script to extract relevant ls data from tars

source("~/lsat/landsat_prep/src/env_setup.R")

#pattern makes sure data of both OLI and TIRS are available
listArch <- list.files(path = paste0(envrmt$path_data_raw, "Bulk Order 959634/ExtTest/"),
                       pattern = "L1TP", full.names = TRUE)


#Band 1 to 7, Band 9 and MTL file

for (i in 1: length(listArch)){
untar(listArch[i], files = untar(listArch[i],list=TRUE)[7], exdir = paste0(envrmt$path_data_raw,"Bulk Order 959634/ExtTest/Tifs"))
}



listArch <- list.files(path = paste0(envrmt$path_data_raw, "Bulk Order 959634/ExtTest/"),
                       pattern = "L1GT", full.names = TRUE)


for (i in 1: length(listArch)){
  untar(listArch[i], files = untar(listArch[i],list=TRUE)[2], exdir = paste0(envrmt$path_data_raw,"Bulk Order 959634/ExtTest/Tifs"))
}
