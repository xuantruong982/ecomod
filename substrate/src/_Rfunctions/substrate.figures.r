
substrate.figures = function( DS=NULL, p=NULL ) {


  if ( DS=="predictions" ) {
    p = spacetime.db( p=p, DS="bigmemory.inla.filenames" )
    P = attach.big.matrix(p$descriptorfile.P , path=p$tmp.datadir )
    pps  =  expand.grid( plons=p$plons, plats=p$plats)
    p$spatial.domain="canada.east"  # force isobaths to work in levelplot
    datarange = log( c( 5, 4000 ))
    dr = seq( datarange[1], datarange[2], length.out=100)
    oc = landmask( db="worldHires", regions=c("Canada", "US"), return.value="not.land", tag="predictions" )
    levelplot( log( P[oc,2] ) ~ plons + plats, pps[oc,], aspect="iso", main=NULL, at=dr, col.regions=rev(color.code( "seis", dr)) ,
      contour=FALSE, labels=FALSE, pretty=TRUE, xlab=NULL,ylab=NULL,scales=list(draw=FALSE),
        panel = function(x, y, subscripts, ...) {
        panel.levelplot (x, y, subscripts, aspect="iso", rez=c(1,1), ...)
        #coastline
        cl = landmask( return.value="coast.lonlat",  ylim=c(36,53), xlim=c(-72,-45)  )
        cl = lonlat2planar( data.frame( cbind(lon=cl$x, lat=cl$y)), proj.type=p$internal.crs )
        panel.xyplot( cl$plon, cl$plat, col = "steelblue", type="l", lwd=0.8 )
   #     zc = isobath.db( p=p, depths=c(200, 400 ) )  
   #     zc = lonlat2planar( zc, proj.type=p$internal.crs) 
   #     panel.xyplot( zc$plon, zc$plat, col = "steelblue", pch=".", cex=0.1 )
      }
    )
  }
  
  if ( DS=="predictions.error" ) {
    p = spacetime.db( p=p, DS="bigmemory.inla.filenames" )
    P = attach.big.matrix(p$descriptorfile.P , path=p$tmp.datadir )
    pps  =  expand.grid( plons=p$plons, plats=p$plats)
    p$spatial.domain="canada.east"  # force isobaths to work in levelplot
    datarange = log( c( 2, 50 ))
    dr = seq( datarange[1], datarange[2], length.out=100)
    oc = landmask( db="worldHires", regions=c("Canada", "US"), return.value="not.land", tag="predictions" )
    levelplot( log( P[oc,3] ) ~ plons + plats, pps[oc,], aspect="iso", main=NULL, at=dr, col.regions=rev(color.code( "seis", dr)) ,
      contour=FALSE, labels=FALSE, pretty=TRUE, xlab=NULL,ylab=NULL,scales=list(draw=FALSE),
        panel = function(x, y, subscripts, ...) {
        panel.levelplot (x, y, subscripts, aspect="iso", rez=c(1,1), ...)
        #coastline
        cl = landmask( return.value="coast.lonlat",  ylim=c(36,53), xlim=c(-72,-45)  )
        cl = lonlat2planar( data.frame( cbind(lon=cl$x, lat=cl$y)), proj.type=p$internal.crs )
        panel.xyplot( cl$plon, cl$plat, col = "steelblue", type="l", lwd=0.8 )
   #     zc = isobath.db( p=p, depths=c(200, 400 ) )  
   #     zc = lonlat2planar( zc, proj.type=p$internal.crs) 
   #     panel.xyplot( zc$plon, zc$plat, col = "steelblue", pch=".", cex=0.1 )
      }
    )
  }
  

  if ( DS=="statistics" ) {
    p = spacetime.db( p=p, DS="bigmemory.inla.filenames" )
    S = attach.big.matrix(p$descriptorfile.S , path=p$tmp.datadir ) 
    p$spatial.domain="canada.east"  # force isobaths to work in levelplot
    datarange = log( c( 5, 800 ))
    dr = seq( datarange[1], datarange[2], length.out=150)
    oc = landmask( db="worldHires", regions=c("Canada", "US"), return.value="not.land", tag="statistics" )
    levelplot( log(S[oc,3])  ~ S[oc,1] + S[oc,2] , aspect="iso", at=dr, col.regions=color.code( "seis", dr) ,
      contour=FALSE, labels=FALSE, pretty=TRUE, xlab=NULL,ylab=NULL,scales=list(draw=FALSE), cex=2,
      panel = function(x, y, subscripts, ...) {
        panel.levelplot (x, y, subscripts, aspect="iso", rez=c(5,5), ...)
        #coastline
        cl = landmask( return.value="coast.lonlat",  ylim=c(36,53), xlim=c(-72,-45) )
        cl = lonlat2planar( data.frame( cbind(lon=cl$x, lat=cl$y)), proj.type=p$internal.crs )
        panel.xyplot( cl$plon, cl$plat, col = "black", type="l", lwd=0.8 )
        zc = isobath.db( p=p, depths=c( 300 ) )  
        zc = lonlat2planar( zc, proj.type=p$internal.crs) 
        panel.xyplot( zc$plon, zc$plat, col = "gray", pch=".", cex=0.1 )
      }
    ) 
  }




}


