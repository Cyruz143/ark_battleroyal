// Add MPKilled for Kill feed
{_x addMPEventHandler ["MPKilled", {call ark_fnc_br_playerKillFeedUI}];} forEach playableUnits;

// Set everyone hostile to each other
west setFriend [west, 0];

// Setup emtpy arrays for loot
allPrimaryWeapons = [];
allSecondaryWeapons = [];
allBackpacks = [];
allVests = [];
allHelmets = [];

// Fill loot arrays
private _primaryWeaponConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 && { getText ( _x >> 'simulation' ) isEqualTo 'Weapon' && { getNumber ( _x >> 'type' ) isEqualTo 1 } } )" configClasses ( configFile >> "cfgWeapons" );
{  private _primaryWeaponString = configName (_x); 
    allPrimaryWeapons pushBack _primaryWeaponString; 
}  forEach _primaryWeaponConfig; 

private _secondaryWeaponConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 && { getText ( _x >> 'simulation' ) isEqualTo 'Weapon' && { getNumber ( _x >> 'type' ) isEqualTo 2 } } )" configClasses ( configFile >> "cfgWeapons" );
{  private _secondaryWeaponString = configName (_x); 
    allSecondaryWeapons pushBack _secondaryWeaponString; 
}  forEach _secondaryWeaponConfig; 

private _backpackConfig = "( getNumber ( _x >> ""scope"" ) isEqualTo 2 && { getNumber ( _x >> ""isbackpack"" ) isEqualTo 1 && { getNumber ( _x >> ""maximumLoad"" ) != 0 } } )" configClasses ( configFile >> "cfgVehicles");
{  private _backpackString = configName (_x); 
    allBackpacks pushBack _backpackString; 
}  forEach _backpackConfig;

private _vestConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 && { getText ( _x >> 'vehicleClass' ) isEqualTo 'ItemsVests' } )" configClasses ( configFile >> "cfgVehicles" );
{  private _vestString = configName (_x); 
    allVests pushBack _vestString; 
}  forEach _vestConfig;

private _helmetConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 && { getText ( _x >> 'vehicleClass' ) isEqualTo 'ItemsHeadgear' } )" configClasses ( configFile >> "cfgVehicles" );
{  private _helmetString = configName (_x); 
    allHelmets pushBack _helmetString; 
}  forEach _helmetConfig;

// Loot blacklist
{  private _brokenSecondary = allSecondaryWeapons find _x;
    allSecondaryWeapons deleteAt _brokenSecondary;
} forEach ["hlc_pistol_P239_40"];

// Set global variables
txt1Layer = "txt1" call BIS_fnc_rscLayer;
txt2Layer = "txt2" call BIS_fnc_rscLayer;
txt7Layer = "txt7" call BIS_fnc_rscLayer;
zoneReductionTime = 180;
zoneSizes = [4500,4000,3500,3000,2500,2000,1500,1000,500,250,100];
currentZoneIndex = 0; // this could be made a mission param to shorten game lengths / player counts (gimmicks?)
zoneCounter = 1;
lastZone = false;
zoneCenter = getMarkerPos "center_zone_marker";
planeExit = getMarkerPos "plane_exit_marker";
currentZoneMarker = createMarker ["currentZone", zoneCenter];
nextZone = createMarker ["nextZone", zoneCenter];

currentZoneMarker setMarkerShape "ELLIPSE";
currentZoneMarker setMarkerBrush "SolidBorder";
currentZoneMarker setMarkerColor "colorOPFOR";

// Set initial size to max
currentZoneMarker setMarkerSize [zoneSizes select currentZoneIndex, zoneSizes select currentZoneIndex];

nextZone setMarkerShape "ELLIPSE";
nextZone setMarkerBrush "SolidBorder";
nextZone setMarkerColor "ColorKhaki";
nextZone setMarkerSize [zoneSizes select (currentZoneIndex + 1), zoneSizes select (currentZoneIndex + 1)];

ark_fnc_br_spawnLoot = {
    private _buildingArray = zoneCenter nearObjects ["Building", 4000];
    // Scale building amount if required + adjust forEach loop to use _scaledBuildings
    /* private _scaledBuildings = [];
    for "_i" from 0 to (count _buildingArray) step 3 do {
        _scaledBuildings pushBack (_buildingArray select _i);
    }; */

    private _buildingCount = 0;
    private _lootCount = 0;

    {
        _buildingCount = _buildingCount + 1;
        private _buildingPositions = _x buildingPos -1;
        private _scaledBuildingPositions = [];
        for "_i" from 0 to (count _buildingPositions -1) step 4 do {
            _scaledBuildingPositions pushBack (_buildingPositions select _i);
        };
        {
            _lootCount = _lootCount + 1;
          
            private _randomNum = ceil (random 3);
            switch (_randomNum) do {
                case 1: {
                    private _primaryWeapon = selectRandom allPrimaryWeapons;
                    private _secondaryWeapon = selectRandom allSecondaryWeapons;
                    private _weapon = selectRandom [_primaryWeapon,_secondaryWeapon];
                    private _magazineArray = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
                    private _magazines = selectRandom _magazineArray;
                    
                    private _itemBox = "WeaponHolderSimulated" createVehicle [0,0,0];
                    _itemBox setDir random 360;
                    _itemBox setPos _x;
                    _itemBox setVectorUp surfaceNormal position _itemBox;
                    _itemBox addWeaponCargoGlobal [_weapon,1];
                    _itemBox addMagazineCargoGlobal [_magazines,3];
                    _itemBox enableDynamicSimulation true;

                    if (ark_br_debugState == 1) then {
                        private _itemBoxPos = getpos _itemBox;
                        private _markerstr = createMarker ["markername" + (str _itemBoxPos), _itemBoxPos];
                        _markerstr setMarkerColor "ColorRed";
                        _markerstr setMarkerShape "ICON";
                        _markerstr setMarkerType "hd_dot";
                    };
                };
                case 2: {
                    private _backpack = selectRandom allBackpacks;
                    private _vest = selectRandom allVests;
                    private _headgear = selectRandom allHelmets;
                    private _item = selectRandom [_backpack,_vest,_headgear];
                    
                    private _itemBox = "WeaponHolderSimulated" createVehicle [0,0,0];
                    _itemBox setDir random 360;
                    _itemBox setPos _x;
                    _itemBox setVectorUp surfaceNormal position _itemBox;
                    if ([_item] call ACE_backpacks_fnc_isBackpack) then {
                        _itemBox addBackpackCargoGlobal [_item,1];
                    } else {
                        _itemBox addItemCargoGlobal [_item,1];
                    };
                    _itemBox enableDynamicSimulation true;

                    if (ark_br_debugState == 1) then {
                        private _itemBoxPos = getpos _itemBox;
                        private _markerstr = createMarker ["markername" + (str _itemBoxPos), _itemBoxPos];
                        _markerstr setMarkerColor "ColorBlue";
                        _markerstr setMarkerShape "ICON";
                        _markerstr setMarkerType "hd_dot";
                    };
                };
                case 3: {
                    private _medicalItem = selectRandom ["ACE_fieldDressing","ACE_morphine"];
                    
                    private _itemBox = "WeaponHolderSimulated" createVehicle [0,0,0];
                    _itemBox setDir random 360;
                    _itemBox setPos _x;
                    _itemBox setVectorUp surfaceNormal position _itemBox;
                    _itemBox addItemCargoGlobal [_medicalItem,1];
                    _itemBox enableDynamicSimulation true;
                    
                    if (ark_br_debugState == 1) then {
                        private _itemBoxPos = getpos _itemBox;
                        private _markerstr = createMarker ["markername" + (str _itemBoxPos), _itemBoxPos];
                        _markerstr setMarkerColor "ColorGreen";
                        _markerstr setMarkerShape "ICON";
                        _markerstr setMarkerType "hd_dot";
                    };
                };
                default { hint format ["%1", _randomNum] };
            };
        } forEach _scaledBuildingPositions;
    } forEach _buildingArray;
    if (ark_br_debugState == 1) then {
        systemChat format["Total buildings in area: %1", _buildingCount];
        systemChat format["Total loot spots: %1", _lootCount];
    };
};

ark_fnc_br_lootCrate = {
    _lootCrate = _this select 0;

    clearItemCargoGlobal _lootCrate; 
    clearMagazineCargoGlobal _lootCrate; 
    clearWeaponCargoGlobal _lootCrate; 
    clearBackpackCargoGlobal _lootCrate; 

    private _selectedBackpack = selectRandom allBackpacks;
    private _selectedVest = selectRandom allVests;
    private _selectedHeadgear = selectRandom allHelmets;
    private _selectedMedical = selectRandom ["ACE_fieldDressing","ACE_morphine"];

    _lootCrate addBackpackCargoGlobal [_selectedBackpack, 1];
    _lootCrate addItemCargoGlobal [_selectedVest, 1];
    _lootCrate addItemCargoGlobal [_selectedHeadgear, 1];
    _lootCrate addItemCargoGlobal [_selectedMedical, 10];

    private _primaryWeapon = selectRandom allPrimaryWeapons;
    private _secondaryWeapon = selectRandom allSecondaryWeapons;
    private _primaryWeaponmagazineArray = getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines");
    private _primaryWeaponmagazine = selectRandom _primaryWeaponmagazineArray;
    private _secondaryWeaponmagazineArray = getArray (configFile >> "CfgWeapons" >> _secondaryWeapon >> "magazines");
    private _secondaryWeaponmagazine = selectRandom _secondaryWeaponmagazineArray;

    _lootCrate addWeaponCargoGlobal [_primaryWeapon, 1];
    _lootCrate addMagazineCargoGlobal [_primaryWeaponmagazine, 10];
    _lootCrate addWeaponCargoGlobal [_secondaryWeapon, 1];
    _lootCrate addMagazineCargoGlobal [_secondaryWeaponmagazine, 10];
    _lootCrate addMagazineCargoGlobal ["HandGrenade", 5];
};

ark_fnc_br_spawnVehicles = {
    private _roadsArray = zoneCenter nearRoads 3500;
    private _vehiclesArray = ["CUP_C_Octavia_CIV", "CUP_C_Skoda_Blue_CIV", "CUP_C_UAZ_Open_TK_CIV", "CUP_C_Ural_Civ_03", "CUP_C_Datsun_4seat" ,"CUP_C_Golf4_random_Civ", "CUP_C_Golf4_kitty_Civ", "C_Offroad_01_repair_F", "C_Quadbike_01_white_F", "C_Offroad_02_unarmed_orange_F", "C_Offroad_02_unarmed_blue_F", "CUP_C_Ikarus_TKC", "CUP_C_Ikarus_Chernarus"];
    private _playerCount = count playableUnits;

    for "_i" from 1 to _playerCount do {
        private _roadSpawnArea = selectRandom _roadsArray;
        private _roadArrayIndex = _roadsArray find _roadSpawnArea;
        _roadsArray deleteAt _roadArrayIndex;
        private _roadPos = getpos _roadSpawnArea;
        private _selectedVehicle = selectRandom _vehiclesArray;

        if (isOnRoad _roadSpawnArea) then {
            private _veh = _selectedVehicle createVehicle _roadPos;
            _veh setDir (getDir _roadSpawnArea);
            _veh setVectorUp surfaceNormal position _veh;
            _veh setfuel 0.1;
            [_veh] call ark_fnc_br_lootCrate;

            if (ark_br_debugState == 1) then {
                private _vehPos = getpos _veh;
                private _markerstr = createMarker ["markername" + (str _vehPos), _vehPos];
                _markerstr setMarkerColor "ColorPink";
                _markerstr setMarkerShape "ICON";
                _markerstr setMarkerType "hd_dot";
            };
        };
    };
};

ark_fnc_br_spawnPlane = {
    private _grp = createGroup [civilian, true];
    private _pilot = _grp createUnit ["C_man_pilot_F", [0,0,0], [], 0, "NONE"];
    c130_start_plane = createVehicle ["CUP_B_C130J_GB", [0,0,1500], [], 0, "FLY"];
    publicVariable "c130_start_plane";
    _pilot moveInDriver c130_start_plane;
    c130_start_plane flyInHeight 1000;

    clearItemCargoGlobal c130_start_plane;
    clearMagazineCargoGlobal c130_start_plane;
    clearWeaponCargoGlobal c130_start_plane;
    clearBackpackCargoGlobal c130_start_plane;

    private _wp = _grp addWaypoint [zoneCenter, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointCombatMode "BLUE";
    _wp setWaypointSpeed "FULL";

    private _wp1 = _grp addWaypoint [planeExit, 0];
    _wp1 setWaypointType "MOVE";
    _wp1 setWaypointBehaviour "CARELESS";
    _wp1 setWaypointCombatMode "BLUE";
    _wp1 setWaypointSpeed "FULL";

    waitUntil { c130_start_plane inArea currentZoneMarker };
    private _cargo = crew c130_start_plane;
    private _removePilot = _cargo find _pilot;
    _cargo deleteAt _removePilot;
    
    private _ejectMessage = "You're inside the zone<br />Eject before the plane leaves the area";

    {
        "alarm_independent" remoteExec ["playSound", _x];
        [_ejectMessage,-1,-1,5,0,0,txt7Layer] remoteExec ["BIS_fnc_dynamicText", _x];
    } forEach _cargo;

    waitUntil { c130_start_plane inArea "plane_exit_marker" };
    deleteVehicle c130_start_plane;
    deleteVehicle _pilot;
};

ark_fnc_br_startingCountdownServer = {
    uiSleep 20;
    [startCrate] call ark_fnc_br_lootCrate;
    {deleteVehicle _x} forEach [fence1,fence2,fence3,fence4,fence5,fence6,fence7,fence8];
};

ark_fnc_br_playerKillFeedUI = {
    private _victim = _this select 0;
    private _attacker = _this select 1;
    private _instigator = _this select 2;
 
    if (isNull _attacker) then {
        _attacker = _instigator;
    };

    if ((isNull _attacker) || (_attacker == _victim)) then {
        private _aceSource = _victim getVariable ["ace_medical_lastDamageSource", objNull];
        if ((!isNull _aceSource) && {_aceSource != _victim}) then {
            _attacker = _aceSource;
        };
    };

    private _victimName = name _victim;
    private _attackerName = name _attacker;

    if ((!isNull _attacker) && {!(_attacker isKindof "CAManBase")}) then {
        _attacker = effectiveCommander _attacker;
    };

    private _killMessage = format ["<t size='0.5' color='#0000cc' font='EtelkaMonospaceProBold'>%1</t><t size='0.5' color='#FFFFFF' font='EtelkaMonospaceProBold'> killed </t><t size='0.5' color='#FF0000' font='EtelkaMonospaceProBold'>%2</t>",_attackerName,_victimName];

    if (isNull _attacker) then {
        _killMessage = format ["<t size='0.5' color='#0000cc' font='EtelkaMonospaceProBold'>%1</t> <t size='0.5' color='#FFFFFF' font='EtelkaMonospaceProBold'>was killedt</t>",_victimName];
    };

    if(_attacker == _victim) then {
        _killMessage = format ["<t size='0.5' color='#0000cc' font='EtelkaMonospaceProBold'>%1</t> <t size='0.5' color='#FFFFFF' font='EtelkaMonospaceProBold'>bled out</t>",_victimName];
    };

    [_killmessage,-safezoneX,-safezoneY,5,0,0,txt2Layer] remoteExec ["BIS_fnc_dynamicText", -2];
};

ark_fnc_br_roundTimer = {
    private _elapsedTime = floor(diag_tickTime - startTime);
    private _remainingZoneTime = floor(zoneCounter * zoneReductionTime - _elapsedTime);
    
    if (_remainingZoneTime < 1 && lastZone) then {
      _remainingZoneTime = 0;
    };
  
    missionNamespace setVariable ["updateZoneTime", _remainingZoneTime];
    publicVariable "updateZoneTime";

    if (_remainingZoneTime < 1 && !(lastZone)) then {
        [] spawn ark_fnc_br_nextZone;
    };

    uiSleep 1;
    [] spawn ark_fnc_br_roundTimer;
};

ark_fnc_br_nextZone = {
    currentZoneIndex = currentZoneIndex + 1;
    zoneCounter = zoneCounter + 1;

    private _currentZoneSize = zoneSizes select currentZoneIndex;
    currentZoneMarker setMarkerSize [_currentZoneSize, _currentZoneSize];

    private _nextZoneSize = zoneSizes select (currentZoneIndex + 1);

    // We have no more zones after the current one, let's hide it
    if (isNil {_nextZoneSize}) then {
        lastZone = true;
        nextZone setMarkerSize [0, 0];
    } else {
        nextZone setMarkerSize [_nextZoneSize, _nextZoneSize];
        [] spawn ark_fnc_br_spawnCrateDrop;
    };

    currentZoneMarker remoteExec ["ark_fnc_br_updateZone", -2];
    "Alarm" remoteExec ["playSound", -2];
    ["Zones have been updated<br />Check your map",-1,safezoneY+0.25,3,0,0,txt1Layer] remoteExec ["BIS_fnc_dynamicText", -2];
};

ark_fnc_br_spawnCrateDrop = {
    private _randomPlayer = selectRandom playableUnits;
    private _position = getPosATL _randomPlayer; 
    _position set [2, 150]; 
    
    private _parachute = createVehicle ["B_Parachute_02_F", _position, [], 0, "FLY"]; 
    private _ammoBox = createVehicle ["B_CargoNet_01_ammo_F", position _parachute, [], 0, "NONE"]; 
    _ammoBox allowDamage false; 
    [_ammoBox] call ark_fnc_br_lootCrate;
    
    _ammoBox attachTo [_parachute, [0, 0, -1.3]]; 
    private _smoke = createVehicle ["SmokeShellOrange", position _parachute, [], 0, "NONE"]; 
    _smoke attachTo [_parachute, [0, 0, 0]]; 
    
    for "_i" from 1 to 3 do {
        [_ammoBox, "air_raid", 500] call CBA_fnc_globalSay3d;
        uiSleep 10;
    };

    waitUntil { getPosATL _ammoBox select 2 < 1 || isNull _parachute }; 
    detach _ammoBox; 
};

ark_fnc_br_movePlayersInPlane = {
    {
        [_x,c130_start_plane] remoteExec ["moveInCargo", _x];
        uiSleep 0.25;
    } forEach playableUnits;
};

ark_fnc_br_init = {
    startTime = diag_tickTime;

    [] spawn ark_fnc_br_roundTimer;
};

[] spawn ark_fnc_br_spawnLoot;
[] spawn ark_fnc_br_spawnVehicles;

if (ark_br_startStyle == 1) then {
    [] spawn ark_fnc_br_spawnPlane;
    {deleteVehicle _x} forEach [fence1,fence2,fence3,fence4,fence5,fence6,fence7,fence8,startCrate];
    [] spawn ark_fnc_br_movePlayersInPlane;
};

waitUntil {
  [] call hull3_mission_fnc_hasSafetyTimerEnded;
};

[] call ark_fnc_br_init;

if (ark_br_startStyle == 0) then {
    [] spawn ark_fnc_br_startingCountdownServer;
};