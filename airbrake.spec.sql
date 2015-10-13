create or replace package airbrake

as

	/** Airbrake.io API communication
	* @author Morten Egan
	* @project AIRBRAKE_UTL
	* @version 0.0.1
	*/

	-- Types and globals
	-- Global variables and types
	type session_settings is record (
		transport_protocol			varchar2(4000)
		, airbrake_host				varchar2(4000)
		, airbrake_host_port		varchar2(4000)
		, airbrake_api_name			varchar2(4000)
		, airbrake_api_version		varchar2(4000)
		, wallet_location			varchar2(4000)
		, wallet_password			varchar2(4000)
		, airbrake_project_id 		varchar2(4000)
		, airbrake_project_key		varchar2(4000)
		, airbrake_user_key			varchar2(4000)
	);
	airbrake_session				session_settings;

	type call_request is record (
		call_endpoint				varchar2(4000)
		, call_method				varchar2(100)
		, call_json					json
	);
	airbrake_call_request			call_request;

	type call_result is record (
		result_type					varchar2(200)
		, result 					json
		, result_list				json_list
	);
	airbrake_response_result		call_result;

	airbrake_api_raw_result			clob;
	airbrake_call_status_code		pls_integer;
	airbrake_call_status_reason		varchar2(256);

	type text_text_arr is table of varchar2(4000) index by varchar2(250);
	airbrake_response_headers		text_text_arr;

	procedure session_setup (
		transport_protocol			varchar2 default null
		, airbrake_host				varchar2 default null
		, airbrake_host_port		varchar2 default null
		, airbrake_api_name			varchar2 default null
		, airbrake_api_version		varchar2 default null
		, wallet_location			varchar2 default null
		, wallet_password			varchar2 default null
		, airbrake_project_id		varchar2 default null
		, airbrake_project_key		varchar2 default null
		, airbrake_user_key			varchar2 default null
	);

	/** Send request to Airbrake API
	* @author Morten Egan
	*/
	procedure talk;

	procedure init_talk (
		endpoint 					varchar2
		, endpoint_method			varchar2 default 'GET'
	);

end airbrake;
/