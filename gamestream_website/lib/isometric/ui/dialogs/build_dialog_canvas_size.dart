
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/editor/editor.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
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
                action: () =>
                  sendClientRequestCanvasModifySize(
                      dimension: 1,
                      add: false,
                      start: true
                  )
              ),
              container(
                  child: "+",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 1,
                          add: true,
                          start: true
                      )
              ),
              Refresh(() => text("Rows: $gridTotalRows")),
              container(
                  child: "-",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 1,
                          add: false,
                          start: false
                      )
              ),
              container(
                  child: "+",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 1,
                          add: true,
                          start: false
                      )
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              container(
                  child: "-",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 2,
                          add: false,
                          start: true
                      )
              ),
              container(
                  child: "+",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 2,
                          add: true,
                          start: true
                      )
              ),
              Refresh(() => text("Columns: $gridTotalColumns")),
              container(
                  child: "-",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 2,
                          add: false,
                          start: false
                      )
              ),
              container(
                  child: "+",
                  width: 50,
                  alignment: Alignment.center,
                  action: () =>
                      sendClientRequestCanvasModifySize(
                          dimension: 2,
                          add: true,
                          start: false
                      )
              ),
            ],
          )
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