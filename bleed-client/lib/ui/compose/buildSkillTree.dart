import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildSkillTree(){
  return WatchBuilder(hud.skillTreeVisible, (bool visible){
    if (!visible){
      return Container();
    }

    return Positioned(
        top: 50,
        child: Container(
          width: screenWidth,
          height: screenHeight,
          child: Row(
            mainAxisAlignment: main.center,
            crossAxisAlignment: cross.start,
            children: [
              onPressed(
                callback: (){},
                child: Container(
                  padding: padding8,
                  width: 400,
                  height: 100,
                  color: Colors.white24,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: main.spread,
                        children: [
                          text(" "),
                          text("Skills"),
                          Tooltip(
                              message: "Close",
                              child: text("x", onPressed: hud.toggle.skillTree))
                        ],
                      ),
                      height8,
                      if (!shotgunUnlocked())
                        text("Unlock Shotgun", onPressed: sendRequestAcquireAbility),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  });
}
