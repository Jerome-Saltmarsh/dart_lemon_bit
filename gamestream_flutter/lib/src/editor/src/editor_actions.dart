
import 'package:gamestream_flutter/library.dart';

class EditorActions {

  static void downloadScene() =>
      GameNetwork.sendClientRequestEdit(EditRequest.Download);

  static void toggleWindowEnabledScene(){
    EditorState.windowEnabledScene.value = !EditorState.windowEnabledScene.value;
  }

  static void toggleWindowEnabledCanvasSize(){
    EditorState.windowEnabledCanvasSize.value = !EditorState.windowEnabledCanvasSize.value;
  }


  static void exportSceneToJson(){

  }

  static void generateScene() =>
      GameNetwork.sendClientRequestEditGenerateScene(
        rows: EditorState.generateRows.value,
        columns: EditorState.generateColumns.value,
        height: EditorState.generateHeight.value,
      );
}