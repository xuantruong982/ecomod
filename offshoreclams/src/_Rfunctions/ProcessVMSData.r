
ProcessVMSData <- function(vms.data,log.data){
  
  ##############################################################################
  ## Do initial processing, fill in some missing values, 
  ##############################################################################

  names(vms.data) <- tolower(names(vms.data))
  vms.data$vmsdate <- as.POSIXct(vms.data$vmsdate,tz="GMT")  # VMS data is in UTC, assign timezone
  vms.data <- vms.data[order(vms.data$vrn, vms.data$vmsdate), ]  # Order dataframe by vrn and DateTime 
  
  ########################################
  # Clean VMS data selected from VMS_pos #
  ########################################
  
  # Shift vmsdate with a duplicate within vrn by one second (duplicate record is moved one second forward)
  vms.data$vmsdate.adj <- adjust.duplicateTimes(vms.data$vmsdate, vms.data$vrn)
  # Create date and time variables in local time
  vms.data$date <- format(strftime(vms.data$vmsdate.adj,format="%Y-%m-%d"), tz="America/Halifax",usetz=TRUE)
  vms.data$time <- format(strftime(vms.data$vmsdate.adj,format="%H:%M:%S"), tz="America/Halifax",usetz=TRUE)
  vms.data$year <- format(strftime(vms.data$vmsdate.adj,format="%Y"), tz="America/Halifax",usetz=TRUE)
  vms.data$vmsdatelocal <- as.POSIXct(paste(vms.data$date, vms.data$time), format="%Y-%m-%d %H:%M:%S",tz="America/Halifax")
  #vms.data$time <- as.POSIXct(vms.data$time,format="%H:%M:%S")


  # Add Watch number (record_no) to VMS data from local Date:Time 
  watchTimes = c("06:00:00","12:00:00","18:00:00")
  vms.data$record_no <- 0
  vms.data$record_no[vms.data$vmsdatelocal<as.POSIXct(paste(vms.data$date,watchTimes[1]))] <- 1
  vms.data$record_no[vms.data$vmsdatelocal>=as.POSIXct(paste(vms.data$date,watchTimes[1]))&vms.data$vmsdatelocal<as.POSIXct(paste(vms.data$date,watchTimes[2]))] <- 2
  vms.data$record_no[vms.data$vmsdatelocal>=as.POSIXct(paste(vms.data$date,watchTimes[2]))&vms.data$vmsdatelocal<as.POSIXct(paste(vms.data$date,watchTimes[3]))] <- 3
  vms.data$record_no[vms.data$vmsdatelocal>=as.POSIXct(paste(vms.data$date,watchTimes[3]))] <- 4
  #vms.data <- vms.data[!duplicated(vms.data),] # Removes any rows that are fully duplicated
  
  ########################################	
  # Cross against logs to pull out trips #
  ########################################	
  
  #Assign logrecord_id to vms.data
  vms.data <- merge(vms.data,log.data[,c("logrecord_id","cfv","date","record_no")], by.x = c("vrn", "date", "record_no"), by.y = c("cfv","date","record_no"),all.x=TRUE) 
  
  #Check for outliers in latitude and longitude  
  
  #Calculate distance travelled between points
  
  #Remove watches without effort
  #Note we lose catch data by removing watches without effort since there is a delay
  #log.data <- log.data[log.data$n_tows!=0,]
  
  return(vms.data)

} # end of function ProcessLogData