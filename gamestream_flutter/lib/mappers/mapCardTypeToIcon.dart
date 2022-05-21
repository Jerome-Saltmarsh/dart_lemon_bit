
import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/icons.dart';

Widget mapCardTypeToIcon(CardType type){
  return _map[type] ?? icons.unknown;
}

final _map = <CardType, Widget> {
  CardType.Passive_Bow_Run_Speed: icons.boots,
};