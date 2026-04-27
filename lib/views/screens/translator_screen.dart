import 'package:flutter/material.dart';
import 'package:translator_app/controllers/translation_controller.dart';
import 'package:translator_app/views/widgets/message_box.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _textController = TextEditingController();
  final TranslationController _controller = TranslationController();

  @override
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTranslate() async {
    FocusScope.of(context).unfocus();
    await _controller.translate(_textController.text);
  }

  void _handleSwapLanguages() {
    final replacementInput = _controller.swapLanguages();

    if (replacementInput != null) {
      _textController.text = replacementInput;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  void _handleClear() {
    _textController.clear();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Translator'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _handleClear,
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From Language:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _controller.sourceLanguage,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.sourceLanguages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: _controller.isLoading
                        ? null
                        : _controller.setSourceLanguage,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: IconButton.filledTonal(
                      onPressed:
                          _controller.isLoading ? null : _handleSwapLanguages,
                      icon: const Icon(Icons.swap_vert),
                      tooltip: 'Swap languages',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To Language:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _controller.targetLanguage,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.targetLanguages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: _controller.isLoading
                        ? null
                        : _controller.setTargetLanguage,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Text to Translate:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Enter text here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _controller.isLoading ? null : _handleTranslate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: _controller.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.translate),
                      label: Text(
                        _controller.isLoading ? 'Translating...' : 'Translate',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_controller.errorMessage != null)
                    MessageBox(
                      text: _controller.errorMessage!,
                      backgroundColor: Colors.red.shade100,
                      borderColor: Colors.red,
                      textColor: Colors.red.shade800,
                    ),
                  if (_controller.saveMessage != null) ...[
                    const SizedBox(height: 12),
                    MessageBox(
                      text: _controller.saveMessage!,
                      backgroundColor: Colors.green.shade100,
                      borderColor: Colors.green,
                      textColor: Colors.green.shade800,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_controller.translatedText.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Translation:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _controller.translatedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
