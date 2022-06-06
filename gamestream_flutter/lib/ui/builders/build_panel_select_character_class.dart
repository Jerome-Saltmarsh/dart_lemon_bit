import 'package:bleed_common/Character_Selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/actions.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:gamestream_flutter/web_socket.dart';

Widget buildPanelSelectCharacterClass() {
  return Center(
    child: buildPanel(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            text("ARCHER", onPressed: () {
              if (!webSocket.connected) {
                connectToGame(CharacterSelection.Archer);
              } else {
                sendClientRequestSelectCharacterType(CharacterSelection.Archer);
              }
            }),
            width32,
            text("KNIGHT", onPressed: () {
              if (!webSocket.connected) {
                connectToGame(CharacterSelection.Warrior);
              } else {
                sendClientRequestSelectCharacterType(
                    CharacterSelection.Warrior);
              }
            }),
            width32,
            text("WIZARD", onPressed: () {
              if (!webSocket.connected) {
                connectToGame(CharacterSelection.Wizard);
              } else {
                sendClientRequestSelectCharacterType(CharacterSelection.Wizard);
              }
            }),
          ]),
    ),
  );
}
