// import 'item_type.dart';
//
// class GameObjectType {
//   // static const Flower = 1;
//   static const Rock = 2;
//   static const Stick = 3;
//   // static const Butterfly = 4;
//   // static const Chicken = 5;
//   static const Crystal = 6;
//   static const Barrel = 7;
//   static const Wheel = 8;
//   static const Candle = 9;
//   static const Bottle = 10;
//   static const Chest = 11;
//   static const Cup = 12;
//   static const Wooden_Shelf_Row = 13;
//   static const Book_Purple = 14;
//   static const Crystal_Small_Blue = 15;
//   // static const Flower_Green = 16;
//   static const Tavern_Sign = 18;
//   // static const Jellyfish = 19;
//   // static const Jellyfish_Red = 20;
//   static const Lantern_Red = 21;
//   // static const Loot = 22;
//   // static const Particle_Emitter = 23;
//   // static const Item = 32;
//
//   static bool isCollidable(int type) =>
//       ItemType.isCollectable(type);
//
//   static bool isPersistable(int type) =>
//       ItemType.isCollectable(type);
//
//   static bool emitsLightBright(int type){
//     if (type == Lantern_Red) return true;
//     return false;
//   }
//
//   static String getName(int value) => const <int, String> {
//     Rock: 'Rock',
//     Stick: 'Stick',
//     Crystal: 'Crystal',
//     Chest: 'Chest',
//     Barrel: 'Barrel',
//     Wheel: 'Wheel',
//     Candle: 'Candle',
//     Bottle: 'Bottle',
//     Cup: 'Cup',
//     Wooden_Shelf_Row: 'Wooden Shelf Row',
//     Book_Purple: 'Book Purple',
//     Crystal_Small_Blue: 'Crystal Small Blue',
//     Tavern_Sign: 'Tavern Sign',
//     Lantern_Red: 'Lantern Red',
//   }[value] ?? '?';
// }
