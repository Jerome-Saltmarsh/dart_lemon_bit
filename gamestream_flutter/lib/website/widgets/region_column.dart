
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/website/enums/website_page.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/style.dart';

class SelectRegionColumn extends StatelessWidget {

  static const Live_Regions = [
    ConnectionRegion.America_North,
    ConnectionRegion.America_South,
    ConnectionRegion.Europe,
    ConnectionRegion.Asia_North,
    ConnectionRegion.Asia_South,
    ConnectionRegion.Oceania,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          text("Select Your Region", size: FontSize.Large),
          height16,
          WatchBuilder(gamestream.network.region, (activeRegion) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: (engine.isLocalHost ? ConnectionRegion.values : Live_Regions)
                    .map((ConnectionRegion region) =>
                    onPressed(
                      action: () {
                        gamestream.network.region.value = region;
                        gamestream.games.website.websitePage.value = WebsitePage.Games;
                      },
                      child: MouseOver(builder: (bool mouseOver) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: activeRegion == region ? Colors.greenAccent : mouseOver ? Colors.green : Colors.white10,
                          child: text(
                              '${engine.enumString(region)}',
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
  }
}