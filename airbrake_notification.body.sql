create or replace package body airbrake_notification

as

	function error_block
	return json_list
	
	as
	
		l_ret_val			json_list := json_list();
		l_depth				pls_integer;
		l_call_depth		pls_integer;
		l_error				json := json();
		l_backtrace			json := json();
		l_backtrace_list	json_list := json_list();

		l_sqlcode			number;
		l_errmsg			varchar2(4000);
	
	begin
	
		$if dbms_db_version.ver_le_11 $then
			-- This is where we do pre 12c stuff
			l_sqlcode := SQLCODE;
			l_errmsg := SQLERRM;
			l_error.put('type', 'ORA' || l_sqlcode);
			l_error.put('message', l_errmsg);
			l_backtrace.put('file', 'Not available before 12c for automatic_stack.');
			l_backtrace_list.append(l_backtrace.to_json_value);
			l_error.put('backtrace', l_backtrace_list);
			l_ret_val.append(l_error.to_json_value);
		$else
			-- We are in 12c, let us use the new utl_call_stack
			l_depth := utl_call_stack.error_depth;
			l_call_depth := utl_call_stack.dynamic_depth;

			for i in reverse 1 .. l_depth loop
				l_error := json();
				l_error.put('type', 'ORA-' || lpad(utl_call_stack.error_number(i), 5, '0'));
				l_error.put('message', utl_call_stack.error_msg(i));
				l_backtrace := json();
				l_backtrace.put('file', utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(l_call_depth - 1)));
				l_backtrace.put('line', utl_call_stack.unit_line(l_call_depth - 1));
				l_backtrace.put('function', utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(l_call_depth)));
				l_backtrace_list := json_list();
				l_backtrace_list.append(l_backtrace.to_json_value);
				l_error.put('backtrace', l_backtrace_list);
				l_ret_val.append(l_error.to_json_value);
			end loop;
		$end
		
		return l_ret_val;
	
		exception
			when others then
				raise;
	
	end error_block;

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
		l_version			varchar2(250);
		l_compatibility		varchar2(250);
		l_module			varchar2(250);
		l_action			varchar2(250);

	begin
	
		dbms_utility.db_version( l_version, l_compatibility );
		dbms_application_info.read_module(l_module, l_action);

		l_ret_val.put('os', dbms_utility.port_string);
		l_ret_val.put('language', 'PL/SQL ' || l_version);
		if substr(l_version,1,3) = '12.' then
			l_ret_val.put('environment', sys_context('USERENV', 'CON_NAME'));
		else
			l_ret_val.put('environment', sys_context('USERENV', 'DB_NAME'));
		end if;
		l_ret_val.put('version', l_version);
		l_ret_val.put('component', l_module);
		l_ret_val.put('action', l_action);
		l_ret_val.put('userName', sys_context('USERENV', 'CURRENT_SCHEMA'));
		l_ret_val.put('userId', sys_context('USERENV', 'CURRENT_USER'));
		
		return l_ret_val;
	
		exception
			when others then
				raise;
	
	end context_block;

	function environment_block
	return json
	
	as
	
		l_ret_val			json := json();
	
	begin
	
		l_ret_val.put('Current schema', sys_context('USERENV', 'CURRENT_SCHEMA'));
		l_ret_val.put('Current user', sys_context('USERENV', 'CURRENT_USER'));
		if dbms_utility.is_cluster_database then
			l_ret_val.put('RAC', 'Yes');
		else
			l_ret_val.put('RAC', 'No');
		end if;
		l_ret_val.put('Database name', sys_context('USERENV', 'DB_NAME'));
		
		return l_ret_val;
	
		exception
			when others then
				raise;
	
	end environment_block;

	procedure automatic_stack
	
	as
	
	begin
	
		airbrake.session_setup(
			airbrake_api_version => 'v3'
		);

		airbrake.init_talk('projects/'|| airbrake.airbrake_session.airbrake_project_id ||'/notices?key='|| airbrake.airbrake_session.airbrake_project_key, 'POST');

		-- First we build the notifier block
		airbrake.airbrake_call_request.call_json.put('notifier', notifier_block);

		-- Automatic build of error stack
		airbrake.airbrake_call_request.call_json.put('errors', error_block);

		-- Build the context block
		airbrake.airbrake_call_request.call_json.put('context', context_block);

		-- Build the environment block
		airbrake.airbrake_call_request.call_json.put('environment', environment_block);

		-- Finally we ship the json away
		airbrake.talk;
		
		exception
			when others then
				raise;
	
	end automatic_stack;

	procedure error_notification (
		error_number				varchar2
		, error_text				varchar2
		, error_location			varchar2 default null
	)

	as

		build_json					json := json();
		temp_json					json := json();
		temp_json2					json := json();
		temp_list					json_list := json_list();

	begin

		airbrake.session_setup(
			airbrake_api_version => 'v3'
		);

		airbrake.init_talk('projects/'|| airbrake.airbrake_session.airbrake_project_id ||'/notices?key='|| airbrake.airbrake_session.airbrake_project_key, 'POST');

		-- First we build the notifier block
		airbrake.airbrake_call_request.call_json.put('notifier', notifier_block);

		-- Build the error block
		temp_json := json();
		temp_json2 := json();
		temp_list := json_list();
		temp_json2.put('file', nvl(error_location,'location_not_available'));
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
		airbrake.airbrake_call_request.call_json.put('environment', environment_block);

		-- Finally we ship the json away
		airbrake.talk;

	end error_notification;

end airbrake_notification;
/