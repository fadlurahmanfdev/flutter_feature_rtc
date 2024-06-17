import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

abstract class VideoCallDataSourceRepository {
  Future<void> saveCallerOffer({
    required String roomId,
    required String offerUserId,
    required Map<String, dynamic> offer,
  });

  Future<void> saveCallerCandidate({
    required String roomId,
    required String candidateUuid,
    required Map<String, dynamic> candidate,
  });

  Future<void> saveReceiverAnswer({
    required String roomId,
    required String answerUserId,
    required Map<String, dynamic> answer,
  });

  Stream<Map<String, dynamic>> listenReceiverAnswer({required String roomId});
}

class VideoCallDataSourceRepositoryImpl extends VideoCallDataSourceRepository {
  DatabaseReference reference = FirebaseDatabase.instance.ref("flutter_feature_rtc");

  @override
  Future<void> saveCallerOffer({
    required String roomId,
    required String offerUserId,
    required Map<String, dynamic> offer,
  }) async {
    try {
      return reference.child(roomId).child("offer").child(offerUserId).set(offer);
    } catch (e) {
      debugPrint("FAILED SAVE OFFER: $e");
    }
  }

  @override
  Future<void> saveCallerCandidate({
    required String roomId,
    required String candidateUuid,
    required Map<String, dynamic> candidate,
  }) async {
    try {
      return reference.child(roomId).child("callerCandidates").child(candidateUuid).set(candidate);
    } catch (e) {
      debugPrint("FAILED SAVE OFFER: $e");
    }
  }

  @override
  Future<void> saveReceiverAnswer({
    required String roomId,
    required String answerUserId,
    required Map<String, dynamic> answer,
  }) async {
    try {
      return reference.child(roomId).child("receiverAnswer").set(answer);
    } catch (e) {
      debugPrint("FAILED SAVE OFFER: $e");
    }
  }

  @override
  Stream<Map<String, dynamic>> listenReceiverAnswer({required String roomId}) {
    return reference.child(roomId).child("receiverAnswer").onChildAdded.map((event) {
      return event.snapshot.value as Map<String, dynamic>;
    });
  }
}
