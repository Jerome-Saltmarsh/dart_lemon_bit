import 'package:file_picker/file_picker.dart';

Future<List<PlatformFile>?> loadFilesFromDisk() async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    dialogTitle: 'Load Image',
    type: FileType.custom,
    allowedExtensions: ['png'],
    allowMultiple: true,
  );
  return result?.files;
}