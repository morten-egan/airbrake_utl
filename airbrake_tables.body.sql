create or replace package body airbrake_tables

as

	function list_projects 
	return airbrake_project_list
	pipelined
	
	as
	
		l_ret_val			airbrake_project_typ;
		l_api_result		airbrake.call_result;
		l_project_count		number;
	
	begin
	
		l_api_result := airbrake_project.list_projects;

		if l_api_result.result.exist('projects') then
			l_project_count := json_list(l_api_result.result.get('projects')).count;
			for i in 1..l_project_count loop
				l_ret_val.id := json_ext.get_number(l_api_result.result, 'projects['||i||'].id');
				l_ret_val.name := json_ext.get_string(l_api_result.result, 'projects['||i||'].name');
				l_ret_val.deployid := json_ext.get_number(l_api_result.result, 'projects['||i||'].deployid');
				l_ret_val.deployat := null;
				l_ret_val.noticetotalcount := json_ext.get_number(l_api_result.result, 'projects['||i||'].noticeTotalCount');
				l_ret_val.rejectioncount := json_ext.get_number(l_api_result.result, 'projects['||i||'].rejectionCount');
				l_ret_val.filecount := json_ext.get_number(l_api_result.result, 'projects['||i||'].fileCount');
				l_ret_val.deploycount := json_ext.get_number(l_api_result.result, 'projects['||i||'].deployCount');
				l_ret_val.groupresolvedcount := json_ext.get_number(l_api_result.result, 'projects['||i||'].groupResolvedCount');
				l_ret_val.groupunresolvedcount := json_ext.get_number(l_api_result.result, 'projects['||i||'].groupUnresolvedCount');
				pipe row(l_ret_val);
			end loop;
		else
			l_ret_val.id := null;
			l_ret_val.name := null;
			l_ret_val.deployid := null;
			l_ret_val.deployat := null;
			l_ret_val.noticetotalcount := null;
			l_ret_val.rejectioncount := null;
			l_ret_val.filecount := null;
			l_ret_val.deploycount := null;
			l_ret_val.groupresolvedcount := null;
			l_ret_val.groupunresolvedcount := null;
			pipe row(l_ret_val);
		end if;
	
		return;
	
		exception
			when others then
				raise;
	
	end list_projects;

	function show_project (
		project_id					in				number
	)
	return airbrake_project_list
	pipelined
	
	as
	
		l_ret_val			airbrake_project_typ;
		l_api_result		airbrake.call_result;
	
	begin
	
		l_api_result := airbrake_project.show_project(project_id);

		if l_api_result.result.exist('project') then
			l_ret_val.id := json_ext.get_number(l_api_result.result, 'project.id');
			l_ret_val.name := json_ext.get_string(l_api_result.result, 'project.name');
			l_ret_val.deployid := json_ext.get_number(l_api_result.result, 'project.deployid');
			l_ret_val.deployat := null;
			l_ret_val.noticetotalcount := json_ext.get_number(l_api_result.result, 'project.noticeTotalCount');
			l_ret_val.rejectioncount := json_ext.get_number(l_api_result.result, 'project.rejectionCount');
			l_ret_val.filecount := json_ext.get_number(l_api_result.result, 'project.fileCount');
			l_ret_val.deploycount := json_ext.get_number(l_api_result.result, 'project.deployCount');
			l_ret_val.groupresolvedcount := json_ext.get_number(l_api_result.result, 'project.groupResolvedCount');
			l_ret_val.groupunresolvedcount := json_ext.get_number(l_api_result.result, 'project.groupUnresolvedCount');
			pipe row(l_ret_val);
		else
			l_ret_val.id := null;
			l_ret_val.name := null;
			l_ret_val.deployid := null;
			l_ret_val.deployat := null;
			l_ret_val.noticetotalcount := null;
			l_ret_val.rejectioncount := null;
			l_ret_val.filecount := null;
			l_ret_val.deploycount := null;
			l_ret_val.groupresolvedcount := null;
			l_ret_val.groupunresolvedcount := null;
			pipe row(l_ret_val);
		end if;
		
		return;
	
		exception
			when others then
				raise;
	
	end show_project;

	function list_deploys (
		project_id						in				number default null
	)
	return airbrake_deploy_list
	pipelined
	
	as
	
		l_ret_val			airbrake_deploy_typ;
		l_api_result		airbrake.call_result;
		l_deploy_count		number;
	
	begin
	
		if project_id is not null then
			l_api_result := airbrake_deploys.list_deploys(project_id);
		else
			l_api_result := airbrake_deploys.list_deploys;
		end if;

		if l_api_result.result.exist('deploys') then
			l_deploy_count := json_list(l_api_result.result.get('deploys')).count;
			for i in 1..l_deploy_count loop
				l_ret_val.id := json_ext.get_string(l_api_result.result, 'deploys['||i||'].id');
				l_ret_val.userId := json_ext.get_number(l_api_result.result, 'deploys['||i||'].userId');
				l_ret_val.projectId := json_ext.get_number(l_api_result.result, 'deploys['||i||'].projectId');
				l_ret_val.environment := json_ext.get_string(l_api_result.result, 'deploys['||i||'].environment');
				l_ret_val.username := json_ext.get_string(l_api_result.result, 'deploys['||i||'].username');
				l_ret_val.repository := json_ext.get_string(l_api_result.result, 'deploys['||i||'].repository');
				l_ret_val.revision := json_ext.get_string(l_api_result.result, 'deploys['||i||'].revision');
				l_ret_val.version := json_ext.get_string(l_api_result.result, 'deploys['||i||'].version');
				l_ret_val.noticetotalcount := json_ext.get_number(l_api_result.result, 'deploys['||i||'].noticeTotalCount');
				l_ret_val.groupresolvedcount := json_ext.get_number(l_api_result.result, 'deploys['||i||'].groupResolvedCount');
				l_ret_val.groupunresolvedcount := json_ext.get_number(l_api_result.result, 'deploys['||i||'].groupUnresolvedCount');
				l_ret_val.errorcreatedcount := json_ext.get_number(l_api_result.result, 'deploys['||i||'].errorCreatedCount');
				l_ret_val.errorresolvedcount := json_ext.get_number(l_api_result.result, 'deploys['||i||'].errorResolvedCount');
				l_ret_val.errorunresolvedcount := json_ext.get_number(l_api_result.result, 'deploys['||i||'].errorUnresolvedCount');
				l_ret_val.createdat := null;
				l_ret_val.updatedat := null;
				pipe row(l_ret_val);
			end loop;
		else
			l_ret_val.id := null;
			l_ret_val.userId := null;
			l_ret_val.projectId := null;
			l_ret_val.environment := null;
			l_ret_val.username := null;
			l_ret_val.repository := null;
			l_ret_val.revision := null;
			l_ret_val.version := null;
			l_ret_val.noticetotalcount := null;
			l_ret_val.groupresolvedcount := null;
			l_ret_val.groupunresolvedcount := null;
			l_ret_val.errorcreatedcount := null;
			l_ret_val.errorresolvedcount := null;
			l_ret_val.errorunresolvedcount := null;
			l_ret_val.createdat := null;
			l_ret_val.updatedat := null;
			pipe row(l_ret_val);
		end if;
		
		return;
	
		exception
			when others then
				raise;
	
	end list_deploys;

	function show_deploy (
		deploy_id					in				varchar2
		, project_id				in				number default null
	)
	return airbrake_deploy_list
	pipelined
	
	as
	
		l_ret_val			airbrake_deploy_typ;
		l_api_result		airbrake.call_result;
	
	begin
	
		if project_id is not null then
			l_api_result := airbrake_deploys.show_deploy(deploy_id, project_id);
		else
			l_api_result := airbrake_deploys.show_deploy(deploy_id);
		end if;

		if l_api_result.result.exist('deploy') then
			l_ret_val.id := json_ext.get_string(l_api_result.result, 'deploy.id');
			l_ret_val.userId := json_ext.get_number(l_api_result.result, 'deploy.userId');
			l_ret_val.projectId := json_ext.get_number(l_api_result.result, 'deploy.projectId');
			l_ret_val.environment := json_ext.get_string(l_api_result.result, 'deploy.environment');
			l_ret_val.username := json_ext.get_string(l_api_result.result, 'deploy.username');
			l_ret_val.repository := json_ext.get_string(l_api_result.result, 'deploy.repository');
			l_ret_val.revision := json_ext.get_string(l_api_result.result, 'deploy.revision');
			l_ret_val.version := json_ext.get_string(l_api_result.result, 'deploy.version');
			l_ret_val.noticetotalcount := json_ext.get_number(l_api_result.result, 'deploy.noticeTotalCount');
			l_ret_val.groupresolvedcount := json_ext.get_number(l_api_result.result, 'deploy.groupResolvedCount');
			l_ret_val.groupunresolvedcount := json_ext.get_number(l_api_result.result, 'deploy.groupUnresolvedCount');
			l_ret_val.errorcreatedcount := json_ext.get_number(l_api_result.result, 'deploy.errorCreatedCount');
			l_ret_val.errorresolvedcount := json_ext.get_number(l_api_result.result, 'deploy.errorResolvedCount');
			l_ret_val.errorunresolvedcount := json_ext.get_number(l_api_result.result, 'deploy.errorUnresolvedCount');
			l_ret_val.createdat := null;
			l_ret_val.updatedat := null;
			pipe row(l_ret_val);
		else
			l_ret_val.id := null;
			l_ret_val.userId := null;
			l_ret_val.projectId := null;
			l_ret_val.environment := null;
			l_ret_val.username := null;
			l_ret_val.repository := null;
			l_ret_val.revision := null;
			l_ret_val.version := null;
			l_ret_val.noticetotalcount := null;
			l_ret_val.groupresolvedcount := null;
			l_ret_val.groupunresolvedcount := null;
			l_ret_val.errorcreatedcount := null;
			l_ret_val.errorresolvedcount := null;
			l_ret_val.errorunresolvedcount := null;
			l_ret_val.createdat := null;
			l_ret_val.updatedat := null;
			pipe row(l_ret_val);
		end if;
		
		return;
	
		exception
			when others then
				raise;
	
	end show_deploy;

end airbrake_tables;
/