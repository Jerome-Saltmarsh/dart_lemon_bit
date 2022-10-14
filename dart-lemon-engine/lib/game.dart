
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'enums.dart';

class Game extends StatefulWidget {
  // Game({
  //     Color backgroundColor = Colors.black,
  //     bool drawCanvasAfterUpdate = true,
  //     int framesPerSecond = 60,
  //     ThemeData? themeData,
  // }){
  //   engine.setFramesPerSecond(framesPerSecond);
  //   engine.backgroundColor.value = backgroundColor;
  //   engine.drawCanvasAfterUpdate = drawCanvasAfterUpdate;
  //   engine.themeData.value = themeData;
  // }

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  void initState() {
    super.initState();
    engine.internalInit();
  }

  @override
  Widget build(BuildContext context) {
    engine.buildContext = context;

    return WatchBuilder(Engine.themeData, (ThemeData? themeData){
      return MaterialApp(
        title: Engine.title,
        // routes: Engine.routes ?? {},
        theme: themeData,
        home: Scaffold(
          body: WatchBuilder(engine.initialized, (bool value) {
            if (!value) {
              return Engine.onBuildLoadingScreen != null ? Engine.onBuildLoadingScreen!(context) : Text("Loading");
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                engine.internalSetScreenSize(constraints.maxWidth, constraints.maxHeight);
                engine.screen.width = constraints.maxWidth;
                engine.screen.height = constraints.maxHeight;
                return Stack(
                  children: [
                    buildCanvas(context),
                    WatchBuilder(Engine.watchBuildUI, (WidgetBuilder? buildUI)
                      => buildUI != null ? buildUI(context) : const SizedBox()
                    )
                  ],
                );
              },
            );
          }),
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }

  Widget buildCanvas(BuildContext context) {
    final child = Listener(
      onPointerSignal: engine.internalOnPointerSignal,
      onPointerDown: engine.internalOnPointerDown,
      onPointerUp: engine.internalOnPointerUp,
      onPointerHover:engine.internalOnPointerHover,
      onPointerMove: engine.internalOnPointerMove,
      child: GestureDetector(
          onTapDown: Engine.onTapDown,
          onLongPress: Engine.onLongPress,
          onPanStart: engine.internalOnPanStart,
          onPanUpdate: Engine.onPanUpdate,
          onPanEnd: engine.internalOnPanEnd,
          child: WatchBuilder(Engine.watchBackgroundColor, (Color backgroundColor){
            return Container(
                color: backgroundColor,
                width: engine.screen.width,
                height: engine.screen.height,
                child: CustomPaint(
                    painter: _GamePainter(repaint: engine.notifierPaintFrame),
                    foregroundPainter: _GameForegroundPainter(
                        repaint: engine.notifierPaintForeground
                    ),
                )
            );
          })),
    );

    return WatchBuilder(engine.cursorType, (CursorType cursorType) =>
      MouseRegion(
        cursor: mapCursorTypeToSystemMouseCursor(cursorType),
        child: child,
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    Engine.onDispose?.call();
  }
}

class _GamePainter extends CustomPainter {

  const _GamePainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size size) {
    engine.internalPaint(_canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _GameForegroundPainter extends CustomPainter {

  const _GameForegroundPainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size _size) {
    Engine.onDrawForeground?.call(Engine.canvas, _size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

