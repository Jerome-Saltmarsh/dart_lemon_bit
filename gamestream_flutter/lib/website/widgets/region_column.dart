
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

class SelectRegionColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WatchBuilder(GameWebsite.region, (activeRegion) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: (Engine.isLocalHost ? ConnectionRegion.values : GameWebsite.Live_Regions)
              .map((ConnectionRegion region) =>
              onPressed(
                action: () {
                  GameWebsite.actionSelectRegion(region);
                  if (Engine.deviceIsPhone) {
                    // GameNetwork.connectToGameAeon();
                  } else {
                    // GameNetwork.connectToGameCombat();
                  }
                },
                child: onMouseOver(builder: (bool mouseOver) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: activeRegion == region ? Colors.greenAccent : mouseOver ? Colors.green : Colors.white10,
                    child: text(
                        '${Engine.enumString(region)}',
                        size: 24,
                        color: mouseOver ? Colors.white : Colors.white60
                    ),
                  );
                }),
              ))
              .toList(),
        ),
      );
    });
  }
}