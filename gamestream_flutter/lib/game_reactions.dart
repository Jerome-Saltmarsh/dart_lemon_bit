
import 'package:gamestream_flutter/library.dart';

/// BLOC
class GameReactions {

  static void initialize(){
    GamePlayer.buffDoubleDamage.onChanged((int duration) {
      ClientState.buff_active_double_damage.value = duration > 0;
    });

    GamePlayer.buffInvincible.onChanged((int duration) {
      ClientState.buff_active_invincible.value = duration > 0;
    });

    GamePlayer.buffNoRecoil.onChanged((int duration) {
      ClientState.buff_active_no_recoil.value = duration > 0;
    });

    GamePlayer.buffInfiniteAmmo.onChanged((int duration) {
      ClientState.buff_active_infinite_ammo.value = duration > 0;
    });

    GamePlayer.buffFast.onChanged((int duration) {
      ClientState.buff_active_fast.value = duration > 0;
    });
  }
}