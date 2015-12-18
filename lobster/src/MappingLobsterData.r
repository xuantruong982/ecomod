
loadfunctions("lobster")

### LOGS ###

#loadfunctions('lobster')
#cpuegrids<-lobGridPlot(subset(logsInSeason,LFA=='34'&SYEAR==2014,c("LFA","GRID_NUM","CPUE")),FUN=mean)
#LobsterMap('34',poly.lst=cpuegrids)


####### 2014 CATCH with survey location LFA 34

loadfunctions('lobster')
logsInSeason<-read.csv(file.path( project.datadirectory("lobster"), "data","logsInSeason.csv"))

catchgrids<-lobGridPlot(subset(logsInSeason,LFA=='34'&SYEAR==2014,c("LFA","GRID_NUM","WEIGHT_KG")),lvls=c(1000,50000,100000,200000,400000,600000,800000,1000000),FUN=sum,border=NA)
	
pdf(file.path( project.datadirectory("lobster"), "R","LFA34.pdf"),8,11)

LobsterMap('34',poly.lst=catchgrids[1:2],title="2014 Lobster Catch")
ContLegend("bottomleft",lvls=catchgrids$lvls/1000,Cont.data=catchgrids,title="Catch (t)",inset=0.02,cex=0.8,bg='white')
ss2015<-read.csv(file.path( project.datadirectory("lobster"), "data","LFA34TrawlStations2015.csv"))
with(subset(ss2015,TYPE%in%c('index','2014_index')),points(DDLON,DDLAT,pch=16,col='red'))
with(subset(ss2015,TYPE%in%c('2014','2014_index')),points(DDLON,DDLAT))
legend('topleft',c('index','2014'),col=c('red','black'),pch=c(16,1),inset=0.02,cex=0.8,bg='white')

dev.off()


loadfunctions('lobster')
catchgrids <-lobGridPlot(subset(logsInSeason,SYEAR==2014,c("LFA","GRID_NUM","WEIGHT_KG")),lvls=c(100,50000,100000,200000,400000,600000,800000,1000000),FUN=sum,border=NA)
	
pdf(file.path( project.datadirectory("lobster"), "R","GridLandings.pdf"),11,8)

LobsterMap(poly.lst=catchgrids[1:2],title="2014 Lobster Catch")
ContLegend("bottomright",lvls=catchgrids$lvls/1000,Cont.data=catchgrids,title="Catch (t)",inset=0.02,cex=0.8,bg='white')

dev.off()


############## LFA grid effort


loadfunctions('lobster')
logsInSeason<-read.csv(file.path( project.datadirectory("lobster"), "data","logsInSeason.csv"))
yy = unique(logsInSeason$SYEAR)


fp = file.path( project.datadirectory("lobster"), "figures")
dir.create(fp, recursive =T, showWarnings =F)

effortgrids <-lobGridPlot(subset(logsInSeason,SYEAR==2014,c("LFA","GRID_NUM","NUM_OF_TRAPS")),lvls=c(100,50000,100000,200000,400000,600000,800000,1000000),FUN=sum,border=NA)
pdf(file=file.path(fp,paste("GridLandings",y,"pdf",sep="."),11,8)
LobsterMap(poly.lst=effortgrids[1:2],title=paste(y,"Lobster Catch"))
ContLegend("bottomright",lvls=effortgrids$lvls/1000,Cont.data=effortgrids,title="Catch (t)",inset=0.02,cex=0.8,bg='white')

dev.off()


############# LFA 41

bycatch41<-read.csv(file.path(project.datadirectory('lobster'),'data',"LFA41bycatch2015.csv"))
bycatch41$LONGITUDE<-abs(bycatch41$LONGITUDE)*-1
bycatch41$EID<-1:nrow(bycatch41)

ylim=c(41.1,44); 		xlim=c(-68,-63.5)

byData<-na.omit(subset(bycatch41,SPECCD_ID==15&OFFAREA!="UNKNOWN"&LONGITUDE<(-63.5),c('EID','LONGITUDE','LATITUDE','EST_DISCARD_WT')))
byContours<-interpolation(byData,ticks='define',place=3,nstrata=5,str.min=0,interp.method='gstat',blank=T,res=0.005,smooth=F,idp=3.5,blank.dist=0.03)
	
lvls=c(1, 2, 5, 10, 20, 50)

cont.lst<-contour.gen(byContours$image.dat,lvls,col="YlGn",colorAdj=1)

# plot Map
LobsterMap("41",mapRes="HR",contours=cont.lst,title="Cusk bycatch LFA 41")
#points(LATITUDE~LONGITUDE,byData,pch=16,cex=0.5)#,col=rgb(0,0,0,0.5))
ContLegend("bottomright",lvls=lvls,Cont.data=cont.lst$Cont.data,title="Est. discards (Kg)",inset=0.02,cex=0.8,bty='n')

grids<-read.csv(file.path( project.datadirectory("lobster"), "data","maps","GridPolys.csv"))


##### From Scallop Survey

# get lobster data from scallop survey
lobdat<-LAFSS(SPA=c("6A","6B","6C"))

#
ScallopAreas<-read.csv(file.path( project.datadirectory("lobster"), "data","maps","NewAreaDefsforISAREADEFS2013.csv"))


pdf(file.path( project.datadirectory("lobster"), "R","SPA6LobsterDensity.pdf"),8,11)

for(i in 2005:2014){
	
	# interpolate abundance
	lob.contours<-interpolation(subset(lobdat,YEAR==i,c('TOW_SEQ','lon','lat','NLobsStd')),ticks='define',place=3,nstrata=5,str.min=0,interp.method='gstat',blank=T,res=0.005,smooth=F,idp=3.5,blank.dist=0.03)

	# define contour lines
	print(lob.contours$str.def)
	lvls=c(1, 2, 5, 10, 20, 50)

	# generate contour lines
	cont.lst<-contour.gen(lob.contours$image.dat,lvls,col="YlGn",colorAdj=1)

	# plot Map
	LobsterMap(ylim=c(44.4,45.2),xlim=c(-67.2,-66.3),mapRes="UR",contours=cont.lst,title=paste("SPA 6 Lobster Density",i),isobath=seq(10,500,10),bathcol=rgb(0,0,1,0.2),bathy.source='bathy',boundaries='scallop',poly.lst=list(ScallopAreas,data.frame(PID=c(16,18))))
	points(lat~lon,lobdat,subset=YEAR==i,pch=16,cex=0.5)#,col=rgb(0,0,0,0.5))
	ContLegend("bottomright",lvls=lvls,Cont.data=cont.lst$Cont.data,title="#/standard tow",inset=0.02,cex=0.8,bty='n')
}
dev.off()


	LobsterMap(ylim=c(44.4,45.2),xlim=c(-67.2,-66.3),mapRes="UR",isobath=seq(10,500,10),bathcol=rgb(0,0,1,0.2),bathy.source='bathy',boundaries='scallop',poly.lst=list(ScallopAreas,data.frame(PID=c(9,16,18))))




		LFAgrid<-read.csv(file.path( project.datadirectory("lobster"), "data","maps","LFAgridPolys.csv"))

		joined<-joinPolys(LFAgrid,operation="UNION")

ScallopAreas<-read.csv(file.path( project.datadirectory("lobster"), "data","maps","NewAreaDefsforISAREADEFS2013.csv"))
pdf(file.path( project.datadirectory("lobster"), "R","LobsterSurveyLFA36.pdf"),11,8)
	LobsterMap(ylim=c(44.8,45.7), xlim=c(-66.8,-64.5),mapRes="UR",isobaths=c(25,40,70,100),bathcol=rev(brewer.pal(5,'Blues')[-1]),bathy.source='bathy',boundaries='scallop',poly.lst=list(ScallopAreas,data.frame(PID=c(16,18))),plot.rivers=F)

dev.off()

		
		LobsterMap()
		LFAlines<-read.csv(file.path(project.datadirectory('lobster'),'data','maps','LFA_Lines.csv'))
		addLines(LFAlines,col='red')



############### FSRS


FSRSvesday.dat$lat<-convert.dd.dddd(FSRSvesday.dat$LATITUDE)
FSRSvesday.dat$lon<-convert.dd.dddd(FSRSvesday.dat$LONGITUDE)

LobsterMap()
points(lat~lon,FSRSvesday.dat,pch=16,col=rgb(0,0,0,0.1))


