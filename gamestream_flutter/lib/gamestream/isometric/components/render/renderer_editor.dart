
import 'package:gamestream_flutter/common/src/isometric/node_size.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';

class RendererEditor extends RenderGroup {

  var mark = -1;

  @override
  int getTotal() => options.editMode ? scene.marks.length : 0;

  @override
  void updateFunction() {
    mark = scene.marks[index];
    final indexZ = scene.getIndexZ(mark);
    final indexRow = scene.getIndexRow(mark);
    final indexColumn = scene.getIndexColumn(mark);
    order =  (indexRow * Node_Size) + (indexColumn * Node_Size) + (indexZ * Node_Height);
  }

  @override
  void renderFunction() {
    render.circle32(
        scene.getIndexPositionX(mark),
        scene.getIndexPositionY(mark),
        scene.getIndexPositionZ(mark),
    );
  }
}