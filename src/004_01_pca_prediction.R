source("~/lsat/landsat_prep/src/000_env_setup.R")

model = readRDS(paste0(envrmt$path_data,"pca/pca_.rds"))
maskList = list.files (paste0(envrmt$path_data,"lsrs/mask/"), pattern = ".tif", full.names = T)
uniqueID = stringr::str_sub(maskList,-26,-12)

for (i in 1:length(maskList)){
  tmp = brick(maskList[i])
  names(tmp)= attributes(model$model$loadings)$dimnames[[1]]
  attributes(model$model$loadings)$dimnames[[1]] = names(tmp)
  names(model$model$center) = names(tmp)
  names(model$model$scale) = names(tmp)
  pc1 = predict(tmp,model$model, index = 1)
  #pc1 = predict(model$model, as.matrix(tmp), index = 1)
  tmp[[nlayers(tmp)+1]] = pc1
  names(tmp)[nlayers(tmp)] = "pc1"
  writeRaster(tmp, filename = paste0(envrmt$path_data,"lsrs/pca/pca_tile",uniqueID[i],".tif"))
  print(i)
}


band = data[,19:25]
br = brick(nrows = 21,ncols=1)
values(br) = band[,1]
br[[2]] = band[,2]
br[[3]] = band[,3]
br[[4]] = band[,4]
br[[5]] = band[,5]
br[[6]] = band[,6]
br[[7]] = band[,7]
names(br) = attributes(model$model$loadings)$dimnames[[1]]
pc1 = predict(br,model$model, index = 1)
data$pc1 = 0
data$pc1 = values(pc1)
saveRDS(data,paste0(envrmt$path_prediction,"observation_data_pca.rds") )


flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}

library(Hmisc)
dataMS = data[,c(3,19:25,27)]
corr_MS = cor(dataMS)
round(corr_MS,2)
corrplot::corrplot(corr_MS, method="color", type = "upper")

dataN = data[,c(17,19:25,27)]
corr_N = rcorr(as.matrix(dataN))
#round(corr_N,2)
flattenCorrMatrix(corr_N$r, corr_N$P)
corrplot::corrplot(corr_N$r, type="upper", order="hclust", 
         p.mat = corr_N$P, sig.level = 0.20, insig = "blank")
corrplot::corrplot(corr_N, method="color", type = "lower")

dataP = data[,c(18,19:25,27)]
corr_P = cor(dataP)
round(corr_P,2)
corrplot::corrplot(corr_P, method="color", type = "lower")


dataP = data[,c(191,19:25,27)]
corr_P = cor(dataP)
round(corr_P,2)
corrplot::corrplot(corr_P, method="color", type = "lower")











