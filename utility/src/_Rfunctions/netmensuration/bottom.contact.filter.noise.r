 
bottom.contact.filter.noise = function( x, good, tdif.min, tdif.max, 
      smoothing = 0.9, filter.quants=c(0.025, 0.975), sd.multiplier=seq( 2, 1, by=-0.1 ) ) {

  ##--------------------------------
  # First, a simple high pass filter to remove noisy data (very large extreme fluctuations)
  # Then, truncation of data based upon variance of central region to permit use of more fine-scale methods 
  # to determine anomlaous data
  OinRange = c(NA, NA)

  fr = range( which(good) )
  aoi = fr[1]:fr[2]
  x$sm.seq = NA
  x$sm.seq[aoi] = interpolate.xy.robust( x[aoi, c("ts", "depth")],  probs=filter.quants, method="sequential.linear" )
  i = which( x$sm.seq != x$depth )
  if (length(i) > 0) good[i] = FALSE
  x$depth[ !good] = NA
  #if (plot.data) points(depth ~ ts, x[ good,], col="orange",pch=20, cex=0.2 )


  ## -----------------------------------
  ## A variance based-criterion for gating 
  # compute SD in the area of interest and compare with a lagged process to 
  # start from centre and move left and continue until sd of residuals begins to deviate sustantially
  # from centre to left 
  
  aoi.range = range( which( good )  )
  aoi.mid = trunc( mean( aoi.range ) ) # approximate midpoint
  aoi.min = aoi.range[1]
  aoi.max = aoi.range[2]
  aoi = aoi.min:aoi.max
  
  aoi.sd = sd( x$depth[ aoi ], na.rm=TRUE )  ## SD 
  buffer = 10 # additional points to add beyond midpoint to seed initial SD estimates
  duration = 0 
  
  for ( sm in sd.multiplier ) {
    target.sd = aoi.sd * sm
    for ( j0 in aoi.mid:aoi.min  ) {#  begin from centre to right 
      sdtest = sd(( x$depth[ (aoi.mid + buffer):j0]), na.rm=T)
      if ( is.na(sdtest) ) next()
      if ( sdtest  >= target.sd ) break()
    }
    for ( j1 in aoi.mid: aoi.max ) {  #  begin from centre to right
      sdtest =  sd(( x$depth[ (aoi.mid - buffer):j1]), na.rm=T)
      if ( is.na(sdtest) ) next()
      if ( sdtest >= target.sd ) break()
    }
    duration = as.numeric( x$timestamp[j1] - x$timestamp[j0]) 
    if ( duration > (tdif.min - 5) & duration < (tdif.max+5)  ) {  # add long tails to have enough data for analysis
      OinRange = c( x$timestamp[j0], x$timestamp[j1] )
      OinRange.indices = which( x$timestamp >= OinRange[1] &  x$timestamp <= OinRange[2] )
      OinRange.indices.not = which( x$timestamp < OinRange[1] |  x$timestamp > OinRange[2] )
      break()
    }  
  }

  if (length(OinRange.indices.not)>0) good[ OinRange.indices.not ] = FALSE

  ## ------------------------------
  #  filter data using some robust mthods that look for small-scaled noise and flag them
  
  x$depth[ !good] = NA
  x$depth.smoothed = x$depth
  x$sm.loess = x$sm.inla = x$sm.spline= NA

  x$sm.inla[aoi] = interpolate.xy.robust( x[aoi, c("ts", "depth.smoothed")],  target.r2=smoothing, probs=filter.quants, method="inla"  )
  kk = x$depth - x$sm.inla
  qnts = quantile( kk[aoi], probs=filter.quants, na.rm=TRUE ) 
  i = which(kk > qnts[2]  | kk < qnts[1] )
  if (length(i) > 0) good[i] = FALSE
  x$depth.smoothed[ !good] = NA  # i.e. sequential deletion of depths

  
  x$sm.loess[aoi] = interpolate.xy.robust( x[aoi, c("ts", "depth.smoothed")],  target.r2=smoothing, method="loess"  )
  kk = x$depth - x$sm.loess
  qnts = quantile( kk[aoi], probs=filter.quants, na.rm=TRUE ) 
  i = which(kk > qnts[2]  | kk < qnts[1] )
  if (length(i) > 0) good[i] = FALSE
  x$depth.smoothed[ !good] = NA
 

  # input to smoooth.spline must not have NA's .. use inla's predictions
  method ="sm.inla"
  if (any( !is.finite( x$sm.inla[aoi]) )) method= "sm.loess"
  x$sm.spline[aoi] =  interpolate.xy.robust( x[aoi, c("ts", method )], target.r2=smoothing, probs=filter.quants, method="smooth.spline" )
  kk = x$depth - x$sm.spline
  qnts = quantile( kk[aoi], probs=filter.quants, na.rm=TRUE ) 
  i = which(kk > qnts[2]  | kk < qnts[1] )
  if (length(i) > 0) good[i] = FALSE
  x$depth.smoothed[ !good] = NA
 

  # finalize solutions based upon priority of reliability
  x$depth[ !good ] = NA
  
  vrs = c( "sm.spline", "sm.loess", "sm.inla")
  cors = data.frame( vrs=vrs, stringsAsFactors=FALSE )
  cors$corel = 0

  for (v in 1:length(vrs)) {
    u = cor(  x[ good, vrs[v] ], x[ good, "depth"], use="pairwise.complete.obs" )
    if ( u > 0.999 ) u=0 # a degenerate solution ... 
    cors[ v, "corel"]  = u 
  }
  
  best = cors[ which.max( cors$corel ), "vrs" ]

  x$depth.smoothed = x[,best] 
  
  if (all(is.na( x$depth.smoothed[aoi]) ) )  x$depth.smoothed = x$depth # give up
  
  return( list( depth.smoothed=x$depth.smoothed, good=good, variance.method=OinRange, variance.method.indices=OinRange.indices ) )

}

