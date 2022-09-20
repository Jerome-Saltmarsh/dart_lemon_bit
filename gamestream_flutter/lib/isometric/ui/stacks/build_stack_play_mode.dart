import 'package:bleed_common/teleport_scenes.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_npc_talk.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_experience.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_health.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_weapons.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_player_designed.dart';
import 'package:gamestream_flutter/isometric/watches/inventory_visible.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/screen.dart';

Widget buildStackPlay() {
  return Stack(
    children: [
      Positioned(top: 75, right: 16, child: buildWatchInventoryVisible()),
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(top: 16, left: 0, child: buildControlsPlayerWeapons()),
      Positioned(top: 0, left: 0, child: Container(
        width: screen.width,
        height: screen.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            watch(player.npcTalk, buildControlNpcTalk),
            watch(player.npcTalkOptions, buildControlNpcTopics)
          ],
        ),
      )),
      Positioned(bottom: 50, left: 0, child: buildWatchMouseTargetName()),
      buildWatchPlayerDesigned(),
      Positioned(bottom: 8, child: Container(
        width: screen.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlPlayerExperience(),
            width6,
            buildControlPlayerHealth(),
          ],
        ),
      )),
      buildPanelWriteMessage(),
    ]
  );
}

Widget buildWatchMouseTargetName(){
   return watch(player.mouseTargetName, (String? name){
      if (name == null) return SizedBox();

      return Container(
        alignment: Alignment.center,
        width: engine.screen.width,
        child: Container(
           color: colours.redDark1,
           height: 50,
           width: 100,
           alignment: Alignment.centerLeft,
           child: Stack(
             children: [
               watch(player.mouseTargetHealth, (double health){
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
    return watch(player.weaponType, buildColumnPlayerWeapons);
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

