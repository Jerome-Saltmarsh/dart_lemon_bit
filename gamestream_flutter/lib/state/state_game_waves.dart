import 'package:lemon_watch/watch.dart';


final gameWaves = GameWaves();

class GameWaves {
  final timer = Watch(0.0, onChanged: (double value){
    gameWaves.canPurchase.value = value > 0;
  });
  final canPurchase = Watch(false);
  final round = Watch(0);

  final purchasePrimary = <Purchase>[];
  final purchaseSecondary = <Purchase>[];
  final purchaseTertiary = <Purchase>[];
  final refresh = Watch(0);
}

class Purchase {
   int type;
   int cost;
   Purchase(this.type, this.cost);
}