
import 'package:bleed_common/card_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/icons.dart';

Widget buildCardTypeIcon(CardType type){
  return _cardTypeIcons[type] ?? icons.unknown;
}

final _cardTypeIcons = <CardType, Widget> {
  CardType.Passive_General_Max_HP_10: icons.armour.padded,
  CardType.Passive_General_Critical_Hit: icons.arrowSkull,
  CardType.Passive_Bow_Run_Speed: icons.boots,
  CardType.Ability_Bow_Long_Shot: icons.crossbow,
  CardType.Ability_Bow_Volley: icons.arrows,
};