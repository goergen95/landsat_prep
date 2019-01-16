MaskAndPredict <- function(shape,lslist, model, path){
  lapply(seq(length(lslist)), function (i){
    tmp <- brick(lslist[i])
    #for (j in nlayers(tmp)){
    #  tmp[[j]] <- focal(tmp[[j]], w=matrix(1/9,nrow=3,ncol=3))
    #}
    shape <- spTransform(shape,crs(tmp))
    s <- crop(shape,tmp)
    r <- rasterize(s,tmp,mask=TRUE)
    tmp = r[[1]]
    #names(r) <- model$finalModel$xNames
    cells.value = Which(is.na(r[[1]])==0, cells = TRUE)
    r[[nlayers(r)+1]] = (r[[3]]/r[[4]])*100
    r[[nlayers(r)+1]] = (r[[2]]/r[[4]])*100
    r[[nlayers(r)+1]] = (r[[5]]/r[[4]])*100
    r = getValues(r)
    r = round(r, digits = 0)
    r = as.integer(r)
    r = na.omit(r)
    r = as.vector(r)
    r = matrix(r, ncol = 10)
    #r %<>% round(digits = 0) %>% as.integer %>% na.omit %>% as.vector %>% matrix(ncol =10)
    #r <- as.data.frame(r)
    pred <- predict_on_batch(model,scale(r))
    pred <- cbind(pred,cells.value)
    tmp[cells.value] = pred[,1]
    writeRaster(tmp, filename = paste0(path,substr(names(tmp),1,19),"prediction_.tif"), overwrite = TRUE)
    print(paste0("Done with prediction ",i," out of ",length(lslist),"."))
    return(paste0(path,substr(names(tmp),1,19),"_prediction.tif"))
  })
}