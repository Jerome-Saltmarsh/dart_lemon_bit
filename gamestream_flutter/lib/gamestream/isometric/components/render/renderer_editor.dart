
import 'package:gamestream_flutter/common/src/isometric/node_size.dart';
import 'package:gamestream_flutter/common/src/types/mark_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';


class RendererEditor extends RenderGroup {

  var markIndex = -1;
  var markType = -1;

  @override
  int getTotal() => options.editMode ? scene.marks.length : 0;

  @override
  void updateFunction() {
    final markValue = scene.marks[index];
    markIndex = MarkType.getIndex(markValue);
    markType = MarkType.getType(markValue);
    final indexZ = scene.getIndexZ(markIndex);
    final indexRow = scene.getIndexRow(markIndex);
    final indexColumn = scene.getIndexColumn(markIndex);
    order =  (indexRow * Node_Size) + (indexColumn * Node_Size) + (indexZ * Node_Height) + Node_Size_Half;
  }

  @override
  void renderFunction() {
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
        engine.color = colors.red2;
        render.circleOutlineAtIndex(index: markIndex, radius: 100.0);
        break;
    }
  }
}