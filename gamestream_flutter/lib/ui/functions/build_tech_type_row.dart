import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/game/build.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'player.dart';


final state = modules.game.state;

Widget buildTechTypeRow(int type, Watch<int> levelWatch) {
  final key = GlobalKey();
  state.panelTypeKey[type] = key;

  return WatchBuilder(levelWatch, (int level) {
    final unlocked = level > 0;
    final cost = TechType.getCost(type, level);
    final upgradeAvailable = cost != null;

    return Container(
      key: key,
      child: WatchBuilder(state.player.equipped, (int equipped) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: onPressed(
                callback: unlocked ? () {
                  Server.equip(type);
                } : null,
                child: WatchBuilder(state.player.equipped, (int equipped) {
                  return Container(
                    padding: padding6,
                    decoration: BoxDecoration(
                      color: equipped == type
                          ? colours.white382
                          : colours.none,
                      borderRadius: borderRadius4,
                    ),
                    height: 48,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: unlocked
                              ? techTypeIcons[type]
                              : techTypeIconsGray[type],
                        ),
                        width16,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            text(
                                TechType.getName(type),
                                color: unlocked
                                    ? colours.white
                                    : colours.white618
                            ),
                            WatchBuilder(player.getTechLevelWatch(type), (int level) {
                              final children = <Widget>[];
                              for (var i = 0; i < 5; i++){
                                children.add(
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: i < level ? Colors.blue : Colors.blue.withOpacity(0.1),
                                  )
                                );
                                if (i + 1 < 5) {
                                   children.add(width4);
                                }
                              }
                              return Row(
                                children: children,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            width6,
            if (upgradeAvailable)
              MouseRegion(
                onEnter: (event) {
                  state.highlightedTechTypeUpgrade.value = type;
                },
                onExit: (event) {
                  if (state.highlightedTechTypeUpgrade.value != type) return;
                  state.highlightedTechTypeUpgrade.value = null;
                },
                child: WatchBuilder(player.getCanAffordWatch(type), (bool canAfford){
                  return onPressed(
                    child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: canAfford ? colours.green : colours.green.withOpacity(0.5), width: 2.0, style: BorderStyle.solid),
                          borderRadius: borderRadius4,
                        ),
                        child: canAfford ? resources.icons.symbols.plus : resources.icons.symbols.plusTransparent),
                    callback: canAfford ? () => Server.upgrade(type) : null,
                  );
                }),
              ),
          ],
        );
      }),
    );
  });
}
