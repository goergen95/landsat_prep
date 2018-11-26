source("~/lsat/landsat_prep/src/env_setup.R")

#extract relevant files from .tar.gz
lzips <- list.files(envrmt$path_data_raw,full.names=TRUE)
targets <- c(4,7:13)

for(i in 1:length(lzips)){
  untar(lzips[i], files = sort(untar(lzips[i],list=TRUE))[targets],exdir = envrmt$path_data_lsr)
}


qatargets <- c(28672,31744,45056,48128,53248,56320,61440,64512)

llsr <- list.files(envrmt$path_data_lsr, full.names = TRUE)
tilesID <- unique(stringr::str_sub(lzips,-42,-37))

#clean from clouds and creat stacks

for (i in 1:length(tilesID)){
  index <- llsr[which(stringr::str_detect(llsr,tilesID[i]))]
  dates <- unique(stringr::str_sub(index,-36,-29))
  print(paste0("Now starting with TileID ",tilesID[i],"."))
  
  for(j in 1:length(dates)){
    print(paste0("Now starting with Date ",dates[j],"."))
    date <- index[which(stringr::str_detect(index,dates[j]))]
    qa <- raster(date[1])
    tmp <- stack(date[2:8])
    
    for (k in 1:length(qatargets)){
      print(paste0("Now starting with BinId ",qatargets[k],"."))
      tmp[qa == qatargets[k]] <- NA
      
    }
    
    print("Now writing raster.")
    names(tmp) <- c("Band1","Band2","Band3","Band4","Band5","Band6","Band7")
    tmp <- writeRaster(tmp,filename = paste0(envrmt$path_data,"/lsrs/tile",tilesID[i],"_",dates[j],".tif"),
                       datatype="INT2S")
  }
}


