import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator_app/models/translation.dart';

class FirebaseService {
  static const String translationsCollection = 'translations';
  static const int historyLimit = 50;
  static const Duration databaseTimeout = Duration(seconds: 8);

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<bool> addTranslation(Translation translation) async {
    try {
      await _firestore
          .collection(translationsCollection)
          .doc(translation.id)
          .set(translation.toMap())
          .timeout(databaseTimeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<List<Translation>> getTranslations() {
    return _firestore
        .collection(translationsCollection)
        .orderBy('timestamp', descending: true)
        .limit(historyLimit)
        .snapshots()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: (sink) {
            sink.addError(
              TimeoutException('History loading took too long'),
            );
          },
        )
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Translation.fromMap({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList(growable: false);
    });
  }

  Future<bool> deleteTranslation(String id) async {
    try {
      await _firestore
          .collection(translationsCollection)
          .doc(id)
          .delete()
          .timeout(databaseTimeout);
      return true;
    } catch (_) {
      return false;
    }
  }
}
