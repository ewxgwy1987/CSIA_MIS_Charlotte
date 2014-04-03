go
use BHSDB_CLT;
go
BEGIN TRANSACTION;
BEGIN TRY

-- From MDS Alarm
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-10','B22','',NULL,NULL,0,NULL,NULL,'CCF2-10');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-11','B22','',NULL,NULL,0,NULL,NULL,'CCF2-11');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-12','B22','',NULL,NULL,0,NULL,NULL,'CCF2-12');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-13','B22','',NULL,NULL,0,NULL,NULL,'CCF2-13');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-14','B22','',NULL,NULL,0,NULL,NULL,'CCF2-14');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-15','B22','',NULL,NULL,0,NULL,NULL,'CCF2-15');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-16','B22','',NULL,NULL,0,NULL,NULL,'CCF2-16');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-17','B22','',NULL,NULL,0,NULL,NULL,'CCF2-17');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-18','B22','',NULL,NULL,0,NULL,NULL,'CCF2-18');
INSERT INTO LOCATIONS VALUES ('CCF2','CCF2-19','B22','',NULL,NULL,0,NULL,NULL,'CCF2-19');
INSERT INTO LOCATIONS VALUES ('CCD2','CCD2A','B22','',NULL,NULL,0,NULL,NULL,'CCD2A');
INSERT INTO LOCATIONS VALUES ('CCD2','CCD2B','B22','',NULL,NULL,0,NULL,NULL,'CCD2B');
INSERT INTO LOCATIONS VALUES ('CCD2','CCD2','B22','',NULL,NULL,0,NULL,NULL,'CCD2');
INSERT INTO LOCATIONS VALUES ('SS3','SS3-2-ATR','A11','',NULL,NULL,0,NULL,NULL,'SS3-02-ATR');
INSERT INTO LOCATIONS VALUES ('SS3','SS3-7','A11','',NULL,NULL,0,NULL,NULL,'SS3-07');
INSERT INTO LOCATIONS VALUES ('ED7','ED7-1A','A11','',NULL,NULL,0,NULL,NULL,'ED7-01A');
INSERT INTO LOCATIONS VALUES ('ED9','ED9-1A','A11','',NULL,NULL,0,NULL,NULL,'ED9-01A');
INSERT INTO LOCATIONS VALUES ('RI2','RI2-2SD','B11','',NULL,NULL,0,NULL,NULL,'RI2-02SD');
INSERT INTO LOCATIONS VALUES ('SS4','SS4-2-ATR','B11','',NULL,NULL,0,NULL,NULL,'SS4-02-ATR');
INSERT INTO LOCATIONS VALUES ('SS4','SS4-4','B11','',NULL,NULL,0,NULL,NULL,'SS4-04');
INSERT INTO LOCATIONS VALUES ('ED8','ED8-1A','B11','',NULL,NULL,0,NULL,NULL,'ED8-01A');
INSERT INTO LOCATIONS VALUES ('ED10','ED10-1A','B11','',NULL,NULL,0,NULL,NULL,'ED10-01A');
INSERT INTO LOCATIONS VALUES ('ED11','ED11-1A','B11','',NULL,NULL,0,NULL,NULL,'ED11-01A');
INSERT INTO LOCATIONS VALUES ('SB3','SB3-4SD','A14','',NULL,NULL,0,NULL,NULL,'SB3-04SD');
INSERT INTO LOCATIONS VALUES ('SB4','SB4-3SD','B14','',NULL,NULL,0,NULL,NULL,'SB4-03SD');
INSERT INTO LOCATIONS VALUES ('MF1A','MF1A-1A','A31','',NULL,NULL,0,NULL,NULL,'MF1A-01A');
INSERT INTO LOCATIONS VALUES ('ME1','ME1-1A','A31','',NULL,NULL,0,NULL,NULL,'ME1-01A');
INSERT INTO LOCATIONS VALUES ('MF2A','MF2A-1A','A31','',NULL,NULL,0,NULL,NULL,'MF2A-01A');
INSERT INTO LOCATIONS VALUES ('MF3A','MF3A-1A','A31','',NULL,NULL,0,NULL,NULL,'MF3A-01A');
INSERT INTO LOCATIONS VALUES ('MF4A','MF4A-1A','A31','',NULL,NULL,0,NULL,NULL,'MF4A-01A');
INSERT INTO LOCATIONS VALUES ('ML1','ML1-1-ATR','A31','',NULL,NULL,0,NULL,NULL,'ML1-01-ATR');
INSERT INTO LOCATIONS VALUES ('MF6','MF6-1A','A31','',NULL,NULL,0,NULL,NULL,'MF6-01A');
INSERT INTO LOCATIONS VALUES ('MU1','MU1A','A31','',NULL,NULL,0,NULL,NULL,'MU1A');
INSERT INTO LOCATIONS VALUES ('MU1','MU1B','A31','',NULL,NULL,0,NULL,NULL,'MU1B');
INSERT INTO LOCATIONS VALUES ('MF1D','MF1D-1A','B32','',NULL,NULL,0,NULL,NULL,'MF1D-01A');
INSERT INTO LOCATIONS VALUES ('ME2','ME2-1A','B32','',NULL,NULL,0,NULL,NULL,'ME2-01A');
INSERT INTO LOCATIONS VALUES ('MF2D','MF2D-1A','B32','',NULL,NULL,0,NULL,NULL,'MF2D-01A');
INSERT INTO LOCATIONS VALUES ('MF3D','MF3D-1A','B32','',NULL,NULL,0,NULL,NULL,'MF3D-01A');
INSERT INTO LOCATIONS VALUES ('MF4C','MF4C-1A','B32','',NULL,NULL,0,NULL,NULL,'MF4C-01A');
INSERT INTO LOCATIONS VALUES ('ML2','ML2-2-ATR','B32','',NULL,NULL,0,NULL,NULL,'ML2-02-ATR');
INSERT INTO LOCATIONS VALUES ('MF5','MF5-1A','B32','',NULL,NULL,0,NULL,NULL,'MF5-01A');
INSERT INTO LOCATIONS VALUES ('MU2','MU2A','B32','',NULL,NULL,0,NULL,NULL,'MU2A');
INSERT INTO LOCATIONS VALUES ('MU2','MU2B','B32','',NULL,NULL,0,NULL,NULL,'MU2B');
INSERT INTO LOCATIONS VALUES ('ME3A','ME3A-1A','A32','',NULL,NULL,0,NULL,NULL,'ME3A-01A');
INSERT INTO LOCATIONS VALUES ('MF1B','MF1B-1A','A32','',NULL,NULL,0,NULL,NULL,'MF1B-01A');
INSERT INTO LOCATIONS VALUES ('ML3','ML3-1SD','A32','',NULL,NULL,0,NULL,NULL,'ML3-01SD');
INSERT INTO LOCATIONS VALUES ('ML3','ML3-2-ATR','A32','',NULL,NULL,0,NULL,NULL,'ML3-02-ATR');
INSERT INTO LOCATIONS VALUES ('ML3','ML3-3SD','A32','',NULL,NULL,0,NULL,NULL,'ML3-03SD');
INSERT INTO LOCATIONS VALUES ('MF2B','MF2B-1A','A32','',NULL,NULL,0,NULL,NULL,'MF2B-01A');
INSERT INTO LOCATIONS VALUES ('MF3B','MF3B-1A','A32','',NULL,NULL,0,NULL,NULL,'MF3B-01A');
INSERT INTO LOCATIONS VALUES ('MF4B','MF4B-1A','A32','',NULL,NULL,0,NULL,NULL,'MF4B-01A');
INSERT INTO LOCATIONS VALUES ('MU3','MU3A','A32','',NULL,NULL,0,NULL,NULL,'MU3A');
INSERT INTO LOCATIONS VALUES ('MU3','MU3B','A32','',NULL,NULL,0,NULL,NULL,'MU3B');
INSERT INTO LOCATIONS VALUES ('CB6B','CB6B-4SD','A13','',NULL,NULL,0,NULL,NULL,'CB6B-04SD');
INSERT INTO LOCATIONS VALUES ('ME3B','ME3B-1A','B31','',NULL,NULL,0,NULL,NULL,'ME3B-01A');
INSERT INTO LOCATIONS VALUES ('MF1C','MF1C-1A','B31','',NULL,NULL,0,NULL,NULL,'MF1C-01A');
INSERT INTO LOCATIONS VALUES ('ML4','ML4-1SD','B31','',NULL,NULL,0,NULL,NULL,'ML4-01SD');
INSERT INTO LOCATIONS VALUES ('ML4','ML4-2-ATR','B31','',NULL,NULL,0,NULL,NULL,'ML4-02-ATR');
INSERT INTO LOCATIONS VALUES ('ML4','ML4-3SD','B31','',NULL,NULL,0,NULL,NULL,'ML4-03SD');
INSERT INTO LOCATIONS VALUES ('XO8','XO8-1A','B31','',NULL,NULL,0,NULL,NULL,'XO8-01A');
INSERT INTO LOCATIONS VALUES ('MF2C','MF2C-1A','B31','',NULL,NULL,0,NULL,NULL,'MF2C-01A');
INSERT INTO LOCATIONS VALUES ('MF3C','MF3C-1A','B31','',NULL,NULL,0,NULL,NULL,'MF3C-01A');
INSERT INTO LOCATIONS VALUES ('MU4','MU4A','B31','',NULL,NULL,0,NULL,NULL,'MU4A');
INSERT INTO LOCATIONS VALUES ('MU4','MU4B','B31','',NULL,NULL,0,NULL,NULL,'MU4B');
INSERT INTO LOCATIONS VALUES ('CB9B','CB9B-5SD','B13','',NULL,NULL,0,NULL,NULL,'CB9B-05SD');
INSERT INTO LOCATIONS VALUES ('TC1','TC1-1A','A21','',NULL,NULL,0,NULL,NULL,'TC1-01A');
INSERT INTO LOCATIONS VALUES ('TC1','TC1-1B','A21','',NULL,NULL,0,NULL,NULL,'TC1-01B');
INSERT INTO LOCATIONS VALUES ('TC1','TC1-2','A21','',NULL,NULL,0,NULL,NULL,'TC1-02');
INSERT INTO LOCATIONS VALUES ('TC1','TC1-2SD','A21','',NULL,NULL,0,NULL,NULL,'TC1-02SD');
INSERT INTO LOCATIONS VALUES ('TC1','TC1-3','A21','',NULL,NULL,0,NULL,NULL,'TC1-03');
INSERT INTO LOCATIONS VALUES ('TC1','TC1-4SD','A21','',NULL,NULL,0,NULL,NULL,'TC1-04SD');
INSERT INTO LOCATIONS VALUES ('XO5','XO5-4','A21','',NULL,NULL,0,NULL,NULL,'XO5-04');
INSERT INTO LOCATIONS VALUES ('XO6','XO6-1A','A21','',NULL,NULL,0,NULL,NULL,'XO6-01A');
INSERT INTO LOCATIONS VALUES ('CB1B','CB1B-4SD','A62','',NULL,NULL,0,NULL,NULL,'CB1B-04SD');
INSERT INTO LOCATIONS VALUES ('RI1','RI1-4SD','A61','',NULL,NULL,0,NULL,NULL,'RI1-04SD');
INSERT INTO LOCATIONS VALUES ('SS1','SS1-2-ATR','A61','',NULL,NULL,0,NULL,NULL,'SS1-02-ATR');
INSERT INTO LOCATIONS VALUES ('SS1','SS1-5','A61','',NULL,NULL,0,NULL,NULL,'SS1-05');
INSERT INTO LOCATIONS VALUES ('ED1','ED1-1A','A61','',NULL,NULL,0,NULL,NULL,'ED1-01A');
INSERT INTO LOCATIONS VALUES ('ED2','ED2-1A','A61','',NULL,NULL,0,NULL,NULL,'ED2-01A');
INSERT INTO LOCATIONS VALUES ('SS2','SS2-2-ATR','B61','',NULL,NULL,0,NULL,NULL,'SS2-02-ATR');
INSERT INTO LOCATIONS VALUES ('SS2','SS2-4','B61','',NULL,NULL,0,NULL,NULL,'SS2-04');
INSERT INTO LOCATIONS VALUES ('ED3','ED3-1A','B61','',NULL,NULL,0,NULL,NULL,'ED3-01A');
INSERT INTO LOCATIONS VALUES ('ED4','ED4-1A','B61','',NULL,NULL,0,NULL,NULL,'ED4-01A');
INSERT INTO LOCATIONS VALUES ('SB1','SB1-2SD','A64','',NULL,NULL,0,NULL,NULL,'SB1-02SD');
INSERT INTO LOCATIONS VALUES ('2TC','2TC-1','B53','',NULL,NULL,0,NULL,NULL,'2TC-01');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-1','B53','',NULL,NULL,0,NULL,NULL,'3TC-01');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-3','B53','',NULL,NULL,0,NULL,NULL,'3TC-03');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-3SD','B53','',NULL,NULL,0,NULL,NULL,'3TC-03SD');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-4SD','B53','',NULL,NULL,0,NULL,NULL,'3TC-04SD');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-4','B53','',NULL,NULL,0,NULL,NULL,'3TC-04');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-5','B53','',NULL,NULL,0,NULL,NULL,'3TC-05');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-6','B53','',NULL,NULL,0,NULL,NULL,'3TC-06');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-7','B53','',NULL,NULL,0,NULL,NULL,'3TC-07');
INSERT INTO LOCATIONS VALUES ('3TC','3TC-8','B53','',NULL,NULL,0,NULL,NULL,'3TC-08');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-1A','B53','',NULL,NULL,0,NULL,NULL,'5TC-01A');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-1B','B53','',NULL,NULL,0,NULL,NULL,'5TC-01B');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-3','B53','',NULL,NULL,0,NULL,NULL,'5TC-03');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-3SD','B53','',NULL,NULL,0,NULL,NULL,'5TC-03SD');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-4SD','B53','',NULL,NULL,0,NULL,NULL,'5TC-04SD');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-4','B53','',NULL,NULL,0,NULL,NULL,'5TC-04');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-5','B53','',NULL,NULL,0,NULL,NULL,'5TC-05');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-6','B53','',NULL,NULL,0,NULL,NULL,'5TC-06');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-7','B53','',NULL,NULL,0,NULL,NULL,'5TC-07');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-8','B53','',NULL,NULL,0,NULL,NULL,'5TC-08');
INSERT INTO LOCATIONS VALUES ('5TC','5TC-9','B53','',NULL,NULL,0,NULL,NULL,'5TC-09');
INSERT INTO LOCATIONS VALUES ('XO3','XO3-1A','B53','',NULL,NULL,0,NULL,NULL,'XO3-01A');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-27AA','B53','',NULL,NULL,0,NULL,NULL,'TC4-27AA');
INSERT INTO LOCATIONS VALUES ('CBO1','CBO1-1SD','A42','',NULL,NULL,0,NULL,NULL,'CBO1-01SD');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-1','A42','',NULL,NULL,0,NULL,NULL,'OS1-01');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-1SD','A42','',NULL,NULL,0,NULL,NULL,'OS1-01SD');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-2','A42','',NULL,NULL,0,NULL,NULL,'OS1-02');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-2SD','A42','',NULL,NULL,0,NULL,NULL,'OS1-02SD');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-3','A42','',NULL,NULL,0,NULL,NULL,'OS1-03');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-4','A42','',NULL,NULL,0,NULL,NULL,'OS1-04');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-5','A42','',NULL,NULL,0,NULL,NULL,'OS1-05');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-6','A42','',NULL,NULL,0,NULL,NULL,'OS1-06');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-7','A42','',NULL,NULL,0,NULL,NULL,'OS1-07');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-8','A42','',NULL,NULL,0,NULL,NULL,'OS1-08');
INSERT INTO LOCATIONS VALUES ('OS1','OS1-18SD','A42','',NULL,NULL,0,NULL,NULL,'OS1-18SD');
INSERT INTO LOCATIONS VALUES ('IB2','IB2-8SD','A52','',NULL,NULL,0,NULL,NULL,'IB2-08SD');
INSERT INTO LOCATIONS VALUES ('IB2','IB2-15SD','A52','',NULL,NULL,0,NULL,NULL,'IB2-15SD');
INSERT INTO LOCATIONS VALUES ('CD2','CD2A','A52','',NULL,NULL,0,NULL,NULL,'CD2A');
INSERT INTO LOCATIONS VALUES ('CD2','CD2B','A52','',NULL,NULL,0,NULL,NULL,'CD2B');
INSERT INTO LOCATIONS VALUES ('IB1','IB1-17SD','B52','',NULL,NULL,0,NULL,NULL,'IB1-17SD');
INSERT INTO LOCATIONS VALUES ('IB1','IB1-20SD','B52','',NULL,NULL,0,NULL,NULL,'IB1-20SD');
INSERT INTO LOCATIONS VALUES ('CD1','CD1A','B52','',NULL,NULL,0,NULL,NULL,'CD1A');
INSERT INTO LOCATIONS VALUES ('CD1','CD1B','B52','',NULL,NULL,0,NULL,NULL,'CD1B');
INSERT INTO LOCATIONS VALUES ('MF6','MF6-14','A51','',NULL,NULL,0,NULL,NULL,'MF6-14');
INSERT INTO LOCATIONS VALUES ('MF5','MF5-15AA','A51','',NULL,NULL,0,NULL,NULL,'MF5-15AA');
INSERT INTO LOCATIONS VALUES ('MU6','MU6A','A51','',NULL,NULL,0,NULL,NULL,'MU6A');
INSERT INTO LOCATIONS VALUES ('MU6','MU6B','A51','',NULL,NULL,0,NULL,NULL,'MU6B');
INSERT INTO LOCATIONS VALUES ('MF5','MF5-12','B51','',NULL,NULL,0,NULL,NULL,'MF5-12');
INSERT INTO LOCATIONS VALUES ('MF6','MF6-11AA','B51','',NULL,NULL,0,NULL,NULL,'MF6-11AA');
INSERT INTO LOCATIONS VALUES ('MU5','MU5A','B51','',NULL,NULL,0,NULL,NULL,'MU5A');
INSERT INTO LOCATIONS VALUES ('MU5','MU5B','B51','',NULL,NULL,0,NULL,NULL,'MU5B');
INSERT INTO LOCATIONS VALUES ('1TC','1TC-1','A41','',NULL,NULL,0,NULL,NULL,'1TC-01');
INSERT INTO LOCATIONS VALUES ('1TC','1TC-2','A41','',NULL,NULL,0,NULL,NULL,'1TC-02');
INSERT INTO LOCATIONS VALUES ('1TC','1TC-2SD','A41','',NULL,NULL,0,NULL,NULL,'1TC-02SD');
INSERT INTO LOCATIONS VALUES ('1TC','1TC-3','A41','',NULL,NULL,0,NULL,NULL,'1TC-03');
INSERT INTO LOCATIONS VALUES ('1TC','1TC-3SD','A41','',NULL,NULL,0,NULL,NULL,'1TC-03SD');
INSERT INTO LOCATIONS VALUES ('1TC','1TC-4','A41','',NULL,NULL,0,NULL,NULL,'1TC-04');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-1','A41','',NULL,NULL,0,NULL,NULL,'TC4-01');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-2','A41','',NULL,NULL,0,NULL,NULL,'TC4-02');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-3','A41','',NULL,NULL,0,NULL,NULL,'TC4-03');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-4','A41','',NULL,NULL,0,NULL,NULL,'TC4-04');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-4SD','A41','',NULL,NULL,0,NULL,NULL,'TC4-04SD');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-5','A41','',NULL,NULL,0,NULL,NULL,'TC4-05');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-6','A41','',NULL,NULL,0,NULL,NULL,'TC4-06');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-6SD','A41','',NULL,NULL,0,NULL,NULL,'TC4-06SD');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-7','A41','',NULL,NULL,0,NULL,NULL,'TC4-07');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-8','A41','',NULL,NULL,0,NULL,NULL,'TC4-08');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-9','A41','',NULL,NULL,0,NULL,NULL,'TC4-09');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-10','A41','',NULL,NULL,0,NULL,NULL,'TC4-10');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-11','A41','',NULL,NULL,0,NULL,NULL,'TC4-11');
INSERT INTO LOCATIONS VALUES ('TC4','TC4-14','A41','',NULL,NULL,0,NULL,NULL,'TC4-14');
INSERT INTO LOCATIONS VALUES ('ICS','ICS-1','A41','',NULL,NULL,0,NULL,NULL,'ICS-01');
INSERT INTO LOCATIONS VALUES ('ICS','ICS-1SD','A41','',NULL,NULL,0,NULL,NULL,'ICS-01SD');
INSERT INTO LOCATIONS VALUES ('ICS','ICS-2','A41','',NULL,NULL,0,NULL,NULL,'ICS-02');
INSERT INTO LOCATIONS VALUES ('ICS','ICS-3','A41','',NULL,NULL,0,NULL,NULL,'ICS-03');
INSERT INTO LOCATIONS VALUES ('ICS','ICS-3SD','A41','',NULL,NULL,0,NULL,NULL,'ICS-03SD');
INSERT INTO LOCATIONS VALUES ('XO1','XO1-1A','A41','',NULL,NULL,0,NULL,NULL,'XO1-01A');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-1','B41','',NULL,NULL,0,NULL,NULL,'CS1-01');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-1SD','B41','',NULL,NULL,0,NULL,NULL,'CS1-01SD');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-1A','B41','',NULL,NULL,0,NULL,NULL,'CS1-01A');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-2','B41','',NULL,NULL,0,NULL,NULL,'CS1-02');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-3','B41','',NULL,NULL,0,NULL,NULL,'CS1-03');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-4','B41','',NULL,NULL,0,NULL,NULL,'CS1-04');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-5','B41','',NULL,NULL,0,NULL,NULL,'CS1-05');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-6','B41','',NULL,NULL,0,NULL,NULL,'CS1-06');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-7A','B41','',NULL,NULL,0,NULL,NULL,'CS1-07A');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-7B','B41','',NULL,NULL,0,NULL,NULL,'CS1-07B');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-7','B41','',NULL,NULL,0,NULL,NULL,'CS1-07');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-8','B41','',NULL,NULL,0,NULL,NULL,'CS1-08');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-1','B41','',NULL,NULL,0,NULL,NULL,'CS2-01');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-1SD','B41','',NULL,NULL,0,NULL,NULL,'CS2-01SD');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-2','B41','',NULL,NULL,0,NULL,NULL,'CS2-02');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-3','B41','',NULL,NULL,0,NULL,NULL,'CS2-03');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-4','B41','',NULL,NULL,0,NULL,NULL,'CS2-04');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-5','B41','',NULL,NULL,0,NULL,NULL,'CS2-05');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-6','B41','',NULL,NULL,0,NULL,NULL,'CS2-06');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-6SD','B41','',NULL,NULL,0,NULL,NULL,'CS2-06SD');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-7','B41','',NULL,NULL,0,NULL,NULL,'CS2-07');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-8','B41','',NULL,NULL,0,NULL,NULL,'CS2-08');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-9','B41','',NULL,NULL,0,NULL,NULL,'CS2-09');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-10','B41','',NULL,NULL,0,NULL,NULL,'CS2-10');
INSERT INTO LOCATIONS VALUES ('CS2','CS2-11','B41','',NULL,NULL,0,NULL,NULL,'CS2-11');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-1A','B41','',NULL,NULL,0,NULL,NULL,'TC2-01A');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-1B','B41','',NULL,NULL,0,NULL,NULL,'TC2-01B');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-2','B41','',NULL,NULL,0,NULL,NULL,'TC2-02');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-2SD','B41','',NULL,NULL,0,NULL,NULL,'TC2-02SD');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-3','B41','',NULL,NULL,0,NULL,NULL,'TC2-03');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-4','B41','',NULL,NULL,0,NULL,NULL,'TC2-04');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-5','B41','',NULL,NULL,0,NULL,NULL,'TC2-05');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-6','B41','',NULL,NULL,0,NULL,NULL,'TC2-06');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-7','B41','',NULL,NULL,0,NULL,NULL,'TC2-07');
INSERT INTO LOCATIONS VALUES ('TC2','TC2-8','B41','',NULL,NULL,0,NULL,NULL,'TC2-08');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-1','B41','',NULL,NULL,0,NULL,NULL,'TC3-01');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-2','B41','',NULL,NULL,0,NULL,NULL,'TC3-02');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-3','B41','',NULL,NULL,0,NULL,NULL,'TC3-03');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-3SD','B41','',NULL,NULL,0,NULL,NULL,'TC3-03SD');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-4','B41','',NULL,NULL,0,NULL,NULL,'TC3-04');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-5','B41','',NULL,NULL,0,NULL,NULL,'TC3-05');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-5SD','B41','',NULL,NULL,0,NULL,NULL,'TC3-05SD');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-6','B41','',NULL,NULL,0,NULL,NULL,'TC3-06');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-7','B41','',NULL,NULL,0,NULL,NULL,'TC3-07');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-8','B41','',NULL,NULL,0,NULL,NULL,'TC3-08');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-9','B41','',NULL,NULL,0,NULL,NULL,'TC3-09');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-10','B41','',NULL,NULL,0,NULL,NULL,'TC3-10');
INSERT INTO LOCATIONS VALUES ('TC3','TC3-11','B41','',NULL,NULL,0,NULL,NULL,'TC3-11');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-44','B41','',NULL,NULL,0,NULL,NULL,'RC2-44');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-45','B41','',NULL,NULL,0,NULL,NULL,'RC2-45');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-14','B41','',NULL,NULL,0,NULL,NULL,'CS1-14');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-15','B41','',NULL,NULL,0,NULL,NULL,'CS1-15');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-16','B41','',NULL,NULL,0,NULL,NULL,'CS1-16');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-17','B41','',NULL,NULL,0,NULL,NULL,'CS1-17');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-18','B41','',NULL,NULL,0,NULL,NULL,'CS1-18');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-19','B41','',NULL,NULL,0,NULL,NULL,'CS1-19');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-20','B41','',NULL,NULL,0,NULL,NULL,'CS1-20');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-21','B41','',NULL,NULL,0,NULL,NULL,'CS1-21');
INSERT INTO LOCATIONS VALUES ('CS1','CS1-22','B41','',NULL,NULL,0,NULL,NULL,'CS1-22');
INSERT INTO LOCATIONS VALUES ('XO4','XO4-1A','B41','',NULL,NULL,0,NULL,NULL,'XO4-01A');
INSERT INTO LOCATIONS VALUES ('XO7','XO7-1A','B41','',NULL,NULL,0,NULL,NULL,'XO7-01A');
INSERT INTO LOCATIONS VALUES ('IC1','IC1-1','B21','',NULL,NULL,0,NULL,NULL,'IC1-01');
INSERT INTO LOCATIONS VALUES ('IC1','IC1-2','B21','',NULL,NULL,0,NULL,NULL,'IC1-02');
INSERT INTO LOCATIONS VALUES ('IC1','IC1-3','B21','',NULL,NULL,0,NULL,NULL,'IC1-03');
INSERT INTO LOCATIONS VALUES ('IC1','IC1-3SD','B21','',NULL,NULL,0,NULL,NULL,'IC1-03SD');
INSERT INTO LOCATIONS VALUES ('IC1','IC1-4','B21','',NULL,NULL,0,NULL,NULL,'IC1-04');
INSERT INTO LOCATIONS VALUES ('IC1','IC1-4SD','B21','',NULL,NULL,0,NULL,NULL,'IC1-04SD');
INSERT INTO LOCATIONS VALUES ('IC2','IC2-1','B21','',NULL,NULL,0,NULL,NULL,'IC2-01');
INSERT INTO LOCATIONS VALUES ('IC2','IC2-2','B21','',NULL,NULL,0,NULL,NULL,'IC2-02');
INSERT INTO LOCATIONS VALUES ('IC2','IC2-2SD','B21','',NULL,NULL,0,NULL,NULL,'IC2-02SD');
INSERT INTO LOCATIONS VALUES ('IC2','IC2-3','B21','',NULL,NULL,0,NULL,NULL,'IC2-03');
INSERT INTO LOCATIONS VALUES ('IC2','IC2-3SD','B21','',NULL,NULL,0,NULL,NULL,'IC2-03SD');
INSERT INTO LOCATIONS VALUES ('IC3','IC3-1','B21','',NULL,NULL,0,NULL,NULL,'IC3-01');
INSERT INTO LOCATIONS VALUES ('IC3','IC3-2','B21','',NULL,NULL,0,NULL,NULL,'IC3-02');
INSERT INTO LOCATIONS VALUES ('IC3','IC3-3','B21','',NULL,NULL,0,NULL,NULL,'IC3-03');
INSERT INTO LOCATIONS VALUES ('IC3','IC3-2SD','B21','',NULL,NULL,0,NULL,NULL,'IC3-02SD');
INSERT INTO LOCATIONS VALUES ('IC3','IC3-3SD','B21','',NULL,NULL,0,NULL,NULL,'IC3-03SD');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-35','B21','',NULL,NULL,0,NULL,NULL,'RC2-35');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-36','B21','',NULL,NULL,0,NULL,NULL,'RC2-36');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-37','B21','',NULL,NULL,0,NULL,NULL,'RC2-37');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-38','B21','',NULL,NULL,0,NULL,NULL,'RC2-38');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-39','B21','',NULL,NULL,0,NULL,NULL,'RC2-39');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-40','B21','',NULL,NULL,0,NULL,NULL,'RC2-40');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-41','B21','',NULL,NULL,0,NULL,NULL,'RC2-41');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-42','B21','',NULL,NULL,0,NULL,NULL,'RC2-42');
INSERT INTO LOCATIONS VALUES ('RC2','RC2-43','B21','',NULL,NULL,0,NULL,NULL,'RC2-43');
INSERT INTO LOCATIONS VALUES ('XO5','XO5-1A','B21','',NULL,NULL,0,NULL,NULL,'XO5-01A');

--From MDS Bag Count
--None

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION;
	THROW
END CATCH;

IF @@TRANCOUNT>0
	COMMIT TRANSACTION;