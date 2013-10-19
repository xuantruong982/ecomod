

  # Spatial reaction-diffusion model solved via stochastic simulation using the Gillespie Alogrithm


  # set.seed(1)



  p = list()
  p$init = loadfunctions( c( "model.ssa", "model.pde" )  )
  
  # details of output storage locations
  p$outdir = project.directory( "model.ssa", "data" )
  p$runname = "test1"
  dir.create( file.path( p$outdir, p$runname), recursive=TRUE ) 
  p$outfnprefix =  file.path( p$outdir, p$runname, "out")  

  
  p = ssa.model.definition( p, ptype = "default.logistic" ) 
  p = ssa.parameters( p, ptype = "systemsize.debug" ) 
  p = ssa.parameters( p, ptype = "logistic.debug" ) 
  p = ssa.parameters( p, ptype = "simtimes.debug" ) 

  p = ssa.db( p , ptype="debug" ) # initialize state variables and propensity matrix

  

  if (ssa.method == "approximation" ) {
    # approximation simular to the tau-leaping method:: ideally only one process should be picked at a time ... 
    #   sampling from the propensities is time-expensive, so a number of picks are made in advance and then updated ..
    p$nsimultaneous.picks =  round( p$nrc * 0.01 ) # 1% update simultaneously should be /seems to be safe  ~ 1 day -> every 1-2 min or 2hrs->100days 
    p = ssa.engine.approximation( p )
  }


  if (ssa.method == "exact" ) {
    p = ssa.engine.exact( p )   # using the exact solution ... ~ 1 day -> every 25-30 minutes
  }


  if (ssa.method == "parallel.filebacked.approximation" ) {
    # no real spead up vs exact method ... most time is spent swaping memory space / attaching/detaching
    p$clusters = rep( "localhost", 2) 
    # nclu = 24
    # p$clusters = c( rep("kaos", nclu ), rep("nyx", nclu ), rep("tartarus", nclu ) )
    p$pconnectmethod = "SOCK" 
    p$nsimultaneous.picks =  round( p$nrc * 0.01 ) # 0.1% update simultaneously should be safe
    p = ssa.db( p , ptype="debug.big.matrix.filebacked" )
    p = ssa.engine.parallel.bigmemory( p )
  }

  
  if ( pmethod=="rambacked" )  {
    # no real spead up vs exact method ... most time is spent swaping memory space / attaching/detaching
    p$clusters = rep( "localhost", 2) 
    # nclu = 24
    # p$clusters = c( rep("kaos", nclu ), rep("nyx", nclu ), rep("tartarus", nclu ) )
    p$pconnectmethod = "SOCK" 
    p$nsimultaneous.picks =  round( p$nrc * 0.01 ) # 0.1% update simultaneously should be safe
    p = ssa.db( p , ptype="debug.big.matrix.rambacked" )
    p = ssa.engine.parallel.bigmemory( p )
  }


  if ( pmethod=="compare.with.PDE.solution" ) {
    # Compare with a PDE version of the model 
    require (deSolve)
    require (lattice)
    p$parmeterizations = c( "reaction", "diffusion.second.order.central") 
    p = ssa.db( p , ptype="debug" )  # update state variable to initial conditions
    A = p$X
    out <- ode.2D(  times=p$modeltimeoutput, y=as.vector(A), parms=p, dimens=c(p$nr, p$nc),
      func=single.species.2D.logistic, 
      method="lsodes", lrw=1e8,  
      atol=p$atol 
    )
   
    image.default( matrix(out[365,2:10001], nrow=100), col=heat.colors(100) )
    diagnostics(out)
    plot(p$modeltimeoutput, apply(out, 1, sum))
    image(out)
    hist( out[1,] )
    select <- c(1, 4, 10, 20, 50, 100, 200, 500 )
    image(out, xlab = "x", ylab = "y", mtext = "Test", subset = select, mfrow = c(2,4), legend =  TRUE)
  }




  plot( seq(0, t.end, length.out=n.times), apply(out[], 3, mean), pch=".", col="blue", type="b" ) 

 






