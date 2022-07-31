import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

const pad = 6.0;

Widget buildPageWebsite() {
  return Stack(
    children: [
      Positioned(
          top: pad,
          right: pad,
          child: buildTextVersion(),
      ),
      Positioned(
          top: pad,
          left: pad,
          child: buildButtonRegion(),
      ),
      Positioned(
          bottom: pad,
          left: pad,
          child: buildMenuDebug() ?? const SizedBox(),
      ),
      Positioned(
        bottom: pad,
        right: pad,
        child: text("Created by Jerome Saltmarsh", color: colours.white618, size: FontSize.Small),
      ),
      Positioned(
          top: 0,
          left: 0,
          child: Container(
              width: engine.screen.width,
              height: engine.screen.height,
              alignment: Alignment.center,
              child: buildWatchBuilderDialog()
          ),
      )
    ],
  );
}

WatchBuilder<Region> buildButtonRegion() {
  return WatchBuilder(core.state.region, (Region region) {
              return text(region.name,
                  onPressed: modules.website.actions.showDialogChangeRegion);
            });
}


Widget buildTextVersion(){
  return text(version, color: colours.white618, size: FontSize.Small);
}