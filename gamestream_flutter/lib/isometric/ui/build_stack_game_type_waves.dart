import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/state/state_game_waves.dart';

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
        child: watch(gameWaves.timer, buildWavesTimer)),
  ],
);

Widget buildWavesTimer(int timer) => timer <= 0 ? const SizedBox() :
  watch(gameWaves.refresh, (t) =>
    Row(
      children: [
          Column(
            children: [
              text("Primary"),
              ...gameWaves.purchasePrimary.map(buildPurchase)
            ],
          ),
        Column(
          children: [
            text("Secondary"),
            ...gameWaves.purchaseSecondary.map(buildPurchase)
          ],
        ),
        Column(
          children: [
            text("Tertiary"),
            ...gameWaves.purchaseTertiary.map(buildPurchase)
          ],
        ),
      ],
    )
  );

Widget buildPurchase(Purchase purchase) =>
  container(
      action: () => sendClientRequestPurchaseWeapon(purchase.type),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text(AttackType.getName(purchase.type)),
          text(purchase.cost),
        ],
      )
  );