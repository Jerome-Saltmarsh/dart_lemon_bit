

import 'package:bleed_common/weapon_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

Widget buildColumnSelectPlayerWeapon(){
   return Column(children: [
        container(child: "Swordsman", action: (){
          sendClientRequestSetWeapon(WeaponType.Sword);
        }),
        container(child: "Wizard", action: (){
          sendClientRequestSetWeapon(WeaponType.Staff);
        }),
        container(child: "Archer", action: (){
          sendClientRequestSetWeapon(WeaponType.Bow);
        }),
   ],);
}