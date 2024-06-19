import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

abstract class VideoCallDataSourceRepository {
  Future<void> saveCallerOffer({
    required String roomId,
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

  Future<Map<String, dynamic>?> getCallerOffer({required String roomId});

  Stream<Map<String, dynamic>> listenCallerOffer({required String roomId});

  Future<List<Map<String, dynamic>>> getCallerCandidates({required String roomId});
}

class VideoCallDataSourceRepositoryImpl extends VideoCallDataSourceRepository {
  DatabaseReference reference = FirebaseDatabase.instance.ref("flutter_feature_rtc");

  @override
  Future<void> saveCallerOffer({
    required String roomId,
    required Map<String, dynamic> offer,
  }) async {
    try {
      return reference.child(roomId).child("offer").set(offer);
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
    return reference.child(roomId).onChildAdded.where((event) => event.snapshot.key == "receiverAnswer").map((event) {
      final newMap = <String, dynamic>{};
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      value.forEach((k, v) {
        newMap[k] = v;
      });
      return newMap;
    });
  }

  @override
  Future<Map<String, dynamic>?> getCallerOffer({required String roomId}) {
    return reference.child(roomId).get().then((snapshot) {
      if (snapshot.hasChild("offer")) {
        final newMap = <String, String>{};
        final value = (snapshot.child("offer").value as Map<dynamic, dynamic>);
        value.forEach((k, v) {
          newMap[k] = v;
        });
        return newMap;
      } else {
        return null;
      }
    });
  }

  @override
  Stream<Map<String, dynamic>> listenCallerOffer({required String roomId}) {
    return reference.child(roomId).onChildAdded.where((event) {
      return event.snapshot.key == "offer";
    }).map((event) {
      final newMap = <String, String>{};
      final value = (event.snapshot.value as Map<dynamic, dynamic>);
      value.forEach((k, v) {
        newMap[k] = v;
      });
      return newMap;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getCallerCandidates({required String roomId}) {
    return reference.child(roomId).child("callerCandidates").get().then((snapshot1) {
      print("MASUK SNAPSHOT 1 KEY: ${snapshot1.key}");
      print("MASUK SNAPSHOT 1 VALUE: ${snapshot1.value}");
      final newList = <Map<String, dynamic>>[];
      for (var snapshot2 in snapshot1.children) {
        print("MASUK SNAPSHOT 2 KEY: ${snapshot2.key}");
        if(snapshot2.key == "callerCandidates"){
          for (var snapshot3 in snapshot2.children) {
            final newMap = <String, dynamic>{};
            print("MASUK SNAPSHOT 3 KEY ${snapshot3.key}");
            print("MASUK SNAPSHOT 3 ${snapshot3.value}");
            final value = snapshot3.value as Map<dynamic, dynamic>;
            value.forEach((k, v) {
              newMap[k] = v;
            });
            newList.add(newMap);
          }
        }
      }
      return newList;
    });
  }
}
