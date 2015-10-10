create user airbrake identified by airbrake
default tablespace users
temporary tablespace temp
quota unlimited on users;

grant create session to airbrake;
grant create table to airbrake;
grant create procedure to airbrake;
grant execute on utl_http to airbrake;
grant create type to airbrake;