
import 'package:file_picker/file_picker.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';

class EditorActions {


  static void downloadScene() =>
      gamestream.network.sendClientRequestEdit(EditRequest.Download);

  static void uploadScene() async {
    final result = await FilePicker.platform.pickFiles(
        withData: true,
        dialogTitle: "Load Scene",
        type: FileType.custom,
        allowedExtensions: ['scene'],
    );
    if (result == null) {
      ClientActions.showMessage('result == null');
      return;
    }
    final contents = result.files[0].bytes;
    if (contents == null) {
      ClientActions.showMessage('contents == null');
      return;
    }
    gamestream.network.uploadScene(contents);
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
      gamestream.network.sendClientRequestEditGenerateScene(
        rows: EditorState.generateRows.value,
        columns: EditorState.generateColumns.value,
        height: EditorState.generateHeight.value,
        octaves: EditorState.generateOctaves.value,
        frequency: EditorState.generateFrequency.value,
      );
}