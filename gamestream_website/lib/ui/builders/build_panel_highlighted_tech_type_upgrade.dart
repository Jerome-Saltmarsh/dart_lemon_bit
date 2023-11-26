import 'package:bleed_common/library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/builders/build_cost.dart';
import 'package:gamestream_flutter/ui/builders/build_row_tech_type.dart';
import 'package:gamestream_flutter/ui/builders/styles.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildPanelHighlightedTechTypeUpgrade(){
  return WatchBuilder(state.highlightedTechTypeUpgrade, (int? type) {
    if (type == null) return empty;
    final level = player.getTechTypeLevel(type);
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
        width: defaultPanelWidth,
        decoration: panelDecoration,
        padding: padding6,
        child: buildCost(cost),
      ),
    );
  });
}
