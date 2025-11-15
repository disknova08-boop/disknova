// import 'package:disknova_project/utilis/responsive_utilis.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class BillingScreen extends StatefulWidget {
//   const BillingScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }
//
// class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
//   Map<String, dynamic> _revenueData = {};
//   List<Map<String, dynamic>> _withdrawals = [];
//   bool _isLoading = true;
//   late TabController _tabController;
//
//   // Google Sheets Form URL - Replace with your actual form URL
//   final String _googleFormUrl = 'https://docs.google.com/forms/d/e/YOUR_FORM_ID/viewform';
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadData();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//
//       // Fetch all videos to calculate earnings
//       final videos = await Supabase.instance.client
//           .from('videos')
//           .select()
//           .eq('user_id', userId ?? '');
//
//       // Fetch payment records
//       final payments = await Supabase.instance.client
//           .from('payments')
//           .select()
//           .eq('user_id', userId ?? '')
//           .order('created_at', ascending: false);
//
//       double totalEarnings = 0;
//       double paidAmount = 0;
//       double pendingAmount = 0;
//       double approvedAmount = 0;
//
//       // Calculate total earnings from videos
//       for (var video in videos) {
//         int views = (video['views'] as int?) ?? 0;
//         double earnings = views * 0.002; // 1 view = $0.002
//         totalEarnings += earnings;
//       }
//
//       // Calculate payment stats
//       for (var payment in payments) {
//         double amount = (payment['amount'] as num?)?.toDouble() ?? 0;
//         String status = payment['status'] ?? 'pending';
//
//         switch (status.toLowerCase()) {
//           case 'paid':
//           case 'completed':
//             paidAmount += amount;
//             break;
//           case 'pending':
//             pendingAmount += amount;
//             break;
//           case 'approved':
//             approvedAmount += amount;
//             break;
//         }
//       }
//
//       // Available = Total - (Paid + Pending + Approved)
//       double availableAmount = totalEarnings - (paidAmount + pendingAmount + approvedAmount);
//
//       setState(() {
//         _revenueData = {
//           'total': totalEarnings,
//           'paid': paidAmount,
//           'available': availableAmount > 0 ? availableAmount : 0,
//           'approved': approvedAmount,
//           'pending': pendingAmount,
//         };
//         _withdrawals = List<Map<String, dynamic>>.from(payments);
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading data: $e');
//       setState(() => _isLoading = false);
//       _showErrorSnackBar('Failed to load data. Please try again.');
//     }
//   }
//
//   Future<void> _createWithdrawalRequest() async {
//     final available = _revenueData['available'] ?? 0;
//
//     // Check minimum balance
//     if (available < 10) {
//       _showErrorSnackBar('Minimum balance of \$10 required for withdrawal');
//       return;
//     }
//
//     // Show confirmation dialog
//     final confirmed = await _showWithdrawalDialog();
//     if (confirmed != true) return;
//
//     try {
//       // Open Google Form in browser
//       final Uri url = Uri.parse(_googleFormUrl);
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         _showErrorSnackBar('Could not open withdrawal form');
//       }
//     } catch (e) {
//       print('Error opening form: $e');
//       _showErrorSnackBar('Failed to open withdrawal form');
//     }
//   }
//
//   Future<bool?> _showWithdrawalDialog() async {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Create Withdrawal Request',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Available Balance: \$${_revenueData['available']?.toStringAsFixed(2) ?? '0.00'}',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF10B981),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'You will be redirected to a form to complete your withdrawal request.',
//               style: TextStyle(color: Color(0xFF64748B)),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFEF3C7),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFFBBF24)),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Minimum payout: \$10\nProcessing time: 3-5 business days',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2563EB),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Continue'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFEF4444),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF10B981),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Revenue Details',
//           style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
//         ),
//         leading: Responsive.isMobile(context)
//             ? IconButton(
//           icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
//           onPressed: () => Scaffold.of(context).openDrawer(),
//         )
//             : null,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//         onRefresh: _loadData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Check your paid, pending and remaining revenue details...',
//                 style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
//               ),
//               const SizedBox(height: 20),
//               _buildRevenueCards(),
//               const SizedBox(height: 32),
//               _buildWithdrawalSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRevenueCards() {
//     return Container(
//       padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Responsive.isMobile(context)
//           ? Column(
//         children: [
//           Row(
//             children: [
//               Expanded(child: _buildRevenueCard('Total', _revenueData['total'] ?? 0, Icons.receipt_outlined, const Color(0xFF8B5CF6))),
//               const SizedBox(width: 12),
//               Expanded(child: _buildRevenueCard('Paid', _revenueData['paid'] ?? 0, Icons.payments_outlined, const Color(0xFF10B981))),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(child: _buildRevenueCard('Available', _revenueData['available'] ?? 0, Icons.account_balance_wallet_outlined, const Color(0xFFF97316))),
//               const SizedBox(width: 12),
//               Expanded(child: _buildRevenueCard('Approved', _revenueData['approved'] ?? 0, Icons.check_circle_outline, const Color(0xFF06B6D4))),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildRevenueCard('Pending', _revenueData['pending'] ?? 0, Icons.pending_outlined, const Color(0xFFF59E0B)),
//         ],
//       )
//           : Row(
//         children: [
//           Expanded(child: _buildRevenueCard('Total', _revenueData['total'] ?? 0, Icons.receipt_outlined, const Color(0xFF8B5CF6))),
//           const SizedBox(width: 16),
//           Expanded(child: _buildRevenueCard('Paid', _revenueData['paid'] ?? 0, Icons.payments_outlined, const Color(0xFF10B981))),
//           const SizedBox(width: 16),
//           Expanded(child: _buildRevenueCard('Available', _revenueData['available'] ?? 0, Icons.account_balance_wallet_outlined, const Color(0xFFF97316))),
//           const SizedBox(width: 16),
//           Expanded(child: _buildRevenueCard('Approved', _revenueData['approved'] ?? 0, Icons.check_circle_outline, const Color(0xFF06B6D4))),
//           const SizedBox(width: 16),
//           Expanded(child: _buildRevenueCard('Pending', _revenueData['pending'] ?? 0, Icons.pending_outlined, const Color(0xFFF59E0B))),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRevenueCard(String title, double value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Color(0xFF64748B),
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               '\$${value.toStringAsFixed(3)}',
//               style: TextStyle(
//                 color: color,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWithdrawalSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: const Color(0xFFE2E8F0)),
//               ),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               labelColor: const Color(0xFF2563EB),
//               unselectedLabelColor: const Color(0xFF64748B),
//               indicatorColor: const Color(0xFF2563EB),
//               indicatorWeight: 3,
//               tabs: const [
//                 Tab(text: 'New Withdrawal'),
//                 Tab(text: 'Old Withdrawals'),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 500,
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildNewWithdrawalTab(),
//                 _buildOldWithdrawalsTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNewWithdrawalTab() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: _createWithdrawalRequest,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1E293B),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 0,
//             ),
//             child: const Text(
//               'Create New Withdrawal Request',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'International Payment System. Bank or UPI or SWIFT or AirTM. Instant Payments. Minimum Payout: \$10. Live Dollar Exchange Rates.',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             '**If your country is not listed then please select USD as your currency and do Swift/Wire Transfer.**',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFF64748B),
//               fontSize: 12,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOldWithdrawalsTab() {
//     if (_withdrawals.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.history, size: 64, color: Color(0xFFCBD5E1)),
//             SizedBox(height: 16),
//             Text(
//               'No withdrawal history',
//               style: TextStyle(
//                 color: Color(0xFF64748B),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: _withdrawals.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final withdrawal = _withdrawals[index];
//         return _buildWithdrawalCard(withdrawal);
//       },
//     );
//   }
//
//   Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
//     final amount = (withdrawal['amount'] as num?)?.toDouble() ?? 0;
//     final status = withdrawal['status'] ?? 'pending';
//     final createdAt = withdrawal['created_at'] != null
//         ? DateTime.parse(withdrawal['created_at'])
//         : DateTime.now();
//     final method = withdrawal['payment_method'] ?? 'N/A';
//
//     Color statusColor;
//     IconData statusIcon;
//     switch (status.toLowerCase()) {
//       case 'paid':
//       case 'completed':
//         statusColor = const Color(0xFF10B981);
//         statusIcon = Icons.check_circle;
//         break;
//       case 'approved':
//         statusColor = const Color(0xFF06B6D4);
//         statusIcon = Icons.check_circle_outline;
//         break;
//       case 'pending':
//         statusColor = const Color(0xFFF59E0B);
//         statusIcon = Icons.pending;
//         break;
//       case 'cancelled':
//       case 'rejected':
//         statusColor = const Color(0xFFEF4444);
//         statusIcon = Icons.cancel;
//         break;
//       default:
//         statusColor = const Color(0xFF64748B);
//         statusIcon = Icons.help_outline;
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(statusIcon, color: statusColor, size: 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '\$${amount.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1E293B),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         status.toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color: statusColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Method: $method',
//                   style: const TextStyle(
//                     color: Color(0xFF64748B),
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt),
//                   style: const TextStyle(
//                     color: Color(0xFF94A3B8),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:disknova_project/utilis/responsive_utilis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _revenueData = {};
  List<Map<String, dynamic>> _withdrawals = [];
  bool _isLoading = true;
  late TabController _tabController;

  // Verification status
  bool _emailVerified = false;
  bool _billingVerified = false;
  bool _channelVerified = false;

  final String _googleFormUrl = 'https://docs.google.com/forms/d/e/YOUR_FORM_ID/viewform';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      // Check verification status
      await _checkVerificationStatus(userId);

      // Fetch all videos to calculate earnings
      final videos = await Supabase.instance.client
          .from('videos')
          .select()
          .eq('user_id', userId ?? '');

      // Fetch payment records
      final payments = await Supabase.instance.client
          .from('payments')
          .select()
          .eq('user_id', userId ?? '')
          .order('created_at', ascending: false);

      double totalEarnings = 0;
      double paidAmount = 0;
      double pendingAmount = 0;
      double approvedAmount = 0;

      // Calculate total earnings from videos
      for (var video in videos) {
        int views = (video['views'] as int?) ?? 0;
        double earnings = views * 0.002;
        totalEarnings += earnings;
      }

      // Calculate payment stats
      for (var payment in payments) {
        double amount = (payment['amount'] as num?)?.toDouble() ?? 0;
        String status = payment['status'] ?? 'pending';

        switch (status.toLowerCase()) {
          case 'paid':
          case 'completed':
            paidAmount += amount;
            break;
          case 'pending':
            pendingAmount += amount;
            break;
          case 'approved':
            approvedAmount += amount;
            break;
        }
      }

      double availableAmount = totalEarnings - (paidAmount + pendingAmount + approvedAmount);

      setState(() {
        _revenueData = {
          'total': totalEarnings,
          'paid': paidAmount,
          'available': availableAmount > 0 ? availableAmount : 0,
          'approved': approvedAmount,
          'pending': pendingAmount,
        };
        _withdrawals = List<Map<String, dynamic>>.from(payments);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load data. Please try again.');
    }
  }

  Future<void> _checkVerificationStatus(String? userId) async {
    if (userId == null) return;

    try {
      // Check email verification
      await Supabase.instance.client.auth.refreshSession();
      _emailVerified = Supabase.instance.client.auth.currentUser?.emailConfirmedAt != null;

      // Check publisher data for billing and channel verification
      final response = await Supabase.instance.client
          .from('publishers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        // Check billing verification
        final hasAddress = response['billing_address'] != null &&
            response['billing_address'].toString().isNotEmpty;
        final hasCity = response['billing_city'] != null &&
            response['billing_city'].toString().isNotEmpty;
        final hasState = response['billing_state'] != null &&
            response['billing_state'].toString().isNotEmpty;
        final hasPincode = response['billing_pincode'] != null &&
            response['billing_pincode'].toString().isNotEmpty;

        _billingVerified = hasAddress && hasCity && hasState && hasPincode;

        // Check channel verification (at least one social link verified)
        final List<String> platforms = [
          'whatsapp_number',
          'facebook_url',
          'instagram_url',
          'telegram_url',
          'google_url',
          'twitter_url',
          'website_url',
        ];

        _channelVerified = platforms.any((platform) =>
        response['${platform}_verified'] == true);
      }
    } catch (e) {
      print('Error checking verification: $e');
    }
  }

  bool _isFullyVerified() {
    return _emailVerified && _billingVerified && _channelVerified;
  }

  Future<void> _createWithdrawalRequest() async {
    final available = _revenueData['available'] ?? 0;

    if (available < 5) {
      _showErrorSnackBar('Minimum balance of \$5 required for withdrawal');
      return;
    }

    final confirmed = await _showWithdrawalDialog();
    if (confirmed != true) return;

    try {
      final Uri url = Uri.parse(_googleFormUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open withdrawal form');
      }
    } catch (e) {
      print('Error opening form: $e');
      _showErrorSnackBar('Failed to open withdrawal form');
    }
  }

  Future<bool?> _showWithdrawalDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Create Withdrawal Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Balance: \$${_revenueData['available']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You will be redirected to a form to complete your withdrawal request.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFBBF24)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Minimum payout: \$5\nProcessing time: 3-5 business days',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
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
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToVerification() {
    Navigator.pushNamed(context, '/social_links_verification');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
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
          'Revenue Details',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        leading: Responsive.isMobile(context)
            ? IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: _logout,
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

        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check your paid, pending and remaining revenue details...',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildRevenueCards(),
              const SizedBox(height: 32),
              _isFullyVerified()
                  ? _buildWithdrawalSection()
                  : _buildVerificationRequiredSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationRequiredSection() {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Complete Verification Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'You need to complete all 3 verification steps before you can create withdrawal requests or view your withdrawal history.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildVerificationCheckList(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToVerification,
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: const Text(
                'Complete Verification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCheckList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildCheckListItem(
            'Email Verification',
            _emailVerified,
            Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildCheckListItem(
            'Billing Address',
            _billingVerified,
            Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _buildCheckListItem(
            'Channel Verification',
            _channelVerified,
            Icons.verified_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckListItem(String title, bool isCompleted, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isCompleted ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
          ),
        ),
        Icon(
          icon,
          color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildRevenueCards() {
    return Container(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 20),
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
      child: Responsive.isMobile(context)
          ? Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildRevenueCard('Total', _revenueData['total'] ?? 0, Icons.receipt_outlined, const Color(0xFF8B5CF6))),
              const SizedBox(width: 12),
              Expanded(child: _buildRevenueCard('Paid', _revenueData['paid'] ?? 0, Icons.payments_outlined, const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRevenueCard('Available', _revenueData['available'] ?? 0, Icons.account_balance_wallet_outlined, const Color(0xFFF97316))),
              const SizedBox(width: 12),
              Expanded(child: _buildRevenueCard('Approved', _revenueData['approved'] ?? 0, Icons.check_circle_outline, const Color(0xFF06B6D4))),
            ],
          ),
          const SizedBox(height: 12),
          _buildRevenueCard('Pending', _revenueData['pending'] ?? 0, Icons.pending_outlined, const Color(0xFFF59E0B)),
        ],
      )
          : Row(
        children: [
          Expanded(child: _buildRevenueCard('Total', _revenueData['total'] ?? 0, Icons.receipt_outlined, const Color(0xFF8B5CF6))),
          const SizedBox(width: 16),
          Expanded(child: _buildRevenueCard('Paid', _revenueData['paid'] ?? 0, Icons.payments_outlined, const Color(0xFF10B981))),
          const SizedBox(width: 16),
          Expanded(child: _buildRevenueCard('Available', _revenueData['available'] ?? 0, Icons.account_balance_wallet_outlined, const Color(0xFFF97316))),
          const SizedBox(width: 16),
          Expanded(child: _buildRevenueCard('Approved', _revenueData['approved'] ?? 0, Icons.check_circle_outline, const Color(0xFF06B6D4))),
          const SizedBox(width: 16),
          Expanded(child: _buildRevenueCard('Pending', _revenueData['pending'] ?? 0, Icons.pending_outlined, const Color(0xFFF59E0B))),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String title, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${value.toStringAsFixed(3)}',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalSection() {
    return Container(
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
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'New Withdrawal'),
                Tab(text: 'Old Withdrawals'),
              ],
            ),
          ),
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewWithdrawalTab(),
                _buildOldWithdrawalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewWithdrawalTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _createWithdrawalRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create New Withdrawal Request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'International Payment System. Bank or UPI or SWIFT or AirTM. Instant Payments. Minimum Payout: \$5. Live Dollar Exchange Rates.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            '**If your country is not listed then please select USD as your currency and do Swift/Wire Transfer.**',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldWithdrawalsTab() {
    if (_withdrawals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              'No withdrawal history',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _withdrawals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final withdrawal = _withdrawals[index];
        return _buildWithdrawalCard(withdrawal);
      },
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
    final amount = (withdrawal['amount'] as num?)?.toDouble() ?? 0;
    final status = withdrawal['status'] ?? 'pending';
    final createdAt = withdrawal['created_at'] != null
        ? DateTime.parse(withdrawal['created_at'])
        : DateTime.now();
    final method = withdrawal['payment_method'] ?? 'N/A';

    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case 'approved':
        statusColor = const Color(0xFF06B6D4);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.pending;
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFF64748B);
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Method: $method',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}