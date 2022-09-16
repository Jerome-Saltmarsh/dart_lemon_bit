import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_button_attack_type.dart';
import 'package:lemon_engine/screen.dart';

Widget buildControlsPlayerWeapons() => Container(
      width: screen.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildWidgetAttackSlot(player.weaponSlot1),
          width6,
          buildWidgetAttackSlot(player.weaponSlot2),
          width6,
          buildWidgetAttackSlot(player.weaponSlot3),
        ],
      ),
    );
