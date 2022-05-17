# Build and upload image to gcloud
gcloud builds submit --tag gcr.io/gogameserver/gamestream-ws

flutter build web --profile --dart-define=Dart2jsOptimization=O0

dart compile exe bin/server.dart -o /tmp/bleed-server
