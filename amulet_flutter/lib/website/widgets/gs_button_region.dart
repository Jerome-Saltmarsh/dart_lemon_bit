

import 'package:flutter/material.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/packages/utils/format_enum_name.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class GSButtonRegion extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    IsometricBuilder(builder: (context, components) =>
        buildWatch(components.options.region, (region) =>
            onPressed(
            action: components.website.showWebsitePageRegion,
            child: Container(
              color: Colors.white12,
              padding: components.style.containerPadding,
              child: Row(
                children: [
                  buildText('Region'),
                  width8,
                  buildBorder(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: buildText(formatEnumName(region?.name ?? 'select')),
                    ),
                  ),
                ],
              ),
            ),
        )));
}