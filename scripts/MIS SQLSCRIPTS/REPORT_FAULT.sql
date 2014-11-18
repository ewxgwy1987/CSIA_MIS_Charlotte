UPDATE REPORT_FAULT SET FAULT_USED=0,MDS_USED=0;

INSERT INTO REPORT_FAULT VALUES('AA_EXFL','(VSU/SD)Fail to Extend/Open','ALARM',1,1,0,GETDATE(),NULL)
INSERT INTO REPORT_FAULT VALUES('AA_REFL','(VSU/SD)Fail to Retract/Close','ALARM',1,1,0,GETDATE(),NULL)
INSERT INTO REPORT_FAULT VALUES('AA_PTPH','MCP/RCP Temperature High','ALARM',0,1,0,GETDATE(),NULL)

UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_ARAL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_BHS';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_BJAM';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_CNFT';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_ENOS';

UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_ENUS';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_EQMS';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_ESTP';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_EXFL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_FIRE';

UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_FSAL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_GNAL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_ISOF';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_IVFT';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_MSBJ';

UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_MTTR';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_NDAL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_NIPS';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_PTPH';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_RDRV';

UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_REFL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_SDAL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_XMAL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_BOVH';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=0 WHERE FAULT_NAME='AA_BOVL';
UPDATE REPORT_FAULT SET MDS_USED=1,FAULT_USED=1 WHERE FAULT_NAME='AA_ENFT';

SELECT * FROM REPORT_FAULT WHERE MDS_USED=1
SELECT * FROM REPORT_FAULT WHERE MDS_USED=1 AND FAULT_USED=1;
SELECT * FROM REPORT_FAULT WHERE MDS_USED=1 AND FAULT_USED=0;
