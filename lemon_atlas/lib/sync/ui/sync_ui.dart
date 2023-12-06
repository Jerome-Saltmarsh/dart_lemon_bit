
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lemon_atlas/lemon_cache/lemon_cache.dart';
import 'package:lemon_atlas/sync/classes/sync_job.dart';
import 'package:lemon_atlas/sync/functions/build_sync_jobs.dart';
import 'package:lemon_atlas/sync/functions/run_sync_job.dart';
import 'package:lemon_atlas/sync/functions/sync_all.dart';
import 'package:lemon_atlas/sync/ui/sync_jobs_column.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class SyncUI extends StatelessWidget {

  final syncJobs = Watch(<SyncJob>[]);
  final settingsEnabled = WatchBool(false);
  final directoryRender = Cache(key: 'directory_render', value: '');
  final directoryExport = Cache(key: 'directory_export', value: '');

  SyncUI({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'LEMON SPRITES',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('LEMON SPRITES'),
          actions: [
            onPressed(
              action: settingsEnabled.toggle,
              child: buildText("SETTINGS"),
            ),
            onPressed(
              action: refreshSyncJobs,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: buildText('REFRESH'),
              ),
            ),
            onPressed(
              action: synchronize,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: buildText('SYNCHRONIZE'),
              ),
            ),
          ],
        ),
        body:  Builder(
          builder: (context) {

            final syncJobsColumn = WatchBuilder(syncJobs, (syncJobs) => SyncJobsColumn(
              syncJobs: syncJobs,
              onClickedFlat: (syncJob){
                tryRunSyncJob(syncJob: syncJob, context: context, rows: 1);
                refreshSyncJobs();
              },
              onClicked: (syncJob){
                tryRunSyncJob(syncJob: syncJob, context: context, rows: 8);
                refreshSyncJobs();
              },
            ));

            return Center(
              child: WatchBuilder(settingsEnabled, (enabled) =>
                enabled ? buildSettings() : syncJobsColumn),
            );
          }
        ),
      ),
    );

  void synchronize() {
    syncAll(
        dirRenders: directoryRender.value,
        dirSprites: directoryExport.value,
      );
    refreshSyncJobs();
  }

  Widget buildSettings() {

    final controllerDirExport = TextEditingController(text: directoryExport.value);
    final controllerDirRender = TextEditingController(text: directoryRender.value);

    return Container(
    color: Colors.white12,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: buildText('SETTINGS')),
          WatchBuilder(directoryRender, (t) {
            return Row(
              children: [
                IconButton(
                    onPressed: () async {
                      final directoryPath = await FilePicker.platform.getDirectoryPath();
                      if (directoryPath == null) return;
                      directoryRender.value = directoryPath;
                      controllerDirRender.text = directoryPath;
                    },
                    icon: const Icon(
                      Icons.folder,
                      size: 48.0, // Adjust the size as needed
                      color: Colors.blue, // You can set the color as per your design
                    ),
                ),
                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: controllerDirRender,
                    decoration: InputDecoration(
                      label: buildText('renders', color: Colors.white70)
                    ),
                    onChanged: (value) {
                      directoryRender.value = value;
                    },
                  ),
                )
              ],
            );
          }),
          WatchBuilder(directoryExport, (t) {
            return Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final directoryPath = await FilePicker.platform.getDirectoryPath();
                    if (directoryPath == null) return;
                    directoryExport.value = directoryPath;
                    controllerDirExport.text = directoryPath;
                  },
                  icon: const Icon(
                    Icons.folder,
                    size: 48.0, // Adjust the size as needed
                    color: Colors.blue, // You can set the color as per your design
                  ),
                ),
                SizedBox(
                  width: 600,
                  child: TextField(
                    controller: controllerDirExport,
                    decoration: InputDecoration(
                        label: buildText('exports', color: Colors.white70)
                    ),
                    onChanged: (value) {
                      directoryExport.value = value;
                    },
                  ),
                )
              ],
            );
          }),
          const Expanded(child: SizedBox()),
          onPressed(
            action: settingsEnabled.setFalse,
            child: buildText('CLOSE'),
          ),
        ],
      ),
  );
  }

  void tryRunSyncJob({
    required SyncJob syncJob,
    required BuildContext context,
    required int rows,
  }) {
    try {
      runSyncJob(
          syncJob: syncJob,
          rows: rows,
       );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
      );
    }
  }

  void refreshSyncJobs() =>
      syncJobs.value = findSyncJobs(
          directory: Directory(directoryRender.value),
          dirRenders: directoryRender.value,
          dirSprites: directoryExport.value,
      );
}