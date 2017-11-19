
## add user
create user vcl0000 identified by ******;
alter user vcl0000 identified by ******;
create tablespace ts_vcl0000 datafile '/u01/app/oracle/product/12.1.0/xe/tablespaces/vcl0000_data.dbf' size 1024M;
alter user vcl0000 default tablespace ts_vcl0000;
grant create session,create table,create view,create sequence,unlimited tablespace to vcl0000;
grant connect ,resource, dba to vcl0000;
