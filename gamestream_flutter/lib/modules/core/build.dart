

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:lemon_watch/watch_builder.dart';

class CoreBuild {

  Widget buildUI() {
    return Stack(
      children: [
        watch(core.state.operationStatus, buildOperationStatus),
        buildWatchErrorMessage(),
      ],
    );
  }

  Widget buildOperationStatus(OperationStatus operationStatus) =>
    operationStatus != OperationStatus.None
        ? _layoutOperationStatus(operationStatus)
        : watchAccount(buildAccount);

  Widget _layoutOperationStatus(OperationStatus operationStatus) =>
    buildLayout(
        child: fullScreen(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              text(operationStatus.name)
            ],
          ),
        )
    );

  Widget buildLoadingScreen(BuildContext context) {
    final double _width = 300;
    final double _height = 50;
    return fullScreen(
      color: colours.black,
      child: WatchBuilder(core.state.download, (double value) {
        value = 0.6182;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text("GAMESTREAM ${(value * 100).toInt()}%", color: Colors.white),
                height8,
                Container(
                  width: _width,
                  height: _height,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.white,
                    width: _width * value,
                    height: _height,
                  ),
                )
              ],
            ),
          ],
        );
      }),
    );
  }
}