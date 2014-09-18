--------------------------------------------------------
--  DDL for Table NFRAW_LFS
--------------------------------------------------------

  CREATE TABLE "GROUNDFISH"."NFRAW_LFS" 
   (	"VESEL" VARCHAR2(2 BYTE), 
	"CRUNO" VARCHAR2(3 BYTE), 
	"STRAT_LINE" VARCHAR2(3 BYTE), 
	"SETNO" VARCHAR2(3 BYTE), 
	"SET_TYPE" VARCHAR2(2 BYTE), 
	"SDATE" VARCHAR2(6 BYTE), 
	"NAFO" VARCHAR2(2 BYTE), 
	"SPEC" VARCHAR2(4 BYTE), 
	"NOMEAS" VARCHAR2(4 BYTE), 
	"RATIO1" VARCHAR2(2 BYTE), 
	"SEX" VARCHAR2(1 BYTE), 
	"GEAR" VARCHAR2(1 BYTE), 
	"DAY_NIGHT" VARCHAR2(1 BYTE), 
	"SIZE_CLASS" VARCHAR2(1 BYTE), 
	"LFS" VARCHAR2(600 BYTE), 
	"RATIO2" VARCHAR2(5 BYTE)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH"  ENABLE ROW MOVEMENT ;
  GRANT SELECT ON "GROUNDFISH"."NFRAW_LFS" TO "MFLIB";
 
  GRANT SELECT ON "GROUNDFISH"."NFRAW_LFS" TO "VDC";
 
  GRANT SELECT ON "GROUNDFISH"."NFRAW_LFS" TO "VDC_DEV";
 
  GRANT SELECT ON "GROUNDFISH"."NFRAW_LFS" TO "RICARDD";
 
  GRANT SELECT ON "GROUNDFISH"."NFRAW_LFS" TO "HUBLEYB";
 
  GRANT SELECT ON "GROUNDFISH"."NFRAW_LFS" TO "GREYSONP";
