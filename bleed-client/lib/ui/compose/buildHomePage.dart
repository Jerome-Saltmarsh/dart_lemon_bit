import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/cupertino.dart';

const _buttonWidth = 220.0;

// Widget buildRegion() {
//   return page(children: [
//     fullScreen(
//         child: Column(
//       children: [
//         titleGameStream,
//         height8,
//         games,
//       ],
//     )),
//     topLeft(child: buttons.leaveRegion),
//   ]);
// }

Widget titleGameStream = Container(
    alignment: Alignment.center, height: 80, child: text("gamestream.online", fontSize: 40));

Widget games = Column(
  crossAxisAlignment: axis.cross.stretch,
  children: [
    ...selectableGameTypes.map((GameType value) {
      final Widget type =
          Container(width: 160, child: text(enumString(value).toUpperCase()));
      final Widget joinButton = button(
          text(gameTypeNames[value], fontSize: 20, fontWeight: FontWeight.bold),
          () {
        game.type.value = value;
      }, minWidth: _buttonWidth, borderWidth: 3);
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


