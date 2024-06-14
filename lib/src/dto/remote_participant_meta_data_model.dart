import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class RemoteParticipantMetaDataModel {
  String? clientData;

  RemoteParticipantMetaDataModel({
    this.clientData,
  });

  factory RemoteParticipantMetaDataModel.fromJson(Map<String, dynamic> json) {
    return RemoteParticipantMetaDataModel(
      clientData: json['clientData']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientData': clientData,
    };
  }
}
