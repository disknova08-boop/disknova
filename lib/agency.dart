import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



class Dev2DeskApp extends StatelessWidget {
  const Dev2DeskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev2Desk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF9333EA),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Dev2DeskHomePage(),
    );
  }
}

class Dev2DeskHomePage extends StatefulWidget {
  const Dev2DeskHomePage({Key? key}) : super(key: key);

  @override
  State<Dev2DeskHomePage> createState() => _Dev2DeskHomePageState();
}

class _Dev2DeskHomePageState extends State<Dev2DeskHomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _activeService = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    Future.delayed(Duration.zero, () {
      _startServiceRotation();
    });
  }

  void _startServiceRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _activeService = (_activeService + 1) % 4;
        });
        _startServiceRotation();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  double _getResponsiveFontSize(BuildContext context, double mobile, double tablet, double desktop) {
    if (_isMobile(context)) return mobile;
    if (_isTablet(context)) return tablet;
    return desktop;
  }

  double _getResponsivePadding(BuildContext context, double mobile, double desktop) {
    return _isMobile(context) ? mobile : desktop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF581C87),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(context),
                    _buildServicesSection(context),
                    _buildProjectsSection(context),
                    _buildWhyChooseSection(context),
                    _buildContactSection(context),
                    _buildFooter(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isMobile = _isMobile(context);

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: _isScrolled
          ? const Color(0xFF0F172A).withOpacity(0.95)
          : Colors.transparent,
      elevation: _isScrolled ? 8 : 0,
      title: Row(
        children: [
          Container(
            width: isMobile ? 32 : 40,
            height: isMobile ? 32 : 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'D2D',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 16,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
            ).createShader(bounds),
            child: Text(
              'Dev2Desk',
              style: TextStyle(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = _isMobile(context);
    final padding = _getResponsivePadding(context, 16, 40);
    final titleSize = _getResponsiveFontSize(context, 32, 40, 48);
    final subtitleSize = _getResponsiveFontSize(context, 16, 18, 20);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: isMobile ? 40 : 80,
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFA78BFA),
                  Color(0xFFF9A8D4),
                  Color(0xFFA78BFA)
                ],
              ).createShader(bounds),
              child: Text(
                'Transform Ideas\nInto Reality',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Premium Software Development Agency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: const Color(0xFFD1D5DB),
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildButton(context, 'Get Started', true, () => _scrollToSection(4)),
                _buildButton(context, 'View Work', false, () => _scrollToSection(2)),
              ],
            ),
            SizedBox(height: isMobile ? 40 : 64),
            _buildStatsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, bool filled, VoidCallback onTap) {
    final isMobile = _isMobile(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 32,
            vertical: isMobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            gradient: filled
                ? const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
            )
                : null,
            border: filled
                ? null
                : Border.all(color: const Color(0xFF9333EA), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (filled) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: isMobile ? 16 : 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final isMobile = _isMobile(context);
    final stats = [
      {'value': '50+', 'label': 'Projects'},
      {'value': '30+', 'label': 'Clients'},
      {'value': '95%', 'label': 'Satisfaction'},
      {'value': '24/7', 'label': 'Support'},
    ];

    return Wrap(
      spacing: isMobile ? 16 : 32,
      runSpacing: isMobile ? 24 : 32,
      alignment: WrapAlignment.center,
      children: stats.map((stat) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: [
              Text(
                stat['value']!,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA78BFA),
                ),
              ),
              SizedBox(height: isMobile ? 4 : 8),
              Text(
                stat['label']!,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final isMobile = _isMobile(context);
    final padding = _getResponsivePadding(context, 20, 40);
    final titleSize = _getResponsiveFontSize(context, 28, 36, 40);

    final services = [
      {
        'icon': Icons.phone_android,
        'title': 'Mobile App Development',
        'desc': 'Flutter & React Native apps that captivate users'
      },
      {
        'icon': Icons.language,
        'title': 'Web Development',
        'desc': 'Responsive websites built with modern tech'
      },
      {
        'icon': Icons.code,
        'title': 'Custom Software',
        'desc': 'Tailored solutions for your business needs'
      },
      {
        'icon': Icons.palette,
        'title': 'UI/UX Design',
        'desc': 'Beautiful interfaces that users love'
      },
    ];

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
            ).createShader(bounds),
            child: Text(
              'Our Services',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 12 : 16,
            alignment: WrapAlignment.center,
            children: List.generate(services.length, (index) {
              final service = services[index];
              final isActive = _activeService == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: isMobile ? MediaQuery.of(context).size.width - 48 : 280,
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                    colors: [Color(0x4D9333EA), Color(0x4DEC4899)],
                  )
                      : null,
                  color: isActive ? null : const Color(0x80334155),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      service['icon'] as IconData,
                      size: isMobile ? 40 : 48,
                      color: const Color(0xFFA78BFA),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      service['title'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    Text(
                      service['desc'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    final isMobile = _isMobile(context);
    final padding = _getResponsivePadding(context, 20, 40);
    final titleSize = _getResponsiveFontSize(context, 28, 36, 40);

    final projects = [
      {
        'name': 'E-Commerce Platform',
        'tech': 'Flutter + Firebase',
        'colors': [Color(0xFF9333EA), Color(0xFFEC4899)]
      },
      {
        'name': 'Healthcare App',
        'tech': 'React Native + Node.js',
        'colors': [Color(0xFF3B82F6), Color(0xFF06B6D4)]
      },
      {
        'name': 'Social Network',
        'tech': 'Flutter + GraphQL',
        'colors': [Color(0xFF10B981), Color(0xFF14B8A6)]
      },
      {
        'name': 'Fintech Solution',
        'tech': 'React + Django',
        'colors': [Color(0xFFF97316), Color(0xFFEF4444)]
      },
    ];

    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
            ).createShader(bounds),
            child: Text(
              'Featured Projects',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 12 : 16,
            alignment: WrapAlignment.center,
            children: projects.map((project) {
              return Container(
                width: isMobile ? MediaQuery.of(context).size.width - 48 : 350,
                height: isMobile ? 160 : 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: project['colors'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project['name'] as String,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isMobile ? 6 : 8),
                          Text(
                            project['tech'] as String,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseSection(BuildContext context) {
    final isMobile = _isMobile(context);
    final padding = _getResponsivePadding(context, 20, 40);
    final titleSize = _getResponsiveFontSize(context, 28, 36, 40);

    final reasons = [
      'Expert Team of Developers',
      'On-Time Project Delivery',
      'Cutting-Edge Technologies',
      'Transparent Communication',
      'Affordable Pricing',
      'Post-Launch Support',
    ];

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
            ).createShader(bounds),
            child: Text(
              'Why Choose Dev2Desk?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 12 : 16,
            alignment: WrapAlignment.center,
            children: reasons.map((reason) {
              return Container(
                width: isMobile ? MediaQuery.of(context).size.width - 48 : 350,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: const Color(0x80334155),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF10B981),
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 12 : 16),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final isMobile = _isMobile(context);
    final padding = _getResponsivePadding(context, 20, 40);
    final titleSize = _getResponsiveFontSize(context, 28, 36, 40);

    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
            ).createShader(bounds),
            child: Text(
              "Let's Build Something Amazing",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            decoration: BoxDecoration(
              color: const Color(0x80334155),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildContactItem(
                  context,
                  Icons.email,
                  'Email',
                  'dev2desk01@gmail.com',
                  'mailto:dev2desk01@gmail.com',
                ),
                SizedBox(height: isMobile ? 12 : 16),
                _buildContactItem(
                  context,
                  Icons.phone,
                  'Phone',
                  '+91 8890043675',
                  'tel:+918890043675',
                ),
                SizedBox(height: isMobile ? 12 : 16),
                _buildContactItem(
                  context,
                  Icons.person,
                  'Founder & CEO',
                  'Vivek Kumar',
                  null,
                ),
                SizedBox(height: isMobile ? 24 : 32),
                ElevatedButton(
                  onPressed: () => _launchURL('mailto:dev2desk01@gmail.com'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 32,
                      vertical: isMobile ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 32,
                        vertical: isMobile ? 12 : 16,
                      ),
                      child: Text(
                        'Start Your Project',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, IconData icon, String label, String value, String? url) {
    final isMobile = _isMobile(context);

    return Material(
      color: const Color(0x80475569),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: url != null ? () => _launchURL(url) : null,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFA78BFA),
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isMobile = _isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: const Color(0x800F172A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isMobile ? 28 : 32,
                height: isMobile ? 28 : 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'D2D',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Dev2Desk',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '© 2025 Dev2Desk. Transforming Ideas Into Reality.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToSection(int section) {
    _scrollController.animateTo(
      section * 600.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}