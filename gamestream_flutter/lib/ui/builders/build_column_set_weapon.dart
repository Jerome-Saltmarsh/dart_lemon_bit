
import 'package:bleed_common/weapon_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/send.dart';

import 'player.dart';

Widget buildColumnSetWeapon(){
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

Widget button({required Function action, required Widget child, Color? color}){
  return onPressed(
      callback: action,
      child: Container(
          padding: EdgeInsets.only(left: 8),
          alignment: Alignment.centerLeft,
          width: 200,
          height: 50,
          color: color ?? Colors.grey,
          child: child)
  );
}