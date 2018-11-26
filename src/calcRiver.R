source("~/lsat/landsat_prep/src/env_setup.R")


lsat <- raster(paste0(envrmt$path_data_river,"Hansen_GFC2015_datamask_50N_070E.tif"))
shp <- readOGR(paste0(envrmt$path_data_river,"aoi.shp"))


fun <- function(x) {x[x==1] <- NA; return(x)}
raster::beginCluster()
lsat <- clusterR(lsat,calc, args = list(fun = fun, datatype = "INT1U"))
raster::endCluster()

#create grid to work on lsat in parts
aoi <- crop(lsat,shp)
grid <- sp::makegrid(shp, n=5, pretty= TRUE)
spgrd <- SpatialPoints(grid, proj4string = CRS(proj4string(shp)))
spgrdWithin <- SpatialPixels(spgrd)
plot(aoi)
plot(spgrdWithin, add = T)
grid <- as(spgrdWithin, "SpatialPolygons")


fun2 <- function(x) {x==2}

name <- c(seq(8))

ls <- lapply(seq(length(grid)), function(i){
  cat(paste0("Now creating tmp-number ",i,"."))
  tmp <- crop(lsat,grid[i],datatype="INT1U")
  cat(paste0("Now polygonizing tmp-number ",i,"."))
  water <- rasterToPolygons(tmp, fun=fun2,
                            na.rm = TRUE,
                            dissolve = TRUE,
                            digits = 8)
  print(i)
  #cat(paste0("Now saving shapefile number ",i,"."))
  #writeOGR(water,
           #dsn=paste0(envrmt$path_data_river,"rivershape",name[i],".shp"),
           #driver="ESRI Shapefile",
           #layer=paste0("rivershape",name[i]))
})


for (i in 1:8){
  cat(paste0("Now creating tmp-number ",i,"."))
  tmp <- crop(lsat,grid[i],datatype="INT1U")
  cat(paste0("Now polygonizing tmp-number ",i,"."))
  water <- rasterToPolygons(tmp, fun=fun2,
                            na.rm = TRUE,
                            dissolve = TRUE,
                            digits = 8)
  cat(paste0("Now saving shapefile number ",i,"."))
  writeOGR(water,
           dsn=paste0(envrmt$path_data_river,"rivershape",name[i],".shp"),
           driver="ESRI Shapefile",
           layer=paste0("rivershape",name[i]))
  print(i)
}



r <- raster(nrow=18, ncol=36)
r[] <- runif(ncell(r)) * 10
r[r>8] <- NA
pol <- rasterToPolygons(r, fun=function(x){x>6}, dissolve = TRUE)


names <- seq(length(grid))
for (i in 1:length(grid)){
  tmp <- crop(lsat,grid[i])
  writeRaster(tmp, filename=paste0(envrmt$path_data_river,"watercrop",names[i],".tif"))
}


shp1 <- readOGR(paste0(envrmt$path_data_river,"einzel.shp"))
shp2 <- readOGR(paste0(envrmt$path_data_river,"riverIli2.shp"))

shb <- bind(shp1,shp2)

writeOGR(shb,dsn=paste0(envrmt$path_data_river,"RIVER.shp"),driver = "ESRI Shapefile",
         layer = "RIVER")
