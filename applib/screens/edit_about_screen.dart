import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';

class EditAboutScreen extends StatefulWidget {
  const EditAboutScreen({super.key});

  @override
  State<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _imagePicker = ImagePicker();

  // Form controllers
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _loadAboutData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _firebaseService.getAboutData();
      if (data != null && mounted) {
        setState(() {
          _bioController.text = data['bio'] ?? '';
          _locationController.text = data['location'] ?? '';
          _emailController.text = data['email'] ?? '';
          _githubController.text = data['github'] ?? '';
          _linkedinController.text = data['linkedin'] ?? '';
          _currentImageUrl = data['imageUrl'];
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _saveAboutData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      String? imageUrl = _currentImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        imageUrl = await _firebaseService.uploadImage(
          File(_selectedImage!.path),
          'about',
        );
      }

      // Save data to Firestore
      await _firebaseService.saveAboutData({
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'email': _emailController.text.trim(),
        'github': _githubController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'imageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('About section updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _currentImageUrl = imageUrl;
          _selectedImage = null;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to save: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _insertLink() async {
    final textController = TextEditingController();
    final urlController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Display Text',
                hintText: 'e.g., my project',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'text': textController.text,
                  'url': urlController.text,
                });
              }
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );

    if (result != null) {
      final markdown = '[${result['text']}](${result['url']})';
      final currentText = _bioController.text;
      final selection = _bioController.selection;

      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        markdown,
      );

      _bioController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + markdown.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit About Section'),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAboutData,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Section
                    _buildImageSection(),
                    const SizedBox(height: 32),

                    // Bio with link button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Bio',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _insertLink,
                              icon: const Icon(Icons.link, size: 18),
                              label: const Text('Add Link'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF7BA7BC),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            hintText:
                                'Tell us about yourself...\n\nUse [text](url) format for links',
                            prefixIcon: const Icon(Icons.description),
                            helperText:
                                'Tip: Select text and click "Add Link" to create hyperlinks',
                            helperMaxLines: 2,
                          ),
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter Bio';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'e.g., New York, USA',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'your.email@example.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // GitHub
                    _buildTextField(
                      controller: _githubController,
                      label: 'GitHub URL',
                      hint: 'https://github.com/username',
                      icon: Icons.code,
                    ),
                    const SizedBox(height: 16),

                    // LinkedIn
                    _buildTextField(
                      controller: _linkedinController,
                      label: 'LinkedIn URL',
                      hint: 'https://linkedin.com/in/username',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isUploading ? null : _saveAboutData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF7BA7BC),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Profile Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF7BA7BC).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7BA7BC), width: 2),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _currentImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(
                _selectedImage != null || _currentImageUrl != null
                    ? 'Change Image'
                    : 'Select Image',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
