
import 'package:bleed_common/armour_type.dart';
import 'package:bleed_common/head_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/pants_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:lemon_watch/watch.dart';

import '../classes/weapon.dart';

const green = Colors.green;
const grey = Colors.grey;
const greyDark = Colors.blueGrey;
final activeTab = Watch(_Tab.Weapon);

Widget buildHudCharacterEditor(){
   return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Row(children: _Tab.values.map((tab) {
         return watch(activeTab, (active){
            return container(
              child: text(tab.name),
              action: () => activeTab.value = tab,
              color: tab == activeTab.value ? greyDark : grey,
            );
         });
       }).toList()),
       height6,
       watch(activeTab, (tab){
          switch (tab){
             case _Tab.Weapon:
               return _buildTabWeapons();
             case _Tab.Armour:
                return _buildTabArmour();
             case _Tab.Head:
                return _buildTabHead();
            case _Tab.Pants:
                return _buildTabPants();
             default:
                return text("not available");
          }
       })
     ],
   );
}

Widget _buildTabArmour(){
   return Column(
      children: ArmourType.values.map(_buildSelectArmourType).toList(),
   );
}

Widget _buildTabWeapons(){
   return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Column(
          children: WeaponType.values.map(_buildButtonPurchaseWeapon).toList(),
       ),
        width6,
        buildColumnPlayerWeapons(),
     ],
   );
}

Widget _buildTabHead(){
   return Column(
      children: HeadType.values.map(_buildButtonHead).toList(),
   );
}

Widget _buildTabPants(){
  return Column(
    children: PantsType.values.map(_buildButtonPants).toList(),
  );
}

Widget _buildButtonHead(int headType) {
   return watch(player.headType, (int playerHeadType){
     print("headType: $headType, playerHeadType: $playerHeadType");
      return container(
          child: text(HeadType.getName(headType)),
          action: () => sendClientRequestSetHeadType(headType),
          color: headType == playerHeadType ? green : grey,
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
   return watch(player.weapons, (List<Weapon> weapons){
      return Column(
        children: weapons.map(_buildButtonEquipWeapon).toList(),
      );
   });
}

Widget _buildButtonEquipWeapon(Weapon weapon){
  return watch(player.weapon, (Weapon equippedWeapon){
    return container(
      color: weapon.uuid == equippedWeapon.uuid ? green : grey,
      child: text(WeaponType.getName(weapon.type)),
      action: (){
        sendClientRequestEquipWeapon(player.weapons.value.indexOf(weapon));
      },
    );
  });
}

Widget _buildButtonPurchaseWeapon(int weapon){
   return watch(player.weaponType, (int equipped){
      return onPressed(
         callback: () => sendClientRequestPurchaseWeapon(weapon),
         child: Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            width: 200,
            height: 50,
            color: equipped == weapon ? Colors.green : Colors.grey,
            child: text(WeaponType.getName(weapon)),
         ),
      );
   });
}

Widget _buildSelectArmourType(int type){
   return watch(player.armourType, (int equipped){
      return onPressed(
         callback: () => sendClientRequestSetArmour(type),
         child: Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            width: 200,
            height: 50,
            color: equipped == type ? Colors.green : Colors.grey,
            child: text(ArmourType.getName(type)),
         ),
      );
   });
}

enum _Tab {
   Weapon,
   Armour,
   Head,
   Pants,
}
