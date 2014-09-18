--------------------------------------------------------
--  DDL for Table NF_STRATUM
--------------------------------------------------------

  CREATE TABLE "GROUNDFISH"."NF_STRATUM" 
   (	"STRAT" VARCHAR2(3 BYTE), 
	"AREAR_NMI" VARCHAR2(4 BYTE), 
	"DMAX" VARCHAR2(4 BYTE), 
	"NAFO_DIV" VARCHAR2(3 BYTE)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "MFD_GROUNDFISH" ;
  GRANT SELECT ON "GROUNDFISH"."NF_STRATUM" TO "MFLIB";
 
  GRANT SELECT ON "GROUNDFISH"."NF_STRATUM" TO "VDC";
 
  GRANT SELECT ON "GROUNDFISH"."NF_STRATUM" TO "VDC_DEV";
 
  GRANT SELECT ON "GROUNDFISH"."NF_STRATUM" TO "RICARDD";
 
  GRANT SELECT ON "GROUNDFISH"."NF_STRATUM" TO "HUBLEYB";
 
  GRANT SELECT ON "GROUNDFISH"."NF_STRATUM" TO "GREYSONP";
