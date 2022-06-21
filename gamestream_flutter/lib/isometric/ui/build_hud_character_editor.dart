
import 'package:bleed_common/armour_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_watch/watch.dart';

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
             color: Colors.grey,
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
   return Column(
      children: [
         _buildWeaponButton(WeaponType.Unarmed),
         _buildWeaponButton(WeaponType.Hammer),
         _buildWeaponButton(WeaponType.Handgun),
         _buildWeaponButton(WeaponType.Pickaxe),
         _buildWeaponButton(WeaponType.Axe),
         _buildWeaponButton(WeaponType.Sword),
         _buildWeaponButton(WeaponType.Staff),
         _buildWeaponButton(WeaponType.Shotgun),
         _buildWeaponButton(WeaponType.Bow),
      ],
   );
}

Widget _buildWeaponButton(int weapon){
   return watch(player.equippedWeapon, (int equipped){
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
   return watch(player.armour, (int equipped){
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