
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

import '../../../flutterkit.dart';
import '../widgets/nothing.dart';

Widget buildControlNpcTalk(String? value) =>
  (value == null || value.isEmpty)
    ? nothing
    : container(
          child: text(value = value.replaceAll(".", " \n\n"), color: white80),
          color: brownLight,
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(16),
      );

Widget buildControlNpcTopics(List<String> topics) =>
  Column(
    children: topics.map((String value) {
      return container(
          margin: const EdgeInsets.only(top: 6),
          child: text(value, color: white80),
          color: brownLight,
          width: 300,
          hoverColor: brownDark,
          action: () {
            sendClientRequestNpcSelectTopic(topics.indexOf(value));
          }
      );
    }).toList(),
  );