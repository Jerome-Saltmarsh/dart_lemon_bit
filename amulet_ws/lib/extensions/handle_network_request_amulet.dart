import '../classes/connection.dart';
import '../packages/src.dart';

extension AmuletRequestHandler on Connection {

  void handleNetworkRequestAmulet(List<String> arguments){

    final player = this.player;
    final amuletPlayer = player;
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
        final amuletItemIndex = arguments.tryGetArgInt('--index');
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
      case NetworkRequestAmulet.Toggle_Inventory_Open:
        player.toggleInventoryOpen();
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
      case NetworkRequestAmulet.Gain_Level:
        if (!root.admin) {
          throw Exception('admin mode not enabled');
        }
        amuletPlayer.gainLevel();
        break;
      case NetworkRequestAmulet.Reset:
        if (!root.admin) {
          throw Exception('admin mode not enabled');
        }
        root.amulet.resetPlayer(amuletPlayer);
        break;
      case NetworkRequestAmulet.Player_Change_Game:
        final index = getArg(arguments, 2);
        final amuletScene = AmuletScene.values[index];
        final amulet = amuletGame.amulet;
        final targetGame = amulet.getAmuletSceneGame(amuletScene);

        amulet.playerChangeGame(
            player: player,
            target: targetGame,
        );

        final portal = targetGame.scene.keys['portal'];

        if (portal != null){
            player.scene.movePositionToIndex(player, portal);
        } else {
          if (player.scene.outOfBoundsPosition(player)){
            player.x = player.scene.rowLength * 0.5;
            player.y = player.scene.columnLength * 0.5;
            player.z = player.scene.heightLength * 0.5;
          }
        }

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