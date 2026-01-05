import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProjectScreen extends StatefulWidget {
  final Project? project; // null for new project

  const EditProjectScreen({super.key, this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _androidLinkController;
  late TextEditingController _iosLinkController;
  late TextEditingController _apkLinkController;
  late TextEditingController _githubLinkController;
  late TextEditingController _contentController;

  File? _selectedImage;
  String? _existingThumbnailUrl;
  bool _isSaving = false;
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  DateTime? _selectedDate;

  // Rich text formatting state
  int _selectionStart = 0;
  int _selectionEnd = 0;

  @override
  void initState() {
    super.initState();
    final project = widget.project;

    _nameController = TextEditingController(text: project?.name ?? '');
    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    _androidLinkController = TextEditingController(
      text: project?.androidLink ?? '',
    );
    _iosLinkController = TextEditingController(text: project?.iosLink ?? '');
    _apkLinkController = TextEditingController(text: project?.apkLink ?? '');
    _githubLinkController = TextEditingController(
      text: project?.githubLink ?? '',
    );
    _contentController = TextEditingController(text: project?.content ?? '');

    _existingThumbnailUrl = project?.thumbnailUrl;
    _tags = List<String>.from(project?.tags ?? []);
    _selectedDate = project?.createdAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _androidLinkController.dispose();
    _iosLinkController.dispose();
    _apkLinkController.dispose();
    _githubLinkController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [
          if (widget.project != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProject,
              tooltip: 'Delete Project',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProject,
            tooltip: 'Save',
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Thumbnail section
                  _buildThumbnailSection(),
                  const SizedBox(height: 24),

                  // Basic info section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Project Name *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter project name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Short Description *',
                              helperText: 'Brief description for the card',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date picker
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Project Date *',
                                helperText: 'Date to display on the card',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat(
                                        'MMMM d, y',
                                      ).format(_selectedDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  color: _selectedDate != null
                                      ? null
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Links section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Links',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leave empty if not applicable',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _androidLinkController,
                            decoration: const InputDecoration(
                              labelText: 'Google Play Link',
                              prefixIcon: Icon(Icons.android),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _iosLinkController,
                            decoration: const InputDecoration(
                              labelText: 'App Store Link',
                              prefixIcon: Icon(Icons.apple),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _apkLinkController,
                            decoration: const InputDecoration(
                              labelText: 'APK Download Link',
                              helperText: 'Used if no store links provided',
                              prefixIcon: Icon(Icons.download),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _githubLinkController,
                            decoration: const InputDecoration(
                              labelText: 'GitHub Repository Link',
                              prefixIcon: Icon(Icons.code),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add technologies, frameworks, or keywords',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),

                          // Tag input
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  decoration: const InputDecoration(
                                    labelText: 'Add Tag',
                                    hintText: 'e.g., Flutter, Firebase, API',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (value) => _addTag(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                icon: const Icon(Icons.add),
                                onPressed: _addTag,
                                tooltip: 'Add Tag',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tags display
                          if (_tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  onDeleted: () => _removeTag(tag),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                );
                              }).toList(),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'No tags added yet',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content section with rich text
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use Markdown for formatting',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),

                          // Formatting toolbar
                          _buildFormattingToolbar(),
                          const SizedBox(height: 8),

                          // Content text field
                          TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Detailed Description',
                              hintText:
                                  'Write a detailed description using Markdown...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 15,
                            onChanged: (value) {
                              setState(() {
                                _selectionStart =
                                    _contentController.selection.start;
                                _selectionEnd =
                                    _contentController.selection.end;
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // Markdown help
                          ExpansionTile(
                            title: const Text('Markdown Help'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMarkdownHelp(
                                      '# Heading 1',
                                      'Large heading',
                                    ),
                                    _buildMarkdownHelp(
                                      '## Heading 2',
                                      'Medium heading',
                                    ),
                                    _buildMarkdownHelp(
                                      '### Heading 3',
                                      'Small heading',
                                    ),
                                    _buildMarkdownHelp(
                                      '**bold text**',
                                      'Bold text',
                                    ),
                                    _buildMarkdownHelp(
                                      '*italic text*',
                                      'Italic text',
                                    ),
                                    _buildMarkdownHelp(
                                      '- List item',
                                      'Bullet point',
                                    ),
                                    _buildMarkdownHelp(
                                      '1. List item',
                                      'Numbered list',
                                    ),
                                    _buildMarkdownHelp('`code`', 'Inline code'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildThumbnailSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Screenshot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : _existingThumbnailUrl != null
                        ? Image.network(
                            _existingThumbnailUrl!,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              const Text('Tap to add screenshot'),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (_selectedImage != null || _existingThumbnailUrl != null)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _existingThumbnailUrl = null;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFormatButton(
          icon: Icons.format_bold,
          tooltip: 'Bold',
          onPressed: () => _applyFormat('**', '**'),
        ),
        _buildFormatButton(
          icon: Icons.format_italic,
          tooltip: 'Italic',
          onPressed: () => _applyFormat('*', '*'),
        ),
        _buildFormatButton(
          icon: Icons.title,
          tooltip: 'Heading 1',
          onPressed: () => _applyFormat('# ', ''),
        ),
        _buildFormatButton(
          icon: Icons.format_list_bulleted,
          tooltip: 'Bullet List',
          onPressed: () => _applyFormat('- ', ''),
        ),
        _buildFormatButton(
          icon: Icons.format_list_numbered,
          tooltip: 'Numbered List',
          onPressed: () => _applyFormat('1. ', ''),
        ),
        _buildFormatButton(
          icon: Icons.code,
          tooltip: 'Code',
          onPressed: () => _applyFormat('`', '`'),
        ),
      ],
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton.outlined(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _buildMarkdownHelp(String syntax, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              syntax,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFormat(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (selection.start == -1) return;

    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            selection.start +
            prefix.length +
            selectedText.length +
            suffix.length,
      ),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1920,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project date')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? thumbnailUrl = _existingThumbnailUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        final projectId =
            widget.project?.id ??
            DateTime.now().millisecondsSinceEpoch.toString();
        final uploadedUrl = await _firebaseService.uploadThumbnail(
          _selectedImage!,
          projectId,
        );

        if (uploadedUrl != null) {
          thumbnailUrl = uploadedUrl;
        } else {
          throw Exception('Failed to upload thumbnail');
        }
      }

      final project = Project(
        id: widget.project?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        androidLink: _androidLinkController.text.trim().isEmpty
            ? null
            : _androidLinkController.text.trim(),
        iosLink: _iosLinkController.text.trim().isEmpty
            ? null
            : _iosLinkController.text.trim(),
        apkLink: _apkLinkController.text.trim().isEmpty
            ? null
            : _apkLinkController.text.trim(),
        githubLink: _githubLinkController.text.trim().isEmpty
            ? null
            : _githubLinkController.text.trim(),
        thumbnailUrl: thumbnailUrl,
        content: _contentController.text.trim(),
        createdAt: _selectedDate ?? widget.project?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        order: widget.project?.order ?? 0,
        tags: _tags,
      );

      bool success;
      if (widget.project == null) {
        // Create new
        final projectId = await _firebaseService.createProject(project);
        success = projectId != null;
      } else {
        // Update existing
        success = await _firebaseService.updateProject(
          widget.project!.id,
          project,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project saved successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to save project');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteProject() async {
    if (widget.project == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);

      final success = await _firebaseService.deleteProject(widget.project!.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted successfully!')),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error deleting project')));
        setState(() => _isSaving = false);
      }
    }
  }
}
