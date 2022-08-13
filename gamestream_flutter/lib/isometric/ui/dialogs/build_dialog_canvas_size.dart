
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
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          text("Canvas Size"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Refresh(() => text("Z: $gridTotalZ")),
              buildButtonIncreaseGridSizeZ(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              container(
                child: "-",
                width: 50,
                alignment: Alignment.center,
                action: editor.actions.increaseCanvasSizeZ
              ),
              container(
                  child: "+",
                  width: 50,
                  alignment: Alignment.center,
                  action: editor.actions.increaseCanvasSizeZ
              ),
              Refresh(() => text("Rows: $gridTotalRows")),
              container(
                  child: "-",
                  width: 50,
                  alignment: Alignment.center,
                  action: editor.actions.increaseCanvasSizeZ
              ),
              container(
                  child: "+",
                  width: 50,
                  alignment: Alignment.center,
                  action: editor.actions.increaseCanvasSizeZ
              ),
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