//
// import 'package:gamestream_server/common.dart';
//
// class MMOItem {
//   static const Rusty_Old_Sword = 0;
//   static const Wooden_Bow = 1;
//   static const Magic_Bow_Of_Frost = 2;
//
//   static const values = [
//     Rusty_Old_Sword,
//     Wooden_Bow,
//     Magic_Bow_Of_Frost,
//   ];
//
//
//   static int getType(int value) {
//     const weapon = GameObjectType.Weapon;
//     return const {
//           Rusty_Old_Sword: weapon,
//           Wooden_Bow: weapon,
//           Magic_Bow_Of_Frost: weapon,
//     }[value] ?? (throw Exception('MMOItem.getType($value)'));
//   }
//
//   static int getSubType(int value) {
//     return const {
//           Rusty_Old_Sword: WeaponType.Sword,
//           Wooden_Bow: WeaponType.Bow,
//           Magic_Bow_Of_Frost: WeaponType.Bow,
//     }[value] ?? (throw Exception('MMOItem.getType($value)'));
//   }
//
//   static int getDamage(int value) => const {
//       Rusty_Old_Sword: 1,
//       Wooden_Bow: 1,
//       Magic_Bow_Of_Frost: 3,
//     }[value] ?? (throw Exception('MMOItem.getDamage($value)'));
//
//   static int getCooldown(int value) => const {
//       Rusty_Old_Sword: 15,
//       Wooden_Bow: 20,
//       Magic_Bow_Of_Frost: 23,
//     }[value] ?? (throw Exception('MMOItem.getCooldown($value)'));
//
//   static double getRange(int value) => const <int, double> {
//       Rusty_Old_Sword: 70,
//       Wooden_Bow: 150,
//       Magic_Bow_Of_Frost: 160,
//     }[value] ?? (throw Exception('MMOItem.getRange($value)'));
//
//   static double getAccuracy(int value) => const <int, double> {
//       Rusty_Old_Sword: 1,
//       Wooden_Bow: 0.8,
//       Magic_Bow_Of_Frost: 1,
//     }[value] ?? (throw Exception('MMOItem.getRange($value)'));
//
//   static String getName(int value) => const {
//       Rusty_Old_Sword: "Rusty_Old_Sword",
//       Wooden_Bow: "Wooden_Bow",
//       Magic_Bow_Of_Frost: "Magic_Bow_Of_Frost",
//     }[value] ?? 'mmo_item-name-missing-$value';
// }