#Function to check for available dates within 5 days of in-situ measurment
#Make sure the list of Images contains only scenes which overlap with the gauge station



checkDate <- function(data,landsat){
  dates <- stringr::str_sub(landsat,-12,-5)
  #dates = stringr::str_sub(landsat,-18,-11)
  timeDiff <- lapply(data$Date, function(x)
  sqrt((as.numeric(as.character(dates))-as.numeric(as.character(x)))**2)
  )
  
  scCheck <- function(x) {
    value <- min(x)
    if (value <= 2) {
      #print("For this measurment there is a scene available within 2 days")
      return(which(x<=2))
      next
    } else if (value > 7) {
      #print("For this measurment there is no scene available.")
      return(NA)
    } else {
      #print("Luckily there is a scene available within 5 days")
      return(which(x > 2 & x < 7))
    }
  }
  index <- lapply(timeDiff, scCheck)
  return(index)
}



