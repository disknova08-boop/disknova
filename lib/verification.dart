// import 'dart:convert';
//
// import 'package:disknova_project/main.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart'as http;
//
// class SocialLinksVerificationScreen extends StatefulWidget {
//   const SocialLinksVerificationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SocialLinksVerificationScreen> createState() =>
//       _SocialLinksVerificationScreenState();
// }
//
// class _SocialLinksVerificationScreenState
//     extends State<SocialLinksVerificationScreen>
//     with TickerProviderStateMixin {
//   final _supabase = Supabase.instance.client;
//
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   bool _isLoading = true;
//   bool _isSendingVerification = false;
//   String? _publisherId;
//
//   // Social link data
//   Map<String, dynamic> _socialLinks = {};
//   Map<String, bool> _verificationStatus = {};
//   Map<String, String> _verificationCodes = {};
//   Map<String, TextEditingController> _codeControllers = {};
//
//   final List<Map<String, dynamic>> _availablePlatforms = [
//     {
//       'key': 'whatsapp_number',
//       'name': 'WhatsApp',
//       'icon': Icons.message,
//       'color': Colors.green
//     },
//     {
//       'key': 'facebook_url',
//       'name': 'Facebook',
//       'icon': Icons.facebook,
//       'color': Colors.blue
//     },
//     {
//       'key': 'instagram_url',
//       'name': 'Instagram',
//       'icon': Icons.camera_alt,
//       'color': Colors.pink
//     },
//     {
//       'key': 'telegram_url',
//       'name': 'Telegram',
//       'icon': Icons.send,
//       'color': Colors.blue.shade700
//     },
//     {
//       'key': 'google_url',
//       'name': 'Google',
//       'icon': Icons.g_mobiledata,
//       'color': Colors.red
//     },
//     {
//       'key': 'twitter_url',
//       'name': 'Twitter',
//       'icon': Icons.flutter_dash,
//       'color': Colors.blue.shade400
//     },
//     {
//       'key': 'website_url',
//       'name': 'Website',
//       'icon': Icons.language,
//       'color': Colors.blue.shade900
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _loadSocialLinks();
//   }
//
//   void _setupAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.15),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
//     );
//
//     _fadeController.forward();
//     _slideController.forward();
//   }
//
//   Future<void> _loadSocialLinks() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final userId = _supabase.auth.currentUser?.id;
//       if (userId == null) throw Exception('User not logged in');
//
//       final response = await _supabase
//           .from('publishers')
//           .select()
//           .eq('user_id', userId)
//           .maybeSingle();
//
//       if (response != null) {
//         _publisherId = response['id'];
//
//         // Load social links
//         for (var platform in _availablePlatforms) {
//           final key = platform['key'];
//           final value = response[key];
//           if (value != null && value.toString().isNotEmpty) {
//             _socialLinks[key] = value;
//             _verificationStatus[key] = response['${key}_verified'] ?? false;
//             _codeControllers[key] = TextEditingController();
//           }
//         }
//       }
//     } catch (e) {
//       _showSnackBar('Error loading links: $e', isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//
//
// // Example function
//   Future<void> _sendVerificationCode(String platform) async {
//     setState(() => _isSendingVerification = true);
//
//     try {
//       final phone = _socialLinks['whatsapp_number'];
//       if (phone == null || phone.toString().isEmpty) {
//         _showSnackBar('Phone number not found for WhatsApp', isError: true);
//         return;
//       }
//
//       // 🔹 Request headers
//       var headers = {
//         'apikey': supabaseKey,
//
//         'Authorization':
//         'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8',
//         'Content-Type': 'application/json'
//       };
//
//       // 🔹 Request body
//       var body = json.encode({
//         "mode": "send",
//         "phone_number": phone,
//         "template_name": "login_otp"
//       });
//
//       // 🔹 Make request
//       var response = await http.post(
//         Uri.parse('https://evajqtqydxmtezgeaief.supabase.co/functions/v1/rapid-function'),
//         headers: headers,
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         if (data['Status'] == "Success") {
//           setState(() {
//             _verificationCodes[platform] = data['Details']; // session_id save
//           });
//           _showSnackBar('OTP sent successfully to $phone');
//         } else {
//           _showSnackBar('Failed to send OTP: ${data['Details']}', isError: true);
//         }
//       } else {
//         print('HTTP Error: ${response.statusCode} ${response.reasonPhrase}');
//         _showSnackBar('Server Error: ${response.reasonPhrase}', isError: true);
//       }
//     } catch (e) {
//       print('Exception: $e');
//       _showSnackBar('Error sending OTP: $e', isError: true);
//     } finally {
//       setState(() => _isSendingVerification = false);
//     }
//   }
//
//   Future<void> _verifyCode(String platform) async {
//     final enteredOtp = _codeControllers[platform]?.text.trim() ?? '';
//     final sessionId = _verificationCodes[platform];
//
//     if (enteredOtp.isEmpty) {
//       _showSnackBar('Enter the OTP', isError: true);
//       return;
//     }
//
//     if (sessionId == null) {
//       _showSnackBar('OTP not sent yet', isError: true);
//       return;
//     }
//
//     try {
//       var headers = {
//         'Authorization':
//         'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8',
//         'Content-Type': 'application/json'
//       };
//
//       var body = json.encode({
//         "mode": "verify",
//         "session_id": sessionId,
//         "otp": enteredOtp,
//       });
//
//       var response = await http.post(
//         Uri.parse('https://evajqtqydxmtezgeaief.supabase.co/functions/v1/rapid-function'),
//         headers: headers,
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         if (data['Status'] == "Success") {
//           await _supabase
//               .from('publishers')
//               .update({'${platform}_verified': true})
//               .eq('id', _publisherId!);
//
//           setState(() {
//             _verificationStatus[platform] = true;
//           });
//
//           _showSnackBar('✅ ${_getPlatformName(platform)} verified successfully!');
//         } else {
//           _showSnackBar('❌ Invalid OTP', isError: true);
//         }
//       } else {
//         print('HTTP Error: ${response.statusCode} ${response.reasonPhrase}');
//         _showSnackBar('Server Error: ${response.reasonPhrase}', isError: true);
//       }
//     } catch (e) {
//       print('Exception: $e');
//       _showSnackBar('Verification failed: $e', isError: true);
//     }
//   }
//
//
//   String _getPlatformName(String key) {
//     return _availablePlatforms
//         .firstWhere((p) => p['key'] == key, orElse: () => {})['name'] ??
//         key;
//   }
//
//   IconData _getPlatformIcon(String key) {
//     return _availablePlatforms
//         .firstWhere((p) => p['key'] == key, orElse: () => {})['icon'] ??
//         Icons.link;
//   }
//
//   Color _getPlatformColor(String key) {
//     return _availablePlatforms
//         .firstWhere((p) => p['key'] == key, orElse: () => {})['color'] ??
//         Colors.blue;
//   }
//
//   bool _hasAtLeastOneVerified() {
//     return _verificationStatus.values.any((verified) => verified == true);
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   Future<void> _proceedToNextScreen() async {
//     if (!_hasAtLeastOneVerified()) {
//       _showSnackBar('Please verify at least one social link', isError: true);
//       return;
//     }
//
//     // Navigate to next screen (Brand Profile or Dashboard)
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, '/brand_profile');
//     }
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     for (var controller in _codeControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final verifiedCount = _verificationStatus.values.where((v) => v).length;
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       // appBar: AppBar(
//       //   title: const Text('Verify Social Links'),
//       //   backgroundColor: const Color(0xFF2563EB),
//       //   foregroundColor: Colors.white,
//       //   elevation: 0,
//       // ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : FadeTransition(
//         opacity: _fadeAnimation,
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(isTablet ? 32 : 16),
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 800),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header Card
//                     _buildHeaderCard(verifiedCount, isTablet),
//                     const SizedBox(height: 24),
//
//                     // Progress Steps
//                     _buildProgressSteps(verifiedCount),
//                     const SizedBox(height: 32),
//
//                     // Social Links List
//                     if (_socialLinks.isEmpty)
//                       _buildEmptyState()
//                     else
//                       ..._socialLinks.keys.map((platform) {
//                         return _buildVerificationCard(
//                           platform,
//                           isTablet,
//                         );
//                       }).toList(),
//
//                     const SizedBox(height: 32),
//
//                     // Continue Button
//                     Center(
//                       child: SizedBox(
//                         width: isTablet ? 300 : double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _hasAtLeastOneVerified()
//                               ? _proceedToNextScreen
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2563EB),
//                             foregroundColor: Colors.white,
//                             padding:
//                             const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: _hasAtLeastOneVerified() ? 2 : 0,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Continue',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: _hasAtLeastOneVerified()
//                                       ? Colors.white
//                                       : Colors.white60,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_forward,
//                                 color: _hasAtLeastOneVerified()
//                                     ? Colors.white
//                                     : Colors.white60,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderCard(int verifiedCount, bool isTablet) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF2563EB).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.verified_user,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Verify Your Social Links',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'At least one link must be verified to continue',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   '$verifiedCount/${_socialLinks.length} Verified',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProgressSteps(int verifiedCount) {
//     return Row(
//       children: [
//         _buildStepIndicator(1, 'Add Links', true),
//         Expanded(child: _buildStepLine(true)),
//         _buildStepIndicator(2, 'Verify', verifiedCount > 0),
//         Expanded(child: _buildStepLine(verifiedCount > 0)),
//         _buildStepIndicator(3, 'Complete', _hasAtLeastOneVerified()),
//       ],
//     );
//   }
//
//   Widget _buildStepIndicator(int step, String label, bool isActive) {
//     return Column(
//       children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: isActive ? const Color(0xFF2563EB) : Colors.grey[300],
//             shape: BoxShape.circle,
//             boxShadow: isActive
//                 ? [
//               BoxShadow(
//                 color: const Color(0xFF2563EB).withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ]
//                 : [],
//           ),
//           child: Center(
//             child: isActive
//                 ? const Icon(Icons.check, color: Colors.white, size: 20)
//                 : Text(
//               '$step',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: isActive ? const Color(0xFF2563EB) : Colors.grey[600],
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStepLine(bool isActive) {
//     return Container(
//       height: 2,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         color: isActive ? const Color(0xFF2563EB) : Colors.grey[300],
//       ),
//     );
//   }
//
//   Widget _buildVerificationCard(String platform, bool isTablet) {
//     final isVerified = _verificationStatus[platform] ?? false;
//     final platformName = _getPlatformName(platform);
//     final platformIcon = _getPlatformIcon(platform);
//     final platformColor = _getPlatformColor(platform);
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isVerified ? Colors.green : Colors.grey[300]!,
//           width: isVerified ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: platformColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(platformIcon, color: platformColor, size: 24),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       platformName,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       _socialLinks[platform].toString(),
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               if (isVerified)
//                 Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green, size: 16),
//                       SizedBox(width: 4),
//                       Text(
//                         'Verified',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//           if (!isVerified) ...[
//             const SizedBox(height: 16),
//             const Divider(),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _codeControllers[platform],
//                     decoration: InputDecoration(
//                       hintText: 'Enter 6-digit code',
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                         const BorderSide(color: Color(0xFF2563EB), width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 12),
//                     ),
//                     keyboardType: TextInputType.number,
//                     maxLength: 6,
//                     buildCounter: (context,
//                         {required currentLength,
//                           required isFocused,
//                           maxLength}) =>
//                     null,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: () => _verifyCode(platform),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2563EB),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text('Verify'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Center(
//               child: TextButton.icon(
//                 onPressed: _isSendingVerification
//                     ? null
//                     : () => _sendVerificationCode(platform),
//                 icon: _isSendingVerification
//                     ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//                     : const Icon(Icons.send, size: 16),
//                 label: Text(
//                   _isSendingVerification
//                       ? 'Sending...'
//                       : 'Send Verification Code',
//                 ),
//                 style: TextButton.styleFrom(
//                   foregroundColor: const Color(0xFF2563EB),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.link_off, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No Social Links Found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Please add your social links in the Brand Profile first',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.arrow_back),
//             label: const Text('Go Back'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2563EB),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:disknova_project/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SocialLinksVerificationScreen extends StatefulWidget {
  const SocialLinksVerificationScreen({Key? key}) : super(key: key);

  @override
  State<SocialLinksVerificationScreen> createState() =>
      _SocialLinksVerificationScreenState();
}

class _SocialLinksVerificationScreenState
    extends State<SocialLinksVerificationScreen>
    with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _isSendingVerification = false;
  bool _isResendingEmail = false;
  String? _publisherId;

  // Step completion status
  bool _emailVerified = false;
  bool _billingVerified = false;

  // Billing form controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Social link data
  Map<String, dynamic> _socialLinks = {};
  Map<String, bool> _verificationStatus = {};
  Map<String, String> _verificationCodes = {};
  Map<String, TextEditingController> _codeControllers = {};

  final List<Map<String, dynamic>> _availablePlatforms = [
    {
      'key': 'whatsapp_number',
      'name': 'WhatsApp',
      'icon': Icons.message,
      'color': Colors.green
    },
    {
      'key': 'facebook_url',
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': Colors.blue
    },
    {
      'key': 'instagram_url',
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': Colors.pink
    },
    {
      'key': 'telegram_url',
      'name': 'Telegram',
      'icon': Icons.send,
      'color': Colors.blue.shade700
    },
    {
      'key': 'google_url',
      'name': 'Google',
      'icon': Icons.g_mobiledata,
      'color': Colors.red
    },
    {
      'key': 'twitter_url',
      'name': 'Twitter',
      'icon': Icons.flutter_dash,
      'color': Colors.blue.shade400
    },
    {
      'key': 'website_url',
      'name': 'Website',
      'icon': Icons.language,
      'color': Colors.blue.shade900
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // FIXED: Check email verification from Supabase auth
      await _supabase.auth.refreshSession();
      _emailVerified = _supabase.auth.currentUser?.emailConfirmedAt != null;

      final response = await _supabase
          .from('publishers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _publisherId = response['id'];

        // FIXED: Check if billing data exists (not a separate verified field)
        final hasAddress = response['billing_address'] != null &&
            response['billing_address'].toString().isNotEmpty;
        final hasCity = response['billing_city'] != null &&
            response['billing_city'].toString().isNotEmpty;
        final hasState = response['billing_state'] != null &&
            response['billing_state'].toString().isNotEmpty;
        final hasPincode = response['billing_pincode'] != null &&
            response['billing_pincode'].toString().isNotEmpty;

        _billingVerified = hasAddress && hasCity && hasState && hasPincode;

        // Load billing data if exists
        if (hasAddress) {
          _addressController.text = response['billing_address'] ?? '';
          _cityController.text = response['billing_city'] ?? '';
          _stateController.text = response['billing_state'] ?? '';
          _pincodeController.text = response['billing_pincode'] ?? '';
        }

        // Load social links
        for (var platform in _availablePlatforms) {
          final key = platform['key'];
          final value = response[key];
          if (value != null && value.toString().isNotEmpty) {
            _socialLinks[key] = value;
            _verificationStatus[key] = response['${key}_verified'] ?? false;
            _codeControllers[key] = TextEditingController();
          }
        }
      }
    } catch (e) {
      _showSnackBar('Error loading data: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEmailVerification() async {
    setState(() => _isResendingEmail = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _showSnackBar('User not logged in', isError: true);
        return;
      }

      await _supabase.auth.resend(
        type: OtpType.signup,
        email: user.email!,
      );

      _showSnackBar('Verification email sent to ${user.email}');
    } catch (e) {
      _showSnackBar('Failed to send verification email: $e', isError: true);
    } finally {
      setState(() => _isResendingEmail = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    try {
      // FIXED: Properly refresh session and check email verification
      await _supabase.auth.refreshSession();

      final user = _supabase.auth.currentUser;
      if (user?.emailConfirmedAt != null) {
        setState(() {
          _emailVerified = true;
        });
        _showSnackBar('✅ Email verified successfully!');
      } else {
        _showSnackBar('Email not verified yet. Please check your inbox.',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Error checking email verification: $e', isError: true);
    }
  }

  Future<void> _saveBillingAddress() async {
    // FIXED: Check if email is verified first
    if (!_emailVerified) {
      _showSnackBar('Please verify your email first', isError: true);
      return;
    }

    if (_addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _pincodeController.text.isEmpty) {
      _showSnackBar('Please fill all billing fields', isError: true);
      return;
    }

    try {
      // FIXED: Only save billing data, no billing_verified field
      await _supabase.from('publishers').update({
        'billing_address': _addressController.text,
        'billing_city': _cityController.text,
        'billing_state': _stateController.text,
        'billing_pincode': _pincodeController.text,
      }).eq('id', _publisherId!);

      setState(() {
        _billingVerified = true;
      });

      _showSnackBar('✅ Billing address saved successfully!');
    } catch (e) {
      _showSnackBar('Error saving billing address: $e', isError: true);
    }
  }

  Future<void> _sendVerificationCode(String platform) async {
    // FIXED: Check prerequisites
    if (!_emailVerified || !_billingVerified) {
      _showSnackBar('Complete previous steps first', isError: true);
      return;
    }

    setState(() => _isSendingVerification = true);

    try {
      final phone = _socialLinks['whatsapp_number'];
      if (phone == null || phone.toString().isEmpty) {
        _showSnackBar('Phone number not found for WhatsApp', isError: true);
        return;
      }

      var headers = {
        'apikey': supabaseKey,
        'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8',
        'Content-Type': 'application/json'
      };

      var body = json.encode({
        "mode": "send",
        "phone_number": phone,
        "template_name": "login_otp"
      });

      var response = await http.post(
        Uri.parse(
            'https://evajqtqydxmtezgeaief.supabase.co/functions/v1/rapid-function'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['Status'] == "Success") {
          setState(() {
            _verificationCodes[platform] = data['Details'];
          });
          _showSnackBar('OTP sent successfully to $phone');
        } else {
          _showSnackBar('Failed to send OTP: ${data['Details']}',
              isError: true);
        }
      } else {
        _showSnackBar('Server Error: ${response.reasonPhrase}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error sending OTP: $e', isError: true);
    } finally {
      setState(() => _isSendingVerification = false);
    }
  }

  Future<void> _verifyCode(String platform) async {
    final enteredOtp = _codeControllers[platform]?.text.trim() ?? '';
    final sessionId = _verificationCodes[platform];

    if (enteredOtp.isEmpty) {
      _showSnackBar('Enter the OTP', isError: true);
      return;
    }

    if (sessionId == null) {
      _showSnackBar('OTP not sent yet', isError: true);
      return;
    }

    try {
      var headers = {
        'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8',
        'Content-Type': 'application/json'
      };

      var body = json.encode({
        "mode": "verify",
        "session_id": sessionId,
        "otp": enteredOtp,
      });

      var response = await http.post(
        Uri.parse(
            'https://evajqtqydxmtezgeaief.supabase.co/functions/v1/rapid-function'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['Status'] == "Success") {
          await _supabase
              .from('publishers')
              .update({'${platform}_verified': true}).eq('id', _publisherId!);

          setState(() {
            _verificationStatus[platform] = true;
          });

          _showSnackBar(
              '✅ ${_getPlatformName(platform)} verified successfully!');
        } else {
          _showSnackBar('❌ Invalid OTP', isError: true);
        }
      } else {
        _showSnackBar('Server Error: ${response.reasonPhrase}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Verification failed: $e', isError: true);
    }
  }
  bool _isValidTelegramUrl(String url) {
    if (url.isEmpty) return false;

    // Regex for Telegram URL validation
    final telegramRegex = RegExp(
      r'^(https?://)?(www\.)?(t\.me|telegram\.me)/.+$',
      caseSensitive: false,
    );

    return telegramRegex.hasMatch(url);
  }
  Future<void> _verifyDirectLink(String platform) async {
    // FIXED: Check prerequisites
    if (!_emailVerified || !_billingVerified) {
      _showSnackBar('Complete previous steps first', isError: true);
      return;
    }

    try {
      if (platform == 'telegram_url') {
        final telegramUrl = _socialLinks[platform]?.toString() ?? '';

        if (!_isValidTelegramUrl(telegramUrl)) {
          _showSnackBar(
            'Invalid Telegram URL format!\n\n'
                'Valid formats:\n'
                '• https://t.me/username\n'
                '• https://telegram.me/username\n'
                '• t.me/username',
            isError: true,
          );
          return;
        }

        // Show dialog explaining Telegram verification
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.telegram, color: Colors.blue),
                SizedBox(width: 8),
                Text('Telegram Verification'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Telegram URL: $telegramUrl',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text(
                  'To complete verification:\n\n'
                      '1. Open your Telegram app\n'
                      '2. Search for @YourBotName\n'
                      '3. Send /link command\n'
                      '4. Click the verification link\n\n'
                      'For now, we\'ll mark this as pending verification.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Continue to Bot'),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        // Save telegram_url but don't verify yet
        await _supabase
            .from('publishers')
            .update({
          'telegram_url': telegramUrl,
          'telegram_url_verified': false, // Not verified yet
        })
            .eq('id', _publisherId!);

        _showSnackBar(
          '✅ Telegram URL saved!\n\n'
              'Now open Telegram and use /link command in the bot to complete verification.',
          isError: false,
        );

        // Reload data
        await _loadData();
        return;
      }

      // For other platforms, mark as verified directly
      await _supabase
          .from('publishers')
          .update({'${platform}_verified': true})
          .eq('id', _publisherId!);

      setState(() {
        _verificationStatus[platform] = true;
      });

      _showSnackBar('✅ ${_getPlatformName(platform)} verified successfully!');
      await _supabase
          .from('publishers')
          .update({'${platform}_verified': true}).eq('id', _publisherId!);

      setState(() {
        _verificationStatus[platform] = true;
      });

      _showSnackBar('✅ ${_getPlatformName(platform)} verified successfully!');
    } catch (e) {
      _showSnackBar('Verification failed: $e', isError: true);
    }
  }

  String _getPlatformName(String key) {
    return _availablePlatforms
        .firstWhere((p) => p['key'] == key, orElse: () => {})['name'] ??
        key;
  }
  Widget _buildVerificationCard(String platform, bool isTablet) {
    final isVerified = _verificationStatus[platform] ?? false;
    final isWhatsApp = platform == 'whatsapp_number';
    final isTelegram = platform == 'telegram_url';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getPlatformColor(platform).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPlatformIcon(platform),
                  color: _getPlatformColor(platform),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPlatformName(platform),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _socialLinks[platform].toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!isVerified) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // ✅ Different UI for Telegram
            if (isTelegram) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Telegram Verification Required',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'To verify your Telegram account:\n'
                          '1. Open Telegram app\n'
                          '2. Search for our bot\n'
                          '3. Send /link command\n'
                          '4. Click verification link',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _verifyDirectLink(platform),
                  icon: const Icon(Icons.telegram, size: 20),
                  label: const Text('Save & Go to Bot'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else if (isWhatsApp) ...[
              // WhatsApp OTP verification (existing code)
              if (_verificationCodes[platform] == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSendingVerification
                        ? null
                        : () => _sendVerificationCode(platform),
                    icon: _isSendingVerification
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send, size: 20),
                    label: Text(_isSendingVerification
                        ? 'Sending OTP...'
                        : 'Send OTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPlatformColor(platform),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _codeControllers[platform],
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: 'Enter 6-digit OTP',
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getPlatformColor(platform),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  buildCounter: (context,
                      {required currentLength,
                        required isFocused,
                        maxLength}) =>
                  null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _verifyCode(platform),
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Verify OTP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPlatformColor(platform),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSendingVerification
                            ? null
                            : () => _sendVerificationCode(platform),
                        icon: _isSendingVerification
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.refresh, size: 20),
                        label: const Text('Resend'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _getPlatformColor(platform),
                          side: BorderSide(color: _getPlatformColor(platform)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              // Other platforms - direct verification
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _verifyDirectLink(platform),
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Mark as Verified'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPlatformColor(platform),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
  IconData _getPlatformIcon(String key) {
    return _availablePlatforms
        .firstWhere((p) => p['key'] == key, orElse: () => {})['icon'] ??
        Icons.link;
  }

  Color _getPlatformColor(String key) {
    return _availablePlatforms
        .firstWhere((p) => p['key'] == key, orElse: () => {})['color'] ??
        Colors.blue;
  }

  bool _hasAtLeastOneVerified() {
    return _verificationStatus.values.any((verified) => verified == true);
  }

  bool _canProceed() {
    return _emailVerified && _billingVerified && _hasAtLeastOneVerified();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _proceedToNextScreen() async {
    if (!_canProceed()) {
      _showSnackBar('Please complete all verification steps', isError: true);
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/brand_profile');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    for (var controller in _codeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verification Steps Header
                    _buildStepsList(),
                    const SizedBox(height: 32),

                    // Verification Status Card
                    _buildVerificationStatusCard(),
                    const SizedBox(height: 32),

                    // FIXED: Step 1 always shows if not verified
                    if (!_emailVerified) _buildEmailVerificationSection(),

                    // FIXED: Step 2 only shows if email verified and billing not verified
                    if (_emailVerified && !_billingVerified)
                      _buildBillingAddressSection(),

                    // FIXED: Step 3 only shows if both previous steps are done
                    if (_emailVerified && _billingVerified) ...[
                      if (_socialLinks.isNotEmpty) ...[
                        ..._socialLinks.keys.map((platform) {
                          return _buildVerificationCard(
                              platform, isTablet);
                        }).toList(),
                      ],
                    ],

                    const SizedBox(height: 32),

                    // Check Details Button
                    // Center(
                    //   child: SizedBox(
                    //     width: isTablet ? 300 : double.infinity,
                    //     child: ElevatedButton(
                    //       onPressed:
                    //       _canProceed() ? _proceedToNextScreen : null,
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: const Color(0xFF2563EB),
                    //         foregroundColor: Colors.white,
                    //         padding:
                    //         const EdgeInsets.symmetric(vertical: 16),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         elevation: _canProceed() ? 2 : 0,
                    //       ),
                    //       child: Text(
                    //         'Check Details',
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w600,
                    //           color: _canProceed()
                    //               ? Colors.white
                    //               : Colors.white60,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStepItem(
            icon: Icons.check_circle,
            title: 'Verify Email Address',
            subtitle: 'First step',
            isCompleted: _emailVerified,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.check_circle,
            title: 'Add Billing Address',
            subtitle: 'Second step',
            isCompleted: _billingVerified,
            isLocked: !_emailVerified,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.check_circle,
            title: 'Verify Channel Links',
            subtitle: 'Last step',
            isCompleted: _hasAtLeastOneVerified(),
            isLocked: !_emailVerified || !_billingVerified,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isLocked = false,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isLocked
                ? Colors.grey[400]
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLocked ? Icons.lock : icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey[500] : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isLocked ? 'Complete previous step first' : subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStatusCard() {
    int completedSteps = 0;
    if (_emailVerified) completedSteps++;
    if (_billingVerified) completedSteps++;
    if (_hasAtLeastOneVerified()) completedSteps++;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2563EB),
            const Color(0xFF2563EB).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Verification Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusBadge('Email', _emailVerified),
              _buildStatusBadge('Billing', _billingVerified),
              _buildStatusBadge('Channels', _hasAtLeastOneVerified()),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completedSteps / 3,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedSteps of 3 steps completed',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.close,
            color: isCompleted ? const Color(0xFF2563EB) : Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.email,
                    color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Verification Required',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter your billing details',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your address',
              prefixIcon: const Icon(Icons.home),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'City',
                    prefixIcon: const Icon(Icons.location_city),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                    hintText: 'State',
                    prefixIcon: const Icon(Icons.map),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pincodeController,
            decoration: InputDecoration(
              labelText: 'Pincode',
              hintText: 'Enter pincode',
              prefixIcon: const Icon(Icons.pin_drop),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) =>
            null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveBillingAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Billing Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildVerificationCard(String platform, bool isTablet) {
  //   final isVerified = _verificationStatus[platform] ?? false;
  //   final isWhatsApp = platform == 'whatsapp_number';
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: isVerified ? Colors.green : Colors.grey[300]!,
  //         width: 2,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                 color: _getPlatformColor(platform).withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Icon(
  //                 _getPlatformIcon(platform),
  //                 color: _getPlatformColor(platform),
  //                 size: 24,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     _getPlatformName(platform),
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     _socialLinks[platform].toString(),
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             if (isVerified)
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 12,
  //                   vertical: 6,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.green.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: const Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Icon(Icons.check_circle, color: Colors.green, size: 16),
  //                     SizedBox(width: 4),
  //                     Text(
  //                       'Verified',
  //                       style: TextStyle(
  //                         color: Colors.green,
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //           ],
  //         ),
  //         if (!isVerified) ...[
  //           const SizedBox(height: 16),
  //           const Divider(),
  //           const SizedBox(height: 16),
  //           if (isWhatsApp) ...[
  //             if (_verificationCodes[platform] == null) ...[
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton.icon(
  //                   onPressed: _isSendingVerification
  //                       ? null
  //                       : () => _sendVerificationCode(platform),
  //                   icon: _isSendingVerification
  //                       ? const SizedBox(
  //                     width: 16,
  //                     height: 16,
  //                     child: CircularProgressIndicator(
  //                       strokeWidth: 2,
  //                       color: Colors.white,
  //                     ),
  //                   )
  //                       : const Icon(Icons.send, size: 20),
  //                   label: Text(_isSendingVerification
  //                       ? 'Sending OTP...'
  //                       : 'Send OTP'),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: _getPlatformColor(platform),
  //                     foregroundColor: Colors.white,
  //                     padding: const EdgeInsets.symmetric(vertical: 14),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ] else ...[
  //               TextField(
  //                 controller: _codeControllers[platform],
  //                 decoration: InputDecoration(
  //                   labelText: 'Enter OTP',
  //                   hintText: 'Enter 6-digit OTP',
  //                   prefixIcon: const Icon(Icons.lock),
  //                   filled: true,
  //                   fillColor: Colors.grey[50],
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(color: Colors.grey[300]!),
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(color: Colors.grey[300]!),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(
  //                       color: _getPlatformColor(platform),
  //                       width: 2,
  //                     ),
  //                   ),
  //                 ),
  //                 keyboardType: TextInputType.number,
  //                 maxLength: 6,
  //                 buildCounter: (context,
  //                     {required currentLength,
  //                       required isFocused,
  //                       maxLength}) =>
  //                 null,
  //               ),
  //               const SizedBox(height: 12),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: ElevatedButton.icon(
  //                       onPressed: () => _verifyCode(platform),
  //                       icon: const Icon(Icons.check, size: 20),
  //                       label: const Text('Verify OTP'),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: _getPlatformColor(platform),
  //                         foregroundColor: Colors.white,
  //                         padding: const EdgeInsets.symmetric(vertical: 14),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: OutlinedButton.icon(
  //                       onPressed: _isSendingVerification
  //                           ? null
  //                           : () => _sendVerificationCode(platform),
  //                       icon: _isSendingVerification
  //                           ? const SizedBox(
  //                         width: 16,
  //                         height: 16,
  //                         child: CircularProgressIndicator(strokeWidth: 2),
  //                       )
  //                           : const Icon(Icons.refresh, size: 20),
  //                       label: const Text('Resend'),
  //                       style: OutlinedButton.styleFrom(
  //                         foregroundColor: _getPlatformColor(platform),
  //                         side: BorderSide(color: _getPlatformColor(platform)),
  //                         padding: const EdgeInsets.symmetric(vertical: 14),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ] else ...[
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton.icon(
  //                 onPressed: () => _verifyDirectLink(platform),
  //                 icon: const Icon(Icons.check, size: 20),
  //                 label: const Text('Mark as Verified'),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: _getPlatformColor(platform),
  //                   foregroundColor: Colors.white,
  //                   padding: const EdgeInsets.symmetric(vertical: 14),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ],
  //       ],
  //     ),
  //   );
  // }
  Widget _buildBillingAddressSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on,
                    color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billing Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter your billing details',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your address',
              prefixIcon: const Icon(Icons.home),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'City',
                    prefixIcon: const Icon(Icons.location_city),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                    hintText: 'State',
                    prefixIcon: const Icon(Icons.map),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pincodeController,
            decoration: InputDecoration(
              labelText: 'Pincode',
              hintText: 'Enter pincode',
              prefixIcon: const Icon(Icons.pin_drop),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) =>
            null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveBillingAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Billing Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}