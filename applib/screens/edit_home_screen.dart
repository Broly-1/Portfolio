import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditHomeScreen extends StatefulWidget {
  const EditHomeScreen({super.key});

  @override
  State<EditHomeScreen> createState() => _EditHomeScreenState();
}

class _EditHomeScreenState extends State<EditHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _headingController = TextEditingController();
  final _paragraphController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  List<String> _selectedProjectIds = [];
  List<Map<String, dynamic>> _allProjects = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load home content
      final homeDoc = await FirebaseFirestore.instance
          .collection('homeContent')
          .doc('main')
          .get();

      if (homeDoc.exists) {
        final data = homeDoc.data()!;
        _headingController.text = data['heading'] ?? '';
        _paragraphController.text = data['paragraph'] ?? '';
        _githubController.text = data['githubUrl'] ?? '';
        _linkedinController.text = data['linkedinUrl'] ?? '';
        _selectedProjectIds = List<String>.from(
          data['featuredProjectIds'] ?? [],
        );
      }

      // Load all projects
      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .orderBy('order')
          .get();

      _allProjects = projectsSnapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc.data()['name'] ?? 'Untitled'};
      }).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveHomeContent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectIds.isEmpty || _selectedProjectIds.length > 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select 1 or 2 featured projects')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('homeContent')
          .doc('main')
          .set({
            'heading': _headingController.text.trim(),
            'paragraph': _paragraphController.text.trim(),
            'githubUrl': _githubController.text.trim(),
            'linkedinUrl': _linkedinController.text.trim(),
            'featuredProjectIds': _selectedProjectIds,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home content saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleProjectSelection(String projectId) {
    setState(() {
      if (_selectedProjectIds.contains(projectId)) {
        _selectedProjectIds.remove(projectId);
      } else {
        if (_selectedProjectIds.length < 2) {
          _selectedProjectIds.add(projectId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select up to 2 featured projects'),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _headingController.dispose();
    _paragraphController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Home Screen')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading
                    TextFormField(
                      controller: _headingController,
                      decoration: const InputDecoration(
                        labelText: 'Heading',
                        border: OutlineInputBorder(),
                        helperText:
                            'Use {{text}} for accent color. Example: I am a {{Flutter Developer}}',
                        helperMaxLines: 2,
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a heading';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Paragraph
                    TextFormField(
                      controller: _paragraphController,
                      decoration: const InputDecoration(
                        labelText: 'Paragraph',
                        border: OutlineInputBorder(),
                        helperText:
                            'Use [text](url) for links. Example: Check my [portfolio](https://example.com)',
                        helperMaxLines: 2,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a paragraph';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // GitHub URL
                    TextFormField(
                      controller: _githubController,
                      decoration: const InputDecoration(
                        labelText: 'GitHub URL',
                        border: OutlineInputBorder(),
                        hintText: 'https://github.com/username',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your GitHub URL';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // LinkedIn URL
                    TextFormField(
                      controller: _linkedinController,
                      decoration: const InputDecoration(
                        labelText: 'LinkedIn URL',
                        border: OutlineInputBorder(),
                        hintText: 'https://linkedin.com/in/username',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your LinkedIn URL';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Featured Projects Section
                    const Text(
                      'Featured Projects (Select 1-2)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedProjectIds.length}/2 selected',
                      style: TextStyle(
                        color:
                            _selectedProjectIds.length >= 1 &&
                                _selectedProjectIds.length <= 2
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Projects List
                    ..._allProjects.map((project) {
                      final isSelected = _selectedProjectIds.contains(
                        project['id'],
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) =>
                              _toggleProjectSelection(project['id']),
                          title: Text(project['name']),
                          secondary: isSelected
                              ? const Icon(Icons.star, color: Colors.amber)
                              : const Icon(Icons.star_border),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveHomeContent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
