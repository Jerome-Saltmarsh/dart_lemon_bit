# Build and upload image to gcloud
gcloud builds submit --tag gcr.io/gogameserver/gamestream-ws

# Build UI
flutter build web --profile --dart-define=Dart2jsOptimization=O0

flutter build web --web-renderer canvaskit --release

# Compile
dart compile exe bin/server.dart -o /tmp/bleed-server
dart compile exe bin/server.dart -o /tmp/bleed-server.exe

# Install
rmdir /s /q "C:\Users\Jerome\github\amulet\packages\amulet_engine" &

mklink /J "C:\Users\Jerome\github\bleed\gamestream_server\lib\packages\gamestream_http_client" "C:\Users\Jerome\github\bleed\gamestream_http_client\lib"

mklink /J "C:\Users\Jerome\github\bleed\gamestream_server\lib\packages\gamestream_firestore" "C:\Users\Jerome\github\bleed\gamestream_firestore\lib"

mklink /J "C:\Users\Jerome\github\bleed\isometric_engine\lib\packages\lemon_math" "C:\Users\Jerome\github\bleed\dart-lemon-math\lib"

mklink /J "C:\Users\Jerome\github\bleed\amulet_ws\lib\packages\isometric_engine" "C:\Users\Jerome\github\bleed\isometric_engine\lib"

mklink /J "C:\Users\Jerome\github\bleed\amulet_ws\lib\packages\amulet_engine" "C:\Users\Jerome\github\bleed\amulet_engine\lib"


# IDE PROGRAM ARGUMENTS (IMPORTANT!)
By default the application will assume that it is being deployed on google cloud.
To run this locally add the following arguments when running main.

--database http --admin

By assigning the database to http this tells the app to connect to the database via a http connection
over the internet instead of directly as done by apps deploy on google cloud.

[SCENE]
Player Spawns in magestically

The cloaked stranger approaches and speaks to the player

'one greets another'
'one guides another'

'dost other hast strength'

'dost other hast wisdom'

'dost other hast courage'