import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareController {
  late Dio dio = Dio();
  final String imageurl;
  final String content;
  final String storelink;

  ShareController({
    required this.imageurl,
    required this.content,
    required this.storelink,
  });

  //download image
  Future<Map> downloadFile({ProgressCallback? onReceiveProgress}) async {
    try {
      Dio dio = Dio();
      String fileName =
          this.imageurl.substring(this.imageurl.lastIndexOf("/") + 1);
      Directory tempDir = await getApplicationDocumentsDirectory();
      String savePath = '${tempDir.path}/$fileName';
      await dio.download(this.imageurl, savePath,
          onReceiveProgress: onReceiveProgress);
      Map updateData = {"local_path": savePath, "hasImage": true};
      return updateData;
    } catch (e) {
      print(e.toString());
      Map updateData = {"local_path": "", "hasImage": false};
      return updateData;
    }
  }

  //Share files
  Future shareLink() async {
    Map downloaddata = await this.downloadFile();
    Share.shareFiles(
      [downloaddata["local_path"]],
      text: this.content + this.storelink,
    );
  }
}
