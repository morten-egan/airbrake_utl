create or replace package airbrake_tables

as

	/** Package with table functions, for selecting information direcly from Airbrake.
	* @author Morten Egan
	* @version 0.0.1
	* @project AIRBRAKE_UTL
	*/
	p_version		varchar2(50) := '0.0.1';

	-- Airbrake record types
	type airbrake_project_typ is record (
		id							number
		, name						varchar2(4000)
		, deployid					number
		, deployat					timestamp
		, noticetotalcount			number
		, rejectioncount			number
		, filecount					number
		, deploycount				number
		, groupresolvedcount		number
		, groupunresolvedcount		number
	);

	type airbrake_project_list is table of airbrake_project_typ;

	type airbrake_deploy_typ is record (
		id							varchar2(100)
		, userId					number
		, projectId					number
		, environment				varchar2(4000)
		, username					varchar2(4000)
		, repository				varchar2(4000)
		, revision					varchar2(4000)
		, version					varchar2(4000)
		, noticetotalcount			number
		, groupresolvedcount		number
		, groupunresolvedcount		number
		, errorcreatedcount			number
		, errorresolvedcount		number
		, errorunresolvedcount		number
		, createdat					timestamp
		, updatedat					timestamp
	);

	type airbrake_deploy_list is table of airbrake_deploy_typ;

	/** List all of the projects for the set user
	* @author Morten Egan
	*/
	function list_projects
	return airbrake_project_list
	pipelined;

	/** List one specific project with the given ID
	* @author Morten Egan
	* @param project_id The project ID to get information about
	*/
	function show_project (
		project_id						in				number
	)
	return airbrake_project_list
	pipelined;

	/** List all of deployments for a given project. Expect project ID to be set in environment, but can be set specifically.
	* @author Morten Egan
	* @param project_id The project id
	*/
	function list_deploys (
		project_id						in				number default null
	)
	return airbrake_deploy_list
	pipelined;

	/** List the details of one deployment.
	* @author Morten Egan
	* @param deploy_id The ID of the deployment
	*/
	function show_deploy (
		deploy_id						in				varchar2
		, project_id					in				number default null
	)
	return airbrake_deploy_list
	pipelined;

end airbrake_tables;
/