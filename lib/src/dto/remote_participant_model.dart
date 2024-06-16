import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'remote_participant_meta_data_model.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class RemoteParticipantModel {
  final String connectionId;
  final String? streamId;
  bool hasAudio;
  bool hasVideo;
  bool isVideoActive;
  bool isAudioActive;
  RemoteParticipantMetaDataModel? metaData;
  RTCPeerConnection? peerConnection;
  MediaStream? mediaStream;

  RemoteParticipantModel({
    required this.connectionId,
    this.streamId,
    this.hasAudio = false,
    this.hasVideo = false,
    this.isAudioActive = false,
    this.isVideoActive = false,
    this.metaData,
    this.peerConnection,
    this.mediaStream,
  });

  RemoteParticipantModel copyWith({
    String? streamId,
    bool? isVideoActive,
    bool? isAudioActive,
    RemoteParticipantMetaDataModel? metaData,
    RTCPeerConnection? peerConnection,
    MediaStream? mediaStream,
  }) {
    return RemoteParticipantModel(
      connectionId: connectionId,
      streamId: streamId ?? this.streamId,
      hasAudio: hasAudio,
      hasVideo: hasVideo,
      isAudioActive: isAudioActive ?? this.isAudioActive,
      isVideoActive: isVideoActive ?? this.isVideoActive,
      metaData: metaData ?? this.metaData,
      peerConnection: peerConnection ?? this.peerConnection,
      mediaStream: mediaStream ?? this.mediaStream,
    );
  }

  factory RemoteParticipantModel.fromJson({
    required Map<String, dynamic> json,
    required RemoteParticipantMetaDataModel metaData,
  }) {
    return RemoteParticipantModel(
      connectionId: json['id'],
      streamId: json['streamId'],
      hasAudio: json['hasAudio'],
      hasVideo: json['hasVideo'],
      isAudioActive: json['isAudioActive'],
      isVideoActive: json['isVideoActive'],
      metaData: metaData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connectionId': connectionId,
      'streamId': streamId,
      'hasAudio': hasAudio,
      'hasVideo': hasVideo,
      'isAudioActive': isAudioActive,
      'isVideoActive': isVideoActive,
      'metaData': metaData?.toJson(),
    };
  }

  String serialize() => jsonEncode(toJson());
}
