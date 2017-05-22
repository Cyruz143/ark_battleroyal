class br_gear {
    class Rifleman {
        primaryWeapon = "";
        primaryWeaponItems[] = {};
        secondaryWeapon = "";
        secondaryWeaponItems[] = {};
        handgunWeapon = "";
        addHandgunItems[] = {};
        uniformWeapons[] = {};
        vestWeapons[] = {};
        backpackWeapons[] = {};
        uniformMagazines[] = {};
        vestMagazines[] = {};
        backpackMagazines[] = {};
        basicAssignItems[] = {"ItemMap", "ItemCompass", "ItemWatch", "ItemGPS"};
        assignItems[] = {};
        binocular = "";
        uniformItems[] = {};
        vestItems[] = {};
        backpackItems[] = {};
        uniformRadios[] = {};
        vestRadios[] = {};
        backpackRadios[] = {};
        uniformMedicalItems[] = {};
        vestMedicalItems[] = {};
        backpackMedicalItems[] = {};
        code = "";
        headGear = "";
        uniform = "";
        goggles = "";
        vest = "";
        backpack = "";
    };

    class Leader : Rifleman {};

    class Officer : Leader {};

    class Crew : Rifleman {};

    class CO : Officer {};

    class XO : CO {
        backpackMagazines[] = {};

    class SL : Officer {};

    class Medic : Rifleman {};

    class FTL : Leader {};

    class AR : Rifleman {};

    class AAR : Rifleman {};

    class RAT : Rifleman {};

    class Vehicle {
        weapons[] = {};
        magazines[] = {};
        items[] = {};
        radios[] = {};
    };

    class Car : Vehicle {};

    class Truck : Vehicle {};

    class Armored : Truck {};

};
};