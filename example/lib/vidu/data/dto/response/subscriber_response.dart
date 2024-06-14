import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'subscriber_response.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class SubscriberResponse {
  final String? streamId;

  const SubscriberResponse({
    this.streamId,
  });

  factory SubscriberResponse.fromJson(Map<String, dynamic> json) => _$SubscriberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriberResponseToJson(this);

  String serialize() => jsonEncode(toJson());

  static SubscriberResponse? deserialize(String? value) =>
      value == null ? null : SubscriberResponse.fromJson(jsonDecode(value));
}
