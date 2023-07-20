
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common/src/mmo/mmo_talent_type.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_actions.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/nothing.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/on_pressed.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUIDialogs on MmoGame {
  Widget buildDialogPlayerTalents() => buildWatch(
      playerTalentsChangedNotifier,
          (_) => buildWatch(
          playerTalentDialogOpen,
              (playersDialogOpen) => !playersDialogOpen
              ? nothing
              : Container(
            width: 500,
            child: Column(
              children: [
                GSContainer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          child: buildText('TALENTS', size: 25)
                      ),
                      onPressed(child: Container(
                          width: 100,
                          height: 100 * goldenRatio_0381,
                          alignment: Alignment.center,
                          color: Colors.black12,
                          child: buildText('x')
                      ), action: toggleTalentsDialog),
                    ],
                  ),
                ),
                GSContainer(
                    height: gamestream.engine.screen.height - 270,
                    alignment: Alignment.topLeft,
                    child: GridView.count(
                        crossAxisCount: 3,
                        children: MMOTalentType.rootValues
                            .map((talentType) => GSContainer(
                            child: Column(
                              children: talentType.children
                                  .map(buildTalent)
                                  .toList(growable: false),
                            )))
                            .toList(growable: false))),
              ],
            ),
          )));

}