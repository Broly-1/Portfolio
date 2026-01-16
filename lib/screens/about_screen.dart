import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Extensions/extensions.dart';
import '../services/firebase_service.dart';
import '../styles/theme_provider.dart';

class AboutContent extends StatefulWidget {
  const AboutContent({super.key});

  @override
  State<AboutContent> createState() => _AboutContentState();
}

class _AboutContentState extends State<AboutContent> {
  final _firebaseService = FirebaseService();
  Map<String, dynamic>? _aboutData;
  bool _isLoading = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  Future<void> _loadAboutData() async {
    final data = await _firebaseService.getAboutData();
    if (mounted) {
      setState(() {
        _aboutData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.black87 : Colors.grey[400]!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ABOUT ME heading
        Text(
          'About Me',
          style: context.textStyle.titleLgBold.copyWith(
            fontSize: context.isMobile ? 24 : 42,
            letterSpacing: context.isMobile ? 2 : 3,
            color: textColor,
          ),
        ),
        SizedBox(height: context.isMobile ? 24 : 40),

        // Content section with image and text
        context.isMobile
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final imageUrl = _aboutData?['imageUrl'] as String?;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: AnimatedScale(
            scale: _isHovering ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 500,
              height: 600,
              decoration: BoxDecoration(
                color: const Color(0xFF7BA7BC),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          return const Center(
                            child: Icon(
                              Icons.person,
                              size: 150,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        size: 150,
                        color: Colors.white54,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 80),

        // About text
        Expanded(child: _buildAboutText(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final imageUrl = _aboutData?['imageUrl'] as String?;

    return Column(
      children: [
        // Profile Image
        Container(
          width: double.infinity,
          height: 350,
          decoration: BoxDecoration(
            color: const Color(0xFF7BA7BC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      return const Center(
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Icon(Icons.person, size: 100, color: Colors.white54),
                ),
        ),
        const SizedBox(height: 30),

        // About text
        _buildAboutText(context),
      ],
    );
  }

  Widget _buildAboutText(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.black87 : Colors.grey[400]!;
    final iconColor = isLightTheme ? Colors.grey[700]! : Colors.grey[500]!;

    final bio = _aboutData?['bio'] as String? ?? 'Loading...';
    final location = _aboutData?['location'] as String? ?? '';
    final email = _aboutData?['email'] as String? ?? '';
    final github = _aboutData?['github'] as String? ?? '';
    final linkedin = _aboutData?['linkedin'] as String? ?? '';

    final textStyle = context.textStyle.bodyLgMedium.copyWith(
      height: 1.8,
      fontSize: context.isMobile ? 14 : 20,
      color: textColor,
      letterSpacing: context.isMobile ? 0.5 : 1.7,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display location if available
        if (location.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  location,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

        // Bio text
        MarkdownBody(
          data: bio,
          styleSheet: MarkdownStyleSheet(
            p: textStyle,
            a: textStyle.copyWith(
              color: themeProvider.accentColor,
              decoration: TextDecoration.underline,
            ),
          ),
          onTapLink: (text, href, title) async {
            if (href != null) {
              final uri = Uri.parse(href);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
        ),
        const SizedBox(height: 40),

        // Social Links
        Wrap(
          spacing: 30,
          runSpacing: 15,
          children: [
            if (github.isNotEmpty)
              _buildSocialImageLink(
                context,
                'assets/github.png',
                'GitHub',
                github,
              ),
            if (linkedin.isNotEmpty)
              _buildSocialImageLink(
                context,
                'assets/linkedin.png',
                'LinkedIn',
                linkedin,
              ),
            if (email.isNotEmpty)
              _buildSocialLink(
                context,
                Icons.email,
                'Email',
                email.startsWith('mailto:') ? email : 'mailto:$email',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLink(
    BuildContext context,
    IconData icon,
    String label,
    String url,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final iconColor = isLightTheme ? Colors.grey[700]! : Colors.grey[400]!;

    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontSize: 18,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialImageLink(
    BuildContext context,
    String imagePath,
    String label,
    String url,
  ) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Row(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isLightTheme = themeProvider.selectedTheme != 'Mocha';
              final iconColor = isLightTheme
                  ? Colors.grey[700]!
                  : Colors.grey[400]!;
              return ColorFiltered(
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                child: Image.asset(imagePath, width: 20, height: 20),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isLightTheme = themeProvider.selectedTheme != 'Mocha';
              final iconColor = isLightTheme
                  ? Colors.grey[700]!
                  : Colors.grey[400]!;
              return Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
