
class SpawnType {
  static const Zombie = 0;
  static const Chicken = 1;
  static const Butterfly = 2;
  static const Rat = 3;
  static const Jellyfish = 4;
  static const Jellyfish_Red = 5;
  static const Template = 6;
  static const Slime = 7;
  static const GameObject_Weapon_Handgun = 8;
  static const GameObject_Weapon_Shotgun = 9;
  static const GameObject_Weapon_Rifle = 10;
  static const GameObject_Weapon_Sword = 11;
  static const Random_Item = 12;
  static const Character = 13;
  static const GameObject = 14;


  static int getValue(int index){
    const max = GameObject_Weapon_Sword;
    if (index < 0) return 0;
    if (index > max) return max;
    return index;
  }
  
  static const values = [
    Zombie,
    Chicken,
    Butterfly,
    Rat,
    Jellyfish,
    Jellyfish_Red,
    Template,
    Slime,
    GameObject_Weapon_Handgun,
    GameObject_Weapon_Shotgun,
    GameObject_Weapon_Rifle,
    GameObject_Weapon_Sword,
    Random_Item,
  ];

  static String getName(int type) {
    return const {
      Zombie: "Zombie",
      Chicken: "Chicken",
      Butterfly: "Butterfly",
      Rat: "Rat",
      Jellyfish: "Jellyfish",
      Jellyfish_Red: "Jellyfish Red",
      Template: "Human",
      Slime: "Slime",
      GameObject_Weapon_Handgun: "Handgun",
      GameObject_Weapon_Shotgun: "Shotgun",
      GameObject_Weapon_Rifle: "Rifle",
      GameObject_Weapon_Sword: "Sword",
      Random_Item: "Random Item",
    } [type] ?? "Unknown ($type)";
  }
}