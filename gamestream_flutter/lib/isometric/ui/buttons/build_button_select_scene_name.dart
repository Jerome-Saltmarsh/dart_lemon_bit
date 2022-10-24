import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_editor.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';

Widget buildButtonSelectSceneName(String gameName) {

  return watch(GameEditor.selectedSceneName, (selectedSceneName) {
    return container(
      width: 300,
      child: gameName,
      color: gameName == selectedSceneName ? greyDark : grey,
      action: () => GameEditor.selectSceneName(gameName),
    );
  });
}


