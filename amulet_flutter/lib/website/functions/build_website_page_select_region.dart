import 'package:flutter/material.dart';
import 'package:amulet_flutter/isometric/components/isometric_options.dart';
import 'package:amulet_flutter/gamestream/network/enums/connection_region.dart';
import 'package:amulet_flutter/gamestream/ui/constants/font_size.dart';
import 'package:amulet_flutter/gamestream/ui/constants/height.dart';
import 'package:amulet_flutter/isometric/ui/widgets/mouse_over.dart';
import 'package:amulet_flutter/website/enums/website_page.dart';
import 'package:amulet_flutter/website/website_game.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';


Widget buildWebsitePageSelectRegion({
  required IsometricOptions options,
  required WebsiteGame website,
  required LemonEngine engine,
}) => Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    buildText('Select Your Region', size: FontSize.large),
    height16,
    Container(
      width: 300,
      child: WatchBuilder(options.server.remote.region, (activeRegion) {
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
                    website.server.remote.region.value = region;
                    website.websitePage.value = WebsitePage.Select_Character;
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
    ),
  ],
);
