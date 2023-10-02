import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_options.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/font_size.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/height.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:gamestream_flutter/website/website_game.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';


Widget buildWebsitePageSelectRegion({
  required IsometricOptions options,
  required WebsiteGame website,
  required Engine engine,
}) => SizedBox(
  width: 300,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      buildText('Select Your Region', size: FontSize.large),
      height16,
      WatchBuilder(options.region, (activeRegion) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: (engine.isLocalHost ? ConnectionRegion.values : const [
              ConnectionRegion.America_North,
              ConnectionRegion.America_South,
              ConnectionRegion.Asia_North,
              ConnectionRegion.Asia_South,
              ConnectionRegion.Europe,
              ConnectionRegion.Oceania,
              ConnectionRegion.LocalHost,
            ])
                .map((ConnectionRegion region) =>
                onPressed(
                  action: () {
                    options.region.value = region;
                    website.websitePage.value = WebsitePage.User;
                  },
                  child: MouseOver(builder: (bool mouseOver) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: activeRegion == region ? Colors.greenAccent : mouseOver ? Colors.green : Colors.white10,
                      child: buildText(
                          '${region.name}',
                          size: 24,
                          color: mouseOver ? Colors.white : Colors.white60
                      ),
                    );
                  }),
                ))
                .toList(),
          ),
        );
      }),
    ],
  ),
);
