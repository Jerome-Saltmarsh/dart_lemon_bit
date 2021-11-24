import 'package:lemon_watch/watch.dart';

final _Settings settings = _Settings();

void toggleAudioMuted(){
  settings.audioMuted.value = !settings.audioMuted.value;
  // rebuildUI();
  // sharedPreferences.setBool('audioMuted' , settings.audioMuted);
}

class _Settings {
  Watch<bool> audioMuted = Watch(false);
  double cameraFollowSpeed = 0.04;
  double zoomFollowSpeed = 0.1;
  double zoomSpeed = 0.0005;
  double maxZoom = 0.1;
  bool developMode = true;
  bool compilePaths = false;
  int floatingTextDuration = 100;
  int maxBulletHoles = 50;
  int maxParticlesMinusOne = 299;
  double interactRadius = 60;
  double manRenderSize = 40.0;
}
