import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class Camera {
  Future<void> getLostData() async {
    final ImagePicker picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    final List<XFile>? files = response.files;
    if (files != null) {
      for (XFile file in files) {
        String mediaType = getType(file.path);
        if (mediaType == 'Pictures' || mediaType == 'Videos') {
          await storeMediaPermanently(file, mediaType);
        }
      }
    } else {
      InAppNotifications.show(
        description: 'Failed to retrieve lost data.',
      );
    }
  }

  String getType(String path) {
    if (path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png')) {
      return 'Pictures';
    } else if (path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi')) {
      return 'Videos';
    } else {
      InAppNotifications.show(
        description: 'You can only upload pictures and videos using this feature',
      );
      return '';
    }
  }

  Future<Map<String, dynamic>> storeMediaPermanently(XFile mediaFile, String typeOfMedia) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/$typeOfMedia/Sent';
    await Directory(dirPath).create(recursive: true);  // Create directory if it doesn't exist

    final String newPath = path.join(dirPath, path.basename(mediaFile.path));
    final savedImage = await File(mediaFile.path).copy(newPath);
    return {
      'file': savedImage,
      'name': path.basename(mediaFile.path),
    };
  }

  Future<Map<String, dynamic>> getMediaFromFolder(bool noVideo) async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickMedia();

    if (media != null) {
      String mediaType = getType(media.path);

      if (mediaType == 'Videos' && noVideo) {
        return {
          'mediaType': mediaType
        };
      }

      if (mediaType == 'Pictures' || mediaType == 'Videos') {
        Map<String, dynamic> mediaDetails = {};
        if(!noVideo){
          mediaDetails = await storeMediaPermanently(media, mediaType);
        }
        return {
          'file': !noVideo ? mediaDetails['file'] : '',
          'name': !noVideo ? mediaDetails['name'] : '',
          'mediaType': mediaType,
          'media': media
        };
      }
    }

    return {};
  }

  Future<List<Map<String, dynamic>>> getMultipleMediaFromFolder() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> medias = await picker.pickMultipleMedia();
    final List<Map<String, dynamic>> allMedia = [];

    for (XFile media in medias) {
      String mediaType = getType(media.path);
      if (mediaType == 'Pictures' || mediaType == 'Videos') {
        Map<String, dynamic> mediaDetails = await storeMediaPermanently(media, mediaType);
        allMedia.add({
          'file': mediaDetails['file'],
          'name': mediaDetails['name'],
          'mediaType': mediaType,
          'medias': mediaDetails['medias']
        });
      }
    }
    return allMedia;
  }

  // Future<Map<String, dynamic>> takeImageWithCamera(bool profileUpload) async {
  //   final ImagePicker picker = ImagePicker();
  //   Map<String, dynamic> photoDetails = {};
  //
  //   try {
  //     final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  //
  //     if (photo == null) {
  //       return {
  //         'name': 'No image selected.',
  //       };
  //     }
  //
  //     if(!profileUpload){
  //       photoDetails = await storeMediaPermanently(photo, 'Pictures');
  //     }
  //     return {
  //       'file': !profileUpload ? photoDetails['file'] : '',
  //       'name': !profileUpload ? photoDetails['name'] : '',
  //       'media': photo
  //     };
  //   } on PlatformException catch (e) {
  //     if (e.code == 'camera_access_denied') {
  //       return {
  //         'name': 'Camera access denied. Please enable it in the app settings.',
  //       };
  //     } else {
  //       return {
  //         'name': 'An error occurred: ${e.message}',
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'name': 'An unexpected error occurred: $e',
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> takeImageWithCamera(bool profileUpload) async {
    final ImagePicker picker = ImagePicker();
    Map<String, dynamic> photoDetails = {};

    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) {
      return {
        'name': 'No image selected.',
      };
    }

    if (!profileUpload) {
      photoDetails = await storeMediaPermanently(photo, 'Pictures');
    }

    return {
      'file': !profileUpload ? photoDetails['file'] : '',
      'name': !profileUpload ? photoDetails['name'] : '',
      'media': photo,
    };
  }

  Future<Map<String, dynamic>> takeVideoWithCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);
    Map<String, dynamic> videoDetails = await storeMediaPermanently(cameraVideo!, 'Videos');
    return {
      'file': videoDetails['file'],
      'name': videoDetails['name'],
      'media': videoDetails['media']
    };
  }
}
