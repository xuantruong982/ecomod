--------------------------------------------------------
--  DDL for Table USGSCAT
--------------------------------------------------------

  CREATE TABLE "GROUNDFISH"."USGSCAT" 
   (	"ID" VARCHAR2(18 BYTE), 
	"CRUISE" VARCHAR2(6 BYTE), 
	"STRATUM" VARCHAR2(5 BYTE), 
	"TOW" VARCHAR2(3 BYTE), 
	"STATION" VARCHAR2(4 BYTE), 
	"SVSPP" VARCHAR2(3 BYTE), 
	"SPEC" NUMBER(4,0), 
	"CATCHSEX" VARCHAR2(1 BYTE), 
	"EXPCATCHWT" NUMBER, 
	"EXPCATCHNUM" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH"  ENABLE ROW MOVEMENT ;
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "MFLIB";
 
  GRANT INSERT ON "GROUNDFISH"."USGSCAT" TO "BRANTON";
 
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "VDC";
 
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "VDC_DEV";
 
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "NWAGSCOL" WITH GRANT OPTION;
 
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "RICARDD";
 
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "HUBLEYB";
 
  GRANT SELECT ON "GROUNDFISH"."USGSCAT" TO "GREYSONP";
