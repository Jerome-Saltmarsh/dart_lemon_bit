import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/builders/build_row_tech_type.dart';
import 'package:lemon_watch/watch_builder.dart';


Widget buildPanelHighlightedStructureType(){
  return WatchBuilder(state.highlightStructureType, (int? type){
    if (type == null) return const SizedBox();
    final context = modules.game.state.keyPanelStructure.currentContext;
    if (context == null) return const SizedBox();
    final renderBox = context.findRenderObject() as RenderBox;

    final cost = StructureType.getCost(type);

    return Positioned(
      right: 220,
      top: renderBox.localToGlobal(Offset.zero).dy,
      child: Container(
        width: 200,
        // height: 200,
        padding: padding8,
        decoration: BoxDecoration(
          color: colours.brownDark,
          borderRadius: borderRadius4,
        ),
        child: Column(
          children: [
            text(StructureType.getName(type)),
            height8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (cost.wood > 0)
                  Column(
                    children: [
                      icons.resources.wood,
                      text(cost.wood),
                    ],
                  ),
                if (cost.stone > 0)
                  Column(
                    children: [
                      icons.resources.stone,
                      text(cost.stone),
                    ],
                  ),
                if (cost.gold > 0)
                  Column(
                    children: [
                      icons.resources.gold,
                      text(cost.gold),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  });
}
