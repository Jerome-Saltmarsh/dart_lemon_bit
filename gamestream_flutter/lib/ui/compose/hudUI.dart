
import 'package:bleed_common/CharacterAction.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/GameType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/cube/camera3d.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/state/decorationImages.dart';
import 'package:gamestream_flutter/ui/ui.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../widgets.dart';

const double _padding = 8;
final emptyContainer = Container();

Widget buildTopLeft() {
  return Positioned(
      top: _padding,
      left: _padding,
      child: Column(
        crossAxisAlignment: axis.cross.start,
        children: [
          Row(
            children: [
              width8,
              WatchBuilder(game.type, (GameType value) {
                if (value == GameType.Moba) {
                  return Row(
                    children: [
                      WatchBuilder(game.teamLivesWest, (int lives) {
                        return text("West: $lives");
                      }),
                      width8,
                      WatchBuilder(game.teamLivesEast, (int lives) {
                        return text("East: $lives");
                      }),
                    ],
                  );
                }
                return emptyContainer;
              }),
              // buildMouseWorldPosition(),
            ],
          ),
          if (uiOptions.showTotalZombies)
            widgets.totalZombies,
        ],
      ));
}


Widget buildSkillsButton() {
  return WatchBuilder(modules.game.state.player.skillPoints, (int value) {
    if (value == 0) return emptyContainer;
    return Container(
        height: 103,
        alignment: Alignment.topLeft,
        child: border(
            color: Colors.white,
            fillColor: Colors.black45,
            padding: padding4,
            child: text("Points $value", color: Colors.white, size: 20)));
  });
}

Widget buildTotalZombies() {
  return WatchBuilder(game.totalZombies, (int value) {
    return text('Zombies: $value');
  });
}

Widget buildTotalPlayers() {
  return WatchBuilder(game.totalPlayers, (int value) {
    return text('Players: $value');
  });
}


Widget buildPlayerLevel() {
  return WatchBuilder(modules.game.state.player.level, (int value) {
    return text('Level $value');
  });
}

Widget buildBottomRight() {
  return WatchBuilder(modules.game.state.player.characterType, (CharacterType type) {
    return Positioned(
        bottom: _padding,
        right: _padding,
        child: Row(
          children: [
            buildMessageBoxIcon(),
          ],
        ));
  });
}

Widget buildMessageBoxIcon() {
  return onPressed(
      hint: "Press Enter",
      callback: modules.game.actions.toggleMessageBox,
      child: border(
        child: text("Say"),
      ));
}

Widget buildMouseWorldPosition() {
  return WatchBuilder(modules.isometric.state.minutes, (int value) {
    return text("Mouse X: ${mouseWorldX.toInt()}, Y: ${mouseWorldY.toInt()}");
  });
}

String padZero(num value) {
  String t = value.toInt().toString();
  if (t.length >= 2) return t;
  return '0$t';
}

Widget characterStatistics() {
  return Positioned(
      bottom: _padding,
      child: Container(
        width: engine.screen.width,
        child: Row(
          mainAxisAlignment: axis.main.center,
          crossAxisAlignment: axis.cross.end,
          children: [
            Column(
              mainAxisAlignment: axis.main.end,
              children: [
                widgets.healthBar,
                height2,
                widgets.magicBar,
                height2,
                widgets.experienceBar,
              ],
            ),
            width8,
            Container(
              width: 200,
            )
          ],
        ),
      ));
}

Widget layout({
  bool expand = true,
  Widget? topLeft,
  Widget? topRight,
  Widget? bottomRight,
  Widget? bottomLeft,
  Widget? top,
  List<Widget>? children,
  Widget? child,
  double padding = 0,
  Color? color,
  Widget? foreground,
}){
  final stack = Stack(
    children: [
      if (children != null)
        ...children,
      if (child != null)
        child,
      if (topLeft != null)
        Positioned(top: padding, left: padding, child: topLeft,),
      if (topRight != null)
        Positioned(top: padding, right: padding, child: topRight,),
      if (bottomRight != null)
        Positioned(bottom: padding, right: padding, child: bottomRight,),
      if (bottomLeft != null)
        Positioned(bottom: padding, left: padding, child: bottomLeft,),
      if (top != null)
        Positioned(top: padding, child: top),
      if (foreground != null)
        foreground,
    ],
  );

  return expand ? fullScreen(child: stack, color: color): stack;
}

Widget buildUI3DCube() {
  return Column(
    children: [
      buttons.exit,
      Refresh(() {
        return text('camera3D.rotation: ${camera3D.rotation}');
      }),
      // Refresh((){
      //   return text('camera3D.viewportWidth: ${camera3D.viewportWidth.toInt()}');
      // }),
      // Refresh((){
      //   return text('camera3D.viewportHeight: ${camera3D.viewportHeight.toInt()}');
      // }),
      Refresh(() {
        return text('camera3D.fov: ${camera3D.fov.toInt()}');
      }),
      Refresh(() {
        return text(
            'camera.position: { x: ${engine.camera.x.toInt()}, y: ${engine.camera.y.toInt()}}');
      }),
      Refresh(() {
        return text('camera.zoom: ${engine.zoom}');
      }),
    ],
  );
}

Widget buildNumberOfPlayersRequiredDialog() {
  return WatchBuilder(game.numberOfPlayersNeeded, (int number) {
    if (number == 0) return emptyContainer;
    return dialog(
        height: 80,
        child: text("Waiting for $number more players to join the game"));
  });
}

Widget buildTopRight() {
  return Positioned(
    top: _padding,
    right: _padding,
    child: buildMenu(),
  );
}

Widget buildIconEdit({
  double size = 19
}) {
  return buildDecorationImage(
      color: colours.none,
      image: decorationImages.edit, width: size, height: size, borderWidth: 0);
}

final playIcon = buildDecorationImage(
    color: colours.none,
    image: decorationImages.play, width: 60, height: 60, borderWidth: 0);

Widget buildMenu() {
  return mouseOver(builder: (BuildContext context, bool mouseOver){

    final menu = border(child: text("Menu"));

    if (!mouseOver){
      return menu;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (core.state.debug) width8,
        if (core.state.debug) buttons.edit,
        buttons.exit,
        buttons.changeCharacter,
        width8,
        buildToggleFullscreen(),
        width8,
        menu,
      ],
    );
  });
}

void clearPlayerMessage() {
  modules.game.state.player.message.value = "";
}

