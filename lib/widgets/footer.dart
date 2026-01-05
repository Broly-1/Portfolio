import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
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
    print('🔍 Footer: Fetching social links from Firebase...');
    final aboutData = await _firebaseService.getAboutData();
    print('📊 Footer: About data received: $aboutData');
    if (mounted && aboutData != null) {
      setState(() {
        _githubUrl = aboutData['github'] as String?;
        _linkedinUrl = aboutData['linkedin'] as String?;
      });
      print('🔗 Footer: GitHub URL: $_githubUrl');
      print('🔗 Footer: LinkedIn URL: $_linkedinUrl');
      // Fetch latest commit after we have the GitHub URL
      if (_githubUrl != null) {
        print('✅ Footer: GitHub URL found, fetching latest commit...');
        _fetchLatestCommit();
      } else {
        print('⚠️ Footer: No GitHub URL found in Firebase data');
      }
    } else {
      print('❌ Footer: No about data received or widget not mounted');
    }
  }

  Future<void> _fetchLatestCommit() async {
    if (_githubUrl == null) {
      print('⚠️ Footer: _fetchLatestCommit called but _githubUrl is null');
      return;
    }

    try {
      print('🔍 Footer: Parsing GitHub URL: $_githubUrl');
      // Extract username from GitHub URL
      final uri = Uri.parse(_githubUrl!);
      final username = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : null;

      print('👤 Footer: Extracted username: $username');
      if (username == null) {
        print('❌ Footer: Failed to extract username from URL');
        return;
      }

      // Fetch latest public events from GitHub
      final apiUrl = 'https://api.github.com/users/$username/events/public';
      print('📡 Footer: Fetching from GitHub API: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));

      print('📊 Footer: GitHub API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final events = json.decode(response.body) as List;
        print('📦 Footer: Received ${events.length} events');

        // Find the first PushEvent
        bool foundCommit = false;
        for (var event in events) {
          if (event['type'] == 'PushEvent') {
            final repo = event['repo']['name'];
            final payload = event['payload'];
            if (payload != null && payload['head'] != null) {
              print('💾 Footer: Found PushEvent in repo: $repo');
              final sha = payload['head'];
              final commitUrl = 'https://github.com/$repo/commit/$sha';
              final shortHash = sha.substring(0, 7);
              print('✅ Footer: Latest commit hash: $shortHash');
              print('🔗 Footer: Commit URL: $commitUrl');
              if (mounted) {
                setState(() {
                  _latestCommitUrl = commitUrl;
                  _latestCommitHash = shortHash;
                });
                print('✨ Footer: State updated with commit hash');
              }
              foundCommit = true;
              break;
            }
          }
        }
        if (!foundCommit) {
          print('⚠️ Footer: No PushEvent found in recent events');
        }
      } else {
        print('❌ Footer: GitHub API returned status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Footer: Error fetching GitHub commit: $e');
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 32,
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLightTheme ? Colors.grey[300]! : Colors.grey[800]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isMobile
            ? _buildMobileFooter(textColor)
            : _buildDesktopFooter(textColor),
      ),
    );
  }

  Widget _buildDesktopFooter(Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        // Left - Copyright
        Text(
          '© 2026 Hassan Kamran',
          style: TextStyle(color: textColor, fontSize: 18, letterSpacing: 1.6),
        ),

        const SizedBox(width: 40),

        // Center - Green dot + All Services Nominal
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(_glowAnimation.value),
                        blurRadius: 8 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              'All Services Nominal',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),

        const Spacer(),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              _formatSessionTime(),
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '$_viewCount views',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                letterSpacing: 1.6,
              ),
            ),
            if (_latestCommitHash != null) ...[
              const SizedBox(width: 20),
              _HoverCommit(
                commitHash: _latestCommitHash!,
                commitUrl: _latestCommitUrl!,
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onTap: () => _launchUrl(_latestCommitUrl!),
              ),
            ],
            const SizedBox(width: 20),
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
          _HoverIcon(
            icon: Icons.code,
            color: textColor,
            hoverColor: themeProvider.accentColor,
            onTap: () => _launchUrl(_githubUrl!),
          ),
        const SizedBox(width: 8),
        if (_linkedinUrl != null)
          _HoverIcon(
            icon: Icons.business,
            color: textColor,
            hoverColor: themeProvider.accentColor,
            onTap: () => _launchUrl(_linkedinUrl!),
          ),
        const SizedBox(width: 8),
        _HoverIcon(
          icon: Icons.camera_alt,
          color: textColor,
          hoverColor: themeProvider.accentColor,
          onTap: () => _launchUrl('https://instagram.com/hassan_k_69'),
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
