source("~/lsat/landsat_prep/src/env_setup.R")

ls <- list.files(paste0(envrmt$path_data,"lsrs/"),full.names=TRUE, pattern = ".tif")
shp <- readOGR(paste0(envrmt$path_data_river,"RIVER.shp"))
shp <- spTransform(shp, CRSobj = crs(raster(ls[1])))
stations <- readOGR(paste0(envrmt$path_data,"stations/stations.shp"))
#stations <- spTransform(stations, CRSobj = crs(raster(ls[1])))
data <- read.csv(paste0(envrmt$path_data,"ili_stations.csv"),header=TRUE)
names(data)[1] <- "Date"
#stations@data <- merge(stations@data,data,by="SID")


###check extent for stations
tiles <- unique(stringr::str_sub(ls,-19,-14))
ext <- data.frame(matrix(ncol=1+length(unique(stations$SID)),nrow=length(unique(tiles))))
colnames(ext) <- c("tiles",sort(as.character(unique(stations$SID))))
ext$tiles=unique(tiles)

for (i in 1:length(tiles)){
  tmp <- raster::raster(ls[stringr::str_detect(ls,tiles[i])][1])
  stations <- spTransform(stations,crs(tmp))
  ext[i,2:(length(unique(stations$SID))+1)]<- raster::cellFromXY(tmp,stations)
}


### check for available dates

source(paste0(envrmt$path_landsat_prep_src,"checkDates.R"))

results <- NULL
obsv <- NULL
for ( stationID in 1:length(stations) ){
  ID <- as.character(unique(data$SID))[stationID]
  for ( tileID in 1:sum(!is.na(ext[,1+stationID]))){
    
    tile <- ext$tiles[which(!is.na(ext[,1+stationID]))[tileID]]
    tiles <- ls[stringr::str_detect(ls,tile)]
    tmp <- data[data$SID==ID,]
    index <- unlist(checkDate(tmp,tiles))
    
    if ( sum(is.na(index))==length(index)){
      print("No scenes available for that observation")
      next
    } else {
    
    insitu <- tmp[which(!is.na(index)),]
    index <- as.vector(na.omit(index))
    exsitu <- NULL
       
       for ( scene in 1:sum(!is.na(index))){
         r <- brick(ls[index[scene]])
         names(r) <- c("Band1","Band2","Band3","Band4","Band5","Band6","Band7")
         exsitu <- rbind(exsitu,r[ext[,names(ext)==ID][ext$tiles==tile]])
       }
       obsv <- cbind(insitu,exsitu)
       obsv$tile <- stringr::str_sub(tiles,-23,-1)[index]
       results <- rbind(results,obsv)
    }
  }
}

#exclude empty cells from rasters
results <- na.omit(results)
saveRDS(results, file = paste0(envrmt$path_prediction,"observation_data.rds"))

