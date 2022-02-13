import 'package:audioplayers/audioplayers.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/randomItem.dart';

import 'Cache.dart';

// interface
final audio = _Audio();

class _Audio {

  final Cache<bool> enabled = Cache(key: 'audio-enabled', value: true);

  void toggle(){
    print("audio.toggle()");
    enabled.value = !enabled.value;
    print("audio.enabled: ${enabled.value}");
  }

  void sniperShot(double x, double y) {
    play('sniper-shot-04.mp3', x, y);
  }

  void assaultRifleShot(double x, double y) {
    play('assault-rifle-shot.mp3', x, y);
  }

  void explosion(double x, double y) {
    _playRandom(_grenadeExplosions, x, y);
  }

  void sniperEquipped(double x, double y) {
    gunPickup(x, y);
  }

  void gunPickup(double x, double y) {
    play("gun-pickup-01.mp3", x, y);
  }

  void reload(double x, double y) {
    play('reload-06.mp3', x, y);
  }

  void itemEquipped(double x, double y) {
    play('item-acquired.mp3', x, y);
  }

  void itemPurchased(double x, double y) {
    play('item-purchase-3.mp3', x, y);
  }

  void play(String name, double x, double y) {
    if (!enabled.value) return;
    try {
      _getAudioPlayer().play('assets/audio/$name',
          isLocal: true,
          volume: _calculateVolume(x, y))
          .catchError((error) {});
    }catch(e){
      print("failed to play audio $name");
    }
  }
}

void initAudioPlayers() {
  for (int i = 0; i < _totalAudioPlayers; i++) {
    _audioPlayers.add(AudioPlayer());
  }
}

void playAudioCockShotgun(double x, double y) {
  audio.play('cock-shotgun-03.mp3', x, y);
}

void playAudioPlayerDeath(double x, double y) {
  _playRandom(_maleScreams, x, y);
}

void playAudioReloadHandgun(double x, double y) {
  audio.play('mag-in-02.mp3', x, y);
}

void playAudioClipEmpty(double x, double y) {
  audio.play('dry-shot-02.mp3', x, y);
}

void playAudioZombieBite(double x, double y) {
  _playRandom(_zombieBite, x, y);
}

void playAudioZombieTargetAcquired(double x, double y) {
  _playRandom(_zombieTalking, x, y);
}

void playAudioZombieDeath(double x, double y) {
  _playRandom(_zombieDeath, x, y);
}

void playAudioZombieHit(double x, double y) {
  _playRandom(_zombieHits, x, y);
}

void playAudioPlayerHurt(double x, double y) {
  _playRandom(_humanHurt, x, y);
}

void playAudioShotgunShot(double x, double y) {
  audio.play('shotgun-shot.mp3', x, y);
}

void playAudioHandgunShot(double x, double y) {
  _playRandom(_pistolShot, x, y);
}

void playAudioUseMedkit(double x, double y) {
  audio.play('medkit.mp3', x, y);
}

void playAudioBuff1(double x, double y) {
  audio.play('buff-1.mp3', x, y);
}

void playAudioMagicalSwoosh18(double x, double y) {
  audio.play('magical-swoosh-18.mp3', x, y);
}

final _PlayAudio playAudio = _PlayAudio();

class _PlayAudio {
  void unlock(double x, double y) {
    audio.play('unlock.mp3', x, y);
  }

  void buff11(double x, double y) {
    audio.play('buff-11.mp3', x, y);
  }

  void arrowFlyingPast6(double x, double y) {
    audio.play('arrow-flying-past-6.mp3', x, y);
  }

  void sciFiBlaster1(double x, double y) {
    audio.play('sci-fi-blaster-1.mp3', x, y);
  }
}

void playAudioCollectStar(double x, double y) {
  audio.play('collect-star-4.mp3', x, y);
}

void playAudioHeal(double x, double y) {
  audio.play('revive-heal-1.mp3', x, y);
}

void playAudioKnifeStrike(double x, double y) {
  _playRandom(_knifeStrikes, x, y);
}

void playAudioThrowGrenade(double x, double y) {
  audio.play('throw.mp3', x, y);
}

void playAudioCrateBreaking(double x, double y) {
  audio.play('crate-breaking.mp3', x, y);
}

// abstraction
int _index = 0;

final List<AudioPlayer> _audioPlayers = [];
const _audioDistanceFade = 0.0065;
const _totalAudioPlayers = 200;

const _zombieHits = [
  'zombie-hit-01.mp3',
  'zombie-hit-02.mp3',
  'zombie-hit-03.mp3',
  'zombie-hit-05.mp3'
];

const _humanHurt = [
  'male-hurt-01.mp3',
  'male-hurt-02.wav',
];

const _zombieDeath = [
  'zombie-death-02.mp3',
  'zombie-death-09.mp3',
  'zombie-death-15.mp3',
];

const _zombieTalking = [
  'zombie-talking-03.mp3',
  'zombie-talking-04.mp3',
  'zombie-talking-05.mp3',
];

const _zombieBite = [
  'zombie-bite-04.mp3',
  'zombie-bite-05.mp3',
  'bloody-punches-1.mp3',
  'bloody-punches-2.mp3',
  'bloody-punches-3.mp3',
];

const _pistolShot = [
  "pistol-shot-19.mp3",
  "pistol-shot-20.mp3",
  "pistol-shot-21.mp3",
  "pistol-shot-22.mp3",
];

const _maleScreams = [
  'male-screams-01.mp3',
  'male-screams-05.mp3',
  'male-screams-06.mp3',
];

const _grenadeExplosions = [
  'explosion-grenade-01.mp3',
  'explosion-grenade-04.mp3'
];

const _knifeStrikes = [
  'dagger-woosh-1.mp3',
  'dagger-woosh-2.mp3',
];

void _playRandom(List<String> values, double x, double y) {
  audio.play(randomItem(values), x, y);
}

AudioPlayer _getAudioPlayer() {
  _index = (_index + 1) % _audioPlayers.length;
  return _audioPlayers[_index];
}

double _calculateVolume(double x, double y) {
  final distance = distanceBetween(x, y, screenCenterWorldX, screenCenterWorldY);
  final v = 1.0 / ((distance * _audioDistanceFade) + 1);
  return v * v;
}
