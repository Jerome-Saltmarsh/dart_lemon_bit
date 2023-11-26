
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/equipment_type.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';

import '../classes/weapon.dart';
import 'constants/colors.dart';

final storeEquipmentType = Watch(EquipmentType.Weapon);

final weaponInformation = Watch<Weapon?>(null);

Widget buildPanelStore(){
  return watch(storeItems, (List<Weapon> weapons){
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
              container(child: "CLOSE", action: sendClientRequestStoreClose),
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
          watch(storeEquipmentType, (tab){
            switch (tab){
              case EquipmentType.Weapon:
                return buildStoreTabWeapons();
              case EquipmentType.Armour:
                return buildColumnSelectPlayerArmour();
              case EquipmentType.Head:
                return buildColumnSelectPlayerHead();
              case EquipmentType.Pants:
                return buildColumnSelectPlayerPants();
              default:
                return text("not available");
            }
          })
        ],
      );
  });
}

Widget buildColumnSelectPlayerArmour(){
   return Column(
      children: ArmourType.values.map(_buildSelectArmourType).toList(),
   );
}

Widget buildStoreTabWeapons(){
   return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
     children: [
        buildWatchPlayerStoreItems(),
        width6,
        buildWatchWeaponInformation(),
     ],
   );
}

Widget buildWatchPlayerStoreItems() {
  return watch(storeItems, (List<Weapon> weapons){
      if (weapons.isEmpty) return const SizedBox();
      return Column(
        children: weapons.map(_buildButtonPurchaseWeapon).toList(),
      );
  });
}

Widget buildWatchWeaponInformation(){
   return watch(weaponInformation, (Weapon? weapon){
      return Container(
         color: grey,
         width: 200,
         padding: const EdgeInsets.all(6),
         child: weapon == null ? null : Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               text(weapon.name),
               text('Damage: ${weapon.damage}'),
             ],
         ),
      );
   });
}

Widget buildColumnSelectPlayerHead(){
   return Column(
      children: HeadType.values.map(buildButtonSelectPlayerHead).toList(),
   );
}

Widget buildColumnSelectPlayerPants(){
  return Column(
    children: PantsType.values.map(_buildButtonPants).toList(),
  );
}

Widget buildButtonSelectPlayerHead(int headType) {
   return watch(player.headType, (int playerHeadType){
      return container(
          child: text(HeadType.getName(headType)),
          action: () => sendClientRequestSetHeadType(headType),
          color: headType == playerHeadType ? greyDark : grey,
      );
   });
}

Widget _buildButtonPants(int pantsType) {
  return watch(player.pantsType, (int playerPantsType){
    return container(
      child: text(PantsType.getName(pantsType)),
      action: () => sendClientRequestSetPantsType(pantsType),
      color: pantsType == playerPantsType ? green : grey,
    );
  });
}

Widget buildColumnPlayerWeapons() {
   return Column(
     children: [
       container(child: text("Inventory")),
       watch(player.weapons, (List<Weapon> weapons){
          return Column(
            children: weapons.map(_buildButtonEquipWeapon).toList(),
          );
       }),
     ],
   );
}

Widget _buildButtonEquipWeapon(Weapon weapon){
  return MouseRegion(
    onEnter: (event){
      weaponInformation.value = weapon;
    },
    onExit: (event){
      if (weaponInformation.value != weapon) return;
      weaponInformation.value = null;
    },
    child: watch(player.weapon, (Weapon equippedWeapon){
      return container(
        color: weapon.uuid == equippedWeapon.uuid ? brownDark : brownLight,
        child: text(WeaponType.getName(weapon.type)),
        action: (){
          sendClientRequestEquipWeapon(player.weapons.value.indexOf(weapon));
        },
      );
    }),
  );
}

Widget _buildButtonPurchaseWeapon(Weapon weapon) {
  return MouseRegion(
    onEnter: (event){
      weaponInformation.value = weapon;
    },
    onExit: (event){
       if (weaponInformation.value != weapon) return;
       weaponInformation.value = null;
    },
    child: container(
        child: text(weapon.name),
        action: () => sendClientRequestPurchaseWeapon(weapon.type),
    ),
  );
}

Widget _buildSelectArmourType(int type) {
   return watch(player.armourType, (int equipped){
     return container(
         child: text(ArmourType.getName(type)),
         action: () => sendClientRequestSetArmour(type),
         color: equipped == type ? green : grey,
     );
   });
}

