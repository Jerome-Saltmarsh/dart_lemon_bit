
import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/player.dart';
import 'package:gamestream_flutter/isometric/ui/functions/render_atlas_src.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_attack_type_to_atlas_src.dart';

Widget buildWidgetAttackSlot(AttackSlot slot) {

  return watch(slot.attackType, (int attackType) {
    return watch(slot.capacity, (int capacity) {
      return watch(slot.rounds, (int rounds) {

        final atlasSrc = mapAttackTypeToAtlasSrc[attackType];

        if (atlasSrc == null)
          throw Exception("Could not find atlas src for attack type $attackType: ${AttackType.getName(attackType)}");

        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle
          ),
          width: 64,
          height: 64,
          child: renderAtlasSrc(atlasSrc),
        );
      });
    });
  });
}