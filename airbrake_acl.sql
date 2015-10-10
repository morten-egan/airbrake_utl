begin
	dbms_network_acl_admin.create_acl (
		acl => 'airbrake_acl.xml',
		description => 'ACL definition for Airbrake.io access',
		principal => 'AIRBRAKE',
		is_grant => true, 
		privilege => 'connect',
		start_date => systimestamp,
		end_date => null
	);

	commit;

	dbms_network_acl_admin.add_privilege (
		acl => 'airbrake_acl.xml',
		principal => 'AIRBRAKE',
		is_grant => true,
		privilege => 'resolve'
	);

	commit;

	dbms_network_acl_admin.assign_acl (
		acl => 'airbrake_acl.xml',
		host => 'airbrake.io',
		lower_port => 443,
		upper_port => null
	);

	commit;

end;
/