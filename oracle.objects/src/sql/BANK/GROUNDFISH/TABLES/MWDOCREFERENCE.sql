--------------------------------------------------------
--  DDL for Table MWDOCREFERENCE
--------------------------------------------------------

  CREATE TABLE "GROUNDFISH"."MWDOCREFERENCE" 
   (	"FK_MISSION" VARCHAR2(16 BYTE), 
	"FK_SERIES_ID" VARCHAR2(16 BYTE), 
	"REPORTTYPE" NUMBER(4,0), 
	"REPORTID" NUMBER(4,0), 
	"REPORTHREF" VARCHAR2(255 BYTE)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" ;
  GRANT SELECT ON "GROUNDFISH"."MWDOCREFERENCE" TO "MFLIB" WITH GRANT OPTION;
 
  GRANT SELECT ON "GROUNDFISH"."MWDOCREFERENCE" TO "VDC";
 
  GRANT SELECT ON "GROUNDFISH"."MWDOCREFERENCE" TO "VDC_DEV";
 
  GRANT SELECT ON "GROUNDFISH"."MWDOCREFERENCE" TO "RICARDD";
 
  GRANT SELECT ON "GROUNDFISH"."MWDOCREFERENCE" TO "HUBLEYB";
 
  GRANT SELECT ON "GROUNDFISH"."MWDOCREFERENCE" TO "GREYSONP";
