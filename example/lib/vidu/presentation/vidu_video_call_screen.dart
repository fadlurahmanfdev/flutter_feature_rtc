import 'package:flutter/material.dart';
import 'package:flutter_feature_rtc/flutter_feature_rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ViduVideoCallScreen extends StatefulWidget {
  final String sessionId;
  final String sessionToken;

  const ViduVideoCallScreen({
    super.key,
    required this.sessionId,
    required this.sessionToken,
  });

  @override
  State<ViduVideoCallScreen> createState() => _ViduVideoCallScreenState();
}

class _ViduVideoCallScreenState extends State<ViduVideoCallScreen> {
  late RTCVidu rtcVidu;
  final localRenderer = RTCVideoRenderer();
  Map<String, RTCVideoRenderer> remoteRenderers = {};

  @override
  void initState() {
    super.initState();

    rtcVidu = RTCVidu(
      onRtcCallback: (state) {
        print("masuk rtc state: ${state}");
      },
      onLocalStreamAdded: (MediaStream stream) {
        setState(() {
          localRenderer.srcObject = stream;
        });
      },
      onAddRemoteStream: (String participantConnectionId, MediaStream stream) async {
        print("MASUK ADD REMOTE STREAM: $participantConnectionId");
        if (!remoteRenderers.containsKey(participantConnectionId)) {
          remoteRenderers[participantConnectionId] = RTCVideoRenderer();
          await remoteRenderers[participantConnectionId]?.initialize();
          setState(() {
            remoteRenderers[participantConnectionId]?.srcObject = stream;
          });
        }
      },
      onRemoveRemoteStream: (participantConnectionId) {
        print("MASUK REMOVE REMOTE STREAM: $participantConnectionId");
        if (remoteRenderers.containsKey(participantConnectionId)) {
          remoteRenderers[participantConnectionId]?.dispose();
          setState(() {
            remoteRenderers.remove(participantConnectionId);
          });
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await renderVideos();
      RTCVidu.httpClientForSslPinning(asset: 'assets/vidudev_bankmas.pem').then((value) {
        rtcVidu.connect(
          url: 'wss://vidudev.bankmas.net:443/openvidu?sessionId=${widget.sessionId}&token=${widget.sessionToken}',
          sessionId: widget.sessionId,
          sessionToken: widget.sessionToken,
          httpClient: value,
        );
      });
    });
  }

  @override
  void dispose() {
    localRenderer.dispose();
    if (remoteRenderers.isNotEmpty) {
      final keys = remoteRenderers.keys.toList();
      for (final key in keys) {
        remoteRenderers[key]?.dispose();
      }
    }
    rtcVidu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Call')),
      body: Stack(
        children: [
          _remoteLayout(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 200,
              margin: EdgeInsets.only(right: 50, bottom: 50),
              width: 100,
              child: RTCVideoView(localRenderer),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> renderVideos() async {
    await localRenderer.initialize();
  }

  Widget _remoteLayout() {
    if (remoteRenderers.length == 1) {
      final firstKey = remoteRenderers.keys.first;
      return RTCVideoView(remoteRenderers[firstKey]!);
    } else {
      return Text("TODO");
    }
  }
}
