import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/cupertino.dart';

const _buttonWidth = 150.0;

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
    Positioned(
      child: _buildServerButton(),
      top: 0,
      right: 0,
    )
  ]);
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
      child: text("LEMON ARCADE", fontSize: 30));
}

Widget _buildPanelGames() {
  return Column(
    children: [
      text("Games"),
      ...selectableGameTypes.map((GameType value) {
        return Container(
          child: button(
            toString(value),
            () {
              game.type.value = value;
            },
            minWidth: _buttonWidth,
          ),
          margin: const EdgeInsets.only(bottom: 8),
        );
      }).toList()
    ],
  );
}
