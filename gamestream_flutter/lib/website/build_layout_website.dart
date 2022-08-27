import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build/build_column_games.dart';

Widget buildPageWebsite({double padding = 6}) {

  return Stack(
    children: [
      Positioned(
        top: padding,
        right: padding,
        child: buildTextVersion(),
      ),
      Positioned(
        top: padding,
        left: padding,
        child: buildButtonRegion(),
      ),
      Positioned(
        bottom: padding,
        left: padding,
        child: buildMenuDebug() ?? const SizedBox(),
      ),
      Positioned(
        bottom: padding,
        right: padding,
        child: text("Created by Jerome Saltmarsh", color: colours.white618,
            size: FontSize.Small),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: screen.width,
          height: screen.height,
          alignment: Alignment.center,
          child: buildColumnGames(),
        ),
      )
    ],
  );
}

WatchBuilder<Region> buildButtonRegion()  =>
  WatchBuilder(core.state.region, (Region region) {
              return text(
                  region.name,
                  onPressed: modules.website.actions.showDialogChangeRegion,
              );
            }
  );


Widget buildTextVersion(){
  return text(version, color: colours.white618, size: FontSize.Small);
}