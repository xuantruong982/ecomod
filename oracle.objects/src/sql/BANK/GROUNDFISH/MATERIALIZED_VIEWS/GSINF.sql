--------------------------------------------------------
--  DDL for Materialized View GSINF
--------------------------------------------------------

  CREATE MATERIALIZED VIEW "GROUNDFISH"."GSINF" ("MISSION", "SETNO", "SDATE", "TIME", "STRAT", "SLAT", "SLONG", "ELAT", "ELONG", "AREA", "DUR", "DIST", "HOWD", "SPEED", "HOWS", "DMIN", "DMAX", "WIND", "FORCE", "CURNT", "TYPE", "GEAR", "AUX", "DEPTH", "ETIME", "REMARKS", "START_DEPTH", "END_DEPTH", "SURFACE_TEMPERATURE", "BOTTOM_TEMPERATURE", "BOTTOM_SALINITY")
  ORGANIZATION HEAP PCTFREE 5 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 2097152 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" 
  BUILD IMMEDIATE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" 
  REFRESH FORCE ON DEMAND
  WITH PRIMARY KEY USING DEFAULT LOCAL ROLLBACK SEGMENT
  DISABLE QUERY REWRITE
  AS SELECT "GSINF"."MISSION" "MISSION","GSINF"."SETNO" "SETNO","GSINF"."SDATE" "SDATE","GSINF"."TIME" "TIME","GSINF"."STRAT" "STRAT","GSINF"."SLAT" "SLAT","GSINF"."SLONG" "SLONG","GSINF"."ELAT" "ELAT","GSINF"."ELONG" "ELONG","GSINF"."AREA" "AREA","GSINF"."DUR" "DUR","GSINF"."DIST" "DIST","GSINF"."HOWD" "HOWD","GSINF"."SPEED" "SPEED","GSINF"."HOWS" "HOWS","GSINF"."DMIN" "DMIN","GSINF"."DMAX" "DMAX","GSINF"."WIND" "WIND","GSINF"."FORCE" "FORCE","GSINF"."CURNT" "CURNT","GSINF"."TYPE" "TYPE","GSINF"."GEAR" "GEAR","GSINF"."AUX" "AUX","GSINF"."DEPTH" "DEPTH","GSINF"."ETIME" "ETIME","GSINF"."REMARKS" "REMARKS","GSINF"."START_DEPTH" "START_DEPTH","GSINF"."END_DEPTH" "END_DEPTH","GSINF"."SURFACE_TEMPERATURE" "SURFACE_TEMPERATURE","GSINF"."BOTTOM_TEMPERATURE" "BOTTOM_TEMPERATURE","GSINF"."BOTTOM_SALINITY" "BOTTOM_SALINITY" FROM "GROUNDFISH"."GSINF"@GROUNDFISH.SABS "GSINF";
 

   COMMENT ON MATERIALIZED VIEW "GROUNDFISH"."GSINF"  IS 'snapshot table for snapshot GROUNDFISH.GSINF';
  GRANT SELECT ON "GROUNDFISH"."GSINF" TO PUBLIC;
 
  GRANT SELECT ON "GROUNDFISH"."GSINF" TO "HUBLEYB";
