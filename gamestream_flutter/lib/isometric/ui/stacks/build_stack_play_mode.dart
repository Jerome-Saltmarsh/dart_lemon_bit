import 'package:bleed_common/teleport_scenes.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_npc_talk.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_experience.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_health.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_page.dart';
import 'package:gamestream_flutter/isometric/watches/inventory_visible.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';
import 'package:lemon_engine/engine.dart';

Widget buildStackPlay() =>
  buildPage(
    children: [
      Positioned(top: 75, right: 16, child: buildWatchInventoryVisible()),
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(top: 0, left: 0, child: Container(
        width: Engine.screen.width,
        height: Engine.screen.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            watch(Game.player.npcTalk, buildControlNpcTalk),
            watch(Game.player.npcTalkOptions, buildControlNpcTopics)
          ],
        ),
      )),
      Positioned(bottom: 50, left: 0, child: buildWatchMouseTargetName()),
      // buildWatchPlayerDesigned(),
      buildPanelWriteMessage(),
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
   return watch(Game.player.mouseTargetName, (String? name){
      if (name == null) return SizedBox();

      return Container(
        alignment: Alignment.center,
        width: Engine.screen.width,
        child: Container(
           color: colours.redDark1,
           height: 50,
           width: 100,
           alignment: Alignment.centerLeft,
           child: Stack(
             children: [
               watch(Game.player.mouseTargetHealth, (double health){
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

Widget buildWatchInventoryVisible(){
  return watch(inventoryVisible, (bool inventoryVisible){
    if (!inventoryVisible) return const SizedBox();
    return watch(Game.player.weapon.type, buildColumnPlayerWeapons);
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
          sendClientRequestTeleportScene(TeleportScenes.Village);
        }),
        height6,
        text("Dungeon 1", onPressed: (){
          sendClientRequestTeleportScene(TeleportScenes.Dungeon_1);
        }),
      ],
    ),
  );
}

