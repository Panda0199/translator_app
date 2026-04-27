import 'package:translator_app/models/translation.dart';
import 'package:translator_app/services/firebase_service.dart';

class HistoryController {
  final FirebaseService _firebaseService;

  HistoryController({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  Stream<List<Translation>> get translationsStream {
    return _firebaseService.getTranslations();
  }

  Future<bool> deleteTranslation(String id) {
    return _firebaseService.deleteTranslation(id);
  }
}
