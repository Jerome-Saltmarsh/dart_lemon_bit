const double playerAutoAimDistance = 40;
const double cameraSpeed = 2;
const double cameraFollow = 0.02;
const int fps = 30;
const int milliSecondsPerSecond = 1000;
const int smoothingFrames = 4;
const double characterRadius = 7;
const int settingsSmoothingMinFPS = 20;
const String localhost = "ws://localhost:8080";
const gpcUrl = 'https://bleed-60-osbmaezptq-ey.a.run.app';
final String gpc = gpcUrl.replaceAll("https", "wss") + "/:8080";
String host = localhost;