import 'package:file_picker/file_picker.dart';

Future<List<PlatformFile>?> loadFilesFromDisk({
  List<String>? allowedExtensions,
  String? dialogTitle,
}) async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    dialogTitle: dialogTitle,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    allowMultiple: true,
  );
  return result?.files;
}