
class ObjectType {
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

  static const Candle = 13;
  static const Barrel = 14;
  static const Barrel_Purple = 15;
  static const Cup = 16;
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
  static const Car_Tire = 30;
  static const Bottle = 31;
  static const Van = 32;
  static const Computer = 33;
  static const Neon_Sign_01 = 34;
  static const Neon_Sign_02 = 35;
  static const Flag_Spawn_Red = 38;
  static const Flag_Spawn_Blue = 39;
  static const Grenade = 40;
  static const Crystal_Glowing_False = 12;
  static const Crystal_Glowing_True = 41;
  static const Sphere = 42;

  static bool isMaterialMetal(int value) => const [
      Barrel_Explosive
  ].contains(value);

  static double getRadius(int value){
    return 15.0;
  }

  static String getName(int value) {
    return const {
      Flag_Red: 'Flag_Red',
      Flag_Blue: 'Flag_Blue',
      Spawn_Red: 'Spawn_Red',
      Spawn_Blue: 'Spawn_Blue',
      Base_Red: 'Base_Red',
      Base_Blue: 'Base_Blue',
      Crate_Wooden: 'Crate_Wooden',
      Barrel_Explosive: 'Barrel_Explosive',
      Barrel_Flaming: 'Barrel_Flaming',
      Credits: 'Credits',
      Car: 'Car',
      Crystal_Glowing_False: 'Crystal',
      Candle: 'Candle',
      Barrel: 'Barrel',
      Barrel_Purple: 'Barrel_Purple',
      Cup: 'Cup',
      Crystal_Small_Red: 'Crystal_Small_Red',
      Crystal_Small_Blue: 'Crystal_Small_Blue',
      Aircon_South: 'South Aircon',
      Toilet: 'Toilet',
      Desk: 'Desk',
      Vending_Machine: 'Vending Machine',
      Bed: 'Bed',
      Sink: 'Sink',
      Firehydrant: 'Firehydrant',
      Chair: 'Chair',
      Car_Tire: 'Car Tire',
      Bottle: 'Bottle',
      Van: 'Van',
      Computer: 'Computer',
      Neon_Sign_01: 'Neon Sign 01',
      Neon_Sign_02: 'Neon Sign 02',
      Flag_Spawn_Red: 'Flag Spawn Red',
      Flag_Spawn_Blue: 'Flag Spawn Blue',
      Grenade: 'Grenade',
      Crystal_Glowing_True: 'Crystal Glowing',
      Sphere: 'Sphere',
    }[value] ?? 'object-type-unknown-$value';
  }

  static const values = [
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
    Crystal_Glowing_False,
    Candle,
    Barrel,
    Barrel_Purple,
    Cup,
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
    Car_Tire,
    Bottle,
    Van,
    Computer,
    Neon_Sign_01,
    Neon_Sign_02,
    Flag_Spawn_Red,
    Flag_Spawn_Blue,
    Grenade,
    Crystal_Glowing_True,
    Sphere
  ];

}