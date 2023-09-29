import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_key_event_handler.dart';
import 'package:gamestream_flutter/user/user.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildWebsitePageNewCharacter({
  required User user,
  double width = 300,
}) {
  final controller = TextEditingController();
  return GSContainer(
    width: width,
    height: width * goldenRatio_1381,
    child: Column(
      children: [
        GSKeyEventHandler(
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white54,
            child: TextField(
              controller: controller,
              autofocus: true,
              cursorColor: Colors.white,
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Name',
                focusColor: Colors.white,
                labelStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none, // Remove the border line
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            onPressed(
              action: () => user.website.websitePage.value = WebsitePage.Select_Character,
              child: buildText('BACK'),
            ),
            onPressed(
              action: () => user.createNewCharacter(
                characterName: controller.text,
              ),
              child: buildText('START'),
            ),
          ],
        ),
      ],
    ),
  );
}

