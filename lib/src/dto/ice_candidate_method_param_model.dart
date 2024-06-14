import 'package:flutter_webrtc/flutter_webrtc.dart';

class IceCandidateMethodParamModel extends RTCIceCandidate {
  final String? endPointName;

  IceCandidateMethodParamModel(
    super.candidate,
    super.sdpMid,
    super.sdpMLineIndex, {
    this.endPointName,
  });

  IceCandidateMethodParamModel copyWith({String? endPointName}) {
    return IceCandidateMethodParamModel(
      candidate,
      sdpMid,
      sdpMLineIndex,
      endPointName: endPointName ?? this.endPointName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'endpointName': endPointName,
    };
  }
}
