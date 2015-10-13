create or replace package airbrake_deploys

as

	/** AirBrake API - This package integrates with the deploys endpoint
	* @author Morten Egan
	* @version 0.0.1
	* @project AIRBRAKE_UTL
	*/
	p_version		varchar2(50) := '0.0.1';

	/** This procedure will create a deployment in Airbrake
	* @author Morten Egan
	* @param environment The environment where the deploy happens
	*/
	procedure create_deploy (
		environment						in				varchar2
		, username						in				varchar2
		, repository					in				varchar2
		, revision						in				varchar2
		, version						in				varchar2
		, project_id					in				number default null
	);

	/** This function will return the json of all the deployments registered in Airbrake for the project ID currently set.
	* @author Morten Egan
	*/
	function list_deploys (
		project_id						in				number default null
	)
	return airbrake.call_result;

	/** This function will return information about a single deployment, with the given deployment id.
	* @author Morten Egan
	* @param deploy_id The ID number of the deployment 
	*/
	function show_deploy (
		deploy_id						in				number
		, project_id					in				number default null
	)
	return airbrake.call_result;

end airbrake_deploys;
/