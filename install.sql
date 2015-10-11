@@user.sql
@@airbrake_acl.sql

connect airbrake/airbrake

@@pljson/install.sql

REM Installing package specs
@@airbrake.spec.sql
@@airbrake_notification.spec.sql

REM Installing package bodies
@@airbrake.body.sql
@@airbrake_notification.body.sql
