import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../isometric/ui/widgets/build_container.dart';
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
      // Positioned(
      //   bottom: padding,
      //   left: padding,
      //   child: buildMenuDebug() ?? const SizedBox(),
      // ),
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

Widget buildButtonRegion() => WatchBuilder(
    core.state.region,
    (Region selectedRegion) => onMouseOver(
        builder: (BuildContext context, bool mouseOver) => !mouseOver
            ? container(child: enumString(selectedRegion), color: Colors.transparent,)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  container(child: text("REGION"), color: Colors.transparent),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: Region.values
                        .map((Region region) => container(
                              action: () => actionSelectRegion(region),
                              color: Colors.transparent,
                              child: text(
                                  enumString(region),
                                  underline: selectedRegion == region,
                                  bold: selectedRegion == region,
                              ),
                            ))
                        .toList(),
                  )
                ],
              )));

Widget buildButtonSelectRegion(Region region){
  return Container(
      height: 50,
      child: text(region.name, onPressed: () => actionSelectRegion(region)));
}

Widget buildTextVersion(){
  return text(version, color: colours.white618, size: FontSize.Small);
}

void actionSelectRegion(Region value) {
  core.state.region.value = value;
}