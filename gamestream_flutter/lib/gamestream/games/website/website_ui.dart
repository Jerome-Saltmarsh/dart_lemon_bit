
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/website/enums/website_page.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/website/widgets/game_type_column.dart';
import 'package:gamestream_flutter/website/widgets/region_column.dart';

extension WebsiteUI on WebsiteGame {

  Widget buildColumnSelectGameType(){
    return WatchBuilder(
        gamestream.gameType,
            (activeGameType) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              GameType.Combat,
              GameType.Fight2D,
              GameType.Capture_The_Flag,
            ]
                .map((gameType) => onPressed(
              action: () => gamestream.startGameType(gameType),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    SizedBox(
                        width: 256,
                        child: GameTypeImage(gameType: gameType)),
                    text(gameType.name, size: 25),
                  ],
                ),
              ),
            ))
                .toList()));

  }

  Widget buildPageWebsiteDesktop() {
    return Center(
      child: WatchBuilder(websitePage, (websitePage){
        if (websitePage == WebsitePage.Region){
          return SelectRegionColumn();
        }
        return WatchBuilder(gamestream.network.region, (ConnectionRegion? region) {
          if (region == null) return SelectRegionColumn();

          final regionButton = onPressed(
            action: showWebsitePageRegion,
            child: Container(
              color: Colors.white12,
              alignment: Alignment.center,
              padding: GameStyle.Container_Padding,
              child: Row(
                children: [
                  text(formatEnumName(region.name)),
                ],
              ),
            ),
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildLogoGameStream(),
                    // width32,
                    regionButton,
                  ],
                ),
              ),
              height32,
              buildColumnSelectGameType(),
            ],
          );
        }
        );
      }),
    );

  }

}