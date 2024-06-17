import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class BaseFeatureRtc {
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
    }
  };

  Future<MediaStream> getUserMedia() {
    return navigator.mediaDevices.getUserMedia(_mediaConstraints);
  }
}
