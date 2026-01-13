import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:hassankamran/Extensions/extensions.dart';
import '../styles/theme_provider.dart';
import '../services/firebase_service.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> with SingleTickerProviderStateMixin {
  int _sessionSeconds = 0;
  Timer? _sessionTimer;
  int _viewCount = 0;
  String? _latestCommitUrl;
  String? _latestCommitHash;
  String? _githubUrl;
  String? _linkedinUrl;
  final _firebaseService = FirebaseService();
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _startSessionTimer();
    _incrementAndFetchViews();
    _fetchSocialLinks();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionSeconds++;
        });
      }
    });
  }

  Future<void> _incrementAndFetchViews() async {
    await _firebaseService.incrementViewCount();
    final count = await _firebaseService.getViewCount();
    if (mounted) {
      setState(() {
        _viewCount = count;
      });
    }
  }

  Future<void> _fetchSocialLinks() async {
    final aboutData = await _firebaseService.getAboutData();
    if (mounted && aboutData != null) {
      setState(() {
        _githubUrl = aboutData['github'] as String?;
        _linkedinUrl = aboutData['linkedin'] as String?;
      });
      // Fetch latest commit after we have the GitHub URL
      if (_githubUrl != null) {
        _fetchLatestCommit();
      }
    }
  }

  Future<void> _fetchLatestCommit() async {
    if (_githubUrl == null) {
      return;
    }

    try {
      // Extract username from GitHub URL
      final uri = Uri.parse(_githubUrl!);
      final username = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : null;

      if (username == null) {
        return;
      }

      // Fetch latest public events from GitHub
      final apiUrl = 'https://api.github.com/users/$username/events/public';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final events = json.decode(response.body) as List;

        // Find the first PushEvent
        bool foundCommit = false;
        for (var event in events) {
          if (event['type'] == 'PushEvent') {
            final repo = event['repo']['name'];
            final payload = event['payload'];
            if (payload != null && payload['head'] != null) {
              final sha = payload['head'];
              final commitUrl = 'https://github.com/$repo/commit/$sha';
              final shortHash = sha.substring(0, 7);
              if (mounted) {
                setState(() {
                  _latestCommitUrl = commitUrl;
                  _latestCommitHash = shortHash;
                });
              }
              foundCommit = true;
              break;
            }
          }
        }
      }
    } catch (e) {
      // Error fetching GitHub commit
    }
  }

  String _formatSessionTime() {
    final hours = _sessionSeconds ~/ 3600;
    final minutes = (_sessionSeconds % 3600) ~/ 60;
    final seconds = _sessionSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.black87 : Colors.grey[300]!;
    final scale = context.responsiveScale;

    // Make dock darker than theme background
    final baseColor = themeProvider.themeBackgroundColor;
    final backgroundColor = Color.lerp(
      baseColor,
      Colors.black,
      isLightTheme ? 0.05 : 0.15,
    )!;

    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: isMobile ? null : screenWidth * 0.7,
        margin: EdgeInsets.only(bottom: 20 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 32 * scale,
          vertical: 30 * scale,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isLightTheme ? Colors.grey[300]! : Colors.grey[800]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15 * scale,
              offset: Offset(0, 5 * scale),
            ),
          ],
        ),
        child: isMobile
            ? _buildMobileFooter(textColor)
            : _buildDesktopFooter(textColor, scale),
      ),
    );
  }

  Widget _buildDesktopFooter(Color textColor, double scale) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        // Left - Copyright
        Text(
          '© 2026 Hassan Kamran',
          style: TextStyle(
            color: textColor,
            fontSize: 18 * scale,
            letterSpacing: 1.6 * scale,
          ),
        ),

        SizedBox(width: 40 * scale),

        // Center - Green dot + All Services Nominal
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(_glowAnimation.value),
                        blurRadius: 8 * scale * _glowAnimation.value,
                        spreadRadius: 2 * scale * _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: 8 * scale),
            Text(
              'All Services Nominal',
              style: TextStyle(
                color: textColor,
                fontSize: 18 * scale,
                letterSpacing: 1.6 * scale,
              ),
            ),
          ],
        ),

        const Spacer(),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14 * scale, color: textColor),
            SizedBox(width: 6 * scale),
            Text(
              _formatSessionTime(),
              style: TextStyle(
                color: textColor,
                fontSize: 18 * scale,
                letterSpacing: 1.6 * scale,
              ),
            ),
            SizedBox(width: 20 * scale),
            Text(
              '$_viewCount views',
              style: TextStyle(
                color: textColor,
                fontSize: 18 * scale,
                letterSpacing: 1.6 * scale,
              ),
            ),
            if (_latestCommitHash != null) ...[
              SizedBox(width: 20 * scale),
              _HoverCommit(
                commitHash: _latestCommitHash!,
                commitUrl: _latestCommitUrl!,
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onTap: () => _launchUrl(_latestCommitUrl!),
              ),
            ],
            SizedBox(width: 20 * scale),
            _buildSocialLinks(textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter(Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: Copyright + Green dot + All Services Nominal
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '© 2026 Hassan Kamran',
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'All Services Nominal',
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bottom row: Time, Views, Commit, Socials
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              _formatSessionTime(),
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_viewCount} views',
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
            if (_latestCommitHash != null) ...[
              const SizedBox(width: 12),
              Icon(Icons.commit, size: 12, color: textColor),
              const SizedBox(width: 4),
              Text(
                _latestCommitHash!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(width: 12),
            _buildSocialLinks(textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLinks(Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_githubUrl != null)
          _HoverImageIcon(
            imagePath: 'assets/github.png',
            color: textColor,
            hoverColor: themeProvider.accentColor,
            onTap: () => _launchUrl(_githubUrl!),
          ),
        const SizedBox(width: 8),
        if (_linkedinUrl != null)
          _HoverImageIcon(
            imagePath: 'assets/linkedin.png',
            color: textColor,
            hoverColor: themeProvider.accentColor,
            onTap: () => _launchUrl(_linkedinUrl!),
          ),
        const SizedBox(width: 8),
        _HoverImageIcon(
          imagePath: 'assets/instagram.png',
          color: textColor,
          hoverColor: themeProvider.accentColor,
          onTap: () => _launchUrl('https://instagram.com/hassan_k_6'),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _HoverIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color hoverColor;
  final VoidCallback onTap;

  const _HoverIcon({
    required this.icon,
    required this.color,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            widget.icon,
            color: _isHovering ? widget.hoverColor : widget.color,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _HoverImageIcon extends StatefulWidget {
  final String imagePath;
  final Color color;
  final Color hoverColor;
  final VoidCallback onTap;

  const _HoverImageIcon({
    required this.imagePath,
    required this.color,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_HoverImageIcon> createState() => _HoverImageIconState();
}

class _HoverImageIconState extends State<_HoverImageIcon> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              _isHovering ? widget.hoverColor : widget.color,
              BlendMode.srcIn,
            ),
            child: Image.asset(widget.imagePath, width: 18, height: 18),
          ),
        ),
      ),
    );
  }
}

class _HoverCommit extends StatefulWidget {
  final String commitHash;
  final String commitUrl;
  final Color textColor;
  final Color hoverColor;
  final VoidCallback onTap;

  const _HoverCommit({
    required this.commitHash,
    required this.commitUrl,
    required this.textColor,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_HoverCommit> createState() => _HoverCommitState();
}

class _HoverCommitState extends State<_HoverCommit> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          children: [
            Icon(
              Icons.commit,
              size: 18,
              color: _isHovering ? widget.hoverColor : widget.textColor,
            ),
            const SizedBox(width: 4),
            Text(
              widget.commitHash,
              style: TextStyle(
                color: _isHovering ? widget.hoverColor : widget.textColor,
                fontSize: 18,
                letterSpacing: 1.6,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
