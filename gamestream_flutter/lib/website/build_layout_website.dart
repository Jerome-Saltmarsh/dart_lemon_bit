import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:lemon_engine/screen.dart';

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
          // top: padding,
          left: 32,
          child: watch(core.state.region, buildStateRegion),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildColumnGames(),
            ],
          ),
        ),
      )
    ],
  );

Widget buildStateRegion(Region selectedRegion) => Container(
  height: screen.height,
  child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: Region.values
            .map((Region region) => buildTextButton('Region ${enumString(region)}',
              action: selectedRegion == region ? null : () => actionSelectRegion(region),
              colorRegular: selectedRegion == region
                ? Colors.white54
                : Colors.white24,
              colorMouseOver: selectedRegion == region
                ? Colors.white54
                : Colors.white54,
        ))
            .toList(),
      ),
);

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