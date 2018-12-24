MaskAndPredict <- function(shape,lslist, model){
  lapply(seq(length(lslist)), function (i){
    tmp <- brick(lslist[i])
    for (j in nlayers(tmp)){
    tmp[[j]] <- focal(tmp[[j]], w=matrix(1/9,nrow=3,ncol=3))
    }
    shape <- spTransform(shape,crs(tmp))
    s <- crop(shape,tmp)
    r <- rasterize(s,tmp,mask=TRUE)
    names(r) <- model$finalModel$xNames
    #r <- as.data.frame(r)
    pred <- raster::predict(r, model, na.rm = TRUE)
    print(paste0("Done with prediction ",i," out of ",length(lslist),"."))
    return(pred)
    })
}