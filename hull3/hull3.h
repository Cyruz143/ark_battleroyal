class Hull3 {
    isEnabled = 1;

    class Briefing {
        blufor = "hull3\briefing\blufor.sqf";
        opfor = "hull3\briefing\opfor.sqf";
        indfor = "hull3\briefing\indfor.sqf";
        civilian = "hull3\briefing\civilian.sqf";
    };

    class Gear {
        #include "br_gear.h"
        unitBaseClass = "Rifleman";
        vehicleBaseClass = "Vehicle";
    };

    class Faction {
        class Default {
            gear = "br_gear";
            uniform = "Default";
        };
    };
};