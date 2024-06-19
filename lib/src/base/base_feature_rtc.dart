import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class BaseFeatureRtc {
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth': '320',
        'minHeight': '240',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };

  Future<MediaStream> getUserMedia() {
    return navigator.mediaDevices.getUserMedia(_mediaConstraints);
  }
}
