
import 'package:file_picker/file_picker.dart';
import 'package:gamestream_flutter/library.dart';

class EditorActions {


  static void uploadScene() async {
    final result = await FilePicker.platform.pickFiles(
        withData: true,
        dialogTitle: "Load Scene",
        type: FileType.custom,
        allowedExtensions: ['scene'],
    );
    if (result == null) {
      gamestream.isometric.clientState.showMessage('result == null');
      return;
    }
    final sceneBytes = result.files[0].bytes;
    if (sceneBytes == null) {
      gamestream.isometric.clientState.showMessage('contents == null');
      return;
    }
    gamestream.isometric.editor.loadScene(sceneBytes);
  }


  static void toggleWindowEnabledScene(){
    EditorState.windowEnabledScene.value = !EditorState.windowEnabledScene.value;
  }

  static void toggleWindowEnabledCanvasSize(){
    EditorState.windowEnabledCanvasSize.value = !EditorState.windowEnabledCanvasSize.value;
  }


  static void exportSceneToJson(){

  }

  static void generateScene() =>
      gamestream.isometric.editor.sendClientRequestEditGenerateScene(
        rows: EditorState.generateRows.value,
        columns: EditorState.generateColumns.value,
        height: EditorState.generateHeight.value,
        octaves: EditorState.generateOctaves.value,
        frequency: EditorState.generateFrequency.value,
      );
}