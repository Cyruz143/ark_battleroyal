// Disable ST grouping
STHUD_UIMode = 0;
STGI_Enabled = false;

// Turn off stamina for unlimited sprinting
player enableStamina false;

// Setup global variables
txt3Layer = "txt3" call BIS_fnc_rscLayer;
txt4Layer = "txt4" call BIS_fnc_rscLayer;
txt5Layer = "txt5" call BIS_fnc_rscLayer;
txt6Layer = "txt6" call BIS_fnc_rscLayer;
currentZone = objNull;
allUniforms = [];

// Update round time + player counts
"updateZoneTime" addPublicVariableEventHandler {

    private _remainingZoneTime = _this select 1;
    private _alivePlayersTotal = count playableUnits;
    private _timeTillZoneChangeText = format ["<t size='0.5' color='#ffffff' font='EtelkaMonospaceProBold'>%1 players alive<br />Zone update in: %2</t>", _alivePlayersTotal, _remainingZoneTime];
    [_timeTillZoneChangeText,-1,-safeZoneY+0.85,5,0,0,txt4Layer] spawn BIS_fnc_dynamicText;
};

ark_fnc_br_playerStartingGear = {
    private _itemConfig = "( getNumber ( _x >> 'scope' ) isEqualTo 2 )" configClasses ( configFile >> "cfgWeapons" );
    {  private _itemString = configName (_x); 
        if (_itemString call BIS_fnc_itemType select 1 == "Uniform") then {allUniforms pushBack _itemString};
    } forEach _itemConfig;
    private _clothing = selectRandom allUniforms;
    player forceAddUniform _clothing;
    for "_i" from 1 to 10 do {player addItemToUniform "ACE_fieldDressing";};
    for "_i" from 1 to 5 do {player addItemToUniform "ACE_morphine";};  
};

ark_fnc_br_playerIntro = {
    player enableSimulation false;

    MissionIntro = [] spawn {
        ["BIS_blackStart", false] call BIS_fnc_blackOut;

        sleep 5;
        playMusic "RadioAmbient9";
        [[["Life is a game.","<t color = '#FFFFFF' align = 'center' shadow = '1' size = '0.5'>%1</t><br/>"],
        ["So fight for survival.","<t color = '#FFFFFF' align = 'center' shadow = '1' size = '0.5'>%1</t><br/>"],
        ["and see if you're worth it","<t align = 'center' shadow = '1' size = '1' font='PuristaBold'>%1</t><br/>"]],0,0,"<t color='#FF0000' align='center'>%1</t>"] spawn BIS_fnc_typeText;
        uiSleep 8;

        if (ark_br_startStyle == 1) then {
            player enableSimulation true;
        };

        ["BIS_blackStart", true] call BIS_fnc_blackIn;
    };
    
    if (ark_br_startStyle == 0) then {
        waitUntil
        {
          [] call hull3_mission_fnc_hasSafetyTimerEnded;
        };
        player enableSimulation true;
        playSound "Alarm";
        
        { 
            private _countDownText = format ["Gates open in <t color='#CC0000'>%1</t>",_x];
            [_countDownText,-1,-1,1,0,0,txt3Layer] spawn BIS_fnc_dynamicText;
            uiSleep 1;
        } forEach [20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1];
    };
};

ark_fnc_br_updateZone = {
    params [
        ["_currentZone", objNull]
    ];
    currentZone = _currentZone;
};

ark_fnc_br_checkPlayersOutSideZone = {
    while { true } do {
        if !(currentZone isEqualTo objNull) then {
            private _outOfZoneWarning = "You're outside the active zone<br /><t color='#CC0000'>Taking Damage!</t>";
            
            if (!(player inArea "currentZone") && alive player) then {
                [_outOfZoneWarning,-1,-1,5,0,0,txt5Layer] spawn BIS_fnc_dynamicText;
                [player,selectrandom [0.2,0.4,0.6],selectrandom ["head","body","hand_l","hand_r","leg_l","leg_r"],selectrandom ["grenade","bullet"]] call ace_medical_fnc_addDamageToUnit;
                private _woundedSound = ["WoundedGuyC_05","WoundedGuyA_08","WoundedGuyB_07"];
                playSound selectRandom _woundedSound;
                private _playerUnconscious = player getVariable ["ACE_isUnconscious", false];
                if (_playerUnconscious) then {player setDamage 1};
                uiSleep 10;
            };
        };
      uiSleep 2;
    };
};

ark_fnc_br_endMusic = {
    while { true } do {
        if ((count playableUnits) < 2 ) exitWith {
            playMusic "champions";
            private _brWinner = playableUnits select 0;
            
            if (alive player) then {
                [player,"Acts_JetsShooterShootingReady_loop"] remoteexec ["switchMove", -2];
            } else {
                [2, _brWinner, -2, getPos _brWinner] call ace_spectator_fnc_setCameraAttributes;
            };
            
            uiSleep 5;

            private _winnerMessage = format ["<t color='#CC0000'>%1</t> is the winner",name (_brWinner)];
            [_winnerMessage,-1,-1,5,1,0,txt6Layer] spawn BIS_fnc_dynamicText;
        };
    uiSleep 2;
    };
};

ark_fnc_br_paradropPlayer = {
    player allowdamage false;
    player setPosASL [((getMarkerPos "center_zone_marker") select 0) + (random [-2000,0,2000]), ((getMarkerPos "center_zone_marker") select 1) + (random [-2000,0,2000]), 2000];

    waituntil {(getpos player select 2) < 200};
    private _chute = createVehicle ["Steerable_Parachute_F", (getPos player), [], 0, "NONE"];
    _chute setPos (getPos player);
    player moveInDriver _chute;
    waituntil {isTouchingGround player};
    player allowDamage true;
};

if (!didJIP) then {
    [] call ark_fnc_br_playerStartingGear;
    [] spawn ark_fnc_br_playerIntro;
    if (ark_br_startStyle == 1) then {
        [] call ark_fnc_br_paradropPlayer;
    };
    [] spawn ark_fnc_br_checkPlayersOutSideZone;
    [] spawn ark_fnc_br_endMusic;
};