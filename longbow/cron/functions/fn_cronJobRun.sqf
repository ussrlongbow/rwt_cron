/*****************************************************************************
Function name: RWT_fnc_cronJobRun;
Authors: longbow
License: MIT License
https://github.com/ussrlongbow/rwt_cron
Version: 1.0
Dependencies:
	RWT_fnc_cronJobAdd
	RWT_fnc_cronJobRemove
	RWT_var_cronDebug
	RWT_var_cronSchedule

Changelog:
	=== 1.0 === 01-Jul-2016
		[added] toggleable logging, see RWT_var_cronDebug in RWT_fnc_cronIinit
		[changed] updated code comments
		
	=== 0.1 === 06-Mar-2015
		Initial release

Description:
	Runs jobs from RWT_var_cronSchedule if time > jobs' execution time.
	Executed on server.

Arguments:
	NONE

Returns:
	NOTHING

*****************************************************************************/
private ["_time","_earliest","_jobs"];

// current time
_time = time;

if (isServer) then {
	// exit if no jobs
	if (count RWT_var_cronSchedule == 0) exitWith {false};

	// get the time of earliest event
	_earliest = RWT_var_cronSchedule select 0;
	// exit if earliest event is in future
	if (_time < _earliest) exitWith {false};

	// remove event from timetable if it occurs
	RWT_var_cronSchedule deleteAt 0;
	_jobs = call compile format ["missionNamespace getVariable ['RWT_var_cronJobsAt_%1',[]]",_earliest];

	// if no jobs at this time, nil this var and exit
	if (_jobs isEqualTo []) exitWith
	{
		[] call compile format ["RWT_var_cronJobsAt_%1 = nil",_earliest];
		false;
	};
	
	// run jobs
	{
		private ["_job","_interval","_new_time","_index"];
		// read job data
		_new_time = 0;
		_index = _x;
		// job we run in this iteration
		_job = call compile format ["RWT_var_cronJob_%1",_index];
		// finding job interval
		_interval = _job select 3;
		// spawn function defined in _job's code
		[_index,(_job select 1)] spawn (_job select 0);
		if (_interval != 0) then
		{
			// reschedule job for new time
			_new_time = _interval + _time;
			_job set [2,_new_time];
			_job set [4,_index];
			_job call RWT_fnc_cronJobAdd;
		} else {_index call RWT_fnc_cronJobRemove;};
	} forEach _jobs;
	// nil var with jobs, since we ran them
	[] call compile format ["RWT_var_cronJobsAt_%1 = nil",_earliest];
};
