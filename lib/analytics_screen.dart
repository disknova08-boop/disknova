// import 'package:disknova_project/utilis/responsive_utilis.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class AnalyticsScreen extends StatefulWidget {
//   const AnalyticsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<AnalyticsScreen> createState() => _AnalyticsScreenState();
// }
//
// class _AnalyticsScreenState extends State<AnalyticsScreen> {
//   Map<String, dynamic> _analytics = {};
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAnalytics();
//   }
//
//   Future<void> _loadAnalytics() async {
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//
//       final videos = await Supabase.instance.client
//           .from('videos')
//           .select()
//           .eq('user_id', userId ?? '');
//
//       int totalViews = 0;
//       double totalEarnings = 0;
//
//       for (var video in videos) {
//         totalViews += (video['views'] as int?) ?? 0;
//         totalEarnings += (video['earnings'] as num?)?.toDouble() ?? 0;
//       }
//
//       setState(() {
//         _analytics = {
//           'totalVideos': videos.length,
//           'totalViews': totalViews,
//           'totalEarnings': totalEarnings,
//           'availableBalance': totalEarnings,
//         };
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Revenue Analytics',
//           style: TextStyle(color: Color(0xFF1E293B)),
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
//           : SingleChildScrollView(
//         padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildRevenueSection(),
//             const SizedBox(height: 32),
//             _buildDailyAnalytics(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRevenueSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Check your overall paid, pending and remaining revenue analytics...',
//           style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
//         ),
//         const SizedBox(height: 20),
//         Responsive(
//           mobile: Column(
//             children: _buildRevenueCards(),
//           ),
//           desktop: Row(
//             children: _buildRevenueCards()
//                 .map((card) => Expanded(child: card))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<Widget> _buildRevenueCards() {
//     return [
//       _buildStatCard(
//         'Total',
//         '\$${_analytics['totalEarnings']?.toStringAsFixed(3) ?? '0.000'}',
//         Icons.receipt_outlined,
//         const Color(0xFF8B5CF6),
//       ),
//       SizedBox(
//         width: Responsive.isMobile(context) ? 0 : 16,
//         height: Responsive.isMobile(context) ? 16 : 0,
//       ),
//       _buildStatCard(
//         'Paid',
//         '\$0',
//         Icons.payments_outlined,
//         const Color(0xFF10B981),
//       ),
//       SizedBox(
//         width: Responsive.isMobile(context) ? 0 : 16,
//         height: Responsive.isMobile(context) ? 16 : 0,
//       ),
//       _buildStatCard(
//         'Available',
//         '\$${_analytics['availableBalance']?.toStringAsFixed(3) ?? '0.000'}',
//         Icons.account_balance_wallet_outlined,
//         const Color(0xFFF59E0B),
//       ),
//     ];
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(Responsive.isMobile(context) ? 20 : 24),
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
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Color(0xFF64748B),
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: Color(0xFF1E293B),
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
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
//   Widget _buildDailyAnalytics() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Daily Analytics',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8FAFC),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFE2E8F0)),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: Color(0xFF64748B),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     DateFormat('MM/dd/yyyy').format(DateTime.now()),
//                     style: const TextStyle(color: Color(0xFF64748B)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 1.3,
//           children: [
//             _buildMetricCard(
//               'Uploaded Files',
//               '${_analytics['totalVideos'] ?? 0}',
//               Icons.video_library_outlined,
//             ),
//             _buildMetricCard(
//               'Views',
//               '${_analytics['totalViews'] ?? 0}',
//               Icons.visibility_outlined,
//             ),
//             _buildMetricCard(
//               'OG Link Earning',
//               '\$0.000000',
//               Icons.link_outlined,
//             ),
//             _buildMetricCard(
//               'Total Earnings',
//               '\$${_analytics['totalEarnings']?.toStringAsFixed(5) ?? '0.00000'}',
//               Icons.monetization_on_outlined,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMetricCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(16),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2563EB).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Color(0xFF64748B),
//                   fontSize: 12,
//                 ),
//               ),
//             ],
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
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  Map<int, Map<String, dynamic>> _monthlyData = {};
  bool _isLoading = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      // Fetch all videos
      final videos = await Supabase.instance.client
          .from('videos')
          .select()
          .eq('user_id', userId ?? '');

      // Fetch payment records
      final payments = await Supabase.instance.client
          .from('payments')
          .select()
          .eq('user_id', userId ?? '');

      int totalViews = 0;
      double totalEarnings = 0;
      double paidAmount = 0;
      double pendingAmount = 0;
      double approvedAmount = 0;
      double cancelledAmount = 0;

      // Calculate total earnings from videos
      Map<int, Map<String, dynamic>> monthlyStats = {};
      for (int day = 1; day <= 31; day++) {
        monthlyStats[day] = {
          'views': 0,
          'earnings': 0,
          'uploadedFiles': 0,
        };
      }

      for (var video in videos) {
        int views = (video['views'] as int?) ?? 0;

        // Calculate earnings: 1 view = $0.002, so 1000 views = $2
        double earnings = views * 0.002;

        totalViews += views;
        totalEarnings += earnings;

        // Update video earnings in database if changed
        if ((video['earnings'] as num?)?.toDouble() != earnings) {
          await Supabase.instance.client
              .from('videos')
              .update({'earnings': earnings})
              .eq('id', video['id']);
        }

        // Parse created_at date
        DateTime createdAt = DateTime.parse(video['created_at']);

        // Check if video is from selected month/year
        if (createdAt.month == _selectedMonth && createdAt.year == _selectedYear) {
          int day = createdAt.day;
          if (monthlyStats.containsKey(day)) {
            monthlyStats[day]!['views'] = (monthlyStats[day]!['views'] as int) + views;
            monthlyStats[day]!['earnings'] = (monthlyStats[day]!['earnings'] as double) + earnings;
            monthlyStats[day]!['uploadedFiles'] = (monthlyStats[day]!['uploadedFiles'] as int) + 1;
          }
        }
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
          case 'cancelled':
          case 'rejected':
            cancelledAmount += amount;
            break;
        }
      }

      // Available = Total - (Paid + Pending + Approved + Cancelled)
      double availableAmount = totalEarnings - (paidAmount + pendingAmount + approvedAmount);

      setState(() {
        _analytics = {
          'totalVideos': videos.length,
          'totalViews': totalViews,
          'totalEarnings': totalEarnings,
          'paidAmount': paidAmount,
          'pendingAmount': pendingAmount,
          'approvedAmount': approvedAmount,
          'availableAmount': availableAmount > 0 ? availableAmount : 0,
          'cancelledAmount': cancelledAmount,
        };
        _monthlyData = monthlyStats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
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
          'Revenue Analytics',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        leading: Responsive.isMobile(context)
            ? IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueSection(),
            const SizedBox(height: 32),
            _buildDailyAnalytics(),
            const SizedBox(height: 32),
            _buildMonthlyAnalytics(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check your overall paid, pending and remaining revenue analytics...',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 20),
        _buildRevenueCards(),
      ],
    );
  }

  Widget _buildRevenueCards() {
    // For mobile: 2 columns, for tablet: 3 columns, for desktop: all in one row
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '\$${_analytics['totalEarnings']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.receipt_outlined,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Paid',
                  '\$${_analytics['paidAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.payments_outlined,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Available',
                  '\$${_analytics['availableAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.account_balance_wallet_outlined,
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  '\$${_analytics['approvedAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.check_circle_outline,
                  const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '\$${_analytics['pendingAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.pending_outlined,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Cancelled',
                  '\$${_analytics['cancelledAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.cancel_outlined,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (Responsive.isTablet(context)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '\$${_analytics['totalEarnings']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.receipt_outlined,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Paid',
                  '\$${_analytics['paidAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.payments_outlined,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Available',
                  '\$${_analytics['availableAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.account_balance_wallet_outlined,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  '\$${_analytics['approvedAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.check_circle_outline,
                  const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '\$${_analytics['pendingAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.pending_outlined,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Cancelled',
                  '\$${_analytics['cancelledAmount']?.toStringAsFixed(3) ?? '0.000'}',
                  Icons.cancel_outlined,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Desktop: All in one row
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '\$${_analytics['totalEarnings']?.toStringAsFixed(3) ?? '0.000'}',
              Icons.receipt_outlined,
              const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Paid',
              '\$${_analytics['paidAmount']?.toStringAsFixed(3) ?? '0.000'}',
              Icons.payments_outlined,
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Available',
              '\$${_analytics['availableAmount']?.toStringAsFixed(3) ?? '0.000'}',
              Icons.account_balance_wallet_outlined,
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Approved',
              '\$${_analytics['approvedAmount']?.toStringAsFixed(3) ?? '0.000'}',
              Icons.check_circle_outline,
              const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Pending',
              '\$${_analytics['pendingAmount']?.toStringAsFixed(3) ?? '0.000'}',
              Icons.pending_outlined,
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Cancelled',
              '\$${_analytics['cancelledAmount']?.toStringAsFixed(3) ?? '0.000'}',
              Icons.cancel_outlined,
              const Color(0xFFEF4444),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
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
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: Responsive.isMobile(context) ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MM/dd/yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildMetricCard(
              'Uploaded Files',
              '${_analytics['totalVideos'] ?? 0}',
              Icons.video_library_outlined,
            ),
            _buildMetricCard(
              'Views',
              '${_analytics['totalViews'] ?? 0}',
              Icons.visibility_outlined,
            ),
            _buildMetricCard(
              'OG Link Earning',
              '\$0.000000',
              Icons.link_outlined,
            ),
            _buildMetricCard(
              'Total Earnings',
              '\$${_analytics['totalEarnings']?.toStringAsFixed(5) ?? '0.00000'}',
              Icons.monetization_on_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyAnalytics() {
    return Container(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monthly Views, Files, Earnings Numbers',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  DateFormat('MMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // _buildChartLegend(),
          // const SizedBox(height: 16),
          _buildMonthlyChart(),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Views', const Color(0xFF10B981),isMobile),
        _buildLegendItem('Uploaded Files', const Color(0xFFF59E0B),isMobile),
        _buildLegendItem('Earnings', const Color(0xFF3B82F6),isMobile),
      ],
    );
  }

  // Widget _buildLegendItem(String label, Color color) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(
  //         width: 12,
  //         height: 12,
  //         decoration: BoxDecoration(
  //           color: color,
  //           shape: BoxShape.circle,
  //         ),
  //       ),
  //       const SizedBox(width: 6),
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           color: Color(0xFF64748B),
  //           fontSize: 12,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildMonthlyChart() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;

    final maxViews = _monthlyData.values.fold<int>(
      0,
          (max, data) => data['views'] > max ? data['views'] : max,
    );
    final maxEarnings = _monthlyData.values.fold<double>(
      0,
          (max, data) => data['earnings'] > max ? data['earnings'] : max,
    );
    final maxFiles = _monthlyData.values.fold<int>(
      0,
          (max, data) => data['uploadedFiles'] > max ? data['uploadedFiles'] : max,
    );

    // Calculate max for Y axis (normalize all values to same scale)
    final normalizedMax = [maxViews.toDouble(), maxFiles * 10.0, maxEarnings * 100]
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Title
          Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 8 : 16,
              bottom: isMobile ? 12 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Performance',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  'Last 30 days overview',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // Legend
          Wrap(
            spacing: isMobile ? 12 : 24,
            runSpacing: 8,
            children: [
              _buildLegendItem('Views', const Color(0xFF10B981), isMobile),
              _buildLegendItem('Files', const Color(0xFFF59E0B), isMobile),
              _buildLegendItem('Earnings', const Color(0xFF3B82F6),isMobile ),

            ],
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Chart
          SizedBox(
            height: isMobile ? 250 : (isTablet ? 350 : 400),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: normalizedMax > 0 ? normalizedMax / 5 : 1,
                  verticalInterval: isMobile ? 10 : 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isMobile ? 30 : 40,
                      interval: isMobile ? 10 : 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < 1 || value.toInt() > 30) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isMobile ? 40 : 50,
                      interval: normalizedMax > 0 ? normalizedMax / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return Text(
                            '0',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }

                        // Format large numbers
                        String formatted;
                        if (value >= 1000000) {
                          formatted = '${(value / 1000000).toStringAsFixed(1)}M';
                        } else if (value >= 1000) {
                          formatted = '${(value / 1000).toStringAsFixed(1)}K';
                        } else {
                          formatted = value.toInt().toString();
                        }

                        return Text(
                          formatted,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                minX: 1,
                maxX: 30,
                minY: 0,
                maxY: normalizedMax > 0 ? normalizedMax * 1.1 : 10,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(

                    getTooltipColor: (touchedSpot) => const Color(0xFF334155),
                    tooltipBorderRadius: BorderRadius.circular(12),
                    // tooltipRoundedRadius: 12,
                    tooltipPadding: EdgeInsets.all(isMobile ? 10 : 12),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final day = spot.x.toInt();
                        final data = _monthlyData[day]!;

                        String label = '';
                        String value = '';
                        Color color = Colors.white;

                        if (spot.barIndex == 0) {
                          label = 'Views';
                          value = _formatNumber(data['views']);
                          color = const Color(0xFF10B981);
                        } else if (spot.barIndex == 1) {
                          label = 'Files';
                          value = data['uploadedFiles'].toString();
                          color = const Color(0xFFF59E0B);
                        } else {
                          label = 'Earnings';
                          value = '\$${data['earnings'].toStringAsFixed(2)}';
                          color = const Color(0xFF3B82F6);
                        }

                        return LineTooltipItem(
                          '$label: $value\nDay $day',
                          TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 11 : 12,
                            height: 1.5,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                  getTouchLineEnd: (data, index) => 0,
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.white.withOpacity(0.5),
                          strokeWidth: 2,
                          dashArray: [5, 5],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: isMobile ? 5 : 6,
                              color: barData.color ?? Colors.blue,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
                lineBarsData: [
                  // Views line (Green)
                  LineChartBarData(
                    spots: _monthlyData.entries
                        .map((e) => FlSpot(
                      e.key.toDouble(),
                      e.value['views'].toDouble(),
                    ))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    color: const Color(0xFF10B981),
                    barWidth: isMobile ? 2.5 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isMobile ? 3 : 4,
                          color: const Color(0xFF10B981),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.3),
                          const Color(0xFF10B981).withOpacity(0.05),
                        ],
                      ),
                    ),
                    shadow: Shadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ),
                  // Uploaded Files line (Orange) - Scaled up by 10
                  LineChartBarData(
                    spots: _monthlyData.entries
                        .map((e) => FlSpot(
                      e.key.toDouble(),
                      (e.value['uploadedFiles'] as int).toDouble() * 10,
                    ))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    color: const Color(0xFFF59E0B),
                    barWidth: isMobile ? 2.5 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isMobile ? 3 : 4,
                          color: const Color(0xFFF59E0B),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF59E0B).withOpacity(0.3),
                          const Color(0xFFF59E0B).withOpacity(0.05),
                        ],
                      ),
                    ),
                    shadow: Shadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ),
                  // Earnings line (Blue) - Scaled up by 100
                  LineChartBarData(
                    spots: _monthlyData.entries
                        .map((e) => FlSpot(
                      e.key.toDouble(),
                      (e.value['earnings'] as double) * 100,
                    ))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: isMobile ? 2.5 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isMobile ? 3 : 4,
                          color: const Color(0xFF3B82F6),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.3),
                          const Color(0xFF3B82F6).withOpacity(0.05),
                        ],
                      ),
                    ),
                    shadow: Shadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method for legend items
  Widget _buildLegendItem(String label, Color color, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 12 : 16,
          height: isMobile ? 12 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

// Helper method to format large numbers
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }}