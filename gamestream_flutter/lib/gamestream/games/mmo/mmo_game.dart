
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/library.dart';

class MmoGame extends IsometricGame {

  final itemListener = Watch(0);
  late int itemLength;
  late Uint8List itemTypes;
  late Uint8List itemSubTypes;

  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);

  MmoGame({required super.isometric});

  void setItem({required int index, required int type, required int subType}){
    itemTypes[index] = type;
    itemSubTypes[index] = subType;
    itemListener.value++;
  }

  void setItemLength(int length){
    itemLength = length;
    itemTypes = Uint8List(length);
    itemSubTypes = Uint8List(length);
    itemListener.value++;
  }

  @override
  Widget customBuildUI(BuildContext context) => buildMMOUI();

  void selectItem(int index) =>
      sendMMORequest(MMORequest.Select_Item, index);

  void selectTalkOption(int index) =>
      sendMMORequest(MMORequest.Select_Talk_Option, index);

  void endInteraction() =>
      sendMMORequest(MMORequest.End_Interaction);

  void sendMMORequest(MMORequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
        ClientRequest.MMO,
        '${request.index} $message'
      );

}