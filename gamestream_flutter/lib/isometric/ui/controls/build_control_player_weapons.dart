import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_button_attack_type.dart';
import 'package:lemon_engine/engine.dart';

Widget buildControlsPlayerWeapons() => Container(
      width: Engine.screen.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
              message: "Left Click",
              child: buildWidgetAttackSlot(Game.player.weaponSlot1)),
          width6,
          Tooltip(
              message: "Right Click",
              child: buildWidgetAttackSlot(Game.player.weaponSlot2)),
          width6,
          Tooltip(
              message: "Space",
              child: buildWidgetAttackSlot(Game.player.weaponSlot3)),
        ],
      ),
    );
