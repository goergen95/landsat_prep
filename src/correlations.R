source("~/lsat/landsat_prep/src/000_env_setup.R")
source("~/GEO-Master/data_analysis/mpg-data-analysis-2018-goergen95/src/ffs_cv_function.R")
library(gam)
data = readRDS(paste0(envrmt$path_prediction,"observation_data_pca.rds"))
data = data[-c(1,6),]
vars = names(data)[c(19:25,27)]
dep = names(data)[3]
#data = data[-c(2,14,17),]
test = at_cont(data = data, dep= "N", vars = vars, model = "gam", metric = "Rsquared")
test[[2]]




  
for ( i in 1:16){
  train = data[-i,]
  #print(length(train[,1]))
  test = data[i,]
  #print(length(test[,1]))
  #mod  = gam(as.formula("N~s(pc1)+s(Band6)+s(Band4)"),data = train)
  mod = lm(as.formula("P04~pc1+Band6+Band4"), data = train)
  summary(mod)
  pred[i] = predict(mod,test)
  pred
  obsv[i] = test$MS
  obsv
}
#pred = pred[-c(2)]
#obsv = obsv[-c(2)]
plot(pred,obsv)
round(postResample(pred,obsv),2)
res = residuals(mod)
plot(residuals(mod),mod$fitted.values)
plot(pred,obsv, xlab = "predicted values", ylab = "observed values", main = "GAM model TSS - R²: 0.69 - RMSE: 49.03 mg/l",sub ="validation based on Leave-One-Out-CV")
data$TSS = data$MS
cor = cor(data[,c(28,19:25,27)])
corrplot(cor,method = "number", type = "upper")
