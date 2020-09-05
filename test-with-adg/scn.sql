conn system/Ora_DB4U@orclpdb
select current_scn, to_char(sysdate, 'YYYYMMDD-HH12MISS') time from v$database;