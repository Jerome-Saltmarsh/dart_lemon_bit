import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';



final state = modules.game.state;

Widget buildRowTechType(int type, Watch<int> levelWatch) {
  final key = GlobalKey();
  state.panelTypeKey[type] = key;

  return WatchBuilder(levelWatch, (int level) {
    final unlocked = level > 0;
    final cost = TechType.getCost(type, level);
    final upgradeAvailable = cost != null;

    return Container(
      key: key,
      child: WatchBuilder(player.weaponType, (int equipped) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: onPressed(
                callback: unlocked ? () {
                  // Server.equip(type);
                } : null,
                child: WatchBuilder(player.weaponType, (int equipped) {
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
                          // child: unlocked
                          //     ? techTypeIcons[type]
                          //     : techTypeIconsGray[type],
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
                        child: unlocked ?
                        canAfford ?
                          icons.symbols.upgrade :
                          icons.symbols.upgradeTransparent :
                          canAfford ?
                          icons.symbols.plus :
                          icons.symbols.plusTransparent),
                    callback: (){
                      // canAfford ? () => Server.upgrade(type) : null;
                    },
                  );
                }),
              ),
          ],
        );
      }),
    );
  });
}
