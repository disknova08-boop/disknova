import 'dart:async';
import 'dart:typed_data';

import 'package:disknova_project/utilis/responsive_utilis.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoUploadsScreen extends StatefulWidget {
  const VideoUploadsScreen({Key? key}) : super(key: key);

  @override
  State<VideoUploadsScreen> createState() => _VideoUploadsScreenState();
}

class _VideoUploadsScreenState extends State<VideoUploadsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      _showError('Error picking file: ${e.toString()}');
    }
  }

  // Future<void> _uploadVideo() async {
  //   if (!_formKey.currentState!.validate() || _selectedFile == null) {
  //     _showError('Please fill all fields and select a video');
  //     return;
  //   }
  //
  //   setState(() {
  //     _isUploading = true;
  //     _uploadProgress = 0;
  //   });
  //
  //   try {
  //     final userId = Supabase.instance.client.auth.currentUser?.id;
  //     if (userId == null) throw Exception('User not authenticated');
  //
  //     final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';
  //
  //     // Upload video file to storage
  //     await Supabase.instance.client.storage
  //         .from('videos')
  //         .uploadBinary(
  //       'uploads/$userId/$fileName',
  //       _selectedFile!.bytes!,
  //     );
  //
  //     // Get public URL
  //     final videoUrl = Supabase.instance.client.storage
  //         .from('videos')
  //         .getPublicUrl('uploads/$userId/$fileName');
  //
  //     // Save video metadata to database
  //     await Supabase.instance.client.from('videos').insert({
  //       'user_id': userId,
  //       'title': _titleController.text.trim(),
  //       'description': _descriptionController.text.trim(),
  //       'video_url': videoUrl,
  //       'file_name': _selectedFile!.name,
  //       'file_size': _selectedFile!.size,
  //       'views': 0,
  //       'earnings': 0,
  //       'created_at': DateTime.now().toIso8601String(),
  //     });
  //
  //     _showSuccess('Video uploaded successfully!');
  //     _resetForm();
  //   } catch (e) {
  //     print('Upload failed: ${e.toString()}');
  //     _showError('Upload failed: ${e.toString()}');
  //   } finally {
  //     setState(() {
  //       _isUploading = false;
  //       _uploadProgress = 0;
  //     });
  //   }
  // }
  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      _showError('Please fill all fields and select a video');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';

      // 🔹 Upload video file
      await Supabase.instance.client.storage
          .from('videos')
          .uploadBinary('uploads/$userId/$fileName', _selectedFile!.bytes!);

      final videoUrl = Supabase.instance.client.storage
          .from('videos')
          .getPublicUrl('uploads/$userId/$fileName');

      String? thumbnailUrl;

      // 🔹 Generate and upload thumbnail (web)
      if (kIsWeb) {
        // final file = html.File(_selectedFile!.bytes!, _selectedFile!.name);

        // final thumbnailBytes = await generateThumbnailWeb(file);
        //
        // if (thumbnailBytes != null) {
        //   final thumbFileName = 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.png';
        //   await Supabase.instance.client.storage
        //       .from('thumbnails')
        //       .uploadBinary('uploads/$userId/$thumbFileName', thumbnailBytes);
        //
        //    // thumbnailUrl = Supabase.instance.client.storage
        //    //    .from('thumbnails')
        //    //    .getPublicUrl('uploads/$userId/$thumbFileName');
        // }
      }

      // 🔹 Insert record in database
      await Supabase.instance.client.from('videos').insert({
        'user_id': userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl ?? '',
        'file_name': _selectedFile!.name,
        'file_size': _selectedFile!.size,
        'views': 0,
        'earnings': 0,
      });

      _showSuccess('Video uploaded successfully!');
      _resetForm();
    } catch (e) {
      print(e);
      _showError('Upload failed: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Video Uploads',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        leading: Responsive.isMobile(context)
            ? IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUploadArea(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Video Title',
                    hint: 'Enter video title',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter video description',
                    icon: Icons.description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  if (_isUploading) ...[
                    LinearProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 16),
                  ],
                  _buildUploadButton(),
                ],
              ).animate().fadeIn(duration: 600.ms),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _isUploading ? null : _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedFileName != null
                    ? Icons.check_circle
                    : Icons.cloud_upload,
                size: 48,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFileName ?? 'Click to select video',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFileName != null
                  ? 'File selected: ${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                  : 'Supports MP4, AVI, MOV, WMV',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _uploadVideo,
        icon: _isUploading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : const Icon(Icons.upload),
        label: Text(_isUploading ? 'Uploading...' : 'Upload Video'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}