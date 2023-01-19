import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/library.dart';


Widget buildWatchMouseTargetName(){
   return watch(GamePlayer.mouseTargetName, (String? name){
      if (name == null) return GameStyle.Null;

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
               watch(GamePlayer.mouseTargetHealth, (double health){
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

