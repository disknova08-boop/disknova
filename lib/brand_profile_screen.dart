import 'package:disknova_project/sign_up_login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BrandProfileScreen extends StatefulWidget {
  const BrandProfileScreen({Key? key}) : super(key: key);

  @override
  State<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends State<BrandProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _telegramController = TextEditingController();
  final _googleController = TextEditingController();
  final _twitterController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _allowVideoDownload = true;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('publishers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _profileId = response['id'];
          _firstNameController.text = response['first_name'] ?? '';
          _lastNameController.text = response['last_name'] ?? '';
          _brandNameController.text = response['brand_name'] ?? '';
          _emailController.text = response['email'] ?? '';
          _allowVideoDownload = response['allow_video_download'] ?? true;
          _whatsappController.text = response['whatsapp_number'] ?? '';
          _facebookController.text = response['facebook_url'] ?? '';
          _instagramController.text = response['instagram_url'] ?? '';
          _telegramController.text = response['telegram_url'] ?? '';
          _googleController.text = response['google_url'] ?? '';
          _twitterController.text = response['twitter_url'] ?? '';
          _websiteController.text = response['website_url'] ?? '';
        });
      }
    } catch (e) {
      _showSnackBar('Error loading profile: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'brand_name': _brandNameController.text.trim(),
        'email': _emailController.text.trim(),
        'allow_video_download': _allowVideoDownload,
        'whatsapp_number': _whatsappController.text.trim(),
        'facebook_url': _facebookController.text.trim(),
        'instagram_url': _instagramController.text.trim(),
        'telegram_url': _telegramController.text.trim(),
        'google_url': _googleController.text.trim(),
        'twitter_url': _twitterController.text.trim(),
        'website_url': _websiteController.text.trim(),
      };

      if (_profileId == null) {
        // Insert new profile
        data['user_id'] = userId;
        final response = await _supabase
            .from('publishers')
            .insert(data)
            .select()
            .single();
        setState(() => _profileId = response['id']);
      } else {
        // Update existing profile
        await _supabase
            .from('publishers')
            .update(data)
            .eq('id', _profileId!);
      }

      _showSnackBar('Profile saved successfully!');
    } catch (e) {
      _showSnackBar('Error saving profile: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _brandNameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _telegramController.dispose();
    _googleController.dispose();
    _twitterController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,

        // title: const Text('Brand Details'),
        backgroundColor: Colors.white,
        // foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () async {
                await _supabase.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return AuthCheck();
                  },));
                }
              },
              style: OutlinedButton.styleFrom(
                side:  BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),

          // GestureDetector(
          //   onTap: () async {
          //     await _supabase.auth.signOut();
          //     if (context.mounted) {
          //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          //         return AuthCheck();
          //       },));
          //     }
          //   },
          //   child: Container(
          //     margin: EdgeInsets.only(right: 20),
          //     padding: EdgeInsets.all(5),
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: Colors.grey,
          //         width: 0.8
          //       ),
          //       borderRadius: BorderRadius.circular(8)
          //     ),
          //     child: Text('Logout',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),
          //   ),
          // ),
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () async {
          //     await _supabase.auth.signOut();
          //     if (context.mounted) {
          //       Navigator.of(context).pushReplacementNamed('/login');
          //     }
          //   },
          // ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 32 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Brand Details',
                        subtitle:
                        'Your Brand Name and Social Links will be visible to your users with the link details.',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _brandNameController,
                                  label: 'Brand Name',
                                  hint: 'linkwala hai',
                                ),
                              ),
                              if (isTablet) const SizedBox(width: 16),
                              if (isTablet)
                                Expanded(
                                  child: _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'dev2desk01@gmail.com',
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                            ],
                          ),
                          if (!isTablet) const SizedBox(height: 16),
                          if (!isTablet)
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'dev2desk01@gmail.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'App Controls',
                        subtitle: 'Turn On or Off App features for your links.',
                        children: [
                          _buildCheckboxTile(
                            title: 'Allow Video Download in App.',
                            value: _allowVideoDownload,
                            onChanged: (value) {
                              setState(() => _allowVideoDownload = value!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'Social Links',
                        subtitle:
                        'You can use these links with a video where if your logo and video title is clicked, user will be redirected to the social link you attach, to maximize your reach.',
                        children: [
                          _buildSocialField(
                            controller: _whatsappController,
                            icon: Icons.message,
                            iconColor: Colors.green,
                            hint: '8780174397',
                          ),
                          const SizedBox(height: 16),
                          _buildSocialField(
                            controller: _facebookController,
                            icon: Icons.facebook,
                            iconColor: Colors.blue,
                            hint: 'Facebook URL',
                          ),
                          const SizedBox(height: 16),
                          _buildSocialField(
                            controller: _instagramController,
                            icon: Icons.camera_alt,
                            iconColor: Colors.pink,
                            hint: 'Instagram URL',
                          ),
                          const SizedBox(height: 16),
                          _buildSocialField(
                            controller: _telegramController,
                            icon: Icons.send,
                            iconColor: Colors.blue[700]!,
                            hint: 't.me/savitabhabijikk',
                          ),
                          const SizedBox(height: 16),
                          _buildSocialField(
                            controller: _googleController,
                            icon: Icons.g_mobiledata,
                            iconColor: Colors.red,
                            hint: 'Google URL',
                          ),
                          const SizedBox(height: 16),
                          _buildSocialField(
                            controller: _twitterController,
                            icon: Icons.flutter_dash,
                            iconColor: Colors.blue[400]!,
                            hint: 'Twitter URL',
                          ),
                          const SizedBox(height: 16),
                          _buildSocialField(
                            controller: _websiteController,
                            icon: Icons.language,
                            iconColor: Colors.blue[900]!,
                            hint: 'Website URL',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(
                          width: isTablet ? 200 : double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? const Color(0xFF2563EB) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}