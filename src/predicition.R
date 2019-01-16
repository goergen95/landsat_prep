source("~/lsat/landsat_prep/src/000_env_setup.R")
source("~/lsat/landsat_prep/src/MaskAndPredict_nnet.R")
library(mgvc)
library(keras)
#install_keras()
library(magrittr)

data <- readRDS(paste0(envrmt$path_prediction,"observation_data.rds"))
river <- readOGR(paste0(envrmt$path_data_river,"RIVER.shp"))
ls <- list.files(path = paste0(envrmt$path_data,"lsrs/"), pattern = ".tif", full.names = TRUE)

# prepare model bulding - mind spatial cross validation!!
data$GRratio = data$Band3/data$Band4
data$BRratio = data$Band2/data$Band4
data$NRratio = data$Band5/data$Band4
predNames = names(data)[c(19:25,27:29)]
pc = princomp(data[predNames])
ms = data$MS
data = matrix(as.vector(pc$scores[,1:3]), nrow =21)
#data = cbind(data,pc$scores[,2])
data =cbind(data,ms)

t= c()
#smp <- sample(length(data[,1]),length(data[,1])*0.95)
for (i in 1:length(data[,1])){
  train <- data[-i,]
  test <- data[i,]
  model = gam(train[,length(train[1,])]~s(train[,1:length(train[1,])-1], fx = FALSE))
  t[i]= (model$coefficients[2]*test[1])+model$coefficients[1]
}


#test = lapply(seq(1:10), function (s){
#  set.seed(s)
t= c()
#smp <- sample(length(data[,1]),length(data[,1])*0.95)
for (i in 1:length(data[,1])){
  train <- data[-i,]
  test <- data[i,]
  model = lm(train[,length(train[1,])]~train[,1:length(train[1,])-1])
  t[i]= (model$coefficients[2]*test[1])+model$coefficients[1]
}

mean(sqrt((t-data[,length(train[1,])])**2))
  
  
  pred = predict(model,test[,1])
  
  
  #data preparation for keras neural networks
  ##training
  t = lapply(predNames, function(predNames,data,i){
    print(predNames[i])
    var = data[predNames[i]]
    if (length(levels(unlist(var)))!=0){
      tmp = to_categorical(as.numeric(unlist(var))-1,length(unlist(unique(var))))
    }else{
      tmp = scale(as.numeric(unlist(var)))
    }
    return(tmp)
    
  }, data = train)
  
  x_train = do.call(cbind,t)
  y_train= train$MS
  
  ##testing
  r = lapply(predNames, function(predNames,data,data2,i){
    print(predNames[i])
    var = data[predNames[i]]
    var2 = data2[predNames[i]]
    if (length(levels(unlist(var)))!=0){
      tmp = to_categorical(as.numeric(unlist(var))-1,length(unlist(unique(var2))))
    }else{
      tmp = scale(as.numeric(unlist(var)))
    }
    return(tmp)
    
  }, data = test,data2 = train)
  
  x_test = do.call(cbind,r)
  y_test = test$MS
  
  
  
  # modelling with training data set
  
  model <- keras_model_sequential()
  model %>%
    layer_dense(units=ncol(x_train), activation = 'relu',input_shape = ncol(x_train)) %>%
    layer_dropout(rate = 0.4) %>%
    layer_dense(units = 64, activation = 'relu') %>%
    layer_dropout(rate = 0.2) %>%
    layer_dense(units = 1, activation = "linear")
  
  summary(model)
  
  model %>% compile(
    loss = 'mse',
    optimizer = "adam",
    metrics = list('mse','mae')
  )
  
  
  history <- model %>% fit(
    x_train, y_train, 
    epochs = 100, batch_size = 1,
    validation_split = 0.1
  )
  
  #history
  results = model %>% evaluate(x_test,y_test)
  results
#  return(results$mean_absolute_error)
#})

pred = predict_on_batch(model,x_test)
obsv = y_test
error = mean(sqrt((pred-obsv)**2))
error
plot(pred,obsv)
saveRDS(model, file = paste0(envrmt$path_data,"tmp/model_nnet.rds"))

#br = brick(paste0(envrmt$path_data,"lsrs/tile148029_20130730.tif"))
#cells.value = Which(is.na(br[[1]])==0, cells = TRUE)

#br[['GRratio']][cells.value] = na.omit(getValues(br[[3]]))/na.omit(getValues(br[[4]]))
#br[['BRratio']] = br[[2]]/br[[4]]
#br[['NRratio']] = br[[5]]/br[[4]]
#cells.value = Which(is.na(br)==0, cells = TRUE)
#br %<>% as.matrix %>% na.omit %>% scale
#head(br)

#pred = predict_on_batch(model,as.matrix(br))
pred = MaskAndPredict(river,ls,model,path = paste0(envrmt$path_data,"predict/"))
#predict all scenes

predScenes <- MaskAndPredict(river,ls,rfmodel, path = paste0(envrmt$path_data,"predict/"))


names <- list.files(paste0(envrmt$path_data,"lsrs/"), pattern = ".tif")
for( i in 1:length(predScenes)){
  writeRaster(predScenes[[i]], filename = paste0(envrmt$path_prediction,names[i]), overwrite =TRUE)
  print(i)
}







