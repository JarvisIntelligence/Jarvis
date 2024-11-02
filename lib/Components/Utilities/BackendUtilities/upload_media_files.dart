import 'dart:convert';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class UploadMediaFiles {
  Future <String> uploadImage (XFile? image) async {
    String url = 'https://staging.jarvisintelligence.com/image/upload';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    if(image != null){
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else {
      return '';
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseBody);
      return responseJson['url'];
    } else {
      // Handle error
      InAppNotifications.show(
          description:
          'Image upload failed. A system error occurred while trying to upload the image.',
          onTap: () {}
      );
    }

    return '';
  }
}