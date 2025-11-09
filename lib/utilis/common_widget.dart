import 'package:disknova_project/utilis/responsive_utilis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isMobile(context) ? double.infinity : 280,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  index: 0,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.video_library_outlined,
                  title: 'Video Uploads',
                  index: 1,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.folder_outlined,
                  title: 'File Manager',
                  index: 2,
                ), _buildMenuItem(
                  context,
                  icon: Icons.branding_watermark,
                  title: 'Branding',
                  index: 3,
                ),_buildMenuItem(
                  context,
                  icon: Icons.verified_outlined,
                  title: 'Verification',
                  index: 4,
                ),_buildMenuItem(
                  context,
                  icon: Icons.home_repair_service,
                  title: 'Billing',
                  index: 5,
                ),_buildMenuItem(
                  context,
                  icon: Icons.security,
                  title: 'Security',
                  index: 6,
                ),
              ],
            ),
          ),
          // _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.05),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'DiskNova',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required int index,
      }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
