/*****************************************************************************
Function name: RWT_fnc_cronInit;
Authors: longbow
License: MIT License
https://github.com/ussrlongbow/rwt_cron
Version: 1.0
Dependencies:
	RWT_fnc_cronJobRun

Changelog:
	=== 1.0 === 01-Jul-2016
		[added] variables initialization moved to function
		
	=== 0.1 === 06-Mar-2015
		Initial release

Description:
	Function initializes cron scheduling manager. Executed on server. postInit
	must be set to 1, or run function manually on server after mission init.

Arguments:
	NONE

Returns:
	NOTHING

*****************************************************************************/
if (isServer) then
{
	// main trigger object, which checks if we have some jobs to do
	RWT_var_cronInstance = createTrigger ["EmptyDetector",[0,0,0],false];
	RWT_var_cronInstance setTriggerActivation ["NONE","PRESENT",true];
	RWT_var_cronInstance setTriggerStatements ["[] call RWT_fnc_cronJobRun", "", ""];
	
	// incremental counter for jobs
	RWT_var_cronIdProvider 	= 0;
	// variable which stores, when we have some jobs to run
	RWT_var_cronSchedule 	= [];
	// Writes debug information to logs, make sure allowFunctionsLog enabled
	// in mission's description.ext. Set to false for production release.
	RWT_var_cronDebug		= true;
};
