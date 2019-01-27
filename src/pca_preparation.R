source("~/lsat/landsat_prep/src/000_env_setup.R")

river = readOGR(paste0(envrmt$path_data_river,"RIVER.shp"))
lslist = list.files(path = paste0(envrmt$path_data,"/lsrs"), pattern = ".tif", full.names = TRUE)
uniqueID = substr(lslist,52,70)
data = readRDS("~/lsat/prediction/observation_data.rds")

corrplot::corrplot()

for (i in 19:23){
  tmp = brick(lslist[i])
  #for (j in nlayers(tmp)){
  #  tmp[[j]] <- focal(tmp[[j]], w=matrix(1/9,nrow=3,ncol=3))
  #}
  shape <- spTransform(river,crs(tmp))
  s <- crop(shape,tmp)
  r <- rasterize(s,tmp,mask=TRUE)
  writeRaster(r, filename = paste0(envrmt$path_data,"lsrs/mask/",uniqueID[i],"_masked.tif"))
  print(i)
  #return(paste0(envrmt$path_data,"lsrs/mask/",uniqueID[i],"_masked.tif"))
}


test1 = rasterPCA(masked[[2]],spca = TRUE)
test2 = rasterPCA(masked[[6]], spca = TRUE)
saveRDS(test1, file = paste0(envrmt$path_data,"/pca/pca_.rds"))
save(test1, file = paste0(envrmt$path_data,"/pca/pca2_.rds"))
x =masked[[6]]
names(x) = names(masked[[2]])
test3 = predict(x,test1$model)

load1 = loadings(test1$model)
org = par()
par(mfrow = c(2,2))
barplot(load1[,1], names.arg=c("Band1","Band2","Band3","Band4","Band5","Band6","Band7"), col = "darkblue", main = "PC1")
barplot(load1[,2], names.arg=c("Band1","Band2","Band3","Band4","Band5","Band6","Band7"), col = "steelblue", main = "PC2")
barplot(load1[,3], names.arg=c("Band1","Band2","Band3","Band4","Band5","Band6","Band7"), col = "lightskyblue1", main = "PC3")
barplot(load1[,4], names.arg=c("Band1","Band2","Band3","Band4","Band5","Band6","Band7"), col = "lightblue", main = "PC4")

eigvalue.pca1 <- factoextra::get_eigenvalue(test1$model)
eigvalue.pca2 <- factoextra::get_eigenvalue(test2$model)
par(org)
barplot(eigvalue.pca1$variance.percent, col = "steelblue",names.arg=c("PCA1","PCA2","PCA3","PCA4","PCA5","PCA6","PCA7"), main = "variance explained by components")




factoextra::fviz_eig(test1$model, addlabels = TRUE,ylim=c(0,50))
factoextra::fviz_eig(test2$model, addlabels = TRUE,ylim=c(0,50))

var.pca1 <- factoextra::get_pca_var(test1$model)
var.pca1
var.pca2 <- factoextra::get_pca_var(test2$model)
var.pca2

factoextra::fviz_pca_var(test1$model, col.var = "black")
factoextra::fviz_pca_var(test2$model, col.var = "black")


corrplot::corrplot(var.pca1$cos2, is.corr=FALSE)
factoextra::fviz_cos2(test1$model, choice = "var", axes = 1:2)
corrplot::corrplot(var.pca2$cos2, is.corr=FALSE)
factoextra::fviz_cos2(test2$model, choice = "var", axes = 1:2)

attributes(test1$model$loadings)$dimnames[[1]] = c("Band 1","Band 2","Band 3","Band 4","Band 5","Band 6","Band 7")
factoextra::fviz_pca_var(test1$model, col.var = "cos2",
                         gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                         alpha.var = "cos2",# add transparency according to cos2-values
                         repel = TRUE # Avoid text overlapping
)
factoextra::fviz_pca_var(pca$model, col.var = "cos2",
                         gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                         alpha.var = "cos2",# add transparency according to cos2-values
                         repel = TRUE # Avoid text overlapping
)



corrplot::corrplot(var.pca$contrib,is.corr = FALSE)
factoextra::fviz_contrib(test1$model,choice = "var",axes=1)
factoextra::fviz_contrib(test1$model,choice = "var",axes=2)
factoextra::fviz_contrib(test1$model,choice = "var",axes=3)
factoextra::fviz_contrib(test1$model,choice = "var",axes=4)
#total contribution for several components
factoextra::fviz_contrib(test1$model, choice = "var", axes = 1:2)
factoextra::fviz_contrib(test1$model, choice = "var", axes = 1:3)

corrplot::corrplot(var.pca$contrib,is.corr = FALSE)
factoextra::fviz_contrib(test1$model,choice = "var",axes=1)
factoextra::fviz_contrib(test1$model,choice = "var",axes=2)
factoextra::fviz_contrib(test1$model,choice = "var",axes=3)
factoextra::fviz_contrib(test1$model,choice = "var",axes=4)
#total contribution for several components
factoextra::fviz_contrib(test1$model, choice = "var", axes = 1:2)
factoextra::fviz_contrib(pca$model, choice = "var", axes = 1:3)
