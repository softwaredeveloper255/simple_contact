import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../auxiliary.dart';
import '../models/message.dart';
import 'api_client.dart';

class AudioCacheClient {
  final Future<Directory> _directoryFuture = getTemporaryDirectory();

  Future<File> cachedNetworkAudioFile(AudioClipContent clip) async {
    final directory = await _directoryFuture;
    final file = File("${directory.path}/${basename(clip.assetUri)}");
    if (!await file.exists()) {
      await file.create(recursive: true);
      final response = await http.get(Uri.parse(Aux.resdbToHttp(clip.assetUri)));
      ApiClient.checkResponseCode(response);
      await file.writeAsBytes(response.bodyBytes);
    }
    return file;
  }
}