import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feature_rtc/src/constant/constant.dart';
import 'package:flutter_feature_rtc/src/dto/ice_candidate_method_param_model.dart';
import 'package:flutter_feature_rtc/src/dto/remote_participant_meta_data_model.dart';
import 'package:flutter_feature_rtc/src/dto/remote_participant_model.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Map<String, dynamic> _iceServers = {
  'sdpSemantics': 'plan-b',
  "iceServers": [
    {"url": "stun:stun.l.google.com:19302"},
  ]
};

final Map<String, dynamic> _constraint = {
  "mandatory": {
    "OfferToReceiveAudio": true,
    "OfferToReceiveVideo": true,
  },
  "optional": [],
};

enum RTCViduState {
  initializeWebSocket,
  createdIdJoinRoom,
  createdLocalOffer,
  localStreamAdded,
  remoteStreamAdded,
  remoteStreamRemoved,
  noParticipantLeft,
  webSocketDone,
  parsingHandleResultError,
  webSocketError,
}

class RTCVidu {
  Function(RTCViduState state) onRtcCallback;
  Function(MediaStream stream) onLocalStream;
  Function(String participantConnectionId, MediaStream stream) onAddRemoteStream;
  Function(String participantConnectionId) onRemoveRemoteStream;

  RTCVidu({
    required this.onRtcCallback,
    required this.onLocalStream,
    required this.onAddRemoteStream,
    required this.onRemoveRemoteStream,
  });

  static Future<HttpClient> httpClientForSslPinning({
    required String asset,
  }) async {
    final pemContent = await rootBundle.load(asset);
    final SecurityContext scontext = SecurityContext();
    scontext.setTrustedCertificatesBytes(pemContent.buffer.asUint8List());
    HttpClient client = HttpClient(context: scontext);
    return client;
  }

  static String getBasicAuthTokenFromUserAndSecret({
    required String user,
    required String secret,
  }) {
    return base64.encode(utf8.encode('$user:$secret'));
  }

  late WebSocket webSocket;
  Timer? _timer;
  late String sessionId;
  late String sessionToken;

  final Map<int, String> _idsReceiveVideo = <int, String>{};
  final List<Map<String, dynamic>> _iceCandidatesParams = <Map<String, dynamic>>[];
  final Map<String, RemoteParticipantModel> _participants = <String, RemoteParticipantModel>{};
  final Map<String, String> _participantEndpoints = <String, String>{};

  Future<void> connect({
    required String url,
    required String sessionId,
    required String sessionToken,
    HttpClient? httpClient,
  }) async {
    try {
      this.sessionId = sessionId;
      this.sessionToken = sessionToken;
      webSocket = await WebSocket.connect(
        url,
        customClient: httpClient,
      );

      onRtcCallback(RTCViduState.initializeWebSocket);
      log("connect -> ${RTCViduState.initializeWebSocket}");

      webSocket.listen(
        (event) {
          final jsonMessage = json.decode(event);
          onMessage(jsonMessage);
        },
        onDone: () {
          onRtcCallback(RTCViduState.webSocketDone);
          _timer?.cancel();
        },
      );

      initLocalMediaStream().then((_) {
        createLocalPeerConnection().then((_) {
          createLocalOffer().then((_) {
            Helper.setSpeakerphoneOn(true);
            // localStream.getAudioTracks().forEach((audioTrack) {
            //   audioTrack.enableSpeakerphone(true);
            //   Helper.setVolume(0, audioTrack);
            // });
          });
        });
      });
    } on Exception catch (e) {
      log("failed connect webRtc: $e");
      onRtcCallback(RTCViduState.webSocketError);
    }
  }

  late MediaStream localStream;

  Future<void> initLocalMediaStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };
    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  late RTCPeerConnection localPeerConnection;

  int? _idJoinRoom;
  bool _localPeerConnectionHasRemoteDescription = false;

  Future<void> createLocalPeerConnection() async {
    localPeerConnection = await createPeerConnection(_iceServers, _constraint);
    localStream.getTracks().forEach((element) {
      localPeerConnection.addTrack(element, localStream);
    });

    localPeerConnection.addStream(localStream);

    localPeerConnection.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        print("MASUK_ RTCIceGatheringStateComplete");
        // TODO
      }
    };

    localPeerConnection.onIceCandidate = (iceCandidate) {
      IceCandidateMethodParamModel iceCandidateModel = IceCandidateMethodParamModel(
        iceCandidate.candidate,
        iceCandidate.sdpMid,
        iceCandidate.sdpMLineIndex,
      );
      if (_userId != null) {
        iceCandidateModel = iceCandidateModel.copyWith(endPointName: _endPointName ?? _userId);
        sendJson(JsonConstants.onIceCandidate, params: iceCandidateModel.toJson());
      } else {
        _iceCandidatesParams.add(iceCandidateModel.toJson());
      }
      _iceCandidatesParams.add(iceCandidateModel.toJson());
    };

    localPeerConnection.addStream(localStream);
    onLocalStream(localStream);
    onRtcCallback(RTCViduState.localStreamAdded);
    _idJoinRoom = sendJson(
      JsonConstants.joinRoom,
      params: {
        JsonConstants.metadata: '{"clientData": "mobile-client"}',
        'secret': '',
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
        // 'dataChannels': 'false',
        'session': sessionId,
        'token': sessionToken,
      },
    );
    onRtcCallback(RTCViduState.createdIdJoinRoom);
  }

  int? _idPublishVideo;

  Future<void> createLocalOffer() async {
    try {
      final sessionDescription = await localPeerConnection.createOffer(_constraint);
      await localPeerConnection.setLocalDescription(sessionDescription);
      _idPublishVideo = sendJson(
        JsonConstants.publishVideo,
        params: {
          'audioOnly': 'false',
          'hasAudio': 'true',
          'doLoopback': 'false',
          'hasVideo': 'true',
          'audioActive': 'true',
          'videoActive': 'true',
          'typeOfVideo': 'CAMERA',
          'frameRate': '30',
          'videoDimensions': '{"width": 320, "height": 240}',
          'sdpOffer': sessionDescription.sdp
        },
      );
      onRtcCallback(RTCViduState.createdLocalOffer);
    } catch (e) {
      log("failed created local offer: $e");
    }
  }

  Future<void> onMessage(Map<String, dynamic> message) async {
    if (message.containsKey(JsonConstants.result)) {
      handleResult(id: message[JsonConstants.id], message: message, result: message[JsonConstants.result]);
    } else if (message.containsKey(JsonConstants.method)) {
      handleMethod(method: message[JsonConstants.method], message: message, params: message[JsonConstants.params]);
    } else {
      log('🌏🌏🌏 ON_MESSAGE_OTHER_FROM_SOCKET: $message 🌏🌏🌏');
    }
  }

  String? _userId;
  String? _endPointName;

  Future<void> handleResult({
    required int id,
    required Map<String, dynamic> message,
    required Map<String, dynamic> result,
  }) async {
    debugPrint("🌝🌝🌝 ON_MESSAGE_RESULT_FROM_SOCKET: $message 🌝🌝🌝");
    try {
      if (id == _idPublishVideo) {
        log("PUBLISH VIDEO ID $id --> ${result[JsonConstants.id]}");
        _endPointName = result[JsonConstants.id];
      } else if (id == _idJoinRoom) {
        log("JOIN ROOM ID $id --> ${result[JsonConstants.id]}");
        _userId = result[JsonConstants.id];
      }

      if (result.containsKey(JsonConstants.sdpAnswer)) {
        _saveAnswer(result: result, id: id);
      } else if (result.containsKey(JsonConstants.sessionId)) {
        if (result.containsKey(JsonConstants.value)) {
          final values = (result[JsonConstants.value] as List<dynamic>).map((e) {
            final jsonString = json.encode(e);
            return json.decode(jsonString) as Map<String, dynamic>;
          }).toList();

          for (final iceCandidate in _iceCandidatesParams) {
            iceCandidate[JsonConstants.endpointName] = result[JsonConstants.endpointName] ?? result[JsonConstants.id];
            iceCandidate[JsonConstants.id] = result[JsonConstants.id] ?? result[JsonConstants.endpointName];
            sendJson(JsonConstants.iceCandidate, params: iceCandidate);
          }

          if (values.isNotEmpty) {
            addParticipantAlreadyInRoom(values);
          }
        }
      }
    } catch (e) {
      log("failed handleResult: $e, message: $message, result: $result");
    }
  }

  void _saveAnswer({required Map<String, dynamic> result, required int id}) {
    RTCSessionDescription sessionDescription = RTCSessionDescription(result[JsonConstants.sdpAnswer], 'answer');
    if (!_localPeerConnectionHasRemoteDescription) {
      localPeerConnection.setRemoteDescription(sessionDescription);
      _localPeerConnectionHasRemoteDescription = true;
    } else if (_idsReceiveVideo.containsKey(id)) {
      _participants[_idsReceiveVideo[id]]?.peerConnection?.setRemoteDescription(sessionDescription);
    }
  }

  void addParticipantAlreadyInRoom(List<Map<String, dynamic>> values) {
    for (final value in values) {
      String remoteParticipantId = value[JsonConstants.id];
      RemoteParticipantModel remoteParticipantModel = RemoteParticipantModel(
        connectionId: remoteParticipantId,
      );
      final metaData = value[JsonConstants.metadata];
      if (metaData != null) {
        final metaDataJson = json.decode(metaData) as Map<String, dynamic>;
        remoteParticipantModel =
            remoteParticipantModel.copyWith(metaData: RemoteParticipantMetaDataModel.fromJson(metaDataJson));
      }

      if (value.containsKey(JsonConstants.streams)) {
        final streams = (value[JsonConstants.streams] as List<dynamic>).map((e) {
          final jsonString = json.encode(e);
          return json.decode(jsonString) as Map<String, dynamic>;
        }).toList();
        if (streams.isNotEmpty) {
          final stream = streams.first;
          remoteParticipantModel = remoteParticipantModel.copyWith(streamId: stream[JsonConstants.id]);
        }
      }
      _participants[remoteParticipantId] = remoteParticipantModel;
      createRemotePeerConnection(remoteParticipantModel).then((peerConnection) {
        receiveVideoFromParticipant(remoteParticipantModel: remoteParticipantModel);
      });
    }
  }

  Future<RTCPeerConnection> createRemotePeerConnection(RemoteParticipantModel remoteParticipant) async {
    final remotePeerConnection = await createPeerConnection(_iceServers, _constraint);
    remotePeerConnection.onIceCandidate = (candidate) {
      final iceCandidate = IceCandidateMethodParamModel(
        candidate.candidate,
        candidate.sdpMid,
        candidate.sdpMLineIndex,
        endPointName: remoteParticipant.streamId ??
            _participantEndpoints[remoteParticipant.connectionId] ??
            remoteParticipant.connectionId,
      );
      sendJson(JsonConstants.iceCandidate, params: iceCandidate.toJson());
    };

    remotePeerConnection.onAddStream = (stream) {
      // TODO
      print("MASUK_ REMOTE STREAM: STREAM ID: ${stream.id}");
      onAddRemoteStream(remoteParticipant.connectionId, stream);
    };

    remotePeerConnection.onRemoveStream = (stream) {
      // TODO
    };

    remoteParticipant.peerConnection = remotePeerConnection;
    return remotePeerConnection;
  }

  Future<void> receiveVideoFromParticipant({required RemoteParticipantModel remoteParticipantModel}) async {
    if (remoteParticipantModel.peerConnection == null) return;
    try {
      final sessionDescription = await remoteParticipantModel.peerConnection!.createOffer(_constraint);
      await remoteParticipantModel.peerConnection!.setLocalDescription(sessionDescription);
      int id = sendJson(JsonConstants.receiveVideoFrom, params: {
        'sender': remoteParticipantModel.streamId ?? remoteParticipantModel.connectionId,
        'sdpOffer': sessionDescription.sdp
      });
      _idsReceiveVideo[id] = remoteParticipantModel.connectionId;
    } catch (e) {
      log("failed receiveVideoFromParticipant: $e");
    }
  }

  void handleMethod({
    required String method,
    required Map<String, dynamic> message,
    required Map<String, dynamic> params,
  }) {
    debugPrint("🪐🪐🪐 ON_MESSAGE_METHOD_FROM_SOCKET: $message  🪐🪐🪐");
    if (method == JsonConstants.iceCandidate) {
      _iceCandidateMethod(params: params);
    } else if (method == JsonConstants.participantLeft) {
      _participantLeftMethod(params: params);
    } else if (method == JsonConstants.participantJoined) {
      _participantJoinedMethod(params: params);
    } else if (method == JsonConstants.participantPublished) {
      _participantPublishedMethod(params: params);
    }
  }

  void _iceCandidateMethod({required Map<String, dynamic> params}) {
    bool isLocal = params[JsonConstants.senderConnectionId] == _userId;
    _saveIceCandidate(params, params[JsonConstants.endpointName], params[JsonConstants.senderConnectionId], isLocal);
  }

  void _saveIceCandidate(Map<String, dynamic> params, String endpointName, String senderConnectionId, bool isLocal) {
    IceCandidateMethodParamModel iceCandidateModel = IceCandidateMethodParamModel(
      params['candidate'],
      params['sdpMid'],
      params['sdpMLineIndex'],
      endPointName: endpointName,
    );
    if (isLocal) {
      localPeerConnection.addCandidate(iceCandidateModel);
    } else if (_participants.containsKey(senderConnectionId)) {
      _participants[senderConnectionId]?.peerConnection?.addCandidate(iceCandidateModel);
      _participantEndpoints[senderConnectionId] = endpointName;
    }
  }

  void _participantLeftMethod({required Map<String, dynamic> params}) {
    String participantConnectionId = params[JsonConstants.connectionId];
    // if (participantId == _userId) {
    //   this.onSelfEvict(_userId);
    // }
    // else
    if (_participants.containsKey(participantConnectionId)) {
      // TODO: COULD BE IMPROVE
      onRemoveRemoteStream(participantConnectionId);
      _participants[participantConnectionId]?.peerConnection?.close();
      _participants.remove(participantConnectionId);
      onRtcCallback(RTCViduState.remoteStreamRemoved);
      if (_participants.isEmpty) {
        onRtcCallback(RTCViduState.noParticipantLeft);
      }
    }
  }

  void _participantJoinedMethod({required Map<String, dynamic> params}) {
    final metaData = params[JsonConstants.metadata];
    RemoteParticipantMetaDataModel? metaDataModel;
    if (metaData != null) {
      final metaDataJson = json.decode(metaData) as Map<String, dynamic>;
      metaDataModel = RemoteParticipantMetaDataModel.fromJson(metaDataJson);
    }
    RemoteParticipantModel remoteParticipant = RemoteParticipantModel(
      connectionId: params[JsonConstants.id],
      metaData: metaDataModel,
    );
    _participants[remoteParticipant.connectionId] = remoteParticipant;
    // this.onParticipantsJoined(remoteParticipant);
    createRemotePeerConnection(remoteParticipant);
    // if (this.onStateChange != null) {
    //   this.onStateChange(SignalingState.CallStateConnected);
    // }
  }

  Future<void> _participantPublishedMethod({required Map<String, dynamic> params}) async {
    String remoteParticipantConnectionId = params[JsonConstants.id];
    if (_participants.containsKey(remoteParticipantConnectionId)) {
      RemoteParticipantModel remoteParticipantModelPublished = _participants[remoteParticipantConnectionId]!;
      if (params.containsKey(JsonConstants.streams)) {
        final streams = (params[JsonConstants.streams] as List<dynamic>).map((e) {
          final jsonString = json.encode(e);
          return json.decode(jsonString) as Map<String, dynamic>;
        }).toList();
        if (streams.isNotEmpty) {
          final stream = streams.first;
          if (stream.containsKey(JsonConstants.id)) {
            remoteParticipantModelPublished =
                remoteParticipantModelPublished.copyWith(streamId: stream[JsonConstants.id]);
          }
        }
      }
      if (remoteParticipantModelPublished.peerConnection != null) {
        receiveVideoFromParticipant(remoteParticipantModel: remoteParticipantModelPublished);
      } else {
        createRemotePeerConnection(remoteParticipantModelPublished)
            .then((RTCPeerConnection remotePeerConnection) async {
          receiveVideoFromParticipant(remoteParticipantModel: remoteParticipantModelPublished);
        });
      }
    }
  }

  int _internalId = 1;

  int sendJson(String method, {Map<String, dynamic>? params}) {
    final dict = <String, dynamic>{};
    dict[JsonConstants.method] = method;
    dict[JsonConstants.id] = _internalId;
    dict['jsonrpc'] = '2.0';
    if ((params?.length ?? 0) > 0) {
      dict[JsonConstants.params] = params;
    }
    updateInternalId();
    final jsonString = json.encode(dict);
    webSocket.add(jsonString);
    // log('◤◢◤◢◤◢◤◢◤◢◤ SEND MESSAGE TO SOCKET METHOD: $method --> $jsonString | ◤◢◤◢◤◢◤◢◤◢◤');
    return _internalId - 1;
  }

  void updateInternalId() {
    _internalId++;
  }

  Future<void> dispose() async {
    unawaited(webSocket.close());
    _timer?.cancel();
    _timer = null;
  }
}
