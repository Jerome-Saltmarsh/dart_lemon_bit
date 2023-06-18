import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/library.dart';
import '../constants/colors.dart';
import '../widgets/build_container.dart';


Widget buildGameDialog(GameDialog? gameDialog) =>
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: GameDialog.values.map((e) =>
            container(
              child: e.name,
              action: ()=> gamestream.isometric.player.gameDialog.value = e,
              color: gameDialog == e ? brownDark : brownLight,
              hoverColor: brownDark,
            ),
        ).toList(),
      ),
      buildButtonCloseGameDialog(),
    ],
  );


Widget buildButtonCloseGameDialog() =>
    container(
      toolTip: "(Press T)",
      child: buildText("x"),
      alignment: Alignment.center,
      action: actionCloseGameDialog,
    );

void actionCloseGameDialog(){
  gamestream.isometric.player.gameDialog.value = null;
}