
import 'package:bleed_common/grid_axis.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/editor/editor_actions.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:golden_ratio/constants.dart';

Widget buildDialogCanvasSize() =>
  Container(
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
                      gridAxis: GridAxis.Row,
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
                          gridAxis: GridAxis.Row,
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
                          gridAxis: GridAxis.Row,
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
                          gridAxis: GridAxis.Row,
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
                          gridAxis: GridAxis.Column,
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
                          gridAxis: GridAxis.Column,
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
                          gridAxis: GridAxis.Column,
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
                          gridAxis: GridAxis.Column,
                          add: true,
                          start: false
                      )
              ),
            ],
          )
        ],
      ),
  );

Widget buildButtonIncreaseGridSizeZ() {
  return container(
                child: "+",
                width: 50,
                alignment: Alignment.center,
                action: increaseCanvasSizeZ,
            );
}