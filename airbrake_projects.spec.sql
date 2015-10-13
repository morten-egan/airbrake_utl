create or replace package airbrake_project

as

	/** Airbrake API - This package integrates with the Airbrake project endpoint
	* @author Morten Egan
	* @version 0.0.1
	* @project AIRBRAKE_UTL
	*/
	p_version		varchar2(50) := '0.0.1';

	/** List all projects for a given user
	* @author Morten Egan
	*/
	function list_projects
	return airbrake.call_result;

	/** List a specific project
	* @author Morten Egan
	* @param project_id The project that we want to retrieve the details on
	*/
	function show_project (
		project_id						in				number
	)
	return airbrake.call_result;

end airbrake_project;
/