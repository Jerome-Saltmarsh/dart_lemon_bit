import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/game/build.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';


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
              child: MouseRegion(
                onEnter: (event) {
                  state.highlightedTechType.value = type;
                },
                onExit: (event) {
                  if (state.highlightedTechType.value != type) return;
                  state.highlightedTechType.value = null;
                },
                child: onPressed(
                  callback: () {
                    if (unlocked) {
                      Server.equip(type);
                    } else {
                      Server.upgrade(type);
                    }
                  },
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
                          text(
                              TechType.getName(type),
                              color: unlocked
                                  ? colours.white
                                  : colours.white618
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            width6,
            if (level > 0 && upgradeAvailable)
              MouseRegion(
                onEnter: (event) {
                  state.highlightedTechTypeUpgrade.value = type;
                },
                onExit: (event) {
                  if (state.highlightedTechTypeUpgrade.value != type) return;
                  state.highlightedTechTypeUpgrade.value = null;
                },
                child: onPressed(
                  child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: colours.green, width: 2.0, style: BorderStyle.solid),
                      ),
                      child: resources.icons.symbols.plus),
                  callback: () => Server.upgrade(type),
                ),
              ),
          ],
        );
      }),
    );
  });
}
