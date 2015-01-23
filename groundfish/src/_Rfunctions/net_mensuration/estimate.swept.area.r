estimate.swept.area = function( gs=NULL, x=NULL, getnames=FALSE, threshold.cv=10  ){

  if (getnames) return( c("names, of variables") )
  
  gs$sweptarea.mean = NA
  gs$depth.mean = NA
  gs$depth.sd = NA
  gs$wingspread.mean = NA
  gs$wingspread.sd = NA

  # debug
  if (FALSE){
   
  
  }
  bc = which( x$timestamp >=gs$bc0.datetime & x$timestamp <= gs$bc1.datetime ) 
  x = x[bc,]
  x = x[order( x$timestamp ) ,]
  
  ##--------------------------------
  # timestamps have frequencies higher than 1 sec .. duplciates are created and this can pose a problem
  x$ts = difftime( x$timestamp, min(x$timestamp), units="secs" )
  x$lon.sm = NA  # interpolated locations
  x$lat.sm = NA  # interpolated locations
  x$time.increment = NA
  ndat = nrow(x)
  
  if (debug) {
    plot (latitude~longitude, data=x, pch=20, cex=.1)
    plot (depth~timestamp, data=x, pch=20, cex=.1)
    plot (depth~ts, data=x, pch=20, cex=.1)
    
  }

  mean.velocity.m.per.sec = gs$speed * 1.852  * 1000 / 3600
  x$distance = x$ts * mean.velocity.m.per.sec 
  
  nupos = sqrt( length( unique( x$longitude)) ^2  + length(unique(x$latitude))^2)
  
  x$distance.sm = NA
  if (nupos > 30) { 
    # interpolated.using.velocity" .. for older data with poor GPS resolution
    # use ship velocity and distance of tow estimated on board to compute incremental distance, assuming a straight line tow
    nn = abs( diff( x$ts ) )
    dd = median( nn[nn>0], na.rm=TRUE )
    x$t = jitter( x$t, amount=dd / 20) # add noise as inla seems unhappy with duplicates in x?
    uu = smooth.spline( x=x$ts, y=x$longitude, keep.data=FALSE) 
    x$lon.sm = uu$y
    vv = smooth.spline( x=x$ts, y=x$latitude, keep.data=FALSE) 
    x$lat.sm = vv$y
    pos = c("lon.sm", "lat.sm")
    dh =  rep(0, ndat-1)
    for( j in 1:(ndat-1) ) dh[j] = geodist( point=x[j,pos], locations=x[j+1,pos], method="vincenty" ) * 1000 # m .. slower but high res
    # dh = zapsmall( dh, 1e-9 )
    x$distance.sm = c( 0, cumsum( dh ) )
  }

  # doorspread
  
  doorspread.median = median(x$doorspread, na.rm=T)
  doorspread.sd = sd(x$doorspread, na.rm=T)
  
  if ( doorspread.sd / doorspread.median > threshold.cv ) {
    if (all( !is.finite(x$distance.sm)) ) {
      SA.door = doorspread.median * max( x$distance.sm, na.rm=TRUE )
    } else {
      SA.door = doorspread.median * max( x$distance, na.rm=TRUE )
    }
  } else {
    # piece-wise integration here.
    #partial.area =  delta.distance * mean.doorspreads
    #out$surfacearea = sum( partial.area )  # km^2
    #out$surfacearea = abs(  out$surfacearea )
    
  }
  
  
  # wingspread .. repeat as above
  
  wingspread.median = median(x$wingspread, na.rm=T)
  wingspread.sd = sd(x$wingspread, na.rm=T)
  
  if ( wingspread.sd / wingspread.median > threshold.cv ) {
    if (all( !is.finite(x$distance.sm)) ) {
      SA.door = wingspread.median * max( x$distance.sm, na.rm=TRUE )
    } else {
      SA.door = wingspread.median * max( x$distance, na.rm=TRUE )
    }
  } else {
    # piece-wise integration here.
    #partial.area =  delta.distance * mean.doorspreads
    #out$surfacearea = sum( partial.area )  # km^2
    #out$surfacearea = abs(  out$surfacearea )
    
  }
  
  
  
  
  return( gs)

}

