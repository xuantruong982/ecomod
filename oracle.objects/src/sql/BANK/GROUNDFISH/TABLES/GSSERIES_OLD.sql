--------------------------------------------------------
--  DDL for Table GSSERIES_OLD
--------------------------------------------------------

  CREATE TABLE "GROUNDFISH"."GSSERIES_OLD" 
   (	"PK_SERIES_ID" VARCHAR2(16 BYTE), 
	"FK_SOURCE_ID" VARCHAR2(16 BYTE), 
	"FK_DATASET_ID" VARCHAR2(16 BYTE), 
	"DESCRIPTION" VARCHAR2(100 BYTE), 
	"AREA_SURVEYED" VARCHAR2(16 BYTE), 
	"MINSTRAT" VARCHAR2(4 BYTE), 
	"MAXSTRAT" VARCHAR2(4 BYTE), 
	"SMONTH" NUMBER(4,0), 
	"EMONTH" NUMBER(4,0), 
	"SYEAR" NUMBER(4,0), 
	"EYEAR" NUMBER(4,0), 
	"SRS" NUMBER(10,8), 
	"REG" NUMBER(10,8), 
	"COMP" NUMBER(10,8), 
	"TAG" NUMBER(10,8), 
	"GEAR" NUMBER(10,8), 
	"EXPLOR" NUMBER(10,8), 
	"TYPE_RANK" VARCHAR2(30 BYTE), 
	"NSETS" NUMBER(4,0), 
	"NMISSION" NUMBER(4,0), 
	"STD_TOW_LEN" NUMBER(8,4), 
	"STD_WING_SIZE" NUMBER(8,4), 
	"TRADITIONAL_NAME" VARCHAR2(30 BYTE)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" ;
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "KOELLERP";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "MFLIB" WITH GRANT OPTION;
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "PCOMEAU";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "HARRISLE";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "ABUNDY";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "VDC";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "NWAGS";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "VDC_DEV";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "RICARDD";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "PED_HALIBUT";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "TRZCINSKIK";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "LUSSEAUS";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "HUBLEYB";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "DENHEYER";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "MACDONALDD";
 
  GRANT SELECT ON "GROUNDFISH"."GSSERIES_OLD" TO "GREYSONP";
