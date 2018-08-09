// Add MPKilled for Kill feed
{_x addMPEventHandler ["MPKilled", {call ark_fnc_br_playerKillFeedUI}];} forEach playableUnits;

// Set everyone hostile to each other
west setFriend [west, 0];

// Setup emtpy arrays for loot
BRallPrimaryWeapons = [];
BRallSecondaryWeapons = [];
BRallBackpacks = [];
BRallVests = [];
BRallHelmets = [];
BRallVehicles = [];

// Fill loot arrays
private _backpackConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 && { getNumber ( _x >> 'isbackpack' ) isEqualTo 1 && { getNumber ( _x >> 'maximumLoad' ) != 0 } } )" configClasses ( configFile >> "cfgVehicles");
{
    private _backpackString = configName (_x);
    BRallBackpacks pushBack _backpackString;
} forEach _backpackConfig;

private _vehicleConfigs = "( getNumber ( _x >> 'scope' ) isEqualTo 2 && { getText ( _x >> 'vehicleClass' ) isEqualTo 'Car' && { getNumber ( _x >> 'side' ) isEqualTo 3 } } )" configClasses ( configFile >> "cfgVehicles");
{
    private _vehicleString = configName (_x);
    BRallVehicles pushBack _vehicleString; 
} forEach _vehicleConfigs;

private _itemConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 )" configClasses ( configFile >> "cfgWeapons" );
{  private _itemString = configName (_x); 
    switch (_itemString call BIS_fnc_itemType select 1) do
    {
        case "AssaultRifle": {BRallPrimaryWeapons pushBack _itemString};
        case "MachineGun": {BRallPrimaryWeapons pushBack _itemString};
        case "Shotgun": {BRallPrimaryWeapons pushBack _itemString};
        case "Rifle": {BRallPrimaryWeapons pushBack _itemString};
        case "SubmachineGun": {BRallPrimaryWeapons pushBack _itemString};
        case "Handgun": {BRallSecondaryWeapons pushBack _itemString};
        case "Vest": {BRallVests pushBack _itemString};
        case "Headgear": {BRallHelmets pushBack _itemString};
        default {};
    };
} forEach _itemConfig;

// Loot blacklist
{ private _brokenPrimary = BRallPrimaryWeapons find _x;
    BRallPrimaryWeapons deleteAt _brokenPrimary;
} forEach ["HLC_Rifle_g3ka4_GL_XMAG"];

{ private _brokenSecondary = BRallSecondaryWeapons find _x;
    BRallSecondaryWeapons deleteAt _brokenSecondary;
} forEach ["hlc_pistol_P239_40"];

{ private _brokenHelmet = BRallHelmets find _x;
    BRallHelmets deleteAt _brokenHelmet;
} forEach ["H_HelmetO_ViperSP_ghex_F","H_HelmetO_ViperSP_hex_F"];

{ private _brokenVest = BRallVests find _x;
    BRallVests deleteAt _brokenVest;
} forEach ["V_RebreatherB","V_RebreatherIR","V_RebreatherIA"];

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
                    private _primaryWeapon = selectRandom BRallPrimaryWeapons;
                    private _magazineArray = getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines");
                    if (isNil "_magazineArray" || { count _magazineArray == 0 }) exitWith {};
                    private _magazines = selectRandom _magazineArray;
                    
                    private _itemBox = "WeaponHolderSimulated" createVehicle [0,0,0];
                    _itemBox setDir random 360;
                    _itemBox setPos _x;
                    _itemBox setVectorUp surfaceNormal position _itemBox;
                    _itemBox addWeaponCargoGlobal [_primaryWeapon,1];
                    _itemBox addMagazineCargoGlobal [_magazines,3];

                    if (ark_br_debugState == 1) then {
                        private _itemBoxPos = getpos _itemBox;
                        private _markerstr = createMarker ["markername" + (str _itemBoxPos), _itemBoxPos];
                        _markerstr setMarkerColor "ColorRed";
                        _markerstr setMarkerShape "ICON";
                        _markerstr setMarkerType "hd_dot";
                    };
                };
                case 2: {
                    private _backpack = selectRandom BRallBackpacks;
                    private _vest = selectRandom BRallVests;
                    private _headgear = selectRandom BRallHelmets;
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

                    if (ark_br_debugState == 1) then {
                        private _itemBoxPos = getpos _itemBox;
                        private _markerstr = createMarker ["markername" + (str _itemBoxPos), _itemBoxPos];
                        _markerstr setMarkerColor "ColorBlue";
                        _markerstr setMarkerShape "ICON";
                        _markerstr setMarkerType "hd_dot";
                    };
                };
                case 3: {
                    private _secondaryWeapon = selectRandom BRallSecondaryWeapons;
                    private _magazineArray = getArray (configFile >> "CfgWeapons" >> _secondaryWeapon >> "magazines");
                    if (isNil "_magazineArray" || { count _magazineArray == 0 }) exitWith {};
                    private _magazines = selectRandom _magazineArray;
                    
                    private _itemBox = "WeaponHolderSimulated" createVehicle [0,0,0];
                    _itemBox setDir random 360;
                    _itemBox setPos _x;
                    _itemBox setVectorUp surfaceNormal position _itemBox;
                    _itemBox addWeaponCargoGlobal [_secondaryWeapon,1];
                    _itemBox addMagazineCargoGlobal [_magazines,3];


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
    params ["_lootCrate"];

    clearItemCargoGlobal _lootCrate; 
    clearMagazineCargoGlobal _lootCrate; 
    clearWeaponCargoGlobal _lootCrate; 
    clearBackpackCargoGlobal _lootCrate; 

    private _selectedBackpack = selectRandom BRallBackpacks;
    private _selectedVest = selectRandom BRallVests;
    private _selectedHeadgear = selectRandom BRallHelmets;

    _lootCrate addBackpackCargoGlobal [_selectedBackpack, 1];
    _lootCrate addItemCargoGlobal [_selectedVest, 1];
    _lootCrate addItemCargoGlobal [_selectedHeadgear, 1];
    _lootCrate addItemCargoGlobal ["ACE_fieldDressing", 10];
    _lootCrate addItemCargoGlobal ["ACE_morphine", 5];

    private _primaryWeapon = selectRandom BRallPrimaryWeapons;
    private _secondaryWeapon = selectRandom BRallSecondaryWeapons;
    
    private _primaryWeaponmagazineArray = getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines");
    if (isNil "_primaryWeaponmagazineArray" || { count _primaryWeaponmagazineArray == 0 }) exitWith {};
    private _primaryWeaponmagazine = selectRandom _primaryWeaponmagazineArray;
    
    private _secondaryWeaponmagazineArray = getArray (configFile >> "CfgWeapons" >> _secondaryWeapon >> "magazines");
    if (isNil "_secondaryWeaponmagazineArray" || { count _secondaryWeaponmagazineArray == 0 }) exitWith {};
    private _secondaryWeaponmagazine = selectRandom _secondaryWeaponmagazineArray;

    _lootCrate addWeaponCargoGlobal [_primaryWeapon, 1];
    _lootCrate addMagazineCargoGlobal [_primaryWeaponmagazine, 10];
    _lootCrate addWeaponCargoGlobal [_secondaryWeapon, 1];
    _lootCrate addMagazineCargoGlobal [_secondaryWeaponmagazine, 10];
    _lootCrate addMagazineCargoGlobal ["HandGrenade", 1];
};

ark_fnc_br_spawnVehicles = {
    private _roadsArray = zoneCenter nearRoads 3500;
    private _playerCount = count playableUnits;

    for "_i" from 1 to _playerCount do {
        private _roadSpawnArea = selectRandom _roadsArray;
        private _roadArrayIndex = _roadsArray find _roadSpawnArea;
        _roadsArray deleteAt _roadArrayIndex;
        private _roadPos = getpos _roadSpawnArea;
        private _selectedVehicle = selectRandom BRallVehicles;

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

ark_fnc_br_startingCountdownServer = {
    uiSleep 20;
    [startCrate] call ark_fnc_br_lootCrate;
    {deleteVehicle _x} forEach [fence1,fence2,fence3,fence4,fence5,fence6,fence7,fence8];
};

ark_fnc_br_playerKillFeedUI = {
    params ["_victim","_attacker","_instigator"];

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

    if (isNull _attacker || _attacker == _victim) then {
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
    private _randomZoneMovement = random [0, -1000, 1000] / currentZoneIndex;
    private _currentZoneSize = zoneSizes select currentZoneIndex;
    private _nextZoneSize = zoneSizes select (currentZoneIndex + 1);

    // We have no more zones after the current one, let's hide it
    if (isNil {_nextZoneSize}) then {
        lastZone = true;
        nextZone setMarkerSize [0, 0];
    } else {
        zoneReductionTime = zoneReductionTime - 5; //Decrease zone time to push players
        currentZoneMarker setMarkerPos [(getMarkerPos currentZoneMarker #0) + _randomZoneMovement, (getMarkerPos currentZoneMarker #1) + _randomZoneMovement];
        currentZoneMarker setMarkerSize [_currentZoneSize, _currentZoneSize];
        nextZone setMarkerPos getMarkerPos currentZoneMarker;
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

    [{getPosATL (_this #0) #2 < 1 || isNull (_this #1)}, {detach (_this #0); deleteVehicle (_this #2);}, [_ammoBox, _parachute, _smoke], 30] call CBA_fnc_waitUntilAndExecute;
};

ark_fnc_br_init = {
    startTime = diag_tickTime;
    [] spawn ark_fnc_br_roundTimer;
};

[] spawn ark_fnc_br_spawnLoot;
[] spawn ark_fnc_br_spawnVehicles;

if (ark_br_startStyle == 1) then {
    {deleteVehicle _x} forEach [fence1,fence2,fence3,fence4,fence5,fence6,fence7,fence8,startCrate];
};

[{ [nil, nil, nil, ['confirm']] call compile preProcessFileLineNumbers 'x\ark\addons\hull3\mission_host_safetytimer_stop.sqf';}, [], 30] call CBA_fnc_waitAndExecute;

waitUntil {
    [] call hull3_mission_fnc_hasSafetyTimerEnded;
};

[] call ark_fnc_br_init;

if (ark_br_startStyle == 0) then {
    [] spawn ark_fnc_br_startingCountdownServer;
};