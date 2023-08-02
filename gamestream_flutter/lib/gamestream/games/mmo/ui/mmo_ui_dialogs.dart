
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common/src/mmo/mmo_talent_type.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_actions.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUIDialogs on MmoGame {

  Widget buildButtonClose({required Function action}) => onPressed(child: Container(
        width: 80,
        height: 80 * goldenRatio_0381,
        alignment: Alignment.center,
        color: Colors.black26,
        child: buildText('x', color: Colors.white70, size: 22)
    ), action: action
  );

  Widget buildDialogTitle(String text) =>
      buildText(text, size: 28.0, color: Colors.white70);

  Widget buildDialogPlayerInventory(){

    final dialog = GSContainer(
      rounded: true,
      width: 340,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: buildDialogTitle('INVENTORY')),
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

    final inventoryButton = buildInventoryButton();

    return buildWatch(playerInventoryOpen, (inventoryOpen) =>
      inventoryOpen ? dialog : inventoryButton);
  }

  Widget buildDialogPlayerTalents() {
    return buildWatch(
      playerTalentsChangedNotifier,
          (_) {

        final dialog = GSContainer(
          width: 500,
          rounded: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 20),
                      child: buildDialogTitle('TALENTS ${playerTalentPoints.value}')
                  ),
                  buildButtonClose(action: toggleTalentsDialog),
                ],
              ),
              GSContainer(
                  height: engine.screen.height - 270,
                  alignment: Alignment.topLeft,
                  child: GridView.count(
                      crossAxisCount: 4,
                      children: MMOTalentType.values
                          .map(buildTalent)
                          .toList(growable: false))),
            ],
          ),
        );

      return buildWatch(playerTalentDialogOpen,
          (playersDialogOpen) => !playersDialogOpen ? nothing : dialog);
    });
  }

  Widget buildTalentHoverDialog() => buildWatch(
      talentHover,
      (talentType) => talentType == null
          ? nothing
          : GSContainer(
              child: buildText(talentType.name),
            ));
}
