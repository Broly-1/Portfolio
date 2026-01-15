import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hassankamran/services/firebase_service.dart';

class EditStatsScreen extends StatefulWidget {
  const EditStatsScreen({super.key});

  @override
  State<EditStatsScreen> createState() => _EditStatsScreenState();
}

class _EditStatsScreenState extends State<EditStatsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _iosController = TextEditingController();
  final TextEditingController _androidController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
  }

  Future<void> _loadCurrentStats() async {
    final stats = await _firebaseService.getAppStats();
    if (mounted) {
      setState(() {
        if (stats != null) {
          _iosController.text = stats.iosDownloads.toString();
          _androidController.text = stats.androidDownloads.toString();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveStats() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final iosDownloads = int.tryParse(_iosController.text) ?? 0;
    final androidDownloads = int.tryParse(_androidController.text) ?? 0;

    final success = await _firebaseService.updateAppStats(
      iosDownloads,
      androidDownloads,
    );

    if (mounted) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Stats updated successfully!' : 'Failed to update stats',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _iosController.dispose();
    _androidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit App Downloads'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveStats,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.apple, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'iOS Downloads',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _iosController,
                              decoration: const InputDecoration(
                                labelText: 'Download Count',
                                hintText: 'e.g., 1500',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.download),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter iOS download count';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.android, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Android Downloads',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _androidController,
                              decoration: const InputDecoration(
                                labelText: 'Download Count',
                                hintText: 'e.g., 2500',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.download),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Android download count';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveStats,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Formatting Tips',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Numbers will be formatted automatically\n'
                              '• 1,000+ = 1K\n'
                              '• 1,000,000+ = 1M\n'
                              '• Example: 1500 displays as 1.5K',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
