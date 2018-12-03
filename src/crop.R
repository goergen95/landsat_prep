#cropping for classification
for (i in 1:length(ls)){
  tshp <- crop(shp,raster(ls[i]))
  tshp <- rasterize(tshp,raster(ls[i]))
  tmp <- mask(brick(ls[i]),tshp, datatype = "INT2S")
  print(i)
}

