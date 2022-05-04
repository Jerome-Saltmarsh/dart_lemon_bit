
import 'package:bleed_common/CharacterType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

const double _padding = 8;
final emptyContainer = Container();

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
  return WatchBuilder(modules.isometric.minutes, (int value) {
    return text("Mouse X: ${mouseWorldX.toInt()}, Y: ${mouseWorldY.toInt()}");
  });
}

String padZero(num value) {
  String t = value.toInt().toString();
  if (t.length >= 2) return t;
  return '0$t';
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

Widget buildNumberOfPlayersRequiredDialog() {
  return WatchBuilder(game.numberOfPlayersNeeded, (int number) {
    if (number == 0) return emptyContainer;
    return dialog(
        height: 80,
        child: text("Waiting for $number more players to join the game"));
  });
}

void clearPlayerMessage() {
  modules.game.state.player.message.value = "";
}

