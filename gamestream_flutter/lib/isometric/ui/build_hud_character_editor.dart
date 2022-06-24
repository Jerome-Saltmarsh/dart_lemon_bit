
import 'package:bleed_common/armour_type.dart';
import 'package:bleed_common/head_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:lemon_watch/watch.dart';

const green = Colors.green;
const grey = Colors.grey;

Widget buildHudCharacterEditor(){
   return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Row(children: _Tab.values.map((tab) => onPressed(
          callback: () => _tab.value = tab,
         child: Container(
             width: 150,
             height: 50,
             padding: const EdgeInsets.only(left: 6),
             color: grey,
             alignment: Alignment.centerLeft,
             child: text(tab.name)),
       )).toList()),
       height6,
       watch(_tab, (tab){
          switch (tab){
             case _Tab.Weapon:
               return _buildTabWeapons();
             case _Tab.Armour:
                return _buildTabArmour();
             case _Tab.Head:
                return _buildTabHead();
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
          children: WeaponType.values.map(_buildWeaponButton).toList(),
       ),
        width6,
        text("Damage: 0"),
     ],
   );
}

Widget _buildTabHead(){
   return Column(
      children: HeadType.values.map(_buildButtonHead).toList(),
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

Widget _buildWeaponButton(int weapon){
   return watch(player.weaponType, (int equipped){
      return onPressed(
         callback: () => sendClientRequestSetWeapon(weapon),
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
}

final _tab = Watch(_Tab.Weapon);