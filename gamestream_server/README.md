# Build and upload image to gcloud
gcloud builds submit --tag gcr.io/gogameserver/gamestream-ws

# Build UI
flutter build web --profile --dart-define=Dart2jsOptimization=O0

flutter build web --web-renderer canvaskit --release

# Compile
dart compile exe bin/server.dart -o /tmp/bleed-server
dart compile exe bin/server.dart -o /tmp/bleed-server.exe

# Symbolic Hard Link
mklink /J common C:\Users\Jerome\github\bleed\bleed-common\lib
mklink /J math C:\Users\Jerome\github\bleed\dart-lemon-math\lib

mklink /D "C:\Users\Jerome\github\bleed\gamestream_server\lib\packages\user_service_client" "C:\Users\Jerome\github\bleed\user_service_client\lib"
