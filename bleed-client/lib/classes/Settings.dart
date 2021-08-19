class Settings {
  bool audioMuted = false;
  double cameraFollow = 0.05;
  double zoomSpeed = 0.0005;
  double maxZoom = 0.1;

  void toggleAudioMuted(){
    audioMuted = !audioMuted;
  }
}

