import 'package:flutter/material.dart';
import 'package:translator_app/controllers/history_controller.dart';
import 'package:translator_app/models/translation.dart';
import 'package:translator_app/views/widgets/translation_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryController _controller = HistoryController();
  late final Stream<List<Translation>> _translationsStream =
      _controller.translationsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Translation>>(
        stream: _translationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading history',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure you have internet connection',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final translations = snapshot.data ?? [];

          if (translations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'No translations yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start translating to see your history here',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: translations.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final translation = translations[index];

              return TranslationCard(
                translation: translation,
                onDelete: () => _showDeleteConfirmation(translation.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(String translationId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Translation'),
          content: const Text('Are you sure you want to delete this translation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteTranslation(translationId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTranslation(String translationId) async {
    final deleted = await _controller.deleteTranslation(translationId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Translation deleted'
              : 'Could not delete translation. Check your internet connection.',
        ),
      ),
    );
  }
}
