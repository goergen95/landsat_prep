at_cont = function(data, dep = NULL, vars = NULL, selected_vars = NULL, model = "gam", metric = "RMSE"){
  
  check = c()
  switch = 0
  vars_org = vars
  while (switch == 0){
    
    if(!is.null(selected_vars)){
      vars <- vars_org[-which(vars_org %in% selected_vars)]
    }
    
    fwd_ds = lapply(seq(length(vars)), function(v){
      if (is.null(selected_vars)){
        if (model == "gam") formula = paste0(dep," ~ s(",vars[v],")")
        if (model == "lm") formula = paste0(dep," ~ ",vars[v])
      } else {
        if (model == "gam") formula = paste0(dep, " ~ s(", paste(c(selected_vars, vars[v]), collapse=")+("),")")
        if (model == "lm") formula  = paste0(dep, " ~ ", paste(c(selected_vars, vars[v]), collapse = " + "))
      }
      
      pred = c()
      obsv = c()
      for (i in 1:length(data[,1])){
        train = data[-i,]
        test = data[i,]
        
        if (model == "gam") mod = gam(as.formula(formula), data = train)
        if (model == "lm") mod = lm(as.formula(formula), data = train)
        
        pred[i] = predict(mod, test)
        obsv[i] = test[dep]
      }
      
      obsv = unlist(obsv)
      results = round(postResample(pred,obsv),5)
      results = data.frame(Variable = vars[v], 
                           RMSE =results[1],
                           Rsquared = results[2], 
                           MAE =results[3])
      return(results)
    })
    fwd_ds <- do.call("rbind", fwd_ds)
    
    if(!is.null(selected_vars)){
      if(model == "gam")formula = paste0(dep, " ~ s(", paste(selected_vars, collapse=")+("),")")
      if(model == "lm") formula  = paste0(dep, " ~ ", paste(selected_vars, collapse = " + "))
      
      for (i in 1:length(data[,1])){
        train = data[-i,]
        test = data[i,]
        
        if (model == "gam") mod = gam(as.formula(formula), data = train)
        if (model == "lm") mod = lm(as.formula(formula), data = train)
        
        pred[i] = predict(mod, test)
        obsv[i] = test[dep]
      }
      obsv = unlist(obsv)
      results_selected = round(postResample(pred,obsv),5)
      results_selected <- data.frame(Variable =  paste0("all: ", paste(selected_vars, collapse=", ")),
                                     RMSE = results_selected[1],
                                     Rsquared = results_selected[2],
                                     MAE =results_selected[3])
      
      fwd_ds <- rbind(results_selected, fwd_ds)
    }
    
    if(!is.null(selected_vars)){
      if(metric=="RMSE") best_var <- as.character(fwd_ds$Variable[which(fwd_ds$RMSE == min(fwd_ds$RMSE)&fwd_ds$RMSE!=fwd_ds$RMSE[1])])
      if(metric=="Rsquared") best_var <- as.character(fwd_ds$Variable[which(fwd_ds$Rsquared == max(fwd_ds$Rsquared)&fwd_ds$Rsquared!=fwd_ds$Rsquared[1])])
      if(metric=="MAE") best_var <- as.character(fwd_ds$Variable[which(fwd_ds$MAE == min(fwd_ds$MAE)&fwd_ds$MAE!=fwd_ds$MAE[1])])
    }else{
      if(metric=="RMSE") best_var <- as.character(fwd_ds$Variable[which(fwd_ds$RMSE == min(fwd_ds$RMSE))])
      if(metric=="Rsquared") best_var <- as.character(fwd_ds$Variable[which(fwd_ds$Rsquared == max(fwd_ds$Rsquared))])
      if(metric=="MAE") best_var <- as.character(fwd_ds$Variable[which(fwd_ds$MAE == min(fwd_ds$MAE))])
    }
    
    if(!is.null(selected_vars)){
      check = fwd_ds[metric][1,]
      if (metric=="Rsquared"){
        if(check>= max(fwd_ds[metric]))
          switch = 1
      }else{
      if(check <= min(fwd_ds[metric]))
        switch = 1
      }
    }
    
    if (is.null(selected_vars)){
      selected_vars = best_var
    }else{
      selected_vars = c(selected_vars,best_var)
    }
    
  }
  vals = data.frame(obsv=obsv,pred = pred)
  res = list(selected_vars,fwd_ds,mod, vals)
  return(res)
}
