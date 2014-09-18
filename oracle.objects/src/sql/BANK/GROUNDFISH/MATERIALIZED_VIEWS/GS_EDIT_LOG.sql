--------------------------------------------------------
--  DDL for Materialized View GS_EDIT_LOG
--------------------------------------------------------

  CREATE MATERIALIZED VIEW "GROUNDFISH"."GS_EDIT_LOG" ("MISSION", "SETNO", "SPEC", "FSHNO", "FSEX", "FLEN", "TABLE_NAME", "FIELD_NAME", "MESSAGE_NUMBER", "CALCULATED_VALUE", "OLD_VALUE", "NEW_VALUE", "EDITOR_RESPONSE")
  ORGANIZATION HEAP PCTFREE 5 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 1048576 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" 
  BUILD IMMEDIATE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" 
  REFRESH FORCE ON DEMAND START WITH sysdate+0 NEXT (trunc(sysdate+1)+19/24)
  WITH ROWID USING DEFAULT LOCAL ROLLBACK SEGMENT
  DISABLE QUERY REWRITE
  AS SELECT "GS_EDIT_LOG"."MISSION" "MISSION","GS_EDIT_LOG"."SETNO" "SETNO","GS_EDIT_LOG"."SPEC" "SPEC","GS_EDIT_LOG"."FSHNO" "FSHNO","GS_EDIT_LOG"."FSEX" "FSEX","GS_EDIT_LOG"."FLEN" "FLEN","GS_EDIT_LOG"."TABLE_NAME" "TABLE_NAME","GS_EDIT_LOG"."FIELD_NAME" "FIELD_NAME","GS_EDIT_LOG"."MESSAGE_NUMBER" "MESSAGE_NUMBER","GS_EDIT_LOG"."CALCULATED_VALUE" "CALCULATED_VALUE","GS_EDIT_LOG"."OLD_VALUE" "OLD_VALUE","GS_EDIT_LOG"."NEW_VALUE" "NEW_VALUE","GS_EDIT_LOG"."EDITOR_RESPONSE" "EDITOR_RESPONSE" FROM "GROUNDFISH"."GS_EDIT_LOG"@GROUNDFISH.SABS "GS_EDIT_LOG";
 

  CREATE UNIQUE INDEX "GROUNDFISH"."I_SNAP$_GS_EDIT_LOG" ON "GROUNDFISH"."GS_EDIT_LOG" ("M_ROW$$") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" ;
 

   COMMENT ON MATERIALIZED VIEW "GROUNDFISH"."GS_EDIT_LOG"  IS 'snapshot table for snapshot GROUNDFISH.GS_EDIT_LOG';
  GRANT SELECT ON "GROUNDFISH"."GS_EDIT_LOG" TO PUBLIC;
 
  GRANT SELECT ON "GROUNDFISH"."GS_EDIT_LOG" TO "HUBLEYB";
 
  GRANT SELECT ON "GROUNDFISH"."GS_EDIT_LOG" TO "GREYSONP";
