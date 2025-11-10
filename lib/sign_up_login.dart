// import 'package:disknova_project/utilis/responsive_utilis.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import 'dashboard.dart';
// import 'demo.dart';
//
// class AuthCheck extends StatelessWidget {
//   const AuthCheck({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<AuthState>(
//       stream: Supabase.instance.client.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         if (snapshot.hasData && snapshot.data?.session != null) {
//           return const DashboardScreen();
//         }
//         return const AuthScreen();
//       },
//     );
//   }
// }
//
// // screens/auth_screen.dart
//
//
// class AuthScreen extends StatefulWidget {
//   const AuthScreen({Key? key}) : super(key: key);
//
//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
//   bool _isLogin = true;
//   bool _isLoading = false;
//   late AnimationController _animationController;
//
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _brandNameController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _brandNameController.dispose();
//     super.dispose();
//   }
//
//   void _toggleAuthMode() {
//     setState(() {
//       _isLogin = !_isLogin;
//     });
//     if (_isLogin) {
//       _animationController.reverse();
//     } else {
//       _animationController.forward();
//     }
//   }
//
//   Future<void> _submitAuth() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final supabase = Supabase.instance.client;
//
//       if (_isLogin) {
//         await supabase.auth.signInWithPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );
//       } else {
//         final response = await supabase.auth.signUp(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );
//
//         if (response.user != null) {
//           await supabase.from('publishers').insert({
//             'user_id': response.user!.id,
//             'first_name': _firstNameController.text.trim(),
//             'last_name': _lastNameController.text.trim(),
//             'brand_name': _brandNameController.text.trim(),
//             'email': _emailController.text.trim(),
//             'created_at': DateTime.now().toIso8601String(),
//           });
//         }
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(_isLogin ? 'Login successful!' : 'Account created successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } on AuthException catch (e) {
//       if (mounted) {
//         print(e.message);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.message), backgroundColor: Colors.red),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         print('Error: ${e.toString()}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFF2563EB).withOpacity(0.1),
//               const Color(0xFF3B82F6).withOpacity(0.05),
//             ],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Responsive(
//               mobile: _buildAuthCard(context, 0.9),
//               tablet: _buildAuthCard(context, 0.7),
//               desktop: _buildAuthCard(context, 0.5),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAuthCard(BuildContext context, double widthFactor) {
//     return Container(
//       width: MediaQuery.of(context).size.width * widthFactor,
//       constraints: const BoxConstraints(maxWidth: 500),
//       margin: EdgeInsets.symmetric(
//         horizontal: Responsive.isMobile(context) ? 16 : 32,
//         vertical: Responsive.isMobile(context) ? 20 : 40,
//       ),
//       padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 40),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 30,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(),
//           SizedBox(height: Responsive.isMobile(context) ? 16 : 24),
//           _buildWelcomeText(),
//           SizedBox(height: Responsive.isMobile(context) ? 24 : 32),
//           _buildForm(),
//           SizedBox(height: Responsive.isMobile(context) ? 20 : 24),
//           _buildSubmitButton(),
//           SizedBox(height: Responsive.isMobile(context) ? 16 : 20),
//           _buildToggleButton(),
//         ],
//       ),
//     ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
//   }
//
//   Widget _buildLogo() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2563EB).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(
//             Icons.cloud_upload_rounded,
//             color: Color(0xFF2563EB),
//             size: 32,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           'DiskNova',
//           style: TextStyle(
//             fontSize: Responsive.isMobile(context) ? 28 : 32,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF1E293B),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWelcomeText() {
//     return Column(
//       children: [
//         Text(
//           _isLogin ? 'Welcome Back' : 'Join Our Family',
//           style: TextStyle(
//             fontSize: Responsive.isMobile(context) ? 24 : 28,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF1E293B),
//           ),
//         ).animate().fadeIn(delay: 200.ms),
//         const SizedBox(height: 8),
//         Text(
//           _isLogin
//               ? 'Login to access your dashboard'
//               : 'Create your publisher account',
//           style: TextStyle(
//             fontSize: Responsive.isMobile(context) ? 14 : 16,
//             color: const Color(0xFF64748B),
//           ),
//         ).animate().fadeIn(delay: 300.ms),
//       ],
//     );
//   }
//
//   Widget _buildForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           if (!_isLogin) ...[
//             _buildTextField(
//               controller: _firstNameController,
//               label: 'First Name',
//               icon: Icons.person_outline,
//               validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//             ),
//             SizedBox(height: Responsive.isMobile(context) ? 12 : 16),
//             _buildTextField(
//               controller: _lastNameController,
//               label: 'Last Name',
//               icon: Icons.person_outline,
//               validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//             ),
//             SizedBox(height: Responsive.isMobile(context) ? 12 : 16),
//             _buildTextField(
//               controller: _brandNameController,
//               label: 'Brand Name',
//               icon: Icons.branding_watermark,
//               validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//             ),
//             SizedBox(height: Responsive.isMobile(context) ? 12 : 16),
//           ],
//           _buildTextField(
//             controller: _emailController,
//             label: 'Email',
//             icon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             validator: (v) {
//               if (v?.isEmpty ?? true) return 'Required';
//               if (!v!.contains('@')) return 'Invalid email';
//               return null;
//             },
//           ),
//           SizedBox(height: Responsive.isMobile(context) ? 12 : 16),
//           _buildTextField(
//             controller: _passwordController,
//             label: 'Password',
//             icon: Icons.lock_outline,
//             obscureText: true,
//             validator: (v) {
//               if (v?.isEmpty ?? true) return 'Required';
//               if (v!.length < 6) return 'Min 6 characters';
//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
//         ),
//         filled: true,
//         fillColor: const Color(0xFFF8FAFC),
//       ),
//     ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0);
//   }
//
//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: Responsive.isMobile(context) ? 50 : 56,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _submitAuth,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2563EB),
//           foregroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation(Colors.white),
//           ),
//         )
//             : Text(
//           _isLogin ? 'Login' : 'Create Account',
//           style: TextStyle(
//             fontSize: Responsive.isMobile(context) ? 16 : 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms);
//   }
//
//   Widget _buildToggleButton() {
//     return TextButton(
//       onPressed: _toggleAuthMode,
//       child: RichText(
//         text: TextSpan(
//           text: _isLogin
//               ? "Don't have an account? "
//               : 'Already have an account? ',
//           style: const TextStyle(color: Color(0xFF64748B)),
//           children: [
//             TextSpan(
//               text: _isLogin ? 'Sign Up' : 'Login',
//               style: const TextStyle(
//                 color: Color(0xFF2563EB),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 600.ms);
//   }
// }
// landing_page.dart
import 'package:disknova_project/utilis/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:disknova_project/utilis/responsive_utilis.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dashboard.dart';
import 'main.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String _selectedCategory='Fast Uploading';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Horizontal scrollable chips
        SizedBox(
          height: 50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCategoryChip('Fast Uploading'),
                      _buildCategoryChip('Unlimited Cloud Storage'),
                      _buildCategoryChip('Easy Sharing'),
                      _buildCategoryChip('Lightning-Fast Video Playback'),
                      _buildCategoryChip('User Data Safety'),
                      _buildCategoryChip('User-Friendly Ads Placement'),
                    ],
                  ),
                ),
              );
            },
          ),
        )
,
        const SizedBox(height: 24),

        // 🔹 Dynamic content area (based on selected chip)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildCategoryContent(isMobile),
        ),
      ],
    );
  }

  /// -------------------------------
  /// CATEGORY CHIP BUILDER
  /// -------------------------------
  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------------
  /// CATEGORY CONTENT BUILDER
  /// -------------------------------
  Widget _buildCategoryContent(bool isMobile) {
    final Map<String, Map<String, dynamic>> content = {
      'Fast Uploading': {
        'icon': Icons.upload,
        'title': 'Fast Uploading',
        'description':
        'Say goodbye to waiting times with DiskNova\'s lightning-fast uploading feature. Upload your files swiftly and efficiently, saving you time and hassle.',
      },
      'Unlimited Cloud Storage': {
        'icon': Icons.cloud,
        'title': 'Unlimited Cloud Storage',
        'description':
        'Never worry about running out of space again. DiskNova offers unlimited cloud storage, providing you with ample room to store all your important files, memories, and projects without constraints.',
      },
      'Easy Sharing': {
        'icon': Icons.share,
        'title': 'Easy Sharing',
        'description':
        'Sharing files has never been easier. DiskNova simplifies the sharing process, allowing you to effortlessly collaborate with colleagues, friends, and family members. Share documents, photos, and videos with just a few clicks.',
      },
      'Lightning-Fast Video Playback': {
        'icon': Icons.play_circle,
        'title': 'Lightning-Fast Video Playback',
        'description':
        'Enjoy seamless and uninterrupted video playback with DiskNova\'s lightning-fast streaming capabilities. Experience smooth viewing of your favorite videos without any lag or buffering.',
      },
      'User Data Safety': {
        'icon': Icons.security,
        'title': 'User Data Safety',
        'description':
        'Your privacy and security matter. With DiskNova, rest assured that your data is safe and secure. Utilizing advanced encryption and robust security measures, DiskNova ensures that your personal information remains protected.',
      },
      'User-Friendly Ads Placement': {
        'icon': Icons.ads_click,
        'title': 'User-Friendly Ads Placement',
        'description':
        'DiskNova ensures that advertisements are seamlessly integrated into the user experience, prioritizing relevance and non-intrusiveness. With carefully placed ads that enhance rather than disrupt user interaction.',
      },
    };

    // ✅ Handle when no chip is selected yet
    if (_selectedCategory == null ||
        !content.containsKey(_selectedCategory)) {
      return const SizedBox.shrink();
    }

    final currentContent = content[_selectedCategory]!;

    return Container(
      key: ValueKey(_selectedCategory), // for AnimatedSwitcher transitions
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: isMobile
          ? Column(
        children: [
          Icon(
            currentContent['icon'],
            color: const Color(0xFF2563EB),
            size: 48,
          ),
          const SizedBox(height: 24),
          Text(
            currentContent['title'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            currentContent['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  currentContent['icon'],
                  color: const Color(0xFF2563EB),
                  size: 48,
                ),
                const SizedBox(height: 24),
                Text(
                  currentContent['title'],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentContent['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[300],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Container(
            width: 350,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                currentContent['icon'],
                size: 100,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}


class LandingPage extends StatefulWidget {
  final VoidCallback onJoinUs;
  final VoidCallback onLogin;

  const LandingPage({Key? key, required this.onJoinUs, required this.onLogin})
      : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _highlightsKey = GlobalKey();
  final GlobalKey _whyDiskNovaKey = GlobalKey();
  final GlobalKey _publisherRatesKey = GlobalKey();
  final GlobalKey _paymentProofsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  String _selectedCategory = 'Fast Uploading';

  final String introVideoId = 'dQw4w9WgXcQ';
  final String referralVideoId = 'dQw4w9WgXcQ';

  final String youtubeChannelUrl = 'https://youtube.com/@disknova';
  final String telegramChannelUrl = 'https://t.me/disknova';
  final String telegramSupportUrl = 'https://t.me/disknova_support';
  final String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.disknova.app';
  final String appStoreUrl = 'https://apps.apple.com/app/disknova/id123456789';
  final String privacyPolicyUrl = 'https://disknova.com/privacy';
  final String termsOfServiceUrl = 'https://disknova.com/terms';
  final String dmcaUrl = 'https://disknova.com/dmca';
  final String contactUsUrl = 'https://disknova.com/contact';
  late YoutubePlayerController _introController;
  late YoutubePlayerController _referralController;

  @override
  void initState() {
    super.initState();
    _introController = YoutubePlayerController.fromVideoId(
      videoId: introVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
    _referralController = YoutubePlayerController.fromVideoId(
      videoId: referralVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    _introController.stopVideo();
    _referralController.stopVideo();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(isMobile),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(isMobile),
                _buildFeatures(isMobile),
                _buildHighlights(isMobile),
                _buildWhyDiskNova(isMobile),
                _buildPublisherRates(isMobile),
                _buildPaymentProofs(isMobile),
                _buildFAQ(isMobile),
                _buildFooter(isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2563EB).withOpacity(0.8),
                  const Color(0xFF3B82F6).withOpacity(0.6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storage_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DiskNova',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Digital Storage Solution',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', () => _scrollToSection(_homeKey)),
          _buildDrawerItem(Icons.featured_play_list, 'Features',
                  () => _scrollToSection(_featuresKey)),
          _buildDrawerItem(Icons.highlight, 'Highlights',
                  () => _scrollToSection(_highlightsKey)),
          _buildDrawerItem(Icons.star, 'Why DiskNova',
                  () => _scrollToSection(_whyDiskNovaKey)),
          _buildDrawerItem(Icons.attach_money, 'Publisher Rates',
                  () => _scrollToSection(_publisherRatesKey)),
          _buildDrawerItem(Icons.payment, 'Payment Proofs',
                  () => _scrollToSection(_paymentProofsKey)),
          _buildDrawerItem(Icons.help, 'FAQ', () => _scrollToSection(_faqKey)),
          _buildDrawerItem(
              Icons.contact_mail, 'Contact Us', () => _launchURL(contactUsUrl)),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child:  Text('Log In',style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onJoinUs();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child:  Text('Join Us',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2563EB)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      floating: true,
      pinned: true,
      expandedHeight: isMobile ? 60 : 70,
      leading: isMobile
          ? IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      )
          : null,
      automaticallyImplyLeading: isMobile,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20, vertical: 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _scrollToSection(_homeKey),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: isMobile?30:0),
                      Text(
                        'DiskNova',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _scrollToSection(_homeKey),
                            child: const Text('Home',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () => _scrollToSection(_featuresKey),
                            child: const Text('Features',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () => _scrollToSection(_highlightsKey),
                            child: const Text('Highlights',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () => _scrollToSection(_whyDiskNovaKey),
                            child: const Text('Why DiskNova',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () =>
                                _scrollToSection(_publisherRatesKey),
                            child: const Text('Rates',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () =>
                                _scrollToSection(_paymentProofsKey),
                            child: const Text('Payments',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () => _scrollToSection(_faqKey),
                            child: const Text('FAQ',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () => _launchURL(contactUsUrl),
                            child: const Text('Contact',
                                style: TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 16)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: widget.onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Log In'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: widget.onJoinUs,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Join Us'),
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

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      key: _homeKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Welcome to ',
            style: TextStyle(
              fontSize: isMobile ? 28 : 48,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Disk',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Nova',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: isMobile ? 12 : 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 50),
            child: Text(
              'DiskNova: Revolutionize Your Digital Storage and File Sharing.',
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          SizedBox(height: isMobile ? 20 : 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
            child: Text(
              'Welcome to DiskNova, the ultimate cloud storage and file-sharing service designed to cater to your every digital need. In the era where data is king, DiskNova stands out as a beacon of reliability, security, and innovation, offering users a seamless experience for storing, accessing, and sharing their digital content.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          SizedBox(height: isMobile ? 32 : 48),
          ElevatedButton.icon(
            onPressed: widget.onJoinUs,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: Text(
              isMobile ? 'Start Uploading' : 'Start Uploading (For Publishers)',
              style: TextStyle(fontSize: isMobile ? 14 : 18),
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 32,
                vertical: isMobile ? 16 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _launchURL(termsOfServiceUrl),
              child: Text(
                'By clicking "Start Uploading" you agree to our Terms & Conditions.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildStoreButton(
                'Google Play',
                Icons.android,
                Colors.black,
                playStoreUrl,
              ),
              _buildStoreButton(
                'App Store',
                Icons.apple,
                Colors.black,
                appStoreUrl,
              ),
            ],
          ).animate().fadeIn(delay: 800.ms),
          SizedBox(height: isMobile ? 24 : 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialIcon(
                Icons.videocam,
                'YouTube',
                Colors.red,
                youtubeChannelUrl,
              ),
              _buildSocialIcon(
                Icons.telegram,
                'Telegram',
                const Color(0xFF2563EB),
                telegramChannelUrl,
              ),
              _buildSocialIcon(
                Icons.support_agent,
                'Support',
                const Color(0xFF16A34A),
                telegramSupportUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton(
      String label,
      IconData icon,
      Color color,
      String url,
      ) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GET IT ON',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
      IconData icon,
      String label,
      Color color,
      String url,
      ) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFeatures(bool isMobile) {
    return Container(
      key: _featuresKey,
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      child: Column(
        children: [
          Text(
            'Products & Features',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
            child: Text(
              'Our platform seamlessly integrates three points of contact – a web dashboard, a mobile app, and a Telegram bot – to provide users with unparalleled flexibility and convenience in managing their files.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 64),
          if (isMobile)
            Column(
              children: [
                _buildFeatureCard(
                  'Dashboard (For Publishers)',
                  'The Dashboard offers users a centralized platform to effortlessly upload files, manage branding elements, and oversee account settings. With intuitive controls and seamless navigation, users can efficiently organize their files and tailor branding to suit their preferences.',
                  Icons.dashboard,
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  'Mobile App (For Consumers)',
                  'Accessible on the go, the mobile app empowers users to access their uploaded files conveniently from their handheld devices. Offering a user-friendly interface, it ensures swift file retrieval and seamless navigation.',
                  Icons.phone_android,
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  'Telegram Channel',
                  'Our Telegram channel! Here, you\'ll discover everything you need to know about link converter bots and get access to our support channel for any assistance you may require.',
                  Icons.telegram,
                  isMobile,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildFeatureCard(
                        'Dashboard (For Publishers)',
                        'The Dashboard offers users a centralized platform to effortlessly upload files, manage branding elements, and oversee account settings. With intuitive controls and seamless navigation, users can efficiently organize their files and tailor branding to suit their preferences.',
                        Icons.dashboard,
                        isMobile,
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        'Mobile App (For Consumers)',
                        'Accessible on the go, the mobile app empowers users to access their uploaded files conveniently from their handheld devices. Offering a user-friendly interface, it ensures swift file retrieval and seamless navigation.',
                        Icons.phone_android,
                        isMobile,
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        'Telegram Channel',
                        'Our Telegram channel! Here, you\'ll discover everything you need to know about link converter bots and get access to our support channel for any assistance you may require.',
                        Icons.telegram,
                        isMobile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
               if(!isMobile) Flexible(
                  child: Container(

                    height: isMobile?100:600,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2563EB).withOpacity(0.1),
                          const Color(0xFF3B82F6).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.devices,
                        size: 120,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildFeatureCard(
      String title,
      String description,
      IconData icon,
      bool isMobile,
      ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(bool isMobile) {
    return Container(
      key: _highlightsKey,
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: const BoxDecoration(color: Color(0xFF1E293B)),
      child: Column(
        children: [
          Text(
            'Highlights',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Explore why our product stands out: adaptability, durability, user-friendly design, and innovation.\nEnjoy reliable customer support and precision in every detail.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[300],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          CategoryChips(),
          // SizedBox(
          //   height: 50,
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: Row(
          //       children: [
          //         _buildCategoryChip('Fast Uploading'),
          //         _buildCategoryChip('Unlimited Cloud Storage'),
          //         _buildCategoryChip('Easy Sharing'),
          //         _buildCategoryChip('Lightning-Fast Video Playback'),
          //         _buildCategoryChip('User Data Safety'),
          //         _buildCategoryChip('User-Friendly Ads Placement'),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: isMobile ? 32 : 48),
          // _buildCategoryContent(isMobile),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ).animate(target: isSelected ? 1 : 0).scale(),
    );
  }

  Widget _buildCategoryContent(bool isMobile) {
    final Map<String, Map<String, dynamic>> content = {
      'Fast Uploading': {
        'icon': Icons.upload,
        'title': 'Fast Uploading',
        'description':
        'Say goodbye to waiting times with DiskNova\'s lightning-fast uploading feature. Upload your files swiftly and efficiently, saving you time and hassle.',
      },
      'Unlimited Cloud Storage': {
        'icon': Icons.cloud,
        'title': 'Unlimited Cloud Storage',
        'description':
        'Never worry about running out of space again. DiskNova offers unlimited cloud storage, providing you with ample room to store all your important files, memories, and projects without constraints.',
      },
      'Easy Sharing': {
        'icon': Icons.share,
        'title': 'Easy Sharing',
        'description':
        'Sharing files has never been easier. DiskNova simplifies the sharing process, allowing you to effortlessly collaborate with colleagues, friends, and family members. Share documents, photos, and videos with just a few clicks.',
      },
      'Lightning-Fast Video Playback': {
        'icon': Icons.play_circle,
        'title': 'Lightning-Fast Video Playback',
        'description':
        'Enjoy seamless and uninterrupted video playback with DiskNova\'s lightning-fast streaming capabilities. Experience smooth viewing of your favorite videos without any lag or buffering.',
      },
      'User Data Safety': {
        'icon': Icons.security,
        'title': 'User Data Safety',
        'description':
        'Your privacy and security matter. With DiskNova, rest assured that your data is safe and secure. Utilizing advanced encryption and robust security measures, DiskNova ensures that your personal information remains protected.',
      },
      'User-Friendly Ads Placement': {
        'icon': Icons.ads_click,
        'title': 'User-Friendly Ads Placement',
        'description':
        'DiskNova ensures that advertisements are seamlessly integrated into the user experience, prioritizing relevance and non-intrusiveness. With carefully placed ads that enhance rather than disrupt user interaction.',
      },
    };
    final currentContent = content[_selectedCategory]!;
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: isMobile
          ? Column(
        children: [
          Icon(
            currentContent['icon'],
            color: const Color(0xFF2563EB),
            size: 48,
          ),
          const SizedBox(height: 24),
          Text(
            currentContent['title'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            currentContent['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  currentContent['icon'],
                  color: const Color(0xFF2563EB),
                  size: 48,
                ),
                const SizedBox(height: 24),
                Text(
                  currentContent['title'],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentContent['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[300],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Container(
            width: 350,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                currentContent['icon'],
                size: 100,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildWhyDiskNova(bool isMobile) {
    return Container(
      key: _whyDiskNovaKey,
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Text(
            'Why DiskNova is Better?',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Explore why our product stands out: adaptability, durability, user-friendly design, and innovation.\nEnjoy reliable customer support and precision in every detail.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          if (isMobile)
            Column(
              children: [
                _buildVideoCard(
                  'Welcome to DiskNova',
                  _introController,
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildHighlightCard(
                  'Unlimited & Live View Count',
                  'A very unique and important feature we offer is Unlimited View Count for videos, with Live View Count updates on the dashboard. This ensures complete transparency, allowing creators to monitor real-time engagement. No other platform provides this level of openness and unlimited view counts and live view counts update feature.',
                  Icons.visibility,
                  isMobile,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildVideoCard(
                    'Welcome to DiskNova',
                    _introController,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildHighlightCard(
                    'Unlimited & Live View Count',
                    'A very unique and important feature we offer is Unlimited View Count for videos, with Live View Count updates on the dashboard. This ensures complete transparency, allowing creators to monitor real-time engagement. No other platform provides this level of openness and unlimited view counts and live view counts update feature.',
                    Icons.visibility,
                    isMobile,
                  ),
                ),
              ],
            ),
          SizedBox(height: isMobile ? 32 : 48),
          if (isMobile)
            Column(
              children: [
                _buildVideoCard(
                  'OG Referral Program',
                  _referralController,
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildHighlightCard(
                  'Original Uploader Referral',
                  'Original Uploader can earn 20% commission from referred publishers\' earnings. This means when you refer someone and they earn money, you automatically get 20% of their earnings credited to your account. It\'s a win-win situation that rewards you for growing our community.',
                  Icons.people,
                  isMobile,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildHighlightCard(
                    'Original Uploader Referral',
                    'Original Uploader can earn 20% commission from referred publishers\' earnings. This means when you refer someone and they earn money, you automatically get 20% of their earnings credited to your account. It\'s a win-win situation that rewards you for growing our community.',
                    Icons.people,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildVideoCard(
                    'OG Referral Program',
                    _referralController,
                    isMobile,
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildVideoCard(
      String title, YoutubePlayerController controller, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: controller,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
      String title,
      String description,
      IconData icon,
      bool isMobile,
      ) {
    return Container(
      // height: isMobile ? null : 350,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.1),
            const Color(0xFF16A34A).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublisherRates(bool isMobile) {
    return Container(
      key: _publisherRatesKey,
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Column(
        children: [
          Text(
            'Publisher Rates',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Monetize your video content by uploading and sharing them with your audience through DiskNova.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          if (isMobile)
            Column(
              children: [
                _buildRateCard('Publishers', [
                  'Unlimited Cloud Storage',
                  '\$2 per 1000+ views',
                  'Realtime View Count Update',
                  '\$10 Minimum Payment',
                  'Raise Withdrawal Anytime',
                  'Instant Payments',
                  'Dashboard File Upload',
                ], isMobile),
                const SizedBox(height: 24),
                _buildRateCard('Consumers', [
                  'Android App',
                  'iOS App',
                  'No SignUp/Login',
                  'Direct Link to App',
                  'Globally Fast Video Streaming',
                  'Advance Video Player',
                  'Premium Subscription Available',
                ], isMobile),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRateCard('Publishers', [
                    'Unlimited Cloud Storage',
                    '\$2 per 1000+ views',
                    'Realtime View Count Update',
                    '\$10 Minimum Payment',
                    'Raise Withdrawal Anytime',
                    'Instant Payments',
                    'Dashboard File Upload',
                  ], isMobile),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildRateCard('Consumers', [
                    'Android App',
                    'iOS App',
                    'No SignUp/Login',
                    'Direct Link to App',
                    'Globally Fast Video Streaming',
                    'Advance Video Player',
                    'Premium Subscription Available',
                  ], isMobile),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildRateCard(String title, List<String> features, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          ...features.map(
                (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF16A34A),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPaymentProofs(bool isMobile) {
    return Container(
      key: _paymentProofsKey,
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Text(
            'Our Payment Methods',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: isMobile ? 16 : 32,
            runSpacing: isMobile ? 16 : 32,
            alignment: WrapAlignment.center,
            children: [
              _buildPaymentMethodIcon(
                'PhonePe',
                Icons.phone_android,
                const Color(0xFF5F259F),
              ),
              _buildPaymentMethodIcon(
                'Google Pay',
                Icons.payment,
                const Color(0xFF4285F4),
              ),
              _buildPaymentMethodIcon(
                'UPI',
                Icons.account_balance,
                const Color(0xFF097939),
              ),
              _buildPaymentMethodIcon(
                'Bank Transfer',
                Icons.account_balance_wallet,
                const Color(0xFF2563EB),
              ),
              _buildPaymentMethodIcon(
                'SWIFT',
                Icons.public,
                const Color(0xFF16A34A),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF16A34A).withOpacity(0.1),
                  const Color(0xFF2563EB).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF16A34A).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instant Payments',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get paid instantly when you reach the minimum threshold of \$10. No waiting, no delays.',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildPaymentMethodIcon(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 40),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQ(bool isMobile) {
    final faqs = [
      {
        'question':
        'How do I contact customer support if I have a question or issue?',
        'answer':
        'You can reach our customer support team through multiple channels: via our Telegram support channel, through the Contact Us form on our website, or by emailing us directly. Our support team is available to assist you with any questions or concerns you may have.',
      },
      {
        'question': 'Information about telegram bot and its features?',
        'answer':
        'Our Telegram bot provides a convenient way to convert and share links. You can access file links, get instant notifications about your uploads, and manage your content directly through Telegram. Join our official Telegram channel to learn more about all available features and get support when needed.',
      },
      {
        'question': 'What about payments?',
        'answer':
        'Publishers earn \$2 per 1000+ views on their content. The minimum payment threshold is \$10, and you can raise a withdrawal request anytime. We offer instant payments through multiple methods including PhonePe, Google Pay, UPI, Bank Transfer, and SWIFT for international publishers.',
      },
      {
        'question': 'Can we upload files other than videos?',
        'answer':
        'Currently, DiskNova is optimized for video content to provide the best streaming experience for publishers and consumers. We focus on delivering high-quality video playback with features like real-time view counting and fast video streaming. This specialization ensures optimal performance and monetization for video creators.',
      },
    ];
    return Container(
      key: _faqKey,
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Column(
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          ...faqs.map(
                (faq) => _buildFAQItem(faq['question']!, faq['answer']!, isMobile),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildFAQItem(String question, String answer, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 8,
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                0,
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
              ),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: const BoxDecoration(color: Color(0xFF1E293B)),
      child: Column(
        children: [
          InkWell(
            onTap: () => _scrollToSection(_homeKey),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storage_rounded,
                    color: Color(0xFF2563EB),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'DiskNova',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'DiskNova: Revolutionize Your Digital Storage and File Sharing.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildStoreButton(
                'Google Play',
                Icons.android,
                Colors.black,
                playStoreUrl,
              ),
              _buildStoreButton(
                'App Store',
                Icons.apple,
                Colors.black,
                appStoreUrl,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterSocialIcon(
                Icons.videocam,
                'YouTube Channel',
                youtubeChannelUrl,
              ),
              _buildFooterSocialIcon(
                Icons.telegram,
                'Official Channel',
                telegramChannelUrl,
              ),
              _buildFooterSocialIcon(
                Icons.support_agent,
                'Telegram Support',
                telegramSupportUrl,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'DISKNOVA,\n30 N Gould St, STE R, Sheridan,\nWY, 82801, USA',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => _launchURL(privacyPolicyUrl),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const Text('•', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () => _launchURL(termsOfServiceUrl),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const Text('•', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () => _launchURL(dmcaUrl),
                child: const Text(
                  'DMCA',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '© 2024 DiskNova. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSocialIcon(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.session != null) {
          // Initialize global user when logged in
          userService.initUser();

          // Return your main screen (Dashboard, BrandDetailsScreen, etc.)
// Return Dashboard when logged in
          return const DashboardScreen();
        }
        return const AuthWrapper();
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showAuthScreen = false;
  bool _isSignUp = false;

  void _showLogin() {
    setState(() {
      _showAuthScreen = true;
      _isSignUp = false;
    });
  }

  void _showSignUp() {
    setState(() {
      _showAuthScreen = true;
      _isSignUp = true;
    });
  }

  void _showLanding() {
    setState(() {
      _showAuthScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showAuthScreen) {
      return LandingPage(onLogin: _showLogin, onJoinUs: _showSignUp);
    }
    return AuthScreen(
      isSignUp: _isSignUp,
      onBack: _showLanding,
      onToggleMode: () {
        setState(() {
          _isSignUp = !_isSignUp;
        });
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  final VoidCallback onBack;
  final VoidCallback onToggleMode;

  const AuthScreen({
    super.key,
    required this.isSignUp,
    required this.onBack,
    required this.onToggleMode,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  bool _obscurePassword = true; // Password hide/show toggle
  bool _showForgotPassword = false; // Forgot password view toggle
  final _forgotPasswordEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _brandNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isSignUp) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSignUp != widget.isSignUp) {
      if (widget.isSignUp) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  // @override
  // void dispose() {
  //   _animationController.dispose();
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   _firstNameController.dispose();
  //   _lastNameController.dispose();
  //   _brandNameController.dispose();
  //   super.dispose();
  // }
// ADD this small helper anywhere inside _AuthScreenState
  void _showSnack(String text, {bool success = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: success ? Colors.green : Colors.red),
    );
  }
  Future<void> _sendPasswordReset() async {
    if (_forgotPasswordEmailController.text.trim().isEmpty) {
      _showSnack('Please enter your email address', success: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _forgotPasswordEmailController.text.trim(),
        redirectTo: '$APP_URL/reset-password',
      );

      _showSnack('Password reset email sent! Check your inbox.', success: true);

      // Go back to login after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _showForgotPassword = false;
          _forgotPasswordEmailController.clear();
        });
      }
    } on AuthException catch (e) {
      _showSnack(e.message, success: false);
    } catch (e) {
      _showSnack('Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _ensurePublisherExists(User user) async {
    final supabase = Supabase.instance.client;

    // check if exists
    final existing = await supabase
        .from('publishers')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      // INSERT publisher (RLS: works only when user has a session)
      await supabase.from('publishers').insert({
        'user_id': user.id,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'brand_name': _brandNameController.text.trim(),
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
      });

      // OPTIONAL: brand_details — skip quietly if table not present
      try {
        await supabase.from('brand_details').insert({
          'user_id': user.id,
          'brand_name': _brandNameController.text.trim(),
          'email': user.email,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // ignore if table doesn't exist or RLS blocks — not critical
      }
    }
  }
  Future<bool> _isEmailRegistered(String email) async {
    final supabase = Supabase.instance.client;
    try {
      final res = await supabase.functions.invoke(
        'auth-check-email',
        body: {'email': email.trim()},
      );
      final data = res.data;
      print(data);
      if (data is Map && data['exists'] == true) return true;
      return false;
    } catch (e) {
      print(e);
      // अगर function call fail हो जाए, सुरक्षित fallback: signup पर ही error पकड़ लेंगे
      return false;
    }
  }
  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (!widget.isSignUp) {
        // -------------------- LOGIN --------------------
        try {
          final response = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.user != null) {
            userService.setUser(response.user!);
            await _ensurePublisherExists(response.user!);
            _showSnack('Login successful!', success: true);
          }
        } on AuthException catch (e) {
          final msg = e.message.toLowerCase();

          if (msg.contains('not confirmed') ||
              msg.contains('email not verified') ||
              msg.contains('confirm your email')) {
            _showSnack(
              'Your email is not verified. Please check your inbox for the verification link.',
              success: false,
            );
          } else if (msg.contains('invalid login credentials')) {
            _showSnack('Invalid email or password. Try again.', success: false);
          } else {
            _showSnack(e.message, success: false);
          }
        }
      } else {
        // -------------------- SIGNUP (pre-check first) --------------------
        final exists = await _isEmailRegistered(email);
        if (exists) {
          _showSnack('This email is already registered. Please log in.', success: false);
          if (mounted) widget.onToggleMode(); // switch to Login
          return;
        }

        // Not registered -> proceed to sign up
        try {
          final response = await supabase.auth.signUp(email: email, password: password,emailRedirectTo: '$APP_URL/confirm');

          if (response.user != null) {
            userService.setUser(response.user!);

            // Confirm email OFF -> session non-null -> insert now
            // Confirm email ON  -> session null     -> wait until user logs in
            if (response.session != null) {
              await _ensurePublisherExists(response.user!);
            }
          }

          _showSnack('Account created successfully!', success: true);
        } on AuthException catch (e) {
          // backup: in case function missed and auth throws already-registered
          final msg = e.message.toLowerCase();
          if (e.statusCode == 400 &&
              (msg.contains('registered') || msg.contains('already') || msg.contains('exists'))) {
            _showSnack('This email is already registered. Please log in.', success: false);
            if (mounted) widget.onToggleMode();
          } else {
            _showSnack(e.message, success: false);
          }
        }
      }
    } catch (e) {
      _showSnack('Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

// REPLACE your _submitAuth with this version

  // Future<void> _submitAuth() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final supabase = Supabase.instance.client;
  //
  //     if (!widget.isSignUp) {
  //       // LOGIN
  //       final response = await supabase.auth.signInWithPassword(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text,
  //       );
  //
  //       // IMPORTANT: Set global user after successful login
  //       if (response.user != null) {
  //         userService.setUser(response.user!);
  //       }
  //     } else {
  //       // SIGNUP
  //       final response = await supabase.auth.signUp(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text,
  //       );
  //
  //       if (response.user != null) {
  //         // IMPORTANT: Set global user after successful signup
  //         userService.setUser(response.user!);
  //
  //         // Insert into publishers table
  //         await supabase.from('publishers').insert({
  //           'user_id': response.user!.id,
  //           'first_name': _firstNameController.text.trim(),
  //           'last_name': _lastNameController.text.trim(),
  //           'brand_name': _brandNameController.text.trim(),
  //           'email': _emailController.text.trim(),
  //           'created_at': DateTime.now().toIso8601String(),
  //         });
  //
  //         // Also create initial brand_details record
  //         await supabase.from('brand_details').insert({
  //           'user_id': response.user!.id,
  //           'brand_name': _brandNameController.text.trim(),
  //           'email': _emailController.text.trim(),
  //           'created_at': DateTime.now().toIso8601String(),
  //         });
  //       }
  //     }
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             widget.isSignUp
  //                 ? 'Account created successfully!'
  //                 : 'Login successful!',
  //           ),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } on AuthException catch (e) {
  //     if (mounted) {
  //       print(e);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.message), backgroundColor: Colors.red),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       print(e.toString());
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2563EB).withOpacity(0.1),
              const Color(0xFF3B82F6).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 28,
                  color: const Color(0xFF2563EB),
                ),
              ),
              Center(
                child: SingleChildScrollView(child: _buildAuthCard(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: MediaQuery.of(context).size.width * (isMobile ? 0.9 : 0.5),
      constraints: const BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 20 : 40,
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          SizedBox(height: isMobile ? 16 : 24),
          _showForgotPassword ? _buildForgotPasswordView() : _buildLoginSignupView(),
        ],
      ),
    );
  }
  Widget _buildForgotPasswordView() {
    return Column(
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email to receive reset link',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _forgotPasswordEmailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v?.isEmpty ?? true) return 'Required';
            if (!v!.contains('@')) return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendPasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
                : const Text(
              'Send Verification Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _showForgotPassword = false;
              _forgotPasswordEmailController.clear();
            });
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

// Update _buildLoginSignupView (original content)
  Widget _buildLoginSignupView() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      children: [
        _buildWelcomeText(),
        SizedBox(height: isMobile ? 24 : 32),
        _buildForm(),

        // Forgot Password Link (only for login)
        if (!widget.isSignUp) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showForgotPassword = true;
                });
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: isMobile ? 20 : 24),
        _buildSubmitButton(),
        SizedBox(height: isMobile ? 16 : 20),
        _buildToggleButton(),
      ],
    );
  }

// Update password field with visibility toggle
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isPasswordField = obscureText;

    return TextFormField(
      controller: controller,
      obscureText: isPasswordField ? _obscurePassword : false,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        suffixIcon: isPasswordField
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF64748B),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.storage_rounded,
            color: Color(0xFF2563EB),
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'DiskNova',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          widget.isSignUp ? 'Join Our Family' : 'Welcome Back',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isSignUp
              ? 'Create your publisher account'
              : 'Login to access your dashboard',
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.isSignUp) ...[
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _brandNameController,
              label: 'Brand Name',
              icon: Icons.branding_watermark,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Required';
              if (!v!.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Required';
              if (v!.length < 6) return 'Min 6 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }



  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Text(
          widget.isSignUp ? 'Create Account' : 'Login',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: widget.onToggleMode,
      child: RichText(
        text: TextSpan(
          text: widget.isSignUp
              ? 'Already have an account? '
              : "Don't have an account? ",
          style: const TextStyle(color: Color(0xFF64748B)),
          children: [
            TextSpan(
              text: widget.isSignUp ? 'Login' : 'Sign Up',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Logout function example
Future<void> logout(BuildContext context) async {
  try {
    await Supabase.instance.client.auth.signOut();

    // IMPORTANT: Clear global user on logout
    userService.clearUser();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
