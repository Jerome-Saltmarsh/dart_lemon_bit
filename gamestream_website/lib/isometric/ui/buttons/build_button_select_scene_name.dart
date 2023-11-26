import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/selected_scene_name.dart';

Widget buildButtonSelectSceneName(String gameName) {

  return watch(selectedSceneName, (selectedSceneName) {
    return container(
      width: 300,
      child: gameName,
      color: gameName == selectedSceneName ? greyDark : grey,
      action: () => selectSceneName(gameName),
    );
  });
}


