
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/editor/editor.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:golden_ratio/constants.dart';

Widget buildDialogCanvasSize(){
  return Container(
      width: 400,
      height: 400 * goldenRatio_0618,
      child: Column(
        children: [
          text("Canvas Size"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              watch(gridTotalZWatch, (t) => text("Z: ${t}")),
              buildButtonIncreaseGridSizeZ(),
            ],
          ),
        ],
      ),
  );
}

Widget buildButtonIncreaseGridSizeZ() {
  return container(
                child: "+",
                width: 50,
                alignment: Alignment.center,
                action: editor.actions.increaseCanvasSizeZ
            );
}