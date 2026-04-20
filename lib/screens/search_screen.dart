import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final void Function(String topic, String difficulty) onSearch;
  const SearchScreen({super.key, required this.onSearch});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleSearch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: Integrate with AI intent extraction
      // For now, just pass the text as topic, and 'any' as difficulty
      final text = _controller.text.trim();
      if (text.isEmpty) throw Exception('Please enter a topic or question.');
      // Call AI intent extraction here
      // final result = await AIService.extractIntent(text);
      // widget.onSearch(result['topic'], result['difficulty']);
      widget.onSearch(text, 'any');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search for Quiz Topic')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter topic, keyword, or question',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _handleSearch,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Search'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
