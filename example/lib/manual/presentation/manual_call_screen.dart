import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:example/manual/data/repository/video_call_datasource_repository.dart';
import 'package:example/manual/presentation/manual_call_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feature_rtc/flutter_feature_rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ManualCallScreen extends StatefulWidget {
  const ManualCallScreen({super.key});

  @override
  State<ManualCallScreen> createState() => _ManualCallScreenState();
}

class _ManualCallScreenState extends State<ManualCallScreen> {
  final store = ManualCallStore(videoCallDataSourceRepository: VideoCallDataSourceRepositoryImpl());
  late String userId;
  String roomId = "room_test";

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      DeviceInfoPlugin().iosInfo.then((iosInfo) {
        userId = iosInfo.identifierForVendor ?? '-';
        initializeLocalRenderer();
        initPlugin();
        initAnswerListener();
      });
    } else {
      DeviceInfoPlugin().androidInfo.then((androidInfo) {
        userId = androidInfo.id.replaceAll(".", "");
        initializeLocalRenderer();
        initPlugin();
        initAnswerListener();
      });
    }
  }

  Future<void> initializeLocalRenderer() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    featureRtcManager.dispose();
    super.dispose();
  }

  late FeatureRtcManager featureRtcManager;

  Future<void> initPlugin() async {
    featureRtcManager = FeatureRtcManager(
      onLocalStreamAdded: (stream) {
        print("MASUK SINI STREAM");
        setState(() {
          print("MASUK SINI STREAM 2");

          localRenderer.initialize().then((_){
            localRenderer.srcObject = stream;
          });
        });
        print("MASUK SINI STREAM 3");
        setState(() {});
      },
      onRemoteStreamAdded: (stream) {
        setState(() {
          remoteRenderer.srcObject = stream;
        });
      },
      onSaveIceCandidate: (String uuid, bool isCaller, iceCandidate) {
        store.saveCallerCandidate(roomId: roomId, uuid: uuid, candidate: iceCandidate);
      },
      onSaveOffer: (String offerUserId, Map<String, dynamic> offer) {
        store.saveCallerOffer(roomId: roomId, offer: offer);
      },
      onCallerListenAnswerOffer: () {
        print("MASUK LISTEN RECEIVER ANSWER NIH");
        streamAnswer = store.listenReceiverAnswer(roomId: roomId).listen((answer) {
          print("MASUK ANSWER: $answer");
          featureRtcManager.setAnswer(answer: answer);
        });
      },
      onSaveAnswer: (Map<String, dynamic> answer) {
        store.saveReceiverAnswer(roomId: roomId, answerUserId: userId, answer: answer);
      },
      onReceiverAddCandidate: () {
        store.getCallerCandidate(roomId: roomId).then(
          (candidates) {
            for (final candidate in candidates) {
              featureRtcManager.addCandidate(candidate: candidate);
            }
          },
        );
      },
    );
  }

  StreamSubscription<Map<String, dynamic>>? streamAnswer;
  late StreamSubscription<Map<String, dynamic>> streamOffer;
  bool isJoinCallButtonVisible = false;
  Map<String, dynamic>? offer;

  Future<void> initAnswerListener() async {
    offer = await store.getCallerOffer(roomId: roomId);
    print("MASUK OFFER: $offer");
    if (offer != null) {
      setState(() {
        isJoinCallButtonVisible = true;
      });
    }
    streamOffer = store.listenCallerOffer(roomId: roomId).listen((offer) {
      if (offer['userId'] != userId) {
        if(mounted){
          setState(() {
            this.offer = offer;
            isJoinCallButtonVisible = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Call Screen'),
      ),
      body: Row(
        children: [
          _localLayout(),
          _remoteLayout(),
        ],
      ),
    );
  }

  Widget _localLayout() {
    return Expanded(
      child: Column(
        children: [
          const Text('LOCAL'),
          Container(
            height: 200,
            width: 100,
            child: RTCVideoView(localRenderer),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              featureRtcManager.startVideoCall(fromUserId: userId);
            },
            child: const Text('Start Video Call'),
          ),
        ],
      ),
    );
  }

  Widget _remoteLayout() {
    return Expanded(
      child: Column(
        children: [
          const Text('REMOTE'),
          Container(
            height: 200,
            width: 100,
            color: Colors.black,
            child: RTCVideoView(remoteRenderer),
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: isJoinCallButtonVisible && offer != null,
            child: ElevatedButton(
              onPressed: () async {
                featureRtcManager.joinCall(fromUserId: userId, offer: offer ?? {});
              },
              child: const Text('Join Video Call'),
            ),
          ),
        ],
      ),
    );
  }
}
