create or replace package body airbrake_project

as

	function list_projects
	return airbrake.call_result
	
	as
	
	begin
	
		dbms_application_info.set_action('list_projects');

		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		airbrake.init_talk('projects?key=' || airbrake.airbrake_session.airbrake_user_key);

		airbrake.talk;
	
		dbms_application_info.set_action(null);
	
		return airbrake.airbrake_response_result;
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end list_projects;

	function show_project (
		project_id						in				number
	)
	return airbrake.call_result
	
	as
	
	begin
	
		dbms_application_info.set_action('show_project');

		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		airbrake.init_talk('projects/'|| project_id ||'?key='|| airbrake.airbrake_session.airbrake_user_key);

		airbrake.talk;
	
		dbms_application_info.set_action(null);
	
		return airbrake.airbrake_response_result;
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end show_project;

begin

	dbms_application_info.set_client_info('airbrake_project');
	dbms_session.set_identifier('airbrake_project');

end airbrake_project;
/