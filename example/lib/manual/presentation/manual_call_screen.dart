import 'package:flutter/material.dart';
import 'package:flutter_feature_rtc/flutter_feature_rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ManualCallScreen extends StatefulWidget {
  const ManualCallScreen({super.key});

  @override
  State<ManualCallScreen> createState() => _ManualCallScreenState();
}

class _ManualCallScreenState extends State<ManualCallScreen> {
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initializeLocalRenderer();
    initPlugin();
  }

  Future<void> initializeLocalRenderer() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  late FeatureRtcManager featureRtcManager;

  Future<void> initPlugin() async {
    featureRtcManager = FeatureRtcManager(
      onLocalStreamAdded: (stream) {
        setState(() {
          localRenderer.srcObject = stream;
        });
      },
      onRemoteStreamAdded: (stream) {
        setState(() {
          remoteRenderer.srcObject = stream;
        });
      },
      onSaveIceCandidate: (iceCandidate) {
        debugPrint("MASUK_ ON ICE CANDIDATE: $iceCandidate");
      },
      onSaveOffer: (Map<String, dynamic> offer) {
        debugPrint("MASUK_ ON SAVE OFFER: $offer");
      },
      onSaveAnswer: (Map<String, dynamic> answer) {
        debugPrint("MASUK_ ON SAVE ANSWER: $answer");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Call Screen'),
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
          Text('LOCAL'),
          Container(
            height: 200,
            width: 100,
            color: Colors.black,
            child: RTCVideoView(localRenderer),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                featureRtcManager.startVideoCall(fromUserId: 'android_1');
              },
              child: Text('Init Local Media Stream 1'))
        ],
      ),
    );
  }

  Widget _remoteLayout() {
    return Expanded(
      child: Column(
        children: [
          Text('REMOTE'),
          Container(
            height: 200,
            width: 100,
            color: Colors.black,
            child: RTCVideoView(remoteRenderer),
          ),
        ],
      ),
    );
  }
}
