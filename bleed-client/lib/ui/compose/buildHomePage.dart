import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/title.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/cupertino.dart';

const _buttonWidth = 220.0;

Widget buildSelectGame() {
  return page(children: [
    fullScreen(
        child: Column(
      children: [
        _buildTitle(),
        height8,
        _buildPanelGames(),
      ],
    )),
    _buildTopRight()
  ]);
}

Positioned _buildTopRight() {
  return Positioned(
    child: Row(
      children: [
        _buildServerButton(),
      ],
    ),
    top: 0,
    right: 0,
  );
}

Widget _buildServerButton() {
  return button("REGION ${toString(game.region.value).toUpperCase()}", () {
    game.region.value = Region.None;
  }, minWidth: _buttonWidth, hint: 'Region');
}

Container _buildTitle() {
  return Container(
      alignment: Alignment.center,
      height: 80,
      child: text(title, fontSize: 40));
}

Widget _buildPanelGames() {
  return Column(
    crossAxisAlignment: axis.cross.stretch,
    children: [
      ...selectableGameTypes.map((GameType value) {
        final Widget type =
            Container(width: 160, child: text(toString(value).toUpperCase()));
        final Widget joinButton = button(
          text(gameTypeNames[value], fontSize: 20, fontWeight: FontWeight.bold),
          () {
            game.type.value = value;
          },
          minWidth: _buttonWidth,
          borderWidth: 3
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: axis.main.center,
            children: [
              joinButton,
              width16,
              type,
            ],
          ),
        );
      }).toList()
    ],
  );
}
