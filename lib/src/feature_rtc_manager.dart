import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_feature_rtc/src/base/base_feature_rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

class FeatureRtcManager extends BaseFeatureRtc {
  Function(MediaStream) onLocalStreamAdded;
  Function(MediaStream) onRemoteStreamAdded;
  Function(String uuid, bool isCaller, Map<String, dynamic> iceCandidate) onSaveIceCandidate;
  Function(String offerUserId, Map<String, dynamic> offer) onSaveOffer;
  Function() onCallerListenAnswerOffer;
  Function(Map<String, dynamic>) onSaveAnswer;
  Function() onReceiverAddCandidate;

  FeatureRtcManager({
    required this.onLocalStreamAdded,
    required this.onRemoteStreamAdded,
    required this.onSaveIceCandidate,
    required this.onSaveOffer,
    required this.onCallerListenAnswerOffer,
    required this.onSaveAnswer,
    required this.onReceiverAddCandidate,
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

  MediaStream? _localStream;
  MediaStream? _remoteStream;

  Future<void> _createLocalMediaStream() async {
    _localStream = await getUserMedia();
    onLocalStreamAdded(_localStream!);
  }

  RTCPeerConnection? _localPeerConnection;

  Future<void> _createPeerConnection() async {
    _localPeerConnection = await createPeerConnection(_configuration, _offerSdpConstraints);

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _localPeerConnection?.addTrack(track, _localStream!);
      });
    }

    if (_localStream != null) {
      _localPeerConnection?.addStream(_localStream!);
    }
    _localPeerConnection?.onIceCandidate = (iceCandidate) {
      final newMapIceCandidate = iceCandidate.toMap() as Map<String, dynamic>;
      newMapIceCandidate['userId'] = _localUserId;
      debugPrint("🌼🌼🌼 ON ICE CANDIDATE: $newMapIceCandidate 🌼🌼🌼");
      onSaveIceCandidate(const Uuid().v4(), isCaller, newMapIceCandidate);
    };

    _localPeerConnection?.onTrack = (event) {
      event.streams.first.getTracks().forEach((track) {
        _remoteStream?.addTrack(track);
      });
    };

    _localPeerConnection?.onAddStream = (stream) {
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
      return _localPeerConnection?.setRemoteDescription(sessionDescription);
    });
  }

  Future<void> _createLocalOffer() async {
    final offer = await _localPeerConnection?.createOffer({'offerToReceiveVideo': 1});
    if (offer != null) {
      final newOffer = offer.toMap() as Map<String, dynamic>;
      newOffer['userId'] = _localUserId;
      debugPrint("🌏🌏🌏 LOCAL OFFER: $newOffer");
      await _localPeerConnection?.setLocalDescription(offer);
      onSaveOffer(_localUserId, newOffer);
    }
  }

  late String _localUserId;
  bool isCaller = false;

  Future<void> startVideoCall({required String fromUserId}) async {
    isCaller = true;
    _localUserId = fromUserId;
    _createLocalMediaStream().then((_) {
      _createLocalPeerConnection().then((_) {
        Helper.setSpeakerphoneOn(true);
        _createLocalOffer().then((_) {
          onCallerListenAnswerOffer();
        });
      });
    });
  }

  Future<void> joinCall({required String fromUserId, required Map<String, dynamic> offer}) async {
    isCaller = false;
    _localUserId = fromUserId;
    _createLocalMediaStream().then((_){
      _createRemotePeerConnection(offer: offer).then((_) async {
        Helper.setSpeakerphoneOn(true);
        _createAnswer().then((_) {
          onReceiverAddCandidate();
        });
      });
    });
  }

  Future<void> _createAnswer() async {
    final answer = await _localPeerConnection?.createAnswer({'offerToReceiveVideo': 1});
    if (answer != null) {
      final newMapAnswer = answer.toMap() as Map<String, dynamic>;
      newMapAnswer['userId'] = _localUserId;
      await _localPeerConnection?.setLocalDescription(answer);
      onSaveAnswer(newMapAnswer);
    }
  }

  Future<void> setAnswer({required Map<String, dynamic> answer}) async {
    final sessionDescription = RTCSessionDescription(answer['sdp'], answer["type"]);
    await _localPeerConnection?.setRemoteDescription(sessionDescription);
  }

  Future<void> addCandidate({required Map<String, dynamic> candidate}) async {
    final rtcIceCandidate = RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMlineIndex']);
    await _localPeerConnection?.addCandidate(rtcIceCandidate);
  }

  void dispose() {
    _localStream?.dispose();
    _remoteStream?.dispose();

    _localPeerConnection?.close();
    _localPeerConnection?.dispose();
  }
}
