part of 'vidu_bloc.dart';

@freezed
class ViduEvent with _$ViduEvent {
  const factory ViduEvent.createConnection({required String sessionId, required String basicAuthToken}) = _CreateConnection;
}