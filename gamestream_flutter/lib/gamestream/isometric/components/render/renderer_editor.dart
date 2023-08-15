
import 'package:gamestream_flutter/common/src/isometric/node_size.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';

class RendererEditor extends RenderGroup {

  var markValue = -1;
  var markIndex = -1;

  @override
  int getTotal() => options.editMode ? scene.marks.length : 0;

  @override
  void updateFunction() {
    markValue = scene.marks[index];
    markIndex = scene.getMarkValueIndex(markValue);
    final indexZ = scene.getIndexZ(markIndex);
    final indexRow = scene.getIndexRow(markIndex);
    final indexColumn = scene.getIndexColumn(markIndex);
    order =  (indexRow * Node_Size) + (indexColumn * Node_Size) + (indexZ * Node_Height);
  }

  @override
  void renderFunction() {
    render.circle32(
        scene.getIndexPositionX(markIndex),
        scene.getIndexPositionY(markIndex),
        scene.getIndexPositionZ(markIndex),
    );
  }
}