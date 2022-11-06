//
// import 'package:flutter/material.dart';
// import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
// import 'package:gamestream_flutter/library.dart';
//
// import 'constants/colors.dart';
//
// final storeEquipmentType = Watch(EquipmentType.Weapon);
//
// // final weaponInformation = Watch<Weapon?>(null);
//
//
// // Widget buildColumnSelectPlayerArmour(){
// //    return Column(
// //       children: BodyType.values.map(_buildSelectArmourType).toList(),
// //    );
// // }
//
// Widget buildStoreTabWeapons(){
//    return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//      children: [
//         buildWatchPlayerStoreItems(),
//         width6,
//         // buildWatchWeaponInformation(),
//      ],
//    );
// }
//
// Widget buildWatchPlayerStoreItems() {
//   return watch(GamePlayer.storeItems, (List<int> weapons){
//       if (weapons.isEmpty) return const SizedBox();
//       return Column(
//         children: weapons.map(_buildButtonPurchaseWeapon).toList(),
//       );
//   });
// }
//
// // Widget buildWatchWeaponInformation(){
// //    return watch(weaponInformation, (Weapon? weapon){
// //       return Container(
// //          color: grey,
// //          width: 200,
// //          padding: const EdgeInsets.all(6),
// //          child: weapon == null ? null : Column(
// //              crossAxisAlignment: CrossAxisAlignment.start,
// //              children: [
// //                text(weapon.name),
// //                text('Damage: ${weapon.damage}'),
// //              ],
// //          ),
// //       );
// //    });
// // }
//
// Widget _buildButtonPurchaseWeapon(int weapon) {
//   return MouseRegion(
//     onEnter: (event){
//       // weaponInformation.value = weapon;
//     },
//     onExit: (event){
//        // if (weaponInformation.value != weapon) return;
//        // weaponInformation.value = null;
//     },
//     child: container(
//         // child: text(weapon.name),
//         // action: () => GameNetwork.sendClientRequestPurchaseWeapon(weapon.type),
//     ),
//   );
// }
//
// // Widget _buildSelectArmourType(int type) {
// //    return watch(GamePlayer.bodyType, (int equipped){
// //      return container(
// //          child: text(BodyType.getName(type)),
// //          action: () => GameNetwork.sendClientRequestSetArmour(type),
// //          color: equipped == type ? green : grey,
// //      );
// //    });
// // }
//
//
