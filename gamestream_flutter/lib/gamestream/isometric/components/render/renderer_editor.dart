
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/editor/editor_tab.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/mark_type.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/node_size.dart';
import 'package:lemon_engine/lemon_engine.dart';


class RendererEditor extends RenderGroup {

  var keys = <MapEntry<String, int>>[];

  var markIndex = -1;
  var markType = -1;

  bool get marksTabEnabled => editorTab == EditorTab.Marks;

  bool get keysTabEnabled => editorTab == EditorTab.Keys;

  EditorTab get editorTab => editor.editorTab.value;

  @override
  void reset() {
    if (keysTabEnabled){
      resetKeys();
    }
    super.reset();
  }

  void resetKeys() {
    keys = scene.keys.entries.toList(growable: false);
    keys.sort(sortKeyEntries);
  }

  int sortKeyEntries(MapEntry<String, int> a, MapEntry<String, int> b){
    final aOrder = getKeyEntryOrder(a);
    final bOrder = getKeyEntryOrder(b);
    if (aOrder > bOrder){
      return 1;
    }
    if (aOrder < bOrder){
      return -1;
    }
    return 0;
  }

  @override
  int getTotal() {
    if (!options.editMode){
      return 0;
    }

    if (marksTabEnabled){
      return scene.marks.length;
    }

    if (keysTabEnabled) {
      return scene.keys.length;
    }

    return 0;

  }

  @override
  void updateFunction() {
    if (marksTabEnabled){
      updateTabMarks();
      return;
    }

    if (keysTabEnabled){
      updateTabKeys();
      return;
    }
  }

  @override
  void renderFunction(LemonEngine engine, IsometricImages images) {
    if (marksTabEnabled){
      renderTabMarks();
      return;
    }

    if (keysTabEnabled){
      renderTabKeys();
      return;
    }
  }

  void renderTabMarks() {
    render.textIndex(markType, markIndex);
    switch (markType){
      case MarkType.Spawn_Whisp:
        engine.color = colors.white;
        render.circleOutlineAtIndex(index: markIndex, radius: 15.0);
        break;
      case MarkType.Spawn_Player:
        engine.color = colors.blue_0;
        render.circleOutlineAtIndex(index: markIndex, radius: 15.0);
        break;
      case MarkType.Spawn_Fallen:
        engine.color = colors.red_2;
        render.circleOutlineAtIndex(index: markIndex, radius: 100.0);
        break;
      case MarkType.Glow:
        engine.color = colors.aqua_1;
        render.circleOutlineAtIndex(index: markIndex, radius: 100.0);
        break;
    }
  }

  void updateTabMarks() {
    final scene = this.scene;
    final markValue = scene.marks[index];
    markIndex = MarkType.getIndex(markValue);
    markType = MarkType.getType(markValue);
    order = getOrderAtIndex(markIndex);
  }

  void updateTabKeys() {
    final keyEntry = keys[index];
    order = getKeyEntryOrder(keyEntry);
  }

  void renderTabKeys() {
    final keyEntry = keys[index];
    final keyIndex = keyEntry.value;
    final keyName = keyEntry.key;
    engine.color = Colors.white;
    render.textIndex(keyName, keyIndex);
    render.wireFrameWhite(keyIndex);
  }

  double getKeyEntryOrder(MapEntry<String, int> keyEntry) =>
      getOrderAtIndex(keyEntry.value);

  double getOrderAtIndex(int index){
    final scene = this.scene;
    final indexZ = scene.getIndexZ(index);
    final indexRow = scene.getRow(index);
    final indexColumn = scene.getColumn(index);
    return
      (indexRow * Node_Size) +
      (indexColumn * Node_Size) +
      (indexZ * Node_Height) +
      (Node_Size);
  }

}