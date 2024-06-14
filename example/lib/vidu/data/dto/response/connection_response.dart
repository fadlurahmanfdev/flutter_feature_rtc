import 'dart:convert';
import 'package:example/vidu/data/dto/response/ice_server_response.dart';
import 'package:example/vidu/data/dto/response/publisher_response.dart';
import 'package:example/vidu/data/dto/response/subscriber_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'connection_response.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class ConnectionResponse {
  final String? id;
  final String? status;
  final String? sessionId;
  final String? location;
  final String? token;
  final String? role;
  // final List<PublisherResponse>? publishers;
  // final List<SubscriberResponse>? subscribers;
  // final List<IceServerResponse>? customIceServers;

  const ConnectionResponse({
    this.id,
    this.status,
    this.sessionId,
    this.location,
    this.token,
    this.role,
    // this.publishers,
    // this.subscribers,
    // this.customIceServers,
  });

  factory ConnectionResponse.fromJson(Map<String, dynamic> json) => _$ConnectionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionResponseToJson(this);

  String serialize() => jsonEncode(toJson());

  static ConnectionResponse? deserialize(String? value) =>
      value == null ? null : ConnectionResponse.fromJson(jsonDecode(value));
}
