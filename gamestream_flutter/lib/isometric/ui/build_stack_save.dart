
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';

import '../../game_widgets.dart';
import 'constants/colors.dart';


final sceneNameController = TextEditingController()..addListener(onSceneNamedChanged);
final enteredSceneNameText = Watch("");

Widget buildControlSceneName(){
  return watch(sceneMetaDataSceneName, (String? sceneName){
      if (sceneName == null || sceneName.trim().isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          color: brownDark,
          child: Column(
            children: [
              text("Enter a name"),
              buildTextFieldName(),
              buildButtonSubmit(),
            ],
          ),
        );
      }
      return text(sceneName);
  });
}

Widget buildButtonSubmit(){
  return watch(enteredSceneNameText, (String name) =>
       container(
           child: "SUBMIT",
           action: name.isEmpty ? null : onButtonPressedSubmit,
           color: name.isEmpty ? grey : greyDark,
       )
  );
}

void onButtonPressedSubmit(){
  sendClientRequestEditorSetSceneName(sceneNameController.text);
}

void onSceneNamedChanged(){
  enteredSceneNameText.value = sceneNameController.text;
}

Widget buildTextFieldName(){
  return Container(
      child: TextField(
        controller: sceneNameController,
        autofocus: true,
      ),
      width: 200,
  );
}