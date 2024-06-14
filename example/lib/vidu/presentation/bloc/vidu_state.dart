part of 'vidu_bloc.dart';

@freezed
class ViduState with _$ViduState {
  const factory ViduState({
    required CreateConnectionStateState createConnectionStateState,
  }) = _ViduState;

  factory ViduState.initialize() => ViduState(
    createConnectionStateState: CreateConnectionStateIdle(),
  );
}

abstract class CreateConnectionStateState {}

class CreateConnectionStateIdle extends CreateConnectionStateState {}

class CreateConnectionStateLoading extends CreateConnectionStateState {}

class CreateConnectionStateSuccess extends CreateConnectionStateState {
  ConnectionResponse connection;
  CreateConnectionStateSuccess({required this.connection});
}

class CreateConnectionStateFailed extends CreateConnectionStateState {
  Exception exception;

  CreateConnectionStateFailed({required this.exception});
}


