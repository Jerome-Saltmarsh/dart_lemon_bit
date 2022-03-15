import 'package:gamestream_flutter/common/GameType.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/toString.dart';
import 'package:flutter/cupertino.dart';

const _buttonWidth = 220.0;

Widget games = Column(
  crossAxisAlignment: axis.cross.stretch,
  children: [
    ...selectableGameTypes.map((GameType value) {
      final Widget type =
          Container(width: 160, child: text(enumString(value).toUpperCase()));
      final Widget joinButton = button(
          text(gameTypeNames[value], size: 20, weight: FontWeight.bold),
          () {
        game.type.value = value;
      }, width: _buttonWidth, borderWidth: 3);
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


