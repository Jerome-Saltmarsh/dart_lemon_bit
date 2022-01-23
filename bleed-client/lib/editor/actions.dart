import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';

import '../actions.dart';

final EditorActions editorActions = EditorActions();

class EditorActions {

  void resetTiles() {
    newScene(rows: game.totalRows, columns: game.totalColumns);
  }

  void newScene({
    int rows = 40,
    int columns = 40,
    Tile tile = Tile.Grass,
  }){
    game.totalRows = rows;
    game.totalColumns = columns;
    game.tiles.clear();
    for (int row = 0; row < rows; row++) {
      List<Tile> columnTiles = [];
      for (int column = 0; column < columns; column++) {
        columnTiles.add(tile);
      }
      game.tiles.add(columnTiles);
    }
    game.crates.clear();
    game.particleEmitters.clear();
    game.environmentObjects.clear();
    game.collectables.clear();
    game.items.clear();
    mapTilesToSrcAndDst();
  }

  void startProcess(String value){
    print("editor.actions.startProcess('$value')");
    editor.state.process.value = value;
  }

  void endProcess(){
    print("editor.actions.processFinished('${editor.state.process.value}')");
    editor.state.process.value = "";
  }

  void endProcessAndCloseDialogs(){
    endProcess();
    closeDialog();
  }

  void closeDialog(){
    print("editor.actions.closeDialog()");
    editor.dialog.value = EditorDialog.None;
  }

  void saveMapToFirestore() async {
    print("editor.actions.saveMapToFirestore()");
    final mapId = editor.mapNameController.text;
    if (mapId.isEmpty) {
      actions.showErrorMessage("map id cannot be empty");
      return;
    }
    editor.actions.startProcess("Saving new map");
    firestoreService.createMap(
        mapId: mapId,
        map: compileGameToJson()
    ).whenComplete(editor.actions.endProcessAndCloseDialogs);
  }

  void loadMapFromFirestore(String name) async {
    final mapJson = await firestoreService.loadMap(name);
    final jsonRows = mapJson['tiles'];
    game.tiles = mapJsonToTiles(jsonRows);
    actions.updateTileRender();
  }
}
