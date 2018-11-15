### Pseudo Code Water Quality IBB Script
## Set Up Environment
source("~/lsat/landsat_prep/src/env_setup.R")


## read in shapefile of study area
#shape <- readOGR(dsn = paste0(envrmt$shapes,"name_of_shapefile.shp"))
## or enter bounding box manually
aoi <- matrix(data=c(47.26,73.13,47.26,83.11,43.38,83.11,43.38,73.13),nrow=4,byrow=TRUE)
#you may want to set the aoi session wide with
#set_aoi(aoi)

login_USGS("da.goergen")
prod_names <- getLandsat_names()
time_range <- c("2013-01-01","2013-12-31")

query <- getLandsat_query(time_range =  time_range, name = prod_names[6], aoi = aoi)

saveRDS(query, file =paste0(envrmt$path_data,"queryLS.rds"))
fileList <- readRDS(file = paste0(envrmt$path_data,"queryLS.rds"))


#exclude files with cloud cover over 20%
fileList <- fileList[which(fileList$SceneCloudCover<10),]
#only include files with data for both sensors
fileListOT <- fileList[which(fileList$SensorIdentifier=="OLI_TIRS"),]



#you might use this call to download data within R
#save order ID here and specify it afer abortion with: espa_order = ""
getLandsat_data(fileListOT, level ="l1", source = "AWS", dir_out = envrmt$path_data_raw,
                username = "da.goergen",force =TRUE)



#if it doesnt work, write out the IDs of scenes of interest and do a file ordering at USGS website
#and use the bulk download application there

write.csv(as.vector(fileList$displayId), file = paste0(envrmt$path_data,"list.csv"),quote = FALSE, sep =",",row.names = FALSE,col.names = FALSE)

