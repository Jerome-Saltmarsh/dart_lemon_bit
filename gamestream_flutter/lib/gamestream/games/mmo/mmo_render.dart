
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common/src/isometric/power_mode.dart';
import 'package:gamestream_flutter/common/src/mmo/mmo_item.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';

extension MMORender on MmoGame {

  void render(Canvas canvas, Size size) {
    renderPlayerHoverItemRange();
    renderPlayerRunLine();
    renderActivatedPower();

  }

  void renderPlayerRunLine({Color color = Colors.purple}) {
    if (player.arrivedAtDestination.value)
      return;

    isometric.color = color;
    isometric.render.renderLine(
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
    isometric.color = Colors.white;
    isometric.render.renderCircleOutline(
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

    final activatedPower = weapons[activatedPowerIndex.value].item.value;

    if (activatedPower == null)
      return;

    final mode = activatedPower.attackType?.mode;
    if (mode == PowerMode.Positional) {
      isometric.color = Colors.white;
      isometric.render.renderCircleOutlineAtPosition(
        position: activePowerPosition,
        radius: 15,
      );
    }

    isometric.color = rangeColor;
    isometric.renderCircleAroundPlayer(radius: activatedPower.range);
  }
}

