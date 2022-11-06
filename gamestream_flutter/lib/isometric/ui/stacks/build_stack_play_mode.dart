import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_ui_interact.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_experience.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_health.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_page.dart';
import 'package:gamestream_flutter/library.dart';

Widget buildStackPlay() =>
  buildPage(
    children: [
      // Positioned(top: 75, right: 16, child: buildWatchBool(GameState.inventoryOpen, GameInventoryUI.buildInventoryUI)),
      watch(GameInventoryUI.itemTypeHover, GameInventoryUI.buildPositionedContainerItemTypeInformation),
      Positioned(top: 50, left: 0, child: GameUIInteract.buildPositionedTrading()),
      GameUIInteract.buildWatchInteractMode(),
    ]
  );

Widget buildBottomPlayerExperienceAndHealthBar() =>
  Positioned(bottom: 8, child: Container(
    width: Engine.screen.width,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildControlPlayerExperience(),
        width6,
        buildControlPlayerHealth(),
      ],
    ),
  ));

Widget buildWatchMouseTargetName(){
   return watch(GameState.player.mouseTargetName, (String? name){
      if (name == null) return SizedBox();

      return Container(
        alignment: Alignment.center,
        width: Engine.screen.width,
        child: Container(
           color: GameColors.redDark1,
           height: 50,
           width: 100,
           alignment: Alignment.centerLeft,
           child: Stack(
             children: [
               watch(GameState.player.mouseTargetHealth, (double health){
                  return Container(
                    height: 50,
                    width: 100 * health,
                    color: Colors.red,
                  );
               }),
               Container(
                   width: 100,
                   height: 50,
                   alignment: Alignment.center,
                   padding: const EdgeInsets.only(left: 6),
                   child: text(name)),
             ],
           ),
        ),
      );
   });
}



Widget buildColumnTeleport(){
  return Container(
    color: brownLight,
    padding: padding8,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text("Village", onPressed: (){
          GameNetwork.sendClientRequestTeleportScene(TeleportScenes.Village);
        }),
        height6,
        text("Dungeon 1", onPressed: (){
          GameNetwork.sendClientRequestTeleportScene(TeleportScenes.Dungeon_1);
        }),
      ],
    ),
  );
}

