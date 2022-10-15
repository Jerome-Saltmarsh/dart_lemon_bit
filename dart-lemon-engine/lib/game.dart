
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {

  @override
  Widget build(BuildContext context) {
    Engine.buildContext = context;

    return WatchBuilder(Engine.themeData, (ThemeData? themeData){
      return MaterialApp(
        title: Engine.title,
        // routes: Engine.routes ?? {},
        theme: themeData,
        home: Scaffold(
          body: WatchBuilder(Engine.watchInitialized, (bool value) {
            if (!value) {
              return Engine.onBuildLoadingScreen != null ? Engine.onBuildLoadingScreen!(context) : Text("Loading");
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                Engine.internalSetScreenSize(constraints.maxWidth, constraints.maxHeight);
                Engine.screen.width = constraints.maxWidth;
                Engine.screen.height = constraints.maxHeight;
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
      onPointerSignal: Engine.internalOnPointerSignal,
      onPointerDown: Engine.internalOnPointerDown,
      onPointerUp: Engine.internalOnPointerUp,
      onPointerHover: Engine.internalOnPointerHover,
      onPointerMove: Engine.internalOnPointerMove,
      child: GestureDetector(
          onTapDown: Engine.onTapDown,
          onLongPress: Engine.onLongPress,
          onPanStart: Engine.internalOnPanStart,
          onPanUpdate: Engine.onPanUpdate,
          onPanEnd: Engine.internalOnPanEnd,
          child: WatchBuilder(Engine.watchBackgroundColor, (Color backgroundColor){
            return Container(
                color: backgroundColor,
                width: Engine.screen.width,
                height: Engine.screen.height,
                child: CustomPaint(
                    painter: _GamePainter(repaint: Engine.notifierPaintFrame),
                    foregroundPainter: _GameForegroundPainter(
                        repaint: Engine.notifierPaintForeground
                    ),
                )
            );
          })),
    );

    return WatchBuilder(Engine.cursorType, (CursorType cursorType) =>
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

  SystemMouseCursor mapCursorTypeToSystemMouseCursor(CursorType value){
    switch (value) {
      case CursorType.Forbidden:
        return SystemMouseCursors.forbidden;
      case CursorType.Precise:
        return SystemMouseCursors.precise;
      case CursorType.None:
        return SystemMouseCursors.none;
      case CursorType.Click:
        return SystemMouseCursors.click;
      default:
        return SystemMouseCursors.basic;
    }
  }

}

class _GamePainter extends CustomPainter {

  const _GamePainter({required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas _canvas, Size size) {
    Engine.internalPaint(_canvas, size);
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

