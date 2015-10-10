create or replace package body airbrake

as

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
	)

	as

	begin

		if transport_protocol is not null then
			-- from 12c we need to lower the protocol name
			airbrake_session.transport_protocol := lower(transport_protocol);
		end if;

		if airbrake_host is not null then
			airbrake_session.airbrake_host := airbrake_host;
		end if;

		if airbrake_host_port is not null then
			airbrake_session.airbrake_host_port := airbrake_host_port;
		end if;

		if airbrake_api_name is not null then
			airbrake_session.airbrake_api_name := airbrake_api_name;
		end if;

		if airbrake_api_version is not null then
			airbrake_session.airbrake_api_version := airbrake_api_version;
		end if;

		if wallet_location is not null then
			airbrake_session.wallet_location := wallet_location;
		end if;

		if wallet_password is not null then
			airbrake_session.wallet_password := wallet_password;
		end if;

		if airbrake_project_id is not null then
			airbrake_session.airbrake_project_id := airbrake_project_id;
		end if;

		if airbrake_project_key is not null then
			airbrake_session.airbrake_project_key := airbrake_project_key;
		end if;

	end session_setup;

	procedure parse_airbrake_result

	as

	begin

		if substr(airbrake_api_raw_result, 1 , 1) = '[' then
			airbrake_response_result.result_type := 'JSON_LIST';
			airbrake_response_result.result_list := json_list(airbrake_api_raw_result);
		else
			airbrake_response_result.result_type := 'JSON';
			airbrake_response_result.result := json(airbrake_api_raw_result);
		end if;

	end parse_airbrake_result;

	procedure talk

	as

		airbrake_request				utl_http.req;
		airbrake_response				utl_http.resp;
		airbrake_result_piece			varchar2(32000);

		airbrake_header_name			varchar2(4000);
		airbrake_header_value			varchar2(4000);

		session_setup_error			exception;
		pragma exception_init(session_setup_error, -20001);

	begin

		dbms_output.put_line(airbrake_session.transport_protocol || '://' || airbrake_session.airbrake_host || ':' || airbrake_session.airbrake_host_port || '/' || airbrake_session.airbrake_api_name || '/' || airbrake_session.airbrake_api_version || '/' || airbrake_call_request.call_endpoint);

		-- Always reset result
		airbrake.airbrake_api_raw_result := null;

		-- Extended error checking
		utl_http.set_response_error_check(
			enable => true
		);
		utl_http.set_detailed_excp_support(
			enable => true
		);

		if airbrake_session.transport_protocol is not null then
			if airbrake_session.transport_protocol = 'https' then
				utl_http.set_wallet(
					airbrake_session.wallet_location
					, airbrake_session.wallet_password
				);
			end if;
		else
			raise_application_error(-20001, 'Transport protocol is not defined');
		end if;

		utl_http.set_follow_redirect (
			max_redirects => 1
		);

		if airbrake_session.airbrake_host is not null and airbrake_session.airbrake_host_port is not null and airbrake_session.airbrake_api_name is not null and airbrake_session.airbrake_api_version is not null then
			airbrake_request := utl_http.begin_request(
				url => airbrake_session.transport_protocol || '://' || airbrake_session.airbrake_host || ':' || airbrake_session.airbrake_host_port || '/' || airbrake_session.airbrake_api_name || '/' || airbrake_session.airbrake_api_version || '/' || airbrake_call_request.call_endpoint
				, method => airbrake_call_request.call_method
			);
			dbms_output.put_line(airbrake_session.transport_protocol || '://' || airbrake_session.airbrake_host || ':' || airbrake_session.airbrake_host_port || '/' || airbrake_session.airbrake_api_name || '/' || airbrake_session.airbrake_api_version || '/' || airbrake_call_request.call_endpoint);
		else
			raise_application_error(-20001, 'airbrake site parameters invalid');
		end if;

		if airbrake_session.airbrake_project_id is not null then
			utl_http.set_header(
				r => airbrake_request
				, name => 'User-Agent'
				, value => 'AIRBRAKE_UTL Oracle pkg - ' || airbrake_session.airbrake_project_id
			);
		else
			raise_application_error(-20001, 'airbrake logon information not setup');
		end if;

		-- Method specific headers
		if (length(airbrake_call_request.call_json.to_char) > 4) then
			utl_http.set_header(
				r => airbrake_request
				, name => 'Content-Type'
				, value => 'application/json'
			);
			utl_http.set_header(
				r => airbrake_request
				, name => 'Content-Length'
				, value => length(airbrake_call_request.call_json.to_char)
			);
			-- Write the content
			utl_http.write_text (
				r => airbrake_request
				, data => airbrake_call_request.call_json.to_char
			);
		end if;

		airbrake_response := utl_http.get_response (
			r => airbrake_request
		);

		-- Should handle exceptions here
		airbrake_call_status_code := airbrake_response.status_code;
		airbrake_call_status_reason := airbrake_response.reason_phrase;

		-- Load header data before reading body
		for i in 1..utl_http.get_header_count(r => airbrake_response) loop
			utl_http.get_header(
				r => airbrake_response
				, n => i
				, name => airbrake_header_name
				, value => airbrake_header_value
			);
			airbrake_response_headers(airbrake_header_name) := airbrake_header_value;
		end loop;

		-- Collect response and put into api_result
		begin
			loop
				utl_http.read_text (
					r => airbrake_response
					, data => airbrake_result_piece
				);
				airbrake_api_raw_result := airbrake_api_raw_result || airbrake_result_piece;
			end loop;

			exception
				when utl_http.end_of_body then
					null;
				when others then
					raise;
		end;

		dbms_output.put_line(airbrake_api_raw_result);

		utl_http.end_response(
			r => airbrake_response
		);

		-- Parse result into json
		parse_airbrake_result;

	end talk;

	procedure init_talk (
		endpoint 				varchar2
		, endpoint_method		varchar2 default 'GET'
	)
	
	as
	
	begin
	
		airbrake_call_request.call_endpoint := endpoint;
		airbrake_call_request.call_method := endpoint_method;
		airbrake_call_request.call_json := json();
	
	end init_talk;

end airbrake;
/