
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'constants/colors.dart';

final storeEquipmentType = Watch(EquipmentType.Weapon);

// final weaponInformation = Watch<Weapon?>(null);

Widget buildPanelStore(){
  return watch(GamePlayer.storeItems, (List<int> weapons){
      if (weapons.isEmpty) return SizedBox();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              container(child: "PURCHASE"),
              container(child: SizedBox()),
              container(child: "CLOSE", action: GameNetwork.sendClientRequestStoreClose),
            ],
          ),
          height6,
          Row(children: EquipmentType.values.map((tab) {
            return watch(storeEquipmentType, (active){
              return container(
                child: text(tab.name),
                action: () => storeEquipmentType.value = tab,
                color: tab == storeEquipmentType.value ? greyDark : grey,
              );
            });
          }).toList()),
          height6,
          // watch(storeEquipmentType, (tab){
          //   switch (tab){
          //     case EquipmentType.Weapon:
          //       return buildStoreTabWeapons();
          //     case EquipmentType.Armour:
          //       return buildColumnSelectPlayerArmour();
          //     case EquipmentType.Head:
          //       return buildColumnSelectPlayerHead();
          //     case EquipmentType.Pants:
          //       return buildColumnSelectPlayerPants();
          //     default:
          //       return text("not available");
          //   }
          // })
        ],
      );
  });
}

// Widget buildColumnSelectPlayerArmour(){
//    return Column(
//       children: BodyType.values.map(_buildSelectArmourType).toList(),
//    );
// }

Widget buildStoreTabWeapons(){
   return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
     children: [
        buildWatchPlayerStoreItems(),
        width6,
        // buildWatchWeaponInformation(),
     ],
   );
}

Widget buildWatchPlayerStoreItems() {
  return watch(GamePlayer.storeItems, (List<int> weapons){
      if (weapons.isEmpty) return const SizedBox();
      return Column(
        children: weapons.map(_buildButtonPurchaseWeapon).toList(),
      );
  });
}

// Widget buildWatchWeaponInformation(){
//    return watch(weaponInformation, (Weapon? weapon){
//       return Container(
//          color: grey,
//          width: 200,
//          padding: const EdgeInsets.all(6),
//          child: weapon == null ? null : Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                text(weapon.name),
//                text('Damage: ${weapon.damage}'),
//              ],
//          ),
//       );
//    });
// }

Widget _buildButtonPurchaseWeapon(int weapon) {
  return MouseRegion(
    onEnter: (event){
      // weaponInformation.value = weapon;
    },
    onExit: (event){
       // if (weaponInformation.value != weapon) return;
       // weaponInformation.value = null;
    },
    child: container(
        // child: text(weapon.name),
        // action: () => GameNetwork.sendClientRequestPurchaseWeapon(weapon.type),
    ),
  );
}

// Widget _buildSelectArmourType(int type) {
//    return watch(GamePlayer.bodyType, (int equipped){
//      return container(
//          child: text(BodyType.getName(type)),
//          action: () => GameNetwork.sendClientRequestSetArmour(type),
//          color: equipped == type ? green : grey,
//      );
//    });
// }


