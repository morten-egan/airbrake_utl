create or replace package body airbrake_notification

as

	function notifier_block
	return json

	as

		notifier_json				json := json();

	begin

		notifier_json.put('name', 'airbrake-plsql');
		notifier_json.put('version', '0.0.1');
		notifier_json.put('url', 'www.codemonth.dk');

		return notifier_json;

	end notifier_block;

	function context_block
	return json
	
	as
	
		l_ret_val			json := json();
	
	begin
	
		dbms_application_info.set_action('context_block');

		l_ret_val.put('os', 'Linux OS 3.1.4');
		l_ret_val.put('language', 'PL/SQL 12.1.0.2.0');
		l_ret_val.put('environment', 'development');
	
		dbms_application_info.set_action(null);
	
		return l_ret_val;
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end context_block;

	procedure error_notification (
		error_number				varchar2
		, error_text				varchar2
	)

	as

		build_json					json := json();
		temp_json					json := json();
		temp_json2					json := json();
		temp_list					json_list := json_list();

	begin

		airbrake.init_talk('projects/'|| airbrake.airbrake_session.airbrake_project_id ||'/notices?key='|| airbrake.airbrake_session.airbrake_project_key, 'POST');

		-- First we build the notifier block
		airbrake.airbrake_call_request.call_json.put('notifier', notifier_block);

		-- Build the error block
		temp_json := json();
		temp_json2 := json();
		temp_list := json_list();
		temp_json2.put('file', 'procedure_name');
		temp_json2.put('line', 43);
		temp_json2.put('function', 'let_this_be_source_line');
		temp_list.append(temp_json2.to_json_value);
		temp_json.put('type', error_number);
		temp_json.put('message', error_text);
		temp_json.put('backtrace', temp_list);
		temp_list := json_list();
		temp_list.append(temp_json.to_json_value);
		airbrake.airbrake_call_request.call_json.put('errors', temp_list);

		-- Build the context block
		airbrake.airbrake_call_request.call_json.put('context', context_block);

		-- Build the environment block
		temp_json := json();
		temp_json.put('oracle_sid', 'ORCL');
		temp_json.put('calling_schema', 'AIRBRAKE');
		airbrake.airbrake_call_request.call_json.put('environment', temp_json);

		-- Finally we ship the json away
		airbrake.talk;

	end error_notification;

end airbrake_notification;
/