// Eject EH for paradrop
player addEventHandler ["GetOutMan", {call ark_fnc_br_playerParachute}];

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

// Update round time + player counts
"updateZoneTime" addPublicVariableEventHandler {

    private _remainingZoneTime = _this select 1;
    private _alivePlayersTotal = count playableUnits;
    private _timeTillZoneChangeText = format ["<t size='0.5' color='#ffffff' font='EtelkaMonospaceProBold'>%1 players alive<br />Zone update in: %2</t>", _alivePlayersTotal, _remainingZoneTime];
    [_timeTillZoneChangeText,-1,-safeZoneY+0.85,5,0,0,txt4Layer] spawn BIS_fnc_dynamicText;
};

ark_fnc_br_playerStartingGear = {
    private _clothing_array = ["U_B_CombatUniform_mcam", "U_B_CombatUniform_mcam_tshirt", "U_B_CombatUniform_mcam_vest", "U_B_HeliPilotCoveralls", "U_O_CombatUniform_ocamo", "U_O_PilotCoveralls", "U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_Poloshirt_stripped", "U_C_Poloshirt_tricolour", "U_C_Poloshirt_salmon", "U_C_Poloshirt_redwhite", "U_C_Commoner1_1", "U_C_Commoner1_2", "U_C_Commoner1_3", "U_Rangemaster", "U_B_CombatUniform_mcam_worn", "U_B_SpecopsUniform_sgg", "U_B_PilotCoveralls", "U_O_CombatUniform_oucamo", "U_O_SpecopsUniform_ocamo", "U_O_SpecopsUniform_blk", "U_O_OfficerUniform_ocamo", "U_I_CombatUniform", "U_I_CombatUniform_tshirt", "U_I_CombatUniform_shortsleeve", "U_I_pilotCoveralls", "U_I_HeliPilotCoveralls", "U_I_OfficerUniform", "U_IG_Guerilla1_1", "U_IG_Guerilla2_1", "U_IG_Guerilla2_2", "U_IG_Guerilla2_3", "U_IG_Guerilla3_1", "U_IG_Guerilla3_2", "U_IG_leader", "U_BG_Guerilla1_1", "U_BG_Guerilla2_1", "U_BG_Guerilla2_2", "U_BG_Guerilla2_3", "U_BG_Guerilla3_1", "U_BG_Guerilla3_2", "U_BG_leader", "U_OG_Guerilla1_1", "U_OG_Guerilla2_1", "U_OG_Guerilla2_2", "U_OG_Guerilla2_3", "U_OG_Guerilla3_1", "U_OG_Guerilla3_2", "U_OG_leader", "U_C_Poor_1", "U_C_Poor_2", "U_C_WorkerCoveralls", "U_C_Poor_shorts_1", "U_C_Commoner_shorts", "U_C_ShirtSurfer_shorts", "U_C_TeeSurfer_shorts_1", "U_C_TeeSurfer_shorts_2", "U_B_CTRG_1", "U_B_CTRG_2", "U_B_CTRG_3", "U_B_survival_uniform", "U_I_G_Story_Protagonist_F", "U_I_G_resistanceLeader_F", "U_C_Journalist", "U_C_Scientist", "MNP_CombatUniform_USMC_T", "MNP_CombatUniform_USMC_ST", "MNP_CombatUniform_USMC_D", "MNP_CombatUniform_USMC_SD", "MNP_CombatUniform_Canada", "MNP_CombatUniform_Canada_S", "MNP_CombatUniform_Canada_D", "MNP_CombatUniform_Canada_DS", "MNP_CombatUniform_Germany", "MNP_CombatUniform_Germany_S", "MNP_CombatUniform_Germany_D", "MNP_CombatUniform_Germany_SD", "MNP_CombatUniform_Ranger_A", "MNP_CombatUniform_Ranger_B", "MNP_CombatUniform_Ranger_C", "MNP_CombatUniform_Ranger_E", "MNP_CombatUniform_Australia", "MNP_CombatUniform_Australia_S", "MNP_CombatUniform_ROK_A", "MNP_CombatUniform_ROK_B", "MNP_CombatUniform_M81_Sh", "MNP_CombatUniform_M81_Rg", "MNP_CombatUniform_Wood_A", "MNP_CombatUniform_Wood_B", "MNP_CombatUniform_3Co_A", "MNP_CombatUniform_3Co_B", "MNP_CombatUniform_3Co_Sh", "MNP_CombatUniform_3Co_Rg", "MNP_CombatUniform_DS_A", "MNP_CombatUniform_DS_B", "MNP_CombatUniform_TS_A", "MNP_CombatUniform_TS_B", "MNP_CombatUniform_Scorpion_A", "MNP_CombatUniform_Scorpion_B", "MNP_CombatUniform_Ranger_Sco_A", "MNP_CombatUniform_Ranger_Sco_B", "MNP_CombatUniform_Ukrainian", "MNP_CombatUniform_AMCU_T", "MNP_CombatUniform_AMCU_ST", "MNP_CombatUniform_OD_Sh", "MNP_CombatUniform_OD_Rg", "MNP_CombatUniform_USMC_arctic", "MNP_CombatUniform_USMC_arctic_B", "MNP_CombatUniform_Ireland", "MNP_CombatUniform_Ireland_S", "MNP_CombatUniform_Ireland_D", "MNP_CombatUniform_Ireland_DS", "MNP_CombatUniform_6CO", "MNP_CombatUniform_6CO_B", "MNP_CombatUniform_NPA_Alt", "MNP_CombatUniform_NPA_Alt_B", "MNP_CombatUniform_DPM", "MNP_CombatUniform_DPM_B", "MNP_CombatUniform_Militia_A", "MNP_CombatUniform_Militia_B", "MNP_CombatUniform_Militia_C", "MNP_CombatUniform_Militia_E", "MNP_CombatUniform_Militia_F", "MNP_CombatUniform_Militia_DA", "MNP_CombatUniform_Militia_DB", "MNP_CombatUniform_Militia_DC", "MNP_CombatUniform_Militia_DE", "MNP_CombatUniform_Militia_DF", "MNP_CombatUniform_Rebel_A", "MNP_CombatUniform_Rebel_B", "MNP_CombatUniform_ASA_GC", "MNP_CombatUniform_ASA_GC2", "MNP_CombatUniform_ASA_GC3", "MNP_CombatUniform_Fin_A", "MNP_CombatUniform_Fin_B", "MNP_CombatUniform_Finarctic_A", "MNP_CombatUniform_Finarctic_B", "MNP_CombatUniform_NZ_A", "MNP_CombatUniform_NZ_B", "MNP_CombatUniform_NOR_A", "MNP_CombatUniform_NOR_B", "MNP_CombatUniform_NOR_D_A", "MNP_CombatUniform_NOR_D_B", "MNP_CombatUniform_RU_Med", "MNP_CombatUniform_RU_Med_B", "MNP_CombatUniform_RU_Med_D", "MNP_CombatUniform_RU_Med_DB", "MNP_CombatUniform_China", "MNP_CombatUniform_China_D", "MNP_CombatUniform_China_Heavy_T", "MNP_CombatUniform_China_Heavy_D", "MNP_CombatUniform_Russia_Heavy", "MNP_CombatUniform_Russia_Heavy_D", "MNP_CombatUniform_CMAR", "MNP_CombatUniform_NKR_Sh", "MNP_CombatUniform_NKR_Rg", "MNP_CombatUniform_NKC_Sh", "MNP_CombatUniform_NKC_Rg", "MNP_CombatUniform_Russia_arctic", "MNP_CombatUniform_RO_Sh", "MNP_CombatUniform_RO_Rg", "MNP_CombatUniform_RO2_Sh", "MNP_CombatUniform_RO2_Rg", "MNP_CombatUniform_RO3_Sh", "MNP_CombatUniform_RO3_Rg", "MNP_CombatUniform_IR_BSJ_A", "MNP_CombatUniform_IR_BSJ_Med", "MNP_CombatUniform_IR_BSJ_Med_B", "MNP_CombatUniform_IR_IRGC_A", "MNP_CombatUniform_IR_IRGC_Med", "MNP_CombatUniform_IR_IRGC_Med_B", "MNP_CombatUniform_DPR_A", "MNP_CombatUniform_DPR_B", "MNP_CombatUniform_RO4_Sh", "MNP_CombatUniform_RO4_Rg", "MNP_CombatUniform_China_J", "U_VirtualMan_F", "U_B_T_Soldier_F", "U_B_T_Soldier_AR_F", "U_B_T_Soldier_SL_F", "U_B_T_Sniper_F", "U_B_CTRG_Soldier_F", "U_B_CTRG_Soldier_2_F", "U_B_CTRG_Soldier_3_F", "U_B_GEN_Soldier_F", "U_B_GEN_Commander_F", "U_O_T_Soldier_F", "U_O_T_Officer_F", "U_O_T_Sniper_F", "U_O_V_Soldier_Viper_F", "U_O_V_Soldier_Viper_hex_F", "U_I_C_Soldier_Para_1_F", "U_I_C_Soldier_Para_2_F", "U_I_C_Soldier_Para_3_F", "U_I_C_Soldier_Para_4_F", "U_I_C_Soldier_Para_5_F", "U_I_C_Soldier_Bandit_1_F", "U_I_C_Soldier_Bandit_2_F", "U_I_C_Soldier_Bandit_3_F", "U_I_C_Soldier_Bandit_4_F", "U_I_C_Soldier_Bandit_5_F", "U_I_C_Soldier_Camo_F", "U_C_man_sport_1_F", "U_C_man_sport_2_F", "U_C_man_sport_3_F", "U_C_Man_casual_1_F", "U_C_Man_casual_2_F", "U_C_Man_casual_3_F", "U_C_Man_casual_4_F", "U_C_Man_casual_5_F", "U_C_Man_casual_6_F", "U_B_CTRG_Soldier_urb_1_F", "U_B_CTRG_Soldier_urb_2_F", "U_B_CTRG_Soldier_urb_3_F", "CUP_U_B_GER_Tropentarn_1", "CUP_U_B_GER_Tropentarn_2", "CUP_U_B_GER_Flecktarn_1", "CUP_U_B_GER_Flecktarn_2", "CUP_U_I_GUE_Flecktarn", "CUP_U_I_GUE_Flecktarn2", "CUP_U_I_GUE_Woodland1", "CUP_U_I_GUE_Flecktarn3", "CUP_U_I_Pilot_01", "CUP_U_I_Leader_01", "CUP_U_I_Worker_02", "CUP_U_I_Woodlander_01", "CUP_U_I_Woodlander_02", "CUP_U_I_Woodlander_03", "CUP_U_I_Villager_03", "CUP_U_I_Villager_04", "CUP_U_I_GUE_Anorak_01", "CUP_U_I_GUE_Anorak_02", "CUP_U_I_GUE_Anorak_03", "CUP_I_B_PMC_Unit_1", "CUP_I_B_PMC_Unit_2", "CUP_I_B_PMC_Unit_3", "CUP_I_B_PMC_Unit_4", "CUP_I_B_PMC_Unit_5", "CUP_I_B_PMC_Unit_6", "CUP_I_B_PMC_Unit_7", "CUP_I_B_PMC_Unit_8", "CUP_I_B_PMC_Unit_9", "CUP_I_B_PMC_Unit_10", "CUP_I_B_PMC_Unit_11", "CUP_I_B_PMC_Unit_12", "CUP_I_B_PMC_Unit_13", "CUP_I_B_PMC_Unit_14", "CUP_I_B_PMC_Unit_15", "CUP_I_B_PMC_Unit_16", "CUP_I_B_PMC_Unit_17", "CUP_I_B_PMC_Unit_18", "CUP_I_B_PMC_Unit_19", "CUP_I_B_PMC_Unit_20", "CUP_I_B_PMC_Unit_21", "CUP_I_B_PMC_Unit_22", "CUP_I_B_PMC_Unit_23", "CUP_I_B_PMC_Unit_24", "CUP_I_B_PMC_Unit_25", "CUP_I_B_PMC_Unit_26", "CUP_I_B_PMC_Unit_27", "CUP_I_B_PMC_Unit_28", "CUP_U_I_RACS_Desert_1", "CUP_U_I_RACS_Desert_2", "CUP_U_I_RACS_PilotOverall", "CUP_U_I_RACS_Urban_1", "CUP_U_I_RACS_Urban_2", "CUP_U_I_RACS_WDL_1", "CUP_U_I_RACS_WDL_2", "CUP_U_I_RACS_mech_1", "CUP_U_I_RACS_mech_2", "CUP_U_O_RUS_Flora_1", "CUP_U_O_RUS_EMR_1", "CUP_U_O_RUS_Flora_2", "CUP_U_O_RUS_EMR_2", "CUP_U_O_RUS_Flora_1_VDV", "CUP_U_O_RUS_EMR_1_VDV", "CUP_U_O_RUS_Flora_2_VDV", "CUP_U_O_RUS_EMR_2_VDV", "CUP_U_O_RUS_Commander", "CUP_U_O_RUS_Gorka_Partizan", "CUP_U_O_RUS_Gorka_Partizan_A", "CUP_U_O_RUS_Gorka_Green", "CUP_U_O_SLA_MixedCamo", "CUP_U_O_SLA_Green", "CUP_U_O_SLA_Urban", "CUP_U_O_SLA_Desert", "CUP_U_O_Partisan_TTsKO", "CUP_U_O_Partisan_TTsKO_Mixed", "CUP_U_O_Partisan_VSR_Mixed1", "CUP_U_O_Partisan_VSR_Mixed2", "CUP_U_O_SLA_Overalls_Pilot", "CUP_U_O_SLA_Overalls_Tank", "CUP_U_O_SLA_Officer_Suit", "CUP_U_O_TK_Officer", "CUP_U_O_TK_MixedCamo", "CUP_U_O_TK_Green", "CUP_O_TKI_Khet_Partug_01", "CUP_O_TKI_Khet_Partug_02", "CUP_O_TKI_Khet_Partug_03", "CUP_O_TKI_Khet_Partug_04", "CUP_O_TKI_Khet_Partug_05", "CUP_O_TKI_Khet_Partug_06", "CUP_O_TKI_Khet_Partug_07", "CUP_O_TKI_Khet_Partug_08", "CUP_O_TKI_Khet_Jeans_01", "CUP_O_TKI_Khet_Jeans_02", "CUP_O_TKI_Khet_Jeans_03", "CUP_O_TKI_Khet_Jeans_04", "CUP_I_TKG_Khet_Partug_01", "CUP_I_TKG_Khet_Partug_02", "CUP_I_TKG_Khet_Partug_03", "CUP_I_TKG_Khet_Partug_04", "CUP_I_TKG_Khet_Partug_05", "CUP_I_TKG_Khet_Partug_06", "CUP_I_TKG_Khet_Partug_07", "CUP_I_TKG_Khet_Partug_08", "CUP_I_TKG_Khet_Jeans_01", "CUP_I_TKG_Khet_Jeans_02", "CUP_I_TKG_Khet_Jeans_03", "CUP_I_TKG_Khet_Jeans_04", "CUP_U_B_USArmy_TwoKnee", "CUP_U_B_USArmy_UBACS", "CUP_U_B_USArmy_Soft", "CUP_U_B_USArmy_PilotOverall", "CUP_U_B_USMC_Officer", "CUP_U_B_USMC_MARPAT_WDL_Sleeves", "CUP_U_B_USMC_MARPAT_WDL_RolledUp", "CUP_U_B_USMC_MARPAT_WDL_Kneepad", "CUP_U_B_USMC_MARPAT_WDL_TwoKneepads", "CUP_U_B_USMC_PilotOverall", "CUP_U_B_USMC_MARPAT_WDL_RollUpKneepad", "CUP_U_B_FR_SpecOps", "CUP_U_B_FR_Scout", "CUP_U_B_FR_Officer", "CUP_U_B_FR_Corpsman", "CUP_U_B_FR_DirAction", "CUP_U_B_FR_DirAction2", "CUP_U_B_FR_Light", "CUP_U_B_FR_Scout1", "CUP_U_B_FR_Scout2", "CUP_U_B_FR_Scout3", "CUP_B_USMC_Navy_Blue", "CUP_B_USMC_Navy_Brown", "CUP_B_USMC_Navy_Green", "CUP_B_USMC_Navy_Red", "CUP_B_USMC_Navy_Violet", "CUP_B_USMC_Navy_White", "CUP_B_USMC_Navy_Yellow", "CUP_U_B_USMC_FROG1_WMARPAT", "CUP_U_B_USMC_FROG1_DMARPAT", "CUP_U_B_USMC_FROG2_WMARPAT", "CUP_U_B_USMC_FROG2_DMARPAT", "CUP_U_B_USMC_FROG3_WMARPAT", "CUP_U_B_USMC_FROG3_DMARPAT", "CUP_U_B_USMC_FROG4_WMARPAT", "CUP_U_B_USMC_FROG4_DMARPAT", "CUP_U_C_Pilot_01", "CUP_U_C_Citizen_01", "CUP_U_C_Citizen_02", "CUP_U_C_Citizen_03", "CUP_U_C_Citizen_04", "CUP_U_C_Worker_01", "CUP_U_C_Worker_02", "CUP_U_C_Worker_03", "CUP_U_C_Worker_04", "CUP_U_C_Profiteer_01", "CUP_U_C_Profiteer_02", "CUP_U_C_Profiteer_03", "CUP_U_C_Profiteer_04", "CUP_U_C_Woodlander_01", "CUP_U_C_Woodlander_02", "CUP_U_C_Woodlander_03", "CUP_U_C_Woodlander_04", "CUP_U_C_Villager_01", "CUP_U_C_Villager_02", "CUP_U_C_Villager_03", "CUP_U_C_Villager_04", "CUP_U_C_Priest_01", "CUP_U_C_Policeman_01", "CUP_U_C_Suit_01", "CUP_U_C_Suit_02", "CUP_U_C_Labcoat_01", "CUP_U_C_Labcoat_02", "CUP_U_C_Labcoat_03", "CUP_U_C_Rocker_01", "CUP_U_C_Rocker_02", "CUP_U_C_Rocker_03", "CUP_U_C_Rocker_04", "CUP_U_C_Mechanic_01", "CUP_U_C_Mechanic_02", "CUP_U_C_Mechanic_03", "CUP_U_C_Fireman_01", "CUP_U_C_Rescuer_01", "CUP_U_B_CZ_WDL_TShirt", "CUP_U_B_BAF_DDPM_S1_RolledUp", "CUP_U_B_BAF_DDPM_S2_UnRolled", "CUP_U_B_BAF_DDPM_Tshirt", "CUP_U_B_BAF_DPM_S1_RolledUp", "CUP_U_B_BAF_DPM_S2_UnRolled", "CUP_U_B_BAF_DPM_Tshirt", "CUP_U_B_BAF_MTP_S1_RolledUp", "CUP_U_B_BAF_MTP_S2_UnRolled", "CUP_U_B_BAF_MTP_Tshirt", "CUP_U_B_BAF_MTP_S3_RolledUp", "CUP_U_B_BAF_MTP_S4_UnRolled", "CUP_U_B_BAF_MTP_S5_UnRolled", "CUP_U_B_BAF_MTP_S6_UnRolled", "CUP_U_B_CDF_MNT_1", "CUP_U_B_CDF_MNT_2", "CUP_U_B_CDF_DST_1", "CUP_U_B_CDF_DST_2", "CUP_U_B_CDF_FST_1", "CUP_U_B_CDF_FST_2", "CUP_U_I_UNO_MNT_1", "CUP_U_I_UNO_MNT_2", "CUP_U_I_UNO_DST_1", "CUP_U_I_UNO_DST_2", "CUP_U_I_UNO_FST_1", "CUP_U_I_UNO_FST_2", "CUP_U_O_CHDKZ_Bardak", "CUP_U_O_CHDKZ_Commander", "CUP_U_O_CHDKZ_Lopotev", "CUP_U_O_CHDKZ_Kam_01", "CUP_U_O_CHDKZ_Kam_02", "CUP_U_O_CHDKZ_Kam_03", "CUP_U_O_CHDKZ_Kam_04", "CUP_U_O_CHDKZ_Kam_05", "CUP_U_O_CHDKZ_Kam_06", "CUP_U_O_CHDKZ_Kam_07", "CUP_U_O_CHDKZ_Kam_08", "CUP_U_O_Pilot_01", "CUP_U_O_Worker_02", "CUP_U_O_Woodlander_01", "CUP_U_O_Woodlander_02", "CUP_U_O_Woodlander_03", "CUP_U_O_Villager_03", "CUP_U_O_Villager_04"];
    private _clothing = selectRandom _clothing_array;
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

ark_fnc_br_playerParachute = {
    if ((getpos player select 2) > 300) then {      
        [] spawn {
            player allowdamage false;
            waituntil {(getpos player select 2) < 300};
            _chute = createVehicle ["Steerable_Parachute_F", (getPos player), [], 0, "NONE"];
            _chute setPos (getPos player);
            player moveInDriver _chute;
            
            waituntil {isTouchingGround player};
            player allowDamage true;
        };
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

if (!didJIP) then {
    [] call ark_fnc_br_playerStartingGear;
    [] spawn ark_fnc_br_playerIntro;
    [] spawn ark_fnc_br_checkPlayersOutSideZone;
    [] spawn ark_fnc_br_endMusic;
};