
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_game_dialog_close.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_editor_dialog.dart';
import 'package:lemon_engine/engine.dart';

Widget buildWatchEditorDialog(EditorDialog? activeEditorDialog){
  if (activeEditorDialog == null) return const SizedBox();

  return Container(
    width: Engine.screen.width,
    height: Engine.screen.height,
    alignment: Alignment.center,
    child: Container(
        width: 350,
        height: 400,
        color: brownDark,
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildButtonGameDialogClose(),
              ],
            ),
            height8,
            buildEditorDialog(activeEditorDialog),
          ],
        )),
  );
}

Widget buildDialog({required Widget child, double width = 350, double height = 400}){
  return Container(
      width: width,
      height: height,
      color: brownDark,
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildButtonGameDialogClose(),
            ],
          ),
          height8,
          child,
        ],
      ));
}
