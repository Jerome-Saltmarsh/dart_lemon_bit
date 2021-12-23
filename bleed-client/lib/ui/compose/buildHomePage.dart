import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/title.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/cupertino.dart';

const _buttonWidth = 180.0;

Widget buildHomePage() {
  return page(children: [
    fullScreen(
        child: Column(
      children: [
        _buildTitle(),
        height8,
        _buildPanelGames(),
        height8,
      ],
    )),
    _buildTopRight()
  ]);
}

Positioned _buildTopRight() {
  return Positioned(
    child: Row(
      children: [
        buildToggleFullscreen(),
        width8,
        _buildServerButton(),
      ],
    ),
    top: 0,
    right: 0,
  );
}

Widget _buildServerButton() {
  return button(toString(game.serverType.value), () {
    game.serverType.value = ServerType.None;
  }, minWidth: _buttonWidth);
}

Container _buildTitle() {
  return Container(
      alignment: Alignment.center,
      height: 80,
      child: text(title, fontSize: 30));
}

Widget _buildPanelGames() {
  return Column(
    crossAxisAlignment: cross.stretch,
    children: [
      ...selectableGameTypes.map((GameType value) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: main.center,
            children: [
              Container(
                  width: 100,
                  child: text(toString(value).toUpperCase())),
              width16,
              button(gameTypeNames[value],
                () {
                  game.type.value = value;
                },
                minWidth: _buttonWidth,
              ),
            ],
          ),
        );
      }).toList()
    ],
  );
}
