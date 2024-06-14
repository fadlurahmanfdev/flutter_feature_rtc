import 'package:example/vidu/data/dto/response/connection_response.dart';
import 'package:example/vidu/data/repository/vidu_datasource_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vidu_bloc.freezed.dart';

part 'vidu_event.dart';

part 'vidu_state.dart';

class ViduBloc extends Bloc<ViduEvent, ViduState> {
  ViduDatasourceRepositoryImpl datasourceRepositoryImpl;

  ViduBloc({required this.datasourceRepositoryImpl}) : super(ViduState.initialize()) {
    on<ViduEvent>((events, emit) async {
      await events.map(
        createConnection: (event) async => await _onCreateConnection(event, emit),
      );
    });
  }

  Future<void> _onCreateConnection(_CreateConnection event, Emitter<ViduState> emit) async {
    try {
      emit(state.copyWith(createConnectionStateState: CreateConnectionStateLoading()));
      final resp = await datasourceRepositoryImpl.createConnection(
        sessionId: event.sessionId,
        basicAuthToken: event.basicAuthToken,
      );
      emit(state.copyWith(createConnectionStateState: CreateConnectionStateSuccess(connection: resp)));
    } on Exception catch (e) {
      emit(state.copyWith(createConnectionStateState: CreateConnectionStateFailed(exception: e)));
    }
  }
}
