create or replace package airbrake_notification

as

	procedure error_notification (
		error_number				varchar2
		, error_text				varchar2
		, error_location			varchar2 default null
	);

	/** Automatic error stack formating and reporting.
	* @author Morten Egan
	*/
	procedure automatic_stack;

end airbrake_notification;
/