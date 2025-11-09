import 'package:disknova_project/utilis/responsive_utilis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({Key? key}) : super(key: key);

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }
  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 250, // You can adjust thumbnail size
        quality: 80,
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint('Thumbnail error: $e');
      return null;
    }
  }
  void _copyVideoLink(String videoUrl) async {
    // Tumhara public share page URL

    await Clipboard.setData(ClipboardData(text: videoUrl));

    _showSuccess('Link copied to clipboard!');

    // Optional: Share both copy + share
    // Share.share(shareableUrl, subject: 'Check out this video!');
  }
  Future<void> _loadVideos() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      final response = await Supabase.instance.client
          .from('videos')
          .select()
          .eq('user_id', userId ?? '')
          .order('created_at', ascending: false);

      setState(() {
        _videos = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading videos: ${e.toString()}');
    }
  }

  Future<void> _deleteVideo(String id, String videoUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete from storage
      final filePath = videoUrl.split('/videos/').last;
      await Supabase.instance.client.storage
          .from('videos')
          .remove([filePath]);

      // Delete from database
      await Supabase.instance.client
          .from('videos')
          .delete()
          .eq('id', id);

      _showSuccess('Video deleted successfully');
      _loadVideos();
    } catch (e) {
      _showError('Error deleting video: ${e.toString()}');
    }
  }

  void _shareVideo(String url) {
    Share.share(url, subject: 'Check out this video!');
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
          'File Manager',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        leading: Responsive.isMobile(context)
            ? IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
            onPressed: _loadVideos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
          ? _buildEmptyState()
          : _buildVideoList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No videos uploaded yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first video to get started',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildVideoCard(video).animate(delay: (index * 50).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final createdAt = DateTime.parse(video['created_at']);
    final formattedDate = DateFormat('MMM dd, yyyy hh:mm a').format(createdAt);
    final fileSize = (video['file_size'] as num?)?.toDouble() ?? 0;
    final fileSizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Responsive(
        mobile: _buildMobileCard(video, formattedDate, fileSizeMB),
        desktop: _buildDesktopCard(video, formattedDate, fileSizeMB),
      ),
    );
  }

  Widget _buildMobileCard(
      Map<String, dynamic> video,
      String formattedDate,
      String fileSizeMB,
      ) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final thumbnailUrl = video['thumbnail_url'] != null && video['thumbnail_url'].isNotEmpty
        ? Supabase.instance.client.storage
        .from('thumbnails')
        .getPublicUrl(video['thumbnail_url'])
        : null;

    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            image: thumbnailUrl != null
                ? DecorationImage(
              image: NetworkImage(thumbnailUrl),
              fit: BoxFit.cover,
            )
                : null,
            color: const Color(0xFF2563EB).withOpacity(0.1),
          ),
          child: thumbnailUrl == null
              ? const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Color(0xFF2563EB),
            ),
          )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video['title'] ?? 'Untitled',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video['description'] ?? '',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.visibility_outlined, '${video['views'] ?? 0}'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.storage_outlined, '$fileSizeMB MB'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareVideo(video['video_url']),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteVideo(
                        video['id'].toString(),
                        video['video_url'],
                      ),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildDesktopCard(
      Map<String, dynamic> video,
      String formattedDate,
      String fileSizeMB,
      ) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final thumbnailUrl = video['thumbnail_url'] != null && video['thumbnail_url'].isNotEmpty
        ? Supabase.instance.client.storage
        .from('thumbnails')
        .getPublicUrl(video['thumbnail_url'])
        : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF2563EB).withOpacity(0.1),
              image: thumbnailUrl != null
                  ? DecorationImage(
                image: NetworkImage(thumbnailUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: thumbnailUrl == null
                ? const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Color(0xFF2563EB),
              ),
            )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title'] ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video['description'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.visibility_outlined, '${video['views'] ?? 0} views'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.storage_outlined, '$fileSizeMB MB'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.calendar_today_outlined, formattedDate),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              IconButton(
                onPressed: () => _shareVideo(video['video_url']),
                icon: const Icon(Icons.share),
                color: const Color(0xFF2563EB),
                tooltip: 'Share',
              ),
              IconButton(
                onPressed: () => _copyVideoLink(video['video_url']),
                icon: const Icon(Icons.copy_all),
                color: Colors.green,
                tooltip: 'Copy Link',
              ),
              IconButton(
                onPressed: () => _deleteVideo(
                  video['id'].toString(),
                  video['video_url'],
                ),
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}