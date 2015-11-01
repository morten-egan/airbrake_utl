create or replace package body airbrake_project

as

	function list_projects
	return airbrake.call_result
	
	as
	
	begin
	

		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		airbrake.init_talk('projects?key=' || airbrake.airbrake_session.airbrake_user_key);

		airbrake.talk;
	
	
		return airbrake.airbrake_response_result;
	
		exception
			when others then
				raise;
	
	end list_projects;

	function show_project (
		project_id						in				number
	)
	return airbrake.call_result
	
	as
	
	begin
	

		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		airbrake.init_talk('projects/'|| project_id ||'?key='|| airbrake.airbrake_session.airbrake_user_key);

		airbrake.talk;
	
	
		return airbrake.airbrake_response_result;
	
		exception
			when others then
				raise;
	
	end show_project;


end airbrake_project;
/