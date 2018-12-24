source("~/lsat/landsat_prep/src/env_setup.R")
source("~/lsat/landsat_prep/src/MaskAndPredict.R")

data <- readRDS(paste0(envrmt$path_prediction,"observation_data.rds"))
river <- readOGR(paste0(envrmt$path_data_river,"RIVER.shp"))
ls <- list.files(path = paste0(envrmt$path_data,"lsrs/"), pattern = ".tif", full.names = TRUE)

# prepare model bulding - mind spatial cross validation!!
smp <- sample(length(data[,1]),length(data[,1])*0.8)
train <- data[smp,]
test <- data[-smp,]

rfmodel <- caret::train(train[,19:25],train$MS, method = "rf")

#formula <- paste(names(train)[4], " ~ ", paste(names(train[19:25]), collapse=" + "))
#lmodel <- lm(formula,train)
#pred <- predict(lmodel,newdata=test)
pred <- predict(rfmodel,test[,19:25])
obsv <- test$MS
pred
obsv
plot(obsv~pred)



#predict all scenes

predScenes <- MaskAndPredict(river,ls,rfmodel)
names <- list.files(paste0(envrmt$path_data,"lsrs/"), pattern = ".tif")
for( i in 1:length(predScenes)){
  writeRaster(predScenes[[i]], filename = paste0(envrmt$path_prediction,names[i]), overwrite =TRUE)
  print(i)
}







