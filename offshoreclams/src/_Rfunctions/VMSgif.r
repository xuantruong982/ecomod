VMSgif<-function(fisheryList,yrs,tail=7,pie.scale=10,wd=800,ht=600,outdir=file.path( project.datadirectory("offshoreclams"), "figures"),...){
	
	require(animation)# for creating gif
	require(TeachingDemos) # for adding pie charts to map
	

	# VMS data
	VMSdat = fisheryList$processed.vms.data
	if(missing(yrs))yrs = unique(VMSdat$year)
	VMSdat = subset(VMSdat, year%in%yrs)
	VMSdat$date =	as.Date(VMSdat$date)

	VMSdat$julian<-julian(VMSdat$date,origin=min(VMSdat$date)-1)
	
	# log data
	fish.dat = fisheryList$processed.log.data
	fishTmp.dat<-subset(fish.dat,year%in%yrs)
	fishTmp.dat$julian<-julian(as.Date(fishTmp.dat$date),origin=min(VMSdat$date)-1)
	BanSum<-sum(subset(fishTmp.dat,bank==1,round_catch))
	BanS<-sqrt(BanSum/pi)/pie.scale
	

	### GIF animations ###
	## set some options first
	oopt = ani.options(interval = 0.4, nmax = length(min(VMSdat$julian):max(VMSdat$julian)), outdir=getwd())
	## use a loop to create images one by one
	saveGIF({
	for (i in 1:ani.options("nmax")) {
	ClamMap2(...,title=min(VMSdat$date)+i-1,isobath=seq(50,500,50),bathy.source='bathy')
	points(lat~lon,subset(VMSdat,julian<=i&julian>i-tail),pch=16,cex=0.1,col=rgb(1,0,0,0.3)) # add VMS
	 print(i)
	# Catch pie charts
	BanFSF<-sum(subset(fishTmp.dat,julian<i&bank==1)$round_catch)
	#browser()
	subplot(pie(c(BanSum-BanFSF,BanFSF),labels=NA),-57.5,44.3,size=rep(BanS,2))

	if(i == ani.options("nmax"))	 points(lat~lon,VMSdat,pch=16,cex=0.1,col=rgb(1,0,0,0.3)) # add VMS
 
	 
	ani.pause() ## pause for a while (�interval�)
	}
	}, interval = 0.05, movie.name = "VMS.gif", ani.width = wd, ani.height = ht)
}

