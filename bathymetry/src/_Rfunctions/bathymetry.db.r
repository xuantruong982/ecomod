
  bathymetry.db = function( p=NULL, DS=NULL, additional.data=c("snowcrab", "groundfish") ) {
   
    if ( DS =="Greenlaw_DEM") {
      # DEM created 2014
      # GCS_WGS_1984, UTM_Zone_20N; spheroid:: 6378137.0, 298.257223563
      # 322624071 "grid points
      # 50 m  horizontal resolution
      # depth range: -5053.6 to 71.48 m 
      fn = project.datadirectory( "bathymetry", "data", "bathymetry.greenlaw.rdata" )
      if (file.exists (fn) ) {
        load(fn)
        return(gdem)
      }

      require(rgdal)
      demfile.adf = project.datadirectory( "bathymetry", "data", "greenlaw_DEM", "mdem_50", "w001001.adf" )  # in ArcInfo adf format
      dem = new( "GDALReadOnlyDataset", demfile.adf )
      # gdem = asSGDF_GROD( dem, output.dim=dim(dem) ) # regrid to another dim
      # gdem = getRasterData(dem) # in matrix format
      gdem = getRasterTable(dem) # as a data frame
      names(gdem) = c("plon", "plat", "z")
      gdem = gdem[ is.finite( gdem$z ) , ]
#     p$depthrange = c(-5000, 1000 )  # inverse to chs convention
#      gdem = gdem[ which( gdem$z < p$depthrange[2] ) , ] # limit to 3000m depths due to file size
#      gdem = gdem[ which( gdem$z > p$depthrange[1] ) , ] # limit to 3000m depths due to file size
      gdem = planar2lonlat( gdem, "utm20", planar.coord.scale=1 )  # plon,plat already in meters
      gdem = gdem[, c("lon", "lat", "z") ]
      save( gdem, file=project.datadirectory( "bathymetry", "data", "bathymetry.greenlaw.rdata"), compress=TRUE )
    }


    if (  DS %in% c("z.lonlat.rawdata.redo", "z.lonlat.rawdata") ) {
			# raw data minimally modified all concatenated
      
      datadir = project.datadirectory("bathymetry", "data" )
			dir.create( datadir, showWarnings=F, recursive=T )
      
      fn = file.path( datadir, "bathymetry.canada.east.lonlat.rawdata.rdata" )
      
      if (DS =="z.lonlat.rawdata" ) {
        load( fn)
        return( bathy )
      }
 
			# this data was obtained from CHS via David Greenberg in 2004; range = -5467.020, 383.153; n=28,142,338
      fn_nwa = file.path( datadir, "nwa.chs15sec.xyz.xz") # xz compressed file
      chs15 = read.table( xzfile( fn_nwa ) ) 
      names(chs15) = c("lon", "lat", "z")
      # chs15 = chs15[ which( chs15$z < 1000 ) , ] 
      chs15$z = - chs15$z  

      # Michelle Greenlaw's DEM from 2014
      # range -3000 to 71.5 m; n=155,241,029 .. but mostly interpolated 
      gdem = bathymetry.db( DS="Greenlaw_DEM" )
      gdem$z = - gdem$z

      bathy = rbind( chs15, gdem )
      rm(gdem, chs15) ; gc()

	 		# chs and others above use chs depth convention: "-" is below sea level,
			# in snowcrab and groundfish convention "-" is above sea level
			# retain postive values at this stage to help contouring near coastlines

			if ( "snowcrab" %in% additional.data ) {
        # range from 23.8 to 408 m below sea level ... these have dropped the "-" for below sea level; n=5925 (in 2014)
			  p0 = p  # loadfunctions "snowcrab" will overwrite p .. store a copy and return it to original state below	
        loadfunctions( "snowcrab")
        sc = snowcrab.db("set.clean")[,c("lon", "lat", "z") ]
				sc = sc [ which (is.finite( rowSums( sc ) ) ) ,]
				j = which(duplicated(sc))
        if (length (j) > 0 ) sc = sc[-j,]
        bathy = rbind( bathy, sc )
			  p = p0
        rm (sc); gc()
         
        #sc$lon = round(sc$lon,1)
        #sc$lat = round(sc$lat,1)
        # contourplot( z~lon+lat, sc, cuts=10, labels=F )
      }
    	
      if ( "groundfish" %in% additional.data ) {
        # n=13031; range = 0 to 1054
				loadfunctions("groundfish")
        warning( "Should use bottom contact estimates as a priority ?" )
				gf = groundfish.db( "set.base" )[, c("lon","lat", "sdepth") ]
				gf = gf[ which( is.finite(rowSums(gf) ) ) ,]
        names(gf) = c("lon", "lat", "z")
				j = which(duplicated(gf))
        if (length (j) > 0 ) gf = gf[-j,]
 				bathy = rbind( bathy, gf )
        rm (gf); gc()
        
        #gf$lon = round(gf$lon,1)
        #gf$lat = round(gf$lat,1)
        #contourplot( z~lon+lat, gf, cuts=10, labels=F )

			}

      bathy = bathy[ - which(duplicated( bathy)),]

      write.table( bathy, file=p$bathymetry.xyz, col.names=F, quote=F, row.names=F)
      save( bathy, file=fn, compress=T )
      return ( fn )
    }

 
    if ( DS %in% c("z.lonlat.discretized", "z.lonlat.discretized.redo" )) {
          
      datadir = project.datadirectory("bathymetry", "data" )
			dir.create( datadir, showWarnings=F, recursive=T )
      fn = file.path( datadir, "bathymetry.canada.east.lonlat.discretized.rdata" )
      
      if (DS =="z.lonlat.discretized" ) {
        load( fn)
        return( bathy )
      }

      B = bathymetry.db ( p=p, DS="z.lonlat.rawdata" ) # larger
    
      # gridding here needs to have a higher resolution than the internal representation 
      # as it is still being treated as "rawdata": so use CHS standard of (p$dres=15 arc second)/3 = 5 arc seconds 
      
      rlon = range(B$lon, na.rm=TRUE)
      rlat = range(B$lat, na.rm=TRUE)
      
      glon = seq( rlon[1], rlon[2], by=p$dres ) 
      glat = seq( rlat[1], rlat[2], by=p$dres )

      B$lon = grid.internal( B$lon, glon )
      B$lat = grid.internal( B$lat, glat )
      B = B[ which( is.finite( rowSums(B) )), ]

      bathy = block.spatial ( xyz=B[,c("lon", "lat","z")], function.block=block.mean )

      save( bathy, file=fn, compress=TRUE)
      return(fn)
    }

    if ( DS %in% c("prepare.intermediate.files.for.dZ.ddZ", "Z.gridded", "dZ.gridded", "ddZ.gridded" ) ) {
			
			tmpdir  = tempdir()
			outdir = project.datadirectory("bathymetry", "interpolated" )
			dir.create( outdir, showWarnings=F, recursive=T )
 
			fn.interp.z = file.path( outdir,  paste(  p$spatial.domain, "Z.interpolated.xyz", sep=".") )
			fn.interp.dz = file.path( outdir,  paste( p$spatial.domain, "dZ.interpolated.xyz", sep=".") )
			fn.interp.ddz = file.path( outdir,  paste( p$spatial.domain, "ddZ.interpolated.xyz", sep=".") )
			
			if (DS=="Z.gridded") { 
				Z = read.table( fn.interp.z )
				names( Z ) = c("lon", "lat", "z")
				return( Z )
			} 
			if (DS=="dZ.gridded") { 
				dZ = read.table( fn.interp.dz )
				names( dZ ) = c("lon", "lat", "dZ")
				return( dZ )
			} 
			if (DS=="ddZ.gridded") { 
				ddZ = read.table( fn.interp.ddz )
				names( ddZ ) = c("lon", "lat", "ddZ")
				return( ddZ )
			} 

			append = "-O -K"
			b.res = "-I10s"  # use full resolution of bathymetry data
			bathy.tension = "-T0.75"  # large steepness :: 0.35+ for steep; 0.25 for smooth
			blocked = file.path(tmpdir, make.random.string(".gmt.blocked"))
			grids  = file.path(tmpdir, make.random.string( ".gmt.depths"))
			z.dds = file.path(tmpdir, make.random.string( ".gmt.z.dds"))
			z.d2ds2 = file.path(tmpdir, make.random.string( ".gmt.z.d2ds2"))
      
      if ( !file.exists( p$bathymetry.bin )) {
        # a GMT binary file of bathymetry .. currently, only the "canada.east" domain 
        # is all that is required/available
        cmd( "gmtconvert -bo", p$bathymetry.xyz, ">", p$bathymetry.bin )
      }

			cmd( "blockmean", p$bathymetry.bin, "-bi3 -bo", p$region, b.res, ">", blocked )  
			cmd( "surface", blocked, "-bi3", p$region, b.res, bathy.tension, paste("-G", grids, sep="") )
			cmd( "grdmath -M", grids, "DDX ABS", grids, "DDY ABS ADD 0.5 MUL =", z.dds )
			cmd( "grdmath -M -N", grids, "CURV =", z.d2ds2 )
			cmd( "grd2xyz", grids, ">", fn.interp.z )  # the scalar in meter 
			cmd( "grd2xyz", z.dds, ">", fn.interp.dz )  # the scalar in meter / meter
			cmd( "grd2xyz", z.d2ds2, ">", fn.interp.ddz )  # the scalar m / m^2

			remove.files( c(blocked, grids, z.dds, z.d2ds2  ) )
			return ("intermediate files completed")
		}
   
		if ( DS %in% c( "Z.redo", "Z.lonlat", "Z.lonlat.grid", "Z.planar", "Z.planar.grid" ) ) { 

			outdir = project.datadirectory("bathymetry", "interpolated" )
			dir.create( outdir, showWarnings=F, recursive=T )
		
			fn.lonlat = file.path( outdir, paste( p$spatial.domain, "Z.interpolated.lonlat.rdata", sep=".") )
      fn.lonlat.grid = file.path( outdir, paste( p$spatial.domain, "Z.interpolated.lonlat.grid.rdata", sep=".") )
      fn.planar = file.path( outdir, paste(p$spatial.domain, "Z.interpolated.planar.rdata", sep=".") )
      fn.planar.grid = file.path( outdir, paste(p$spatial.domain, "Z.interpolated.planar.grid.rdata", sep=".") )

      if ( DS == "Z.lonlat" ) {
        load( fn.lonlat )
        return( Z )
      }
      if ( DS == "Z.lonlat.grid" ) {   # not used ... drop?
        load( fn.lonlat.grid )
        return( Z )
      }
      if ( DS == "Z.planar" ) {
        load( fn.planar )
        return( Z )
      }
      if ( DS == "Z.planar.grid" ) {    # used by map.substrate
        load( fn.planar.grid )
        return( Z )
      }
  
      Z0 = Z = bathymetry.db( p, DS="Z.gridded" )
      Z$lon = grid.internal( Z$lon, p$lons )
      Z$lat = grid.internal( Z$lat, p$lats )
      Z = block.spatial ( xyz=Z, function.block=block.mean ) 
     
      # create Z in lonlat xyz dataframe format
      save(Z, file=fn.lonlat, compress=T)  

      # create Z in lonlat grid/matrix format
      Z = xyz2grid(Z, p$lons, p$lats)  # using R
      save(Z, file=fn.lonlat.grid, compress=T) # matrix/grid format
      
      # ---- convert to planar coords ...
      # must use the interpolated grid to get even higher resolution "data" with extrapolation on edges 
      Z = lonlat2planar( Z0, proj.type= p$internal.projection )   
      Z = Z[, c("plon", "plat", "z")]
      Z$plon = grid.internal( Z$plon, p$plons )
      Z$plat = grid.internal( Z$plat, p$plats )
  
      gc()
      Z = block.spatial ( xyz=Z, function.block=block.mean ) 
      
      # create Z in planar xyz format 
      save( Z, file=fn.planar, compress=T ) 

      # create Z in matrix/grid format 
      gc()
      Z = xyz2grid( Z, p$plons, p$plats)
      save( Z, file=fn.planar.grid, compress=T ) 
    
      return ("interpolated depths completed")

		} 
    
		if ( DS %in% c( "dZ.redo", "dZ.lonlat", "dZ.lonlat.grid", "dZ.planar", "dZ.planar.grid" ) ) { 
  
			outdir = file.path( project.datadirectory("bathymetry"), "interpolated" )
			dir.create( outdir, showWarnings=F, recursive=T )
	    
      fn.lonlat = file.path( outdir, paste( p$spatial.domain, "dZ.interpolated.lonlat.rdata", sep=".")  )
      fn.lonlat.grid = file.path( outdir, paste( p$spatial.domain, "dZ.interpolated.lonlat.grid.rdata", sep=".")  )
      fn.planar = file.path( outdir, paste( p$spatial.domain, "dZ.interpolated.planar.rdata", sep=".")  )
      fn.planar.grid = file.path( outdir, paste( p$spatial.domain, "dZ.interpolated.planar.grid.rdata", sep=".")  )

      if ( DS == "dZ.lonlat" ) {
        load( fn.lonlat )
        return( dZ )
      }
      if ( DS == "dZ.lonlat.grid" ) {
        load( fn.lonlat.grid )
        return( dZ )
      }
      if ( DS == "dZ.planar" ) {
        load( fn.planar )
        return( dZ )
      }
      if ( DS == "dZ.planar.grid" ) {
        load( fn.planar.grid )
        return( dZ )
      }
  
      dZ0 = bathymetry.db( p, DS="dZ.gridded" )
      dZ0$dZ = log( abs( dZ0$dZ ) )

      dZ = dZ0
      dZ$lon = grid.internal( dZ$lon, p$lons )
      dZ$lat = grid.internal( dZ$lat, p$lats )
      dZ = block.spatial ( xyz=dZ, function.block=block.mean ) 
     
      # create dZ in lonlat xyz dataframe format
      save(dZ, file=fn.lonlat, compress=T)  

      # create dZ in lonlat grid/matrix format
      dZ = xyz2grid(dZ, p$lons, p$lats)
      save(dZ, file=fn.lonlat.grid, compress=T) # matrix/grid format
      
      
      # ---- convert to planar coords ...
      # must use the interpolated grid to get even higher resolution "data" with extrpolation on edges 
      dZ = lonlat2planar( dZ0, proj.type= p$internal.projection )  # utm20, WGS84 (snowcrab geoid) 
      dZ = dZ[, c("plon", "plat", "dZ")]
      dZ$plon = grid.internal( dZ$plon, p$plons )
      dZ$plat = grid.internal( dZ$plat, p$plats )
  
      gc()
      dZ = block.spatial ( xyz=dZ, function.block=block.mean ) 
      
      # create dZ in planar xyz format 
      save( dZ, file=fn.planar, compress=T ) 

      # create dZ in matrix/grid format 
      gc()
      dZ = xyz2grid( dZ, p$plons, p$plats)
      save( dZ, file=fn.planar.grid, compress=T ) 
      
      return ("interpolated files complete, load via another call for the saved files")
    }
    
    if ( DS %in% c( "ddZ.redo", "ddZ.lonlat", "ddZ.planar", "ddZ.lonlat.grid", "ddZ.planar.grid"  ) ) { 
     	outdir = file.path( project.datadirectory("bathymetry"), "interpolated" )
			dir.create( outdir, showWarnings=F, recursive=T )
	  
      fn.lonlat = file.path( outdir,  paste( p$spatial.domain, "ddZ.interpolated.lonlat.rdata", sep=".")  )
      fn.lonlat.grid = file.path( outdir,  paste( p$spatial.domain, "ddZ.interpolated.lonlat.grid.rdata", sep=".")  )
      fn.planar = file.path( outdir,  paste( p$spatial.domain, "ddZ.interpolated.planar.rdata", sep=".")  )
      fn.planar.grid = file.path( outdir,  paste( p$spatial.domain, "ddZ.interpolated.planar.grid.rdata", sep=".") )

      if ( DS == "ddZ.lonlat" ) {
        load( fn.lonlat )
        return( ddZ )
      }
      if ( DS == "ddZ.lonlat.grid" ) {
        load( fn.lonlat.grid )
        return( ddZ )
      }
      if ( DS == "ddZ.planar" ) {
        load( fn.planar )
        return( ddZ )
      }
      if ( DS == "ddZ.planar.grid" ) {
        load( fn.planar.grid )
        return( ddZ )
      }

      ddZ0 = bathymetry.db( p, DS="ddZ.gridded" )
      ddZ0$ddZ = log( abs( ddZ0$ddZ ) )

      # ----- convert to lonlats blocked
      ddZ = ddZ0
      ddZ$lon = grid.internal( ddZ$lon, p$lons )
      ddZ$lat = grid.internal( ddZ$lat, p$lats )
      ddZ = block.spatial ( xyz=ddZ, function.block=block.mean ) 
      
      # lonlat xyz dataframe format
      save(ddZ, file=fn.lonlat, compress=T)  

      ddZ = xyz2grid(ddZ, p$lons, p$lats)
      save(ddZ, file=fn.lonlat.grid, compress=T) # matrix/grid format
          
      # ---- convert to planar coords ...
      # must use the interpolated grid to get even higher resolution "data" with extrpolation on edges 
      ddZ = ddZ0
      ddZ = lonlat2planar( ddZ0, proj.type= p$internal.projection )  # utm20, WGS84 (snowcrab geoid) 
      ddZ = ddZ[, c("plon", "plat", "ddZ")]
      gc()
      ddZ$plon = grid.internal( ddZ$plon, p$plons )
      ddZ$plat = grid.internal( ddZ$plat, p$plats )
   
      ddZ = block.spatial ( xyz=ddZ, function.block=block.mean ) 
      
      # create ddZ in planar xyz format 
      save( ddZ, file=fn.planar, compress=T ) 

      gc()
      ddZ = xyz2grid(ddZ, p$plons, p$plats)
      save( ddZ, file=fn.planar.grid, compress=T ) 
      
      return ("interpolated files complete, load via another call for the saved files")
    }


    if (DS %in% c("baseline", "baseline.redo") ) {
      # form prediction surface in planar coords for SS snowcrab area
      outfile =  file.path( project.datadirectory("bathymetry"), "interpolated", paste( p$spatial.domain, "baseline.interpolated.rdata" , sep=".") )

      if ( DS=="baseline" ) {
        load( outfile )
        return (Z)
      }

	
      # ---------
			
      if ( p$spatial.domain == "canada.east" ) {
     		p = spatial.parameters( type=p$spatial.domain, p=p )
        Z = bathymetry.db( p, DS="Z.planar" )
				Z = Z[ which(Z$z < 1000 & Z$z > 0 ) ,] 
			}

      # ---------
		
			if ( p$spatial.domain =="SSE" ) {
        Z = bathymetry.db( p, DS="Z.planar" )
  		  Z = Z[ which(Z$z < 800 & Z$z > 0 ) ,] 
		  }
		
      if ( p$spatial.domain =="SSE" ) {
        Z = bathymetry.db( p, DS="Z.planar" )
  		  Z = Z[ which(Z$z < 2000 & Z$z > 0 ) ,] 
		  }

     
      # ---------

			if ( p$spatial.domain == "snowcrab" ) {
 
        # NOTE::: snowcrab baseline == SSE baseline, except it is a subset 
        # begin with the SSE conditions 
        p0 = p 
        p = spatial.parameters( type="SSE", p=p )
        Z = bathymetry.db( p, DS="baseline" )
        p = p0

        kk = which( Z$z < 350 & Z$z > 10  )
	  	  if (length( kk) > 0) Z = Z[ kk, ]
        jj = filter.region.polygon( Z[,c(1:2)], region="cfaall", planar=T,  proj.type=p$internal.projection ) 
        if (length( jj) > 0) Z = Z[ jj, ]
        # filter out area 4X   
        corners = data.frame( cbind( 
          lon = c(-63, -65.5, -56.8, -66.3 ),  
          lat = c( 44.75, 43.8, 47.5, 42.8 )  
        ) )
        corners = lonlat2planar( corners, proj.type=p$internal.projection )
        dd1 = which( Z$plon < corners$plon[1] & Z$plat > corners$plat[1]  ) 
        if (length( dd1) > 0) Z = Z[- dd1, ]
        dd2 = which( Z$plon < corners$plon[2] & Z$plat > corners$plat[2]  ) 
        if (length( dd2) > 0) Z = Z[- dd2, ]
        dd3 = which( Z$plon > corners$plon[3] ) # east lim
        if (length( dd3) > 0) Z = Z[- dd3, ]
        dd4 = which( Z$plon < corners$plon[4] )  #west lim
        if (length( dd4) > 0) Z = Z[- dd4, ]
        dd5 = which( Z$plat > corners$plat[3]  ) # north lim
        if (length( dd5) > 0) Z = Z[- dd5, ]
        dd6 = which( Z$plat < corners$plat[4]  )  #south lim 
        if (length( dd6) > 0) Z = Z[- dd6, ]
         
      }
			
      # require (lattice); levelplot( z~plon+plat, data=Z, aspect="iso")
			
      save (Z, file=outfile, compress=T )

			return( paste( "Baseline data file completed:", outfile )  )
    }
 

    if (DS %in% c( "complete", "complete.redo") ) {
      # form prediction surface in planar coords for SS snowcrab area
      
      outfile =  file.path( project.datadirectory("bathymetry"), "interpolated", paste( p$spatial.domain, "complete.rdata" , sep=".") )
      if (p$spatial.domain == "snowcrab" ) outfile=gsub( p$spatial.domain, "SSE", outfile )

      if ( DS=="complete" ) {
        if (file.exists( outfile) ) load( outfile )
        if (p$spatial.domain == "snowcrab" ) {
          id = bathymetry.db( DS="lookuptable.sse.snowcrab" )
          Z = Z[id,]
        }
        return (Z )
      }
   
      Z = bathymetry.db( p, DS="Z.planar" )
      dZ = bathymetry.db( p, DS="dZ.planar" )
      ddZ = bathymetry.db( p, DS="ddZ.planar" )
      Z = merge( Z, dZ, by=c("plon", "plat"), sort=FALSE )
      Z = merge( Z, ddZ, by=c("plon", "plat"), sort=FALSE )
      save (Z, file=outfile, compress=T )

			return( paste( "Completed:", outfile )  )
    }
 

# ----------------
	

    if (DS %in% c("lookuptable.sse.snowcrab.redo", "lookuptable.sse.snowcrab" )) { 
      # create a lookuptable for SSE -> snowcrab domains
      # both share the same initial domains + resolutions
      fn = file.path( project.datadirectory("bathymetry"), "interpolated", "sse.snowcrab.lookup.rdata") 
      if (DS== "lookuptable.sse.snowcrab" ) { 
        if (file.exists(fn)) load(fn)
        return(id)
      }
      zSSE = bathymetry.db ( p=spatial.parameters( type="SSE" ), DS="baseline" )
      zSSE$id.sse = 1:nrow(zSSE)
      
      zsc  = bathymetry.db ( p=spatial.parameters( type="snowcrab" ), DS="baseline" )
      zsc$id.sc = 1:nrow(zsc)

      z = merge( zSSE, zsc, by =c("plon", "plat"), all.x=T, all.y=T, sort=F )
      ii = which(is.finite(z$id.sc ) & is.finite(z$id.sse )  )
      if (length(ii) != nrow(zsc) ) stop("Error in sse-snowcrab lookup table size")
      id = sort( z$id.sse[ ii] )
      # oo= zSSE[id,] 

      save( id, file=fn, compress=T )
      return(fn)
    }     

    if (DS %in% "bigmemory.inla" ) { 

      # create file backed bigmemory objects

      p$tmp.datadir = file.path( p$project.root, "tmp" )
      if( !file.exists(p$tmp.datadir)) dir.create( p$tmp.datadir, recursive=TRUE, showWarnings=FALSE )

      # input data stored as a bigmatrix to permit operations with min memory usage
      p$backingfile.W = "input.bigmatrix.tmp"
      p$descriptorfile.W = "input.bigmatrix.desc"

      p$backingfile.P = "predictions.bigmatrix.tmp"
      p$descriptorfile.P = "predictions.bigmatrix.desc"

      p$backingfile.S = "statistics.bigmatrix.tmp"
      p$descriptorfile.S = "statstics.bigmatrix.desc"
     
#      p$backingfile.Pmat = "predictions_mat.bigmatrix.tmp"
#      p$descriptorfile.Pmat = "predictions_mat.bigmatrix.desc"

     
      # ------------------------------
      # load raw data .. slow so only if needed
      if (p$reload.rawdata) {
        # can use the raw data but data density is too clustered .. 
        # CPU speed / ram requirements are still to high, Jae: 2015
        # B = bathymetry.db ( p=p, DS="z.lonlat.rawdata" )  
        # use the discretized version as it is a bit more functional
        B = bathymetry.db ( p=p, DS="z.lonlat.discretized" )  
        
        B = lonlat2planar( B, proj.type=p$internal.projection ) 
        # 6 digits required to get complete distribution of diffs:  
        # hist( log(diff( sort( unique( B$plat)) )) )
 
        rlon = range(B$plon, na.rm=TRUE)
        rlat = range(B$plat, na.rm=TRUE)
        
        glon = seq( rlon[1], rlon[2], by=p$pres/5 )
        glat = seq( rlat[1], rlat[2], by=p$pres/5 )

        B$plon = grid.internal( B$plon, glon )
        B$plat = grid.internal( B$plat, glat )
        B = B[ which( is.finite( rowSums(B) )), ]

        B = block.spatial ( xyz=B[,c("plon", "plat", "z")], function.block=block.mean )

        W = filebacked.big.matrix( nrow=nrow(B), ncol=3, type="double", dimnames=NULL, separated=FALSE, 
          backingpath=p$tmp.datadir, backingfile=p$backingfile.W, descriptorfile=p$descriptorfile.W ) 
        W[] = as.matrix( B[,c("plon", "plat", "z")] )
        # levelplot( z~plon+plat, W, xlab='', ylab='', col.regions=colorRampPalette(c( "white", "darkblue", "black"), space = "Lab")(n), scale=list(draw=FALSE), aspect="iso", cuts=n )
      }

      if (p$reset.outputfiles ) {
        # ------------------------------
        # prediction indices in matrix structure 
        #  Pmat = filebacked.big.matrix( ncol=p$nplats, nrow=p$nplons, type="integer", dimnames=NULL, separated=FALSE, 
        #   backingpath=p$tmp.datadir, backingfile=p$backingfile.Pmat, descriptorfile=p$descriptorfile.Pmat ) 
        # Pmat[] = c(1:(p$nplons*p$nplats))
          # col=lat=ydir, row=lon=xdir is format of matrix image, etc
          # Pmat = matrix( 1:(p$nplons*p$nplats), ncol=p$nplats, nrow=p$nplons ) 
          # P = as.vector(Pmat)
          # Pmat[ cbind( round(( P$plon - p$plons[1]) / p$pres ) + 1, round(( P$plat - p$plats[1] ) / p$pres ) + 1 ) ] = P$var


        # ------------------------------
        # predictions storage matrix (discretized) 
        P = filebacked.big.matrix( nrow=p$nplon * p$nplat, ncol=3, type="double", init=0, dimnames=NULL, separated=FALSE, 
          backingpath=p$tmp.datadir, backingfile=p$backingfile.P, descriptorfile=p$descriptorfile.P ) 

        # ------------------------------
        # statistics storage matrix ( aggregation window, AW )
        sbbox = list( plats = seq( p$corners$plat[1], p$corners$plat[2], by=p$dist.mwin ), 
                        plons = seq( p$corners$plon[1], p$corners$plon[2], by=p$dist.mwin )
        )
        AW = expand.grid( sbbox$plons, sbbox$plats )
        attr( AW , "out.attrs") = NULL
        names( AW ) = c("plon", "plat")
        statsvars = c("range", "range.sd", "spatial.error", "observation.error") 
        nstats = length( statsvars ) 
        S = filebacked.big.matrix( nrow=nrow(AW), ncol=nstats+2, type="double", init=0, dimnames=NULL, separated=FALSE, 
          backingpath=p$tmp.datadir, backingfile=p$backingfile.S, descriptorfile=p$descriptorfile.S ) 
        S[,1] = AW[,1]
        S[,2] = AW[,2]
      
      }

      S = attach.big.matrix(p$descriptorfile.S , path=p$tmp.datadir ) 
      p$nS = nrow(S) # nS=1735488
      
      return(p)
    }
   
# ----------------
    
    if (DS %in% "bigmemory.inla.cleanup" ) { 
      
      # load bigmemory data objects pointers
      p$reload.rawdata=FALSE 
      p$reset.outputfiles=FALSE
      p = bathymetry.db( p=p, DS="bigmemory.inla" )

      todelete = file.path( p$tmp.datadir,
        c( p$backingfile.P, p$descriptorfile.P, 
           p$backingfile.S, p$descriptorfile.S, 
           p$backingfile.W, p$descriptorfile.W 
      )) 
      
      for (fn in todelete ) file.remove(fn) 
      
      return( todelete )

    }

    # -----------------

    if (DS %in% c( "statistics", "statistics.redo", "predictions", "predictions.redo" )  ) { 
      
      # load bigmemory data objects pointers
      p$reload.rawdata=FALSE 
      p$reset.outputfiles=FALSE
      p = bathymetry.db( p=p, DS="bigmemory.inla" )

      fn.P =  file.path( p$project.root, "data", p$spatial.domain, "predictions.rdata" ) 
      fn.S =  file.path( p$project.root, "data", p$spatial.domain, "statistics.rdata" ) 

      if ( DS=="statistics" ) {
        stats = NULL
        if (file.exists( fn.S) ) load( fn.S )
        return( stats ) 
      }
 
      if ( DS=="predictions" ) {
        preds = NULL
        if (file.exists( fn.P ) ) load( fn.P )
        return( preds ) 
      }

      if ( DS =="statsitics.redo" ) {
        sss = attach.big.matrix(p$descriptorfile.S, path=p$tmp.datadir)  # statistical outputs
               
        sbbox = list( plats = seq( p$corners$plat[1], p$corners$plat[2], by=p$dist.mwin ), 
                      plons = seq( p$corners$plon[1], p$corners$plon[2], by=p$dist.mwin )
        )
        
        snr = length(sbbox$plons)
        snc = length(sbbox$plats)
        
        stats = list(
          bbox = sbbox,
          range = matrix( data=S[,1], nrow=snr, ncol=snc ) ,
          range.sd = matrix( data=S[,2], nrow=snr, ncol=snc ) ,
          var.spatial = matrix( data=S[,3], nrow=snr, ncol=snc ) ,
          var.observation = matrix( data=S[,4], nrow=snr, ncol=snc )
### add some more here ... curvature / slope, etc
        )  

        save( stats,  file=fn.S, compress=TRUE )
        return( fn.S)
      }
   
      if ( DS =="predictions.redo" ) {
        ppp = attach.big.matrix(p$descriptorfile.P, path=p$tmp.datadir)  # predictions

        # tidy up cases where there are no data:
        means = ppp[,2] 
        nd = which( ppp[,1]==0 )
        if (length(nd)>0) means[nd] = NA # no data .. no mean
        
        variance = ppp[,3] 
        nd = which( ppp[,1] <= 1 )
        if (length(nd)>0) variance[nd] = NA

        ### need to define domain
        # inside = inout( pG$lattice$loc, full.domain$loc ) 
        # means[ !inside ] = NA
        # variance[ !inside ] = NA
         
        plotdata=FALSE
          if (plotdata) {
            coordsp = expand.grid( plons=p$plons, plats=p$plats )
            lv = levelplot( log(  means ) ~ plons+plats, coordsp , xlab='', ylab='', col.regions=rev(sequential_hcl(100)), scale=list(draw=FALSE), aspect="iso" )
            print(lv)
          }

        preds = list( 
          bbox = list( plons=p$plons, plats=p$plats ),
          m = matrix( data=means, nrow=p$nplons, ncol=p$nplats ) ,
          v = matrix( data=variance, nrow=p$nplons, ncol=p$nplats )
        )
        save( preds, file=fn.P, compress=TRUE )
        return(fn.P)
      } 
    }

    if (DS %in% c( "parameters.inla" )  ) { 

      p$init.files = loadfunctions( c( "spacetime", "utility", "parallel", "bathymetry" ) )
 
      p$libs = RLibrary( 
        "rgdal", "lattice", "parallel", "INLA", "geosphere", "sp", "raster", "colorspace" ,
        "bigmemory.sri", "synchronicity", "bigmemory", "biganalytics", "bigtabulate", "bigalgebra")
      
      p$project.name = "bathymetry"
      p$project.root = project.datadirectory( p$project.name )
      
      p = spatial.parameters( type="canada.east.highres", p=p ) ## highres = 0.5 km discretization
     
      p$dist.max = 25 # length scale (km) of local analysis .. for acceptance into the local analysis/model
      p$dist.mwin = 1 # resolution (km) of data aggregation (i.e. generation of the ** statistics ** )
      p$dist.pred = 0.95 # % of dist.max where **predictions** are retained (to remove edge effects)
     
      ## this changes with resolution: at p$pres=0.25 and a p$dist.max=25: the max count expected is 40000
      p$n.min = 100
      p$n.max = 15000 # numerical time/memory constraint

      p$inla.mesh.offset   = p$pres * c( 5, 25 ) # km
      p$inla.mesh.max.edge = p$pres * c( 5, 25 ) # km
      p$inla.mesh.cutoff   = p$pres * c( 2.5, 25 ) # km 

      p$inla.alpha = 2 # bessel function curviness
      p$inla.nsamples = 5000 # posterior similations 
      p$expected.range = 50 # km , with dependent var on log scale
      p$expected.sigma = 1e-1  # spatial standard deviation (partial sill) .. on log scale

      p$Yoffset = 1000 ## data range is from -383 to 5467 m .. shift all to positive valued as this will operate on the logs

      p$predict.in.one.go = FALSE # use false, one go is very very slow and a resource expensive method
      p$predict.type = "response"  # same scale as observations 
      # p$predict.type = "latent.spatial.field" # random field centered to zero
        
      return(p)

    }

  }  






