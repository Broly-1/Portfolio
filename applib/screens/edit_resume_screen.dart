import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditResumeScreen extends StatefulWidget {
  const EditResumeScreen({super.key});

  @override
  State<EditResumeScreen> createState() => _EditResumeScreenState();
}

class _EditResumeScreenState extends State<EditResumeScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isUploading = false;
  String? _currentResumeUrl;
  String? _currentResumeFileName;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentResume();
  }

  Future<void> _loadCurrentResume() async {
    setState(() => _isLoading = true);
    try {
      final doc = await _firestore.collection('resume').doc('main').get();
      if (doc.exists && mounted) {
        setState(() {
          _currentResumeUrl = doc.data()?['url'] as String?;
          _currentResumeFileName = doc.data()?['fileName'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading resume: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadResume() async {
    try {
      // Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileName = file.name;
      final fileBytes = file.bytes;

      if (fileBytes == null) {
        throw Exception('Could not read file data');
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child('resume/$fileName');
      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();

      // Save to Firestore
      await _firestore.collection('resume').doc('main').set({
        'url': downloadUrl,
        'fileName': fileName,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _currentResumeUrl = downloadUrl;
          _currentResumeFileName = fileName;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteResume() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text(
          'Are you sure you want to delete the current resume?',
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

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);

      // Delete from Storage
      if (_currentResumeFileName != null) {
        await _storage.ref().child('resume/$_currentResumeFileName').delete();
      }

      // Delete from Firestore
      await _firestore.collection('resume').doc('main').delete();

      if (mounted) {
        setState(() {
          _currentResumeUrl = null;
          _currentResumeFileName = null;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Resume'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current Resume Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 32,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Current Resume',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_currentResumeUrl != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _currentResumeFileName ??
                                                  'resume.pdf',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Click to preview',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.open_in_new),
                                        tooltip: 'Preview',
                                        onPressed: () {
                                          // Open in new tab/window
                                          // For web, use url_launcher
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Delete',
                                        color: Colors.red,
                                        onPressed: _deleteResume,
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[700]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No resume uploaded',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Upload Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upload New Resume',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Only PDF files are supported',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_isUploading) ...[
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_uploadProgress * 100).toStringAsFixed(0)}% uploaded',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _pickAndUploadResume,
                                    icon: const Icon(Icons.upload_file),
                                    label: Text(
                                      _currentResumeUrl != null
                                          ? 'Replace Resume'
                                          : 'Upload Resume',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instructions
                      Card(
                        color: Colors.blue.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[300],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInstruction(
                                'Upload your resume in PDF format',
                              ),
                              _buildInstruction(
                                'Visitors can download it by clicking the Resume button',
                              ),
                              _buildInstruction(
                                'You can replace or delete the resume anytime',
                              ),
                              _buildInstruction(
                                'The resume will be stored securely in Firebase',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.check_circle, size: 16, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
