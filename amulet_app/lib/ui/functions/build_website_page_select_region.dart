import 'package:amulet_app/amulet_app.dart';
import 'package:amulet_app/enums/src.dart';
import 'package:amulet_flutter/isometric/consts/font_size.dart';
import 'package:amulet_flutter/isometric/consts/height.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/isometric/ui/widgets/mouse_over.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';

import '../enums/website_page.dart';


Widget buildWebsitePageSelectRegion({
  required AmuletApp amuletApp,
}) => Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    buildText('Select Your Region', size: FontSize.large),
    height16,
    Container(
      width: 300,
      child: WatchBuilder(amuletApp.connectionRegion, (activeRegion) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: ConnectionRegion.values
                .map((ConnectionRegion region) =>
                onPressed(
                  action: () {
                    amuletApp.connectionRegion.value = region;
                    amuletApp.websitePage.value = WebsitePage.Select_Character;
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
