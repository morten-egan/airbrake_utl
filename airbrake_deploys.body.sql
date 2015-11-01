create or replace package body airbrake_deploys

as

	procedure create_deploy (
		environment						in				varchar2
		, username						in				varchar2
		, repository					in				varchar2
		, revision						in				varchar2
		, version						in				varchar2
		, project_id					in				number default null
	)
	
	as

	begin

		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		if project_id is not null then
			airbrake.init_talk('projects/'|| project_id ||'/deploys?key='|| airbrake.airbrake_session.airbrake_project_key, 'POST');
		else
			airbrake.init_talk('projects/'|| airbrake.airbrake_session.airbrake_project_id ||'/deploys?key='|| airbrake.airbrake_session.airbrake_project_key, 'POST');
		end if;

		airbrake.airbrake_call_request.call_json.put('environment', environment);

		airbrake.airbrake_call_request.call_json.put('username', username);

		airbrake.airbrake_call_request.call_json.put('repository', repository);

		airbrake.airbrake_call_request.call_json.put('revision', revision);

		airbrake.airbrake_call_request.call_json.put('version', version);

		airbrake.talk;
	
		exception
			when others then
				raise;
	
	end create_deploy;

	function list_deploys (
		project_id						in				number default null
	)
	return airbrake.call_result
	
	as
	
	begin
	
		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		if project_id is not null then
			airbrake.init_talk('projects/'|| project_id ||'/deploys?key='|| airbrake.airbrake_session.airbrake_user_key);
		else
			airbrake.init_talk('projects/'|| airbrake.airbrake_session.airbrake_project_id ||'/deploys?key='|| airbrake.airbrake_session.airbrake_user_key);
		end if;

		airbrake.talk;
	
		return airbrake.airbrake_response_result;
	
		exception
			when others then
				raise;
	
	end list_deploys;

	function show_deploy (
		deploy_id						in				number
		, project_id					in				number default null
	)
	return airbrake.call_result
	
	as
	
	begin
	
		airbrake.session_setup(
			airbrake_api_version => 'v4'
		);

		if project_id is not null then
			airbrake.init_talk('projects/'|| project_id ||'/deploys/'|| deploy_id ||'?key='|| airbrake.airbrake_session.airbrake_user_key);
		else
			airbrake.init_talk('projects/'|| airbrake.airbrake_session.airbrake_project_id ||'/deploys/'|| deploy_id ||'?key='|| airbrake.airbrake_session.airbrake_user_key);
		end if;

		airbrake.talk;
		
		return airbrake.airbrake_response_result;
	
		exception
			when others then
				raise;
	
	end show_deploy;

end airbrake_deploys;
/