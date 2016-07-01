/*****************************************************************************
Function name: RWT_fnc_cronJobRemove;
Authors: longbow
License: MIT License
https://github.com/ussrlongbow/rwt_cron
Version: 1.0
Dependencies:
	RWT_var_cronDebug

Changelog:
	=== 1.0 === 01-Jul-2016
		[added] toggleable logging, see RWT_var_cronDebug in RWT_fnc_cronIinit
		[changed] updated code comments
		
	=== 0.1 === 06-Mar-2015
		Initial release

Description:
	Function removes a job from cron scheduling manager. Executed on server.

Arguments:
	NUMBER _ID
		_ID - Integer, just job's numeric identifier.

Returns:
	NOTHING

*****************************************************************************/
private "_id";
_id = _this;
if (isServer) then
{
	if (RWT_var_cronDebug) then
	{
		diag_log format ["RWT_fnc_cronJobRemove: __LINE__: removing job with id: %1",_id];
	};
	call compile format ["RWT_var_cronJob_%1 = nil",_id];
};
