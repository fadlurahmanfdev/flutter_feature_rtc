import 'package:draggable_widget/draggable_widget.dart';
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
  Map<String, bool> isParticipantsCameraActive = {};
  Map<String, bool> isParticipantsMicActive = {};
  bool micMuted = false;

  @override
  void initState() {
    super.initState();

    rtcVidu = RTCVidu(
      onRtcCallback: (state) {
        print("masuk_ rtc state: ${state}");
        switch (state) {
          case RTCViduState.endCall:
            Navigator.of(context).pop();
          default:
            break;
        }
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
      onMicMuted: (isMuted) {
        setState(() {
          micMuted = isMuted;
        });
      },
      onRemoteCameraActive: (isActive, connectionId) {
        print("MASUK ${connectionId} CAMERA ACTIVE -> ${isActive}");
        setState(() {
          isParticipantsCameraActive[connectionId] = isActive;
        });
      },
      onRemoteMicActive: (isActive, connectionId) {
        print("MASUK ${connectionId} REMOTE MIC ACTIVE -> ${isActive}");
        setState(() {
          isParticipantsMicActive[connectionId] = isActive;
        });
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
          DraggableWidget(
            initialPosition: AnchoringPosition.bottomRight,
            bottomMargin: 250,
            horizontalSpace: 20,
            intialVisibility: true,
            child: Container(
              height: 200,
              width: 100,
              child: RTCVideoView(localRenderer),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _controlLayout(),
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
      final isCameraActive = isParticipantsCameraActive[firstKey] ?? false;
      return isCameraActive
          ? RTCVideoView(remoteRenderers[firstKey]!)
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey,
              child: Icon(
                Icons.no_photography_outlined,
                color: Colors.black,
              ),
            );
    } else {
      return Text("NOTHING");
    }
  }

  Widget _controlLayout() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              rtcVidu.muteOrUnMuteAudio();
            },
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              child: Icon(
                micMuted ? Icons.mic : Icons.mic_off,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              rtcVidu.endCall();
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              child: Icon(
                Icons.call_end,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              rtcVidu.switchCamera();
            },
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              child: Icon(
                Icons.autorenew,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
