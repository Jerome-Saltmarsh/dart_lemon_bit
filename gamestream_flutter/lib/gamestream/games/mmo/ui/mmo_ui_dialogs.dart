
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common/src/mmo/mmo_talent_type.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_actions.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUIDialogs on MmoGame {

  Widget buildButtonClose({required Function action}) => onPressed(child: Container(
        width: 100,
        height: 100 * goldenRatio_0381,
        alignment: Alignment.center,
        color: Colors.black26,
        child: buildText('x')
    ), action: action
  );

  Widget buildDialogTitle(String text) =>
      buildText(text, size: 28.0, color: Colors.white70);

  Widget buildDialogPlayerInventory(){
    return buildWatch(playerInventoryOpen, (inventoryOpen){
       if (!inventoryOpen){
         return buildInventoryButton();
       } else {
         return GSContainer(
           rounded: true,
           width: 340,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   buildDialogTitle('INVENTORY'),
                   buildButtonClose(action: toggleInventoryOpen),
                 ],
               ),
              height16,
              buildPlayerTreasures(),
              height16,
              Row(
                children: [
                  buildPlayerEquipped(),
                  width16,
                  buildPlayerItems(),
                ],
              )
           ],),
         );
       }
    });
  }

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
                          child: buildDialogTitle('TALENTS ${playerTalentPoints.value}')
                      ),
                      buildButtonClose(action: toggleTalentsDialog),
                    ],
                  ),
                ),
                GSContainer(
                    height: gamestream.engine.screen.height - 270,
                    alignment: Alignment.topLeft,
                    child: GridView.count(
                        crossAxisCount: 3,
                        children: MMOTalentType.values
                            .map(buildTalent)
                            .toList(growable: false))),
              ],
            ),
          )));

}
