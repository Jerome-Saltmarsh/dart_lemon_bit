
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common/src/isometric/power_mode.dart';
import 'package:gamestream_flutter/common/src/mmo/mmo_item.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';

extension MMORender on MmoGame {

  void render(Canvas canvas, Size size) {
    renderPlayerHoverItemRange();
    renderPlayerRunLine();
    renderActivatedPower();

    if (activatedPowerIndex.value != -1){
      final activePower = weapons[activatedPowerIndex.value];
      final mode = activePower?.attackType?.mode;

      if (mode == PowerMode.Positional) {
          renderer.color = Colors.blue;
          renderer.renderCircleAtPosition(
            position: activePowerPosition,
            radius: 10,
          );
      }
    }
  }

  void renderPlayerRunLine({Color color = Colors.purple}) {
    if (player.arrivedAtDestination.value)
      return;

    renderer.color = color;
    renderer.renderLine(
      player.x,
      player.y,
      player.z,
      player.runX,
      player.runY,
      player.runZ,
    );
  }

  void renderPlayerHoverItemRange() {
    final item = itemHover.value;
    if (item == null) return;
    renderPlayerItemRange(item);
  }

  void renderPlayerItemRange(MMOItem item) {
    if (item.range <= 0) return;
    renderer.color = Colors.white;
    renderer.renderCircle(
        player.x,
        player.y,
        player.z,
        item.range,
        sections: 20
    );
  }

  void renderActivatedPower({Color rangeColor = Colors.white}) {
    if (activatedPowerIndex.value == -1)
      return;

    final activatedPower = weapons[activatedPowerIndex.value];

    if (activatedPower == null)
      return;

    renderer.color = rangeColor;
    renderer.renderCircleAroundPlayer(radius: activatedPower.range);
  }
}

