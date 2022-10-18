import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/enums/region.dart';
import 'package:gamestream_flutter/game_colors.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';

import 'build/build_column_games.dart';




final colorRegion = Colors.orange;

Widget buildStateRegion(Region selectedRegion) => Container(
  height: Engine.screen.height,
  child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: Region.values
            .map((Region region) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: buildTextButton('Region ${enumString(region)}',
                action: selectedRegion == region ? null : () => actionSelectRegion(region),
                size: 18,
                colorRegular: selectedRegion == region
                  ? colorRegion.withOpacity(0.54)
                  : colorRegion.withOpacity(0.24),
                colorMouseOver: selectedRegion == region
                    ? colorRegion.withOpacity(0.54)
                    : colorRegion.withOpacity(0.39),
        ),
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
  return text(version, color: GameColors.white618, size: FontSize.Small);
}

void actionSelectRegion(Region value) {
  Website.region.value = value;
}