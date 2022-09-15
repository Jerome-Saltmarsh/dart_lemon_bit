
import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/functions/render_atlas_src.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_attack_type_to_atlas_src.dart';

Widget buildButtonAttackType(int type) {
  final atlasSrc = mapAttackTypeToAtlasSrc[type];

  if (atlasSrc == null)
    throw Exception("Could not find atlas src for attack type $type: ${AttackType.getName(type)}");

  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle
    ),
    width: 64,
    height: 64,
    child: renderAtlasSrc(atlasSrc),
  );
}