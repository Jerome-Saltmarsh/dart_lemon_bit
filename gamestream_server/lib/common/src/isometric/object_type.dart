
class ObjectType {
  static const Nothing = 0;
  static const Flag_Red = 1;
  static const Flag_Blue = 2;
  static const Spawn_Red = 3;
  static const Spawn_Blue = 4;
  static const Base_Red = 5;
  static const Base_Blue = 6;
  static const Crate_Wooden = 7;
  static const Barrel_Explosive = 8;
  static const Barrel_Flaming = 9;
  static const Credits = 10;
  static const Car = 11;
  static const Crystal = 12;
  static const Candle = 13;
  static const Barrel = 14;
  static const Barrel_Purple = 15;
  static const Cup = 16;
  static const Tavern_Sign = 17;
  static const Crystal_Small_Red = 18;
  static const Crystal_Small_Blue = 19;
  static const Aircon_South = 20;
  static const Toilet = 21;
  static const Desk = 23;
  static const Vending_Machine = 24;
  static const Bed = 25;
  static const Sink = 26;
  static const Firehydrant = 27;
  static const Chair = 28;
  static const Washing_Machine = 29;
  static const Car_Tire = 30;
  static const Bottle = 31;
  static const Van = 32;
  static const Computer = 33;
  static const Neon_Sign_01 = 34;
  static const Neon_Sign_02 = 35;
  static const Vending_Upgrades = 36;
  static const Pipe_Vertical = 37;
  static const Flag_Spawn_Red = 38;
  static const Flag_Spawn_Blue = 39;
  static const Grenade = 40;


  static bool isMaterialMetal(int value) => const [
      Barrel_Explosive
  ].contains(value);

  static double getRadius(int value){
    return 15.0;
  }

  static String getName(int value) {
    return const {
      Nothing: "Nothing",
      Flag_Red: "Red Flag",
      Flag_Blue: "Blue Flag",
      Spawn_Red: "Red Spawn",
      Spawn_Blue: "Blue Spawn",
      Base_Red: "Red Base",
      Base_Blue: "Blue Base",
      Crate_Wooden: "Wooden Crate",
      Barrel_Explosive: "Explosive Barrel",
      Barrel_Flaming: "Flaming Barrel",
      Credits: "Credits",
      Car: "Car",
      Crystal: "Crystal",
      Candle: "Candle",
      Barrel: "Barrel",
      Barrel_Purple: "Purple Barrel",
      Cup: "Cup",
      Tavern_Sign: "Tavern Sign",
      Crystal_Small_Red: "Red Small Crystal",
      Crystal_Small_Blue: "Blue Small Crystal",
      Aircon_South: "South Aircon",
      Toilet: "Toilet",
      Desk: "Desk",
      Vending_Machine: "Vending Machine",
      Bed: "Bed",
      Sink: "Sink",
      Firehydrant: "Firehydrant",
      Chair: "Chair",
      Washing_Machine: "Washing Machine",
      Car_Tire: "Car Tire",
      Bottle: "Bottle",
      Van: "Van",
      Computer: "Computer",
      Neon_Sign_01: "Neon Sign 01",
      Neon_Sign_02: "Neon Sign 02",
      Vending_Upgrades: "Vending Upgrades",
      Pipe_Vertical: "Vertical Pipe",
      Flag_Spawn_Red: "Red Spawn Flag",
      Flag_Spawn_Blue: "Blue Spawn Flag",
      Grenade: "Grenade",
    }[value] ?? 'object-type-unknown-$value';
  }

  static const values = [
    Nothing,
    Flag_Red,
    Flag_Blue,
    Spawn_Red,
    Spawn_Blue,
    Base_Red,
    Base_Blue,
    Crate_Wooden,
    Barrel_Explosive,
    Barrel_Flaming,
    Credits,
    Car,
    Crystal,
    Candle,
    Barrel,
    Barrel_Purple,
    Cup,
    Tavern_Sign,
    Crystal_Small_Red,
    Crystal_Small_Blue,
    Aircon_South,
    Toilet,
    Desk,
    Vending_Machine,
    Bed,
    Sink,
    Firehydrant,
    Chair,
    Washing_Machine,
    Car_Tire,
    Bottle,
    Van,
    Computer,
    Neon_Sign_01,
    Neon_Sign_02,
    Vending_Upgrades,
    Pipe_Vertical,
    Flag_Spawn_Red,
    Flag_Spawn_Blue,
    Grenade,
  ];

}