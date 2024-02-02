
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lemon_pubspec/pubspec/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class LemonPubspecApp extends StatelessWidget {


  const LemonPubspecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUBSPEC SYNC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'PUBSPEC SYNC'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final file = File('C:/Users/Jerom/github/amulet/amulet_flutter/pubspec.yaml');
  List<String> missing = [];

  void rebuildPage() => setState(() { });

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          onPressed(
              action: refreshMissing,
              child: const Text('REFRESH'),
          ),
          const SizedBox(width: 6.0),
          onPressed(
              action: () {
                addMissing(missing, file);
                refreshMissing();
              },
              child: const Text('ADD'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: missing.map((e) => buildText(e)).toList(growable: false),
          ),
        ),
      ),
    );

  void refreshMissing() =>
      setMissing(getMissing(file));

  void setMissing(List<String> values) =>
      setState(() {
        missing = values;
      });
}
