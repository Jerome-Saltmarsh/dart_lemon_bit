import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_equip_attack_type.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/state/state_game_waves.dart';
import 'package:lemon_engine/screen.dart';

import 'widgets/build_container.dart';

Widget buildStackGameTypeWavesUI() => Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          child: watch(player.points, (int points) => text("Points: $points")),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: Container(
                alignment: Alignment.center,
                width: screen.width,
                height: screen.height,
                child: buildWatchBool(gameWaves.canPurchase, buildWavesTimer),
            ),
        ),
      ],
    );

Widget buildWavesTimer() =>
  Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      watch(gameWaves.timer, (double time) => Container(
        width: 300,
        height: 50,
        padding: EdgeInsets.all(3),
        color: Colors.white,
        alignment: Alignment.centerLeft,
        child: Container(
          width: 300 * time,
          height: 50,
          color: Colors.green,
        ),
      )),
      height64,
      watch(gameWaves.refresh, (t) =>
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Column(
                children: [
                  text("Primary"),
                  ...gameWaves.purchasePrimary.map(buildPurchase)
                ],
              ),
              width8,
            Column(
              children: [
                text("Secondary"),
                ...gameWaves.purchaseSecondary.map(buildPurchase)
              ],
            ),
            width8,
            Column(
              children: [
                text("Tertiary"),
                ...gameWaves.purchaseTertiary.map(buildPurchase)
              ],
            ),
          ],
        )
      ),
    ],
  );

Widget buildPurchase(Purchase purchase) =>
  container(
      action: () => sendClientRequestPurchaseWeapon(purchase.type),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // text(AttackType.getName(purchase.type)),
          buildIconAttackType(purchase.type),
          text(purchase.cost),
        ],
      )
  );