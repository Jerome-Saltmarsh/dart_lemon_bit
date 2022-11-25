# Build and upload image to gcloud
gcloud builds submit --tag gcr.io/gogameserver/gamestream-ws

# Build UI
flutter build web --profile --dart-define=Dart2jsOptimization=O0

# Compile
dart compile exe bin/server.dart -o /tmp/bleed-server
dart compile exe bin/server.dart -o /tmp/bleed-server.exe

# Symbolic Hard Link
mklink /J common C:\Users\Jerome\github\bleed\bleed-common\lib
