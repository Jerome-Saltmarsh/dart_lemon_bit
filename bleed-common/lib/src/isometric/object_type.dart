
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
  
  static String getName(int value){
    return value.toString();
  }
  
  static const values = [
    Nothing,
  ];
}