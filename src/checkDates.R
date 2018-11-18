#Function to check for available dates within 5 days of in-situ measurment
#Make sure the list of Images contains only scenes which overlap with the gauge station



checkDate <- function(data,landsat){
  dates <- substr(landsat,11,18)
  
  timeDiff <- lapply(data$Date, function(x)
  sqrt((as.numeric(as.character(dates))-as.numeric(as.character(x)))**2)
  )
  
  scCheck <- function(x) {
    value <- min(x)
    if (value <= 2) {
      print("For this measurment there is a scene available within 2 days")
      return(which(x<=2))
      next
    } else if (value > 5) {
      print("For this measurment there is no scene available.")
    } else {
      print("Luckily there is a scene available within 5 days")
      return(which(x > 2 & x < 5))
    }
  }
  index <- lapply(timeDiff, scCheck)
  return(index)
}



