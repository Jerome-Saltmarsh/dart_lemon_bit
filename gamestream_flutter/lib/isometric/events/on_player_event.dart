import 'package:bleed_common/PlayerEvent.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

void onPlayerEvent(int event) {
  switch (event) {
    case PlayerEvent.Level_Up:
      modules.game.actions.emitPixelExplosion(player.x, player.y, amount: 20);
      audio.buff(player.x, player.y);
      spawnFloatingText(player.x, player.y, 'LEVEL UP');
      break;
    case PlayerEvent.Skill_Upgraded:
      audio.unlock(player.x, player.y);
      break;
    case PlayerEvent.Dash_Activated:
      audio.buff11(player.x, player.y);
      break;
    case PlayerEvent.Item_Purchased:
      audioSingleItemUnlock();
      break;
    case PlayerEvent.Ammo_Acquired:
      audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Item_Equipped:
      audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Medkit:
      audio.medkit(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Item_Sold:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Drink_Potion:
      audio.bottle(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Wood:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Rock:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Experience:
      audio.collectStar3(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Gold:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Hello_Male_01:
      audioSingleMaleHello.play();
      break;
  }
}
