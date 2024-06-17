import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_feature_rtc/src/base/base_feature_rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FeatureRtcManager extends BaseFeatureRtc {
  Function(MediaStream) onLocalStreamAdded;
  Function(MediaStream) onRemoteStreamAdded;
  Function(Map<String, dynamic>) onSaveIceCandidate;
  Function(Map<String, dynamic>) onSaveOffer;
  Function(Map<String, dynamic>) onSaveAnswer;

  FeatureRtcManager({
    required this.onLocalStreamAdded,
    required this.onRemoteStreamAdded,
    required this.onSaveIceCandidate,
    required this.onSaveOffer,
    required this.onSaveAnswer,
  });

  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'plan-b',
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  final Map<String, dynamic> _offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  late MediaStream _localStream;
  MediaStream? _remoteStream;

  Future<void> _createLocalMediaStream() async {
    _localStream = await getUserMedia();
    onLocalStreamAdded(_localStream);
  }

  late RTCPeerConnection _localPeerConnection;

  Future<void> _createPeerConnection() async {
    _localPeerConnection = await createPeerConnection(_configuration, _offerSdpConstraints);

    _localStream.getTracks().forEach((track) {
      _localPeerConnection.addTrack(track, _localStream);
    });

    _localPeerConnection.addStream(_localStream);
    _localPeerConnection.onIceCandidate = (iceCandidate) {
      final newMapIceCandidate = iceCandidate.toMap() as Map<String, dynamic>;
      newMapIceCandidate['userId'] = _localUserId;
      debugPrint("🌼🌼🌼 ON ICE CANDIDATE: $newMapIceCandidate 🌼🌼🌼");
      onSaveIceCandidate(newMapIceCandidate);
    };

    _localPeerConnection.onTrack = (event) {
      event.streams.first.getTracks().forEach((track) {
        _remoteStream?.addTrack(track);
      });
    };

    _localPeerConnection.onAddStream = (stream) {
      debugPrint("ON ADD REMOTE STREAM: ${stream.id}");
      // TODO
      _remoteStream = stream;
      onRemoteStreamAdded(_remoteStream!);
    };
  }

  Future<void> _createLocalPeerConnection() {
    return _createPeerConnection();
  }

  Future<void> _createRemotePeerConnection({required Map<String, dynamic> offer}) {
    final sessionDescription = RTCSessionDescription(offer["sdp"], offer["type"]);
    return _createPeerConnection().then((_) {
      return _localPeerConnection.setRemoteDescription(sessionDescription);
    });
  }

  Future<void> _createLocalOffer() async {
    final offer = await _localPeerConnection.createOffer({'offerToReceiveVideo': 1});
    final newOffer = offer.toMap() as Map<String, dynamic>;
    newOffer['userId'] = _localUserId;
    debugPrint("🌏🌏🌏 LOCAL OFFER: $newOffer");
    await _localPeerConnection.setLocalDescription(offer);
    onSaveOffer(newOffer);
  }

  String? _localUserId;
  bool isCaller = false;

  Future<void> startVideoCall({required String fromUserId}) async {
    isCaller = true;
    _localUserId = fromUserId;
    await _createLocalMediaStream().then((_) async {
      await _createLocalPeerConnection().then((_) async {
        await _createLocalOffer();
      });
    });
  }

  Future<void> joinCall({required String fromUserId, required Map<String, dynamic> offer}) async {
    isCaller = false;
    _localUserId = fromUserId;
    await _createRemotePeerConnection(offer: offer).then((_) async {
      await _createAnswer();
    });
  }

  Future<void> _createAnswer() async {
    final answer = await _localPeerConnection.createAnswer({'offerToReceiveVideo': 1});
    final newMapAnswer = answer.toMap() as Map<String, dynamic>;
    newMapAnswer['userId'] = _localUserId;
    await _localPeerConnection.setLocalDescription(answer);
    onSaveAnswer(newMapAnswer);
  }

  Future<void> addCandidate({required Map<String, dynamic> mapCandidate}) async {
    final iceCandidate =
        RTCIceCandidate(mapCandidate['candidate'], mapCandidate['sdpMid'], mapCandidate['sdpMlineIndex']);
    await _localPeerConnection.addCandidate(iceCandidate);
  }
}
