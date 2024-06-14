import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'ice_server_response.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class IceServerResponse  {
  final String? url;
  final String? username;
  final String? credential;

  const IceServerResponse({
    this.url,
    this.username,
    this.credential,
  });

  factory IceServerResponse.fromJson(Map<String, dynamic> json) => _$IceServerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IceServerResponseToJson(this);

  String serialize() => jsonEncode(toJson());

  static IceServerResponse? deserialize(String? value) =>
      value == null ? null : IceServerResponse.fromJson(jsonDecode(value));
}
