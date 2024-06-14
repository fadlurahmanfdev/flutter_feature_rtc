import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'publisher_response.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class PublisherResponse {
  final String? streamId;

  const PublisherResponse({
    this.streamId,
  });

  factory PublisherResponse.fromJson(Map<String, dynamic> json) => _$PublisherResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PublisherResponseToJson(this);

  String serialize() => jsonEncode(toJson());

  static PublisherResponse? deserialize(String? value) =>
      value == null ? null : PublisherResponse.fromJson(jsonDecode(value));
}
