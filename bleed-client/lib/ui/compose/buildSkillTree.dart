import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildSkillTree() {
  return WatchBuilder(hud.skillTreeVisible, (bool visible) {
    if (!visible) {
      return Container();
    }

    return WatchBuilder(game.player.skillPoints, (int points) {

      bool pointsLeft = points > 0;

      return Positioned(
          top: 50,
          child: Container(
            width: screen.width,
            height: screen.height,
            child: Row(
              mainAxisAlignment: axis.main.center,
              crossAxisAlignment: axis.cross.start,
              children: [
                onPressed(
                  callback: () {},
                  child: Container(
                    padding: padding8,
                    width: 400,
                    height: 100,
                    color: Colors.white24,
                    child: Column(
                      crossAxisAlignment: axis.cross.start,
                      children: [
                        Row(
                          mainAxisAlignment: axis.main.spread,
                          children: [
                            text(" "),
                            text("Skill Points $points"),
                            Tooltip(
                                message: "Close",
                                child:
                                    text("x", onPressed: hud.skillTreeVisible.setFalse))
                          ],
                        ),
                        height8,
                        if (!game.player.unlocked.shotgun)
                          text("Explosion",
                              onPressed: pointsLeft
                                  ? sendRequestAcquireShotgun
                                  : null,
                              color: pointsLeft
                                  ? Colors.white
                                  : Colors.white38),

                        if (!game.player.unlocked.handgun)
                          text("Blink",
                              onPressed: pointsLeft
                                  ? sendRequestAcquireHandgun
                                  : null,
                              color: pointsLeft
                                  ? Colors.white
                                  : Colors.white38),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
    });
  });
}
