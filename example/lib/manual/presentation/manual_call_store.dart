import 'package:example/manual/data/repository/video_call_datasource_repository.dart';
import 'package:mobx/mobx.dart';

part 'manual_call_store.g.dart';

class ManualCallStore = ManualCallStoreBase with _$ManualCallStore;

abstract class ManualCallStoreBase with Store {
  VideoCallDataSourceRepository videoCallDataSourceRepository;

  ManualCallStoreBase({required this.videoCallDataSourceRepository});

  @action
  Future<void> saveCallerOffer({
    required String roomId,
    required String offerUserId,
    required Map<String, dynamic> offer,
  }) async {
    return videoCallDataSourceRepository.saveCallerOffer(roomId: roomId, offerUserId: offerUserId, offer: offer);
  }

  @action
  Future<void> saveCallerCandidate({
    required String roomId,
    required String uuid,
    required Map<String, dynamic> candidate,
  }) async {
    return videoCallDataSourceRepository.saveCallerCandidate(roomId: roomId, candidateUuid: uuid, candidate: candidate);
  }

  @action
  Future<void> saveReceiverAnswer({
    required String roomId,
    required String answerUserId,
    required Map<String, dynamic> answer,
  }) async {
    return videoCallDataSourceRepository.saveReceiverAnswer(roomId: roomId, answerUserId: answerUserId, answer: answer);
  }

  @action
  Stream<Map<String, dynamic>> listenReceiverAnswer({
    required String roomId,
  }) {
    return videoCallDataSourceRepository.listenReceiverAnswer(roomId: roomId);
  }
}
