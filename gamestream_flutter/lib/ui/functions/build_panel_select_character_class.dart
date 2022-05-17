
import 'package:bleed_common/Character_Selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';

Widget buildPanelSelectCharacterClass() {
  return Center(
    child: buildPanel(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           text("ARCHER", onPressed: () {
             core.actions.connectToGame(CharacterSelection.Archer);
           }),
           width32,
            text("WIZARD", onPressed: () {
              core.actions.connectToGame(CharacterSelection.Wizard);
            }),
            width32,
            text("KNIGHT", onPressed: () {
              core.actions.connectToGame(CharacterSelection.Warrior);
            }),
      ]),
    ),
  );
}