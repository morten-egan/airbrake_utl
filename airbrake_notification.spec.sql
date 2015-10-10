create or replace package airbrake_notification

as

	procedure error_notification (
		error_number				varchar2
		, error_text				varchar2
	);

end airbrake_notification;
/