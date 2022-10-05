import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../isometric/ui/widgets/build_container.dart';
import 'build/build_column_games.dart';
import 'package:lemon_watch/watch.dart';

final isVisibleDialogCustomRegion = Watch(false);

Widget buildPageWebsite({double padding = 6})  =>
  Stack(
    children: [
      Positioned(
        top: padding,
        right: padding,
        child: buildTextVersion(),
      ),
      // buildWatchBool(isVisibleDialogCustomRegion, () {
      //   return Positioned(
      //     top: 16,
      //     left: 100,
      //     child: buildDialogCustomRegion(),
      //   );
      // }),
      Positioned(
          top: 0,
          left: 180,
          child: buildWatchBool(isVisibleDialogCustomRegion, buildInputCustomConnectionString),
        ),
        Positioned(
          top: padding,
          left: padding,
          child: buildButtonRegion(),
      ),
      Positioned(
        bottom: padding,
        right: padding,
        child: text("Created by Jerome Saltmarsh", color: colours.white618,
            size: FontSize.Small),
      ),
      Positioned(
        top: screen.height * 0.25,
        left: 0,
        child: Container(
          width: screen.width,
          height: screen.height,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // text("GAMESTREAM", size: 60),
              // height64,
              buildColumnGames(),
            ],
          ),
        ),
      )
    ],
  );

Widget buildButtonRegion() => WatchBuilder(
    core.state.region,
    (Region selectedRegion) => onMouseOver(
        builder: (BuildContext context, bool mouseOver) =>
            !mouseOver
            ? container(
                child: Row(
                children: [
                text('REGION ', color: Colors.white54),
                text(enumString(selectedRegion), color: Colors.white70),
            ],
          ),
          color: Colors.transparent,
        )
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


Widget buildInputCustomConnectionString() =>
    Container(
      width: 280,
      margin: const EdgeInsets.only(left: 12),
      child: TextField(
        autofocus: true,
        controller: website.state.customConnectionStrongController,
        decoration: InputDecoration(
            labelText: 'ws connection string'
        ),
      ),
    );

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