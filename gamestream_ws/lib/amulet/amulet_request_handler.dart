import 'package:gamestream_ws/gamestream/classes/connection.dart';
import 'package:gamestream_ws/packages.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_scene.dart';

import 'classes/amulet_player.dart';

extension AmuletRequestHandler on Connection {

  void handleNetworkRequestAmulet(List<String> arguments){

    final player = this.player;
    if (player is! AmuletPlayer) {
      errorInvalidPlayerType();
      return;
    }

    final amuletGame = player.amuletGame;

    final inventoryOpen = arguments.getArgBool('--inventory');
    if (inventoryOpen != null) {
      player.inventoryOpen = inventoryOpen;
      return;
    }

    final requestIndex = parseArg1(arguments);
    if (requestIndex == null) return;
    if (!isValidIndex(requestIndex, NetworkRequestAmulet.values)){
      errorInvalidClientRequest();
      return;
    }
    final mmoRequest = NetworkRequestAmulet.values[requestIndex];

    switch (mmoRequest){
      case NetworkRequestAmulet.Spawn_Random_Enemy:
        amuletGame.spawnRandomEnemy();
        break;
      case NetworkRequestAmulet.Acquire_Amulet_Item:
        final amuletItemIndex = arguments.getArgInt('--index');
        final amuletItem = AmuletItem.values.tryGet(amuletItemIndex);
        if (amuletItem == null){
          sendServerError('invalid amulet item index');
          return;
        }
        player.acquireAmuletItem(amuletItem);
        break;
      case NetworkRequestAmulet.End_Interaction:
        player.endInteraction();
        break;
      case NetworkRequestAmulet.Select_Item:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectItem(index);
        break;
      case NetworkRequestAmulet.Select_Treasure:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectTreasure(index);
        break;
      case NetworkRequestAmulet.Select_Weapon:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectWeaponAtIndex(index);
        break;
      case NetworkRequestAmulet.Select_Talk_Option:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectNpcTalkOption(index);
        break;
      case NetworkRequestAmulet.Toggle_Skills_Dialog:
        player.toggleSkillsDialog();
        break;
      case NetworkRequestAmulet.Toggle_Inventory_Open:
        player.toggleInventoryOpen();
        break;
      case NetworkRequestAmulet.Upgrade_Talent:
        final index = parseArg2(arguments);
        if (index == null) return;
        if (!isValidIndex(index, AmuletTalentType.values)){
          errorInvalidClientRequest();
          return;
        }
        final mmoTalentType = AmuletTalentType.values[index];
        player.upgradeTalent(mmoTalentType);
        break;
      case NetworkRequestAmulet.Upgrade_Element:
        final index = parseArg2(arguments);
        if (index == null) return;
        if (!isValidIndex(index, AmuletElement.values)){
          errorInvalidClientRequest();
          return;
        }
        final amuletElement = AmuletElement.values[index];
        player.upgradeAmuletElement(amuletElement);
        break;
      case NetworkRequestAmulet.Set_Inventory_Open:
        throw Exception('not implemented');
      case NetworkRequestAmulet.Player_Change_Game:
        final index = getArg(arguments, 2);
        final amuletScene = AmuletScene.values[index];
        final amulet = amuletGame.amulet;
        final targetGame = amulet.getAmuletSceneGame(amuletScene);
        amulet.playerChangeGame(
            player: player,
            target: targetGame,
        );
        break;
    }

  }
}


extension ListExtensions<T> on List<T> {

  T? tryGet(int? index) =>
      index == null ||
      index < 0 ||
      index >= length
        ? null
        : this[index];
}