/*****************************************************************************
Function name: RWT_fnc_cronJobAdd;
Authors: longbow
License: MIT License
https://github.com/ussrlongbow/rwt_cron
Version: 1.0
Dependencies:
	RWT_var_cronIdProvider
	RWT_var_cronSchedule
	RWT_var_cronDebug

Changelog:
	=== 1.0 === 01-Jul-2016
		[added] toggleable logging, see RWT_var_cronDebug in RWT_fnc_cronIinit
		[changed] BIS_fnc_sortNum replaced with sort command
		[changed] changed variable names to unified naming standart
		[changed] updated code comments
		
	=== 0.1 === 06-Mar-2015
		Initial release

Description:
	Function adds a job to cron scheduling manager. Executed on server.

Arguments:
	ARRAY [_JOB,_ARGS,_FIRSTRUN,_INTERVAL,_ID]
		_JOB - Code to be executed by cron manager, executed in scheduled
			environment (by 'spawn' command)
		_ARGS - arguments for _JOB, available as (_this select 1)
		_FIRSTRUN - when this job should be executed first time.
			if _FIRSTRUN > time, it will be postponed until time reaches this
			value,	set it to 0 if you wish immediate execution after adding
			to cron manager
		_INTERVAL - interval in seconds between job runs, set to 0 if it is a
			one-time job
		_ID - Integer, just job's numeric identifier, use 0 to create a new
			job, and any other value > 0 to edit existing job. Added job
			parameters are stored on server in variable RWT_var_cronJob_X,
			where X = _ID.

Returns:
	NOTHING

*****************************************************************************/
// executing only on server host or in singleplayer
if (isServer) then {
	// debug logging
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobAdd: Entering function"];
	};
	private ["_job","_isnew","_first_time","_index","_time"];

	_job = _this;

	// debug logging
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobAdd: supplied job params: %1",_job];
	};

	// using time as our 'clock', since serverTime returns weird values after
	// mission start in multiplayer
	_time = time;

	// if we add new job this param should be 0
	// if modifying existing should be equal to job's id
	_isnew = _this select 4;

	// get new id for cron job
	_index = if (_isnew == 0) then
	{
		RWT_var_cronIdProvider = RWT_var_cronIdProvider + 1;
		RWT_var_cronIdProvider;
	} else {_isnew};
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobAdd: creating/modifying job: %1",_index];
	};

	// write the cron job to variable cronjob_##id
	_job call compile format ["RWT_var_cronJob_%1 = _this",_index];
	// first time to run this job
	// rounding down to seconds
	_first_time = floor (_this select 2);
	
	// if first time run is earlier current time that means immediate execution
	// all immedtiate to run jobs are considered to run at time 0 seconds from server start
	// means that we put all these jobs to var RWT_var_cronJobsAt_0
	// otherwise job execution may be delayed
	if (_time > _first_time) then {_first_time = 0};
	
	// if we already have _first_time in time table, do not alter it
	// primarily to avoid unnecessary sorting for immediate events
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobAdd: cron schedule before adding a job: %1",RWT_var_cronSchedule];
	};
	if (!(_first_time in RWT_var_cronSchedule)) then
	{
		// adding to timetable and sorting array to have earliest event
		// always available by (RWT_var_cronSchedule select 0)
		RWT_var_cronSchedule pushBack _first_time;
		RWT_var_cronSchedule sort true;
	};
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobAdd: cron schedule after adding a job: %1",RWT_var_cronSchedule];
	};
	// get the list of existing jobs for requested time
	_jobs = call compile format ["missionNamespace getVariable ['RWT_var_cronJobsAt_%1',[]]",_first_time];
	_jobs pushBack _index;
	_jobs call compile format ["RWT_var_cronJobsAt_%1 = _this",_first_time];
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobAdd: Exiting function"];
	};
};
