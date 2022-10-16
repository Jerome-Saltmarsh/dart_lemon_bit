import 'package:bleed_common/game_wave_request.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_equip_attack_type.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_weapons.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/state/state_game_waves.dart';
import 'package:lemon_engine/engine.dart';

Widget buildStackGameTypeWavesUI() => Stack(
      children: [
        Positioned(top: 16, left: 0, child: buildControlsPlayerWeapons()),
        Positioned(
          bottom: 0,
          left: 0,
          child: watch(Game.player.points, (int points) => text("Points: $points")),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: Container(
                alignment: Alignment.center,
                width: Engine.screen.width,
                height: Engine.screen.height,
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
      text("READY", onPressed: () => sendClientRequest(ClientRequest.Game_Waves, GameWaveRequest.ready)),
      height16,
      Stack(
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
          Container(
              width: 300,
              height: 50,
              alignment: Alignment.center,
              child: watch(gameWaves.round, (int round) => text("Round $round", color: Colors.black))
          ),
        ],
      ),

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
      toolTip: AttackType.getName(purchase.type),
      action: () => sendClientRequestPurchaseWeapon(purchase.type),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildIconAttackType(purchase.type),
          text(purchase.cost),
        ],
      )
  );