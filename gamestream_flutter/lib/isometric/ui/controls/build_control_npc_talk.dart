
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:golden_ratio/constants.dart';

import '../../../flutterkit.dart';
import '../widgets/nothing.dart';

const _width = 400;

Widget buildControlNpcTalk(String? value) =>
  (value == null || value.isEmpty)
    ? nothing
    : container(
          child: SingleChildScrollView(child: text(value = value.replaceAll(". ", "\n\n"), color: white80, height: 2.2)),
          color: brownLight,
          width: _width,
          height: _width * goldenRatio_0618,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(16),
      );

Widget buildControlNpcTopics(List<String> topics) =>
  Column(
    children: topics.map((String value) {
      return container(
          margin: const EdgeInsets.only(top: 6),
          child: text(value, color: white80, align: TextAlign.center),
          color: value.endsWith("(QUEST)") ? green : brownLight,
          hoverColor: brownDark,
          width: _width,
          alignment: Alignment.center,
          action: () {
            sendClientRequestNpcSelectTopic(topics.indexOf(value));
          }
      );
    }).toList(),
  );