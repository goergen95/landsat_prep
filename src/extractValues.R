library(tmap)
source("~/lsat/landsat_prep/src/env_setup.R")

ls <- list.files(paste0(envrmt$path_data,"lsrs/"),full.names=TRUE)
shp <- readOGR(paste0(envrmt$path_data_river,"RIVER.shp"))
shp <- spTransform(shp, CRSobj = crs(raster(ls[1])))
stations <- readOGR(paste0(envrmt$path_data,"stations/stations.shp"))
stations <- spTransform(stations, CRSobj = crs(raster(ls[1])))
data <- read.csv(paste0(envrmt$path_data,"ili_stations.csv"),header=TRUE)
x <- names(data)
x[1] <- "Date"
names(data) <- x


###check extent for stations
tiles <- unique(stringr::str_sub(ls,-19,-14))
ext <- data.frame(SID1=rep(0,7),SID2=rep(0,7),SID3=rep(0,7),SID4=rep(0,7),SID5=rep(0,7),SID6=rep(0,7),SID7=rep(0,7),Tile = tiles)

for (i in 1:length(tiles)){
  tmp <- raster(ls[which(stringr::str_detect(ls,tiles[i]))][1])
  ext[i,1:7]<- cellFromXY(tmp,stations)
}


### check for available dates
index <- list.files(envrmt$path_data_raw)
source(paste0(envrmt$path_landsat_prep_src,"checkDates.R"))
index2 <- na.omit(unlist(checkDate(data[data$SID=="SID5",],index)))



exdata <- data.frame()
for (i in 1:length(index2)){
  if(!is.na(ext$SID5[ext$Tile==stringr::str_sub(ls,-19,-14)[index2[i]]])){
    tmp <- brick(ls[index2[i]])
    names(tmp) <- c("Band1","Band2","Band3","Band4","Band5","Band6","Band7")
    data <- extract(tmp,stations[stations$SID=="SID5",],df=TRUE)
    exdata <- cbind(exdata,data)
  }else{
    print("NO!")
    next
  }
}
  

index <- list.files(envrmt$path_data_raw)
source(paste0(envrmt$path_landsat_prep_src,"checkDates.R"))
index2 <- na.omit(unlist(checkDate(data[data$SID=="SID5",],index)))



exdata <- data.frame()
for (i in 1:length(index2)){
  if(!is.na(ext$SID6[ext$Tile==stringr::str_sub(ls,-19,-14)[index2[i]]])){
    tmp <- brick(ls[index2[i]])
    names(tmp) <- c("Band1","Band2","Band3","Band4","Band5","Band6","Band7")
    data <- extract(tmp,stations[stations$SID=="SID6",],df=TRUE)
    exdata <- cbind(exdata,data)
  }else{
    print("NO!")
    next
  }
}
    
    
tm_shape(shp)+tm_fill( col = "blue")+
  tm_shape(stations)+tm_dots(col="red",scale =4)+
  tm_shape(raster(ls[1]))+tm_raster(alpha = 0.5)+
  tm_shape(raster(ls[4]))+tm_raster(alpha = 0.5)+
  tm_shape(raster(ls[8]))+tm_raster(alpha = 0.5)+
  tm_shape(raster(ls[15]))+tm_raster(alpha = 0.5)+
  tm_shape(raster(ls[21]))+tm_raster(alpha = 0.5)+
  tm_shape(raster(ls[27]))+tm_raster(alpha = 0.5)+
  tm_shape(raster(ls[34]))+tm_raster(alpha = 0.5)


