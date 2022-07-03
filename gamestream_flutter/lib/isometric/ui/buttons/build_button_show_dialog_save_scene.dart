

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';

Widget buildButtonShowDialogSaveScene() {
  return container(
      child: "Save",
      alignment: Alignment.center,
      action: actionGameDialogShowSceneSave,
  );
}