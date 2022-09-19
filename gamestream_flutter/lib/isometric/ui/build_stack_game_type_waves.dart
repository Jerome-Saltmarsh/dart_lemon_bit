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

Widget buildWavesTimer(int timer) {
  if (timer <= 0) return const SizedBox();

  return watch(gameWaves.refresh, (t) {
    return Row(
      children: [
          Column(
            children: [
              text("Primary"),
              ...gameWaves.purchasePrimary.map((e) => container(child: AttackType.getName(e.type)))
            ],
          ),
        Column(
          children: [
            text("Secondary"),
            ...gameWaves.purchaseSecondary.map((e) => container(child: AttackType.getName(e.type)))
          ],
        ),
        Column(
          children: [
            text("Tertiary"),
            ...gameWaves.purchaseTertiary.map((e) => container(child: AttackType.getName(e.type)))
          ],
        )

      ],
    );
  });
}