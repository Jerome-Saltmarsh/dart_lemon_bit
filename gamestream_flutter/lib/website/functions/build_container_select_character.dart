import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/height.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/user/user.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildContainerSelectCharacter(User user) =>
  GSContainer(
      child: Column(
        children: [
          onPressed(
            action: user.refreshCharacterNames,
            child: buildText('CHARACTERS'),
          ),
          onPressed(
            action: user.createNewCharacter,
            child: buildText('CREATE NEW', color: Colors.orange),
          ),
          height12,
          buildWatch(
              user.characters,
              (characters) => Column(
                  children: characters
                      .map((character) => onPressed(
                            action: () =>
                                user.loadCharacterById(character['uuid']),
                            child: buildText(character['name']),
                          ))
                      .toList(growable: false))),
        ],
      ),
);
