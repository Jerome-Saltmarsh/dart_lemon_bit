
import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

Widget buildWavesTimer(int timer) {
  if (timer <= 0) return const SizedBox();
  return Column(
    children: [
      text('NEXT WAVE: $timer'),
      text("Assault Rifle", onPressed: (){
        sendClientRequestPurchaseWeapon(
          AttackType.Assault_Rifle,
        );
      }),
      text("Handgun"),
      text("Sword"),
    ],
  );
}