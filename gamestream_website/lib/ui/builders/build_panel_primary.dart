import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_health.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';

import 'build_panel.dart';
import 'build_panel_resources.dart';
import 'build_panel_tech.dart';
import 'build_time.dart';

Widget buildPanelPrimary() {
  return Positioned(
      top: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPanelMenu(),
          height6,
          buildPanel(child: buildTime()),
          height6,
          buildControlPlayerHealth(),
          height6,
          buildPanelResources(),
          height6,
          buildPanelTech(),
        ],
      ));
}
