insert into PICTURES
select 'Charlotte-ReportLogo','Charlotte Douglas International Airpot','Logo Used On all reports for Charlotte',
BulkColumn FROM OPENROWSET(Bulk 'D:\1Pteris Global Ltd\GUO WENYU\projects\US charlotte\MIS\MIS SQLSCRIPTS\logo.jpg', SINGLE_BLOB) AS BLOB;

select * from PICTURES;
delete from PICTURES;
SELECT PIC_TITLE, PIC_IMAGE FROM PICTURES WHERE PIC_NAME = 'Charlotte-ReportLogo'