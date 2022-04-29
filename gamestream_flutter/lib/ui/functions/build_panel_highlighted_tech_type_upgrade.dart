import 'package:bleed_common/library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/functions/build_cost.dart';
import 'package:gamestream_flutter/ui/functions/build_tech_type_row.dart';
import 'package:gamestream_flutter/ui/functions/styles.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildPanelHighlightedTechTypeUpgrade(){
  return WatchBuilder(state.highlightedTechTypeUpgrade, (int? type) {
    if (type == null) return empty;
    final level = state.player.getTechTypeLevel(type);
    final cost = TechType.getCost(type, level);
    if (cost == null) return empty;
    final key = state.panelTypeKey[type];
    if (key == null) return empty;
    final context = key.currentContext;
    if (context == null) return empty;
    final renderBox = context.findRenderObject() as RenderBox;

    return Positioned(
      right: 238,
      top: renderBox.localToGlobal(Offset.zero).dy,
      child: Container(
        width: 200,
        decoration: boxStandard,
        padding: padding6,
        child: Column(
          children: [
            text("Level ${level + 1}"),
            buildCost(cost),
          ],
        ),
      ),
    );
  });
}
