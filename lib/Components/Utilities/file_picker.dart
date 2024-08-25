import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CustomFilePicker {
  Future<void> savePickedFiles(PlatformFile file) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Files/Sent';
    await Directory(dirPath).create(recursive: true);

    final String newPath = path.join(dirPath, path.basename(file.path ?? ''));
    await File(file.path ?? '').copy(newPath);
  }

  String determineFileLogo(String? fileExtension) {
    switch(fileExtension){
      case 'pdf':
       return 'assets/icons/file_extensions/pdf_icon.png';
      case 'doc':
       return 'assets/icons/file_extensions/doc_icon.png';
      case 'docx':
       return 'assets/icons/file_extensions/docx_icon.png';
      case 'mp3':
       return 'assets/icons/file_extensions/mp3_icon.png';
      case 'ppt':
       return 'assets/icons/file_extensions/ppt_icon.png';
      case 'txt':
       return 'assets/icons/file_extensions/txt_icon.png';
      case 'xls':
       return 'assets/icons/file_extensions/xls_icon.png';
      case 'png':
        return 'assets/icons/file_extensions/png_icon.png';
      case 'jpg':
        return 'assets/icons/file_extensions/jpg_icon.png';
      case 'jpeg':
        return 'assets/icons/file_extensions/jpg_icon.png';
      case 'mp4':
        return 'assets/icons/file_extensions/mp4_icon.png';
      case 'webp':
        return 'assets/icons/file_extensions/webp_icon.png';
      case 'gif':
        return 'assets/icons/file_extensions/gif_icon.png';
      default:
       return 'assets/icons/file_extensions/document_icon.png';
    }
  }

  String convertFileSize(String bytesStr) {
    int bytes = int.parse(bytesStr);
    double kilobytes = bytes / 1024;
    double megabytes = kilobytes / 1024;

    if (megabytes >= 1) {
      return "${megabytes.toStringAsFixed(2)} MB";
    } else {
      return "${kilobytes.toStringAsFixed(2)} KB";
    }
  }

  Future<List<Map<String, dynamic>>> pickFiles() async {
    List<Map<String, dynamic>> pickedFiles = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'mp3', 'ppt', 'txt', 'xls', 'gif', 'mp4', 'png', 'jpg'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;
      for (var file in files) {
        await savePickedFiles(file);
        String fileSize  = convertFileSize(file.size.toString());
        String fileLogo = determineFileLogo(file.extension);
        pickedFiles.add({
          'name': file.name,
          'size': fileSize,
          'extension': file.extension,
          'fileLogo': fileLogo
        });
      }
      return pickedFiles;
    }
    return [];
  }
}
