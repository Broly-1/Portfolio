import 'package:flutter/material.dart';
import 'package:hassankamran/models/home_content.dart';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/services/firebase_service.dart';
import 'package:hassankamran/widgets/project_card.dart';
import 'package:hassankamran/Extensions/extensions.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/theme_provider.dart';
import '../widgets/bottom_widgets.dart';
import 'project_detail_screen.dart';

class HomeContentScreen extends StatelessWidget {
  final Function(String, {String? projectId}) onNavigate;

  const HomeContentScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final scale = context.responsiveScale;

    return StreamBuilder<HomeContent?>(
      stream: firebaseService.streamHomeContent(),
      builder: (context, homeSnapshot) {
        if (homeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final homeContent = homeSnapshot.data;
        if (homeContent == null) {
          return const Center(
            child: Text(
              'No home content found. Please add content from admin.',
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : (isTablet ? 48 : 120 * scale),
            vertical: isMobile ? 24 : 60 * scale,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : screenWidth * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section with accent color support
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildHeadingWithAccent(
                        context,
                        homeContent.heading,
                        themeProvider.accentColor,
                        scale,
                      );
                    },
                  ),
                  SizedBox(height: 20 * scale),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700 * scale),
                    child: _buildParagraphWithLinks(
                      context,
                      homeContent.paragraph,
                      scale,
                    ),
                  ),
                  SizedBox(height: 32 * scale),

                  // Action buttons - minimalist icon-only style
                  Wrap(
                    spacing: 20 * scale,
                    runSpacing: 12 * scale,
                    children: [
                      if (homeContent.githubUrl != null)
                        _buildMinimalistImageButton(
                          context,
                          'assets/github.png',
                          'GitHub',
                          () => _launchUrl(homeContent.githubUrl!),
                          scale,
                        ),
                      if (homeContent.linkedinUrl != null)
                        _buildMinimalistImageButton(
                          context,
                          'assets/linkedin.png',
                          'LinkedIn',
                          () => _launchUrl(homeContent.linkedinUrl!),
                          scale,
                        ),
                      _buildMinimalistIconButton(
                        context,
                        Icons.arrow_forward,
                        'More about me',
                        () => onNavigate('about'),
                        scale,
                      ),
                    ],
                  ),

                  SizedBox(height: 80 * scale),

                  // Featured projects grid
                  StreamBuilder<List<Project>>(
                    stream: firebaseService.streamProjects(),
                    builder: (context, projectsSnapshot) {
                      if (projectsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allProjects = projectsSnapshot.data ?? [];
                      final featuredProjects = allProjects
                          .where(
                            (p) =>
                                homeContent.featuredProjectIds.contains(p.id),
                          )
                          .take(2)
                          .toList();

                      if (featuredProjects.isEmpty) {
                        return Center(
                          child: Text(
                            'No featured projects selected',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final spacing = 20.0 * scale;
                          final isMobile = constraints.maxWidth < 900;
                          // On mobile, use full available width; on desktop, clamp it
                          final cardWidth = isMobile
                              ? double.infinity
                              : constraints.maxWidth.clamp(
                                  300.0 * scale,
                                  600.0 * scale,
                                );
                          final canFitTwo =
                              !isMobile &&
                              constraints.maxWidth >=
                                  (600.0 * scale * 2 + spacing);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Featured Projects header with View all button
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return Row(
                                    children: [
                                      Icon(
                                        Icons.star_border,
                                        size: 24 * scale,
                                        color: themeProvider.accentColor,
                                      ),
                                      SizedBox(width: 10 * scale),
                                      Text(
                                        'Featured Projects',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22 * scale,
                                          letterSpacing: 1.6 * scale,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (canFitTwo)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                constraints.maxWidth -
                                                (cardWidth * 2 + spacing),
                                          ),
                                          child: InkWell(
                                            onTap: () => onNavigate('projects'),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'View all',
                                                  style: TextStyle(
                                                    color: themeProvider
                                                        .accentColor,
                                                    fontSize: 18 * scale,
                                                    letterSpacing: 1.6 * scale,
                                                  ),
                                                ),
                                                SizedBox(width: 6 * scale),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color:
                                                      themeProvider.accentColor,
                                                  size: 18 * scale,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 32 * scale),
                              // Project cards
                              Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: featuredProjects.map((project) {
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: isMobile
                                          ? double.infinity
                                          : cardWidth,
                                    ),
                                    child: SizedBox(
                                      width: isMobile
                                          ? double.infinity
                                          : cardWidth,
                                      child: ProjectCard(
                                        project: project,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => ProjectDetailScreen(
                                                    project: project,
                                                  ),
                                              transitionsBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 400,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  SizedBox(height: 80 * scale),

                  // Bottom Widgets (Accent Selector, Cal.com, Recent Commits)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return BottomWidgets(
                        scale: scale,
                        maxWidth: constraints.maxWidth,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalistIconButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    double scale,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 12 * scale),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4 * scale),
        child: Padding(
          padding: EdgeInsets.all(8 * scale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18 * scale),
              SizedBox(width: 6 * scale),
              Text(tooltip, style: TextStyle(fontSize: 14 * scale)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalistImageButton(
    BuildContext context,
    String imagePath,
    String tooltip,
    VoidCallback onPressed,
    double scale,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 12 * scale),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4 * scale),
        child: Padding(
          padding: EdgeInsets.all(8 * scale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final isLightTheme = themeProvider.selectedTheme != 'Mocha';
                  final iconColor = isLightTheme
                      ? Colors.black87
                      : Colors.white;
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    child: Image.asset(
                      imagePath,
                      width: 18 * scale,
                      height: 18 * scale,
                    ),
                  );
                },
              ),
              SizedBox(width: 6 * scale),
              Text(tooltip, style: TextStyle(fontSize: 14 * scale)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error silently
    }
  }

  // Parse heading and apply accent color to {{text}}
  Widget _buildHeadingWithAccent(
    BuildContext context,
    String heading,
    Color accentColor,
    double scale,
  ) {
    final regex = RegExp(r'\{\{(.+?)\}\}');
    final matches = regex.allMatches(heading);

    if (matches.isEmpty) {
      // No accent markers, return plain text
      return Text(
        heading,
        style: TextStyle(
          fontSize: 36 * scale,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 1.6 * scale,
          color: Colors.white,
        ),
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: heading.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 36 * scale,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 1.6 * scale,
              color: Colors.white,
            ),
          ),
        );
      }

      // Add accented text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: 36 * scale,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 1.6 * scale,
            color: accentColor,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < heading.length) {
      spans.add(
        TextSpan(
          text: heading.substring(lastIndex),
          style: TextStyle(
            fontSize: 36 * scale,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 1.6 * scale,
            color: Colors.white,
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(children: spans),
    );
  }

  // Parse paragraph and make [text](url) clickable
  Widget _buildParagraphWithLinks(
    BuildContext context,
    String paragraph,
    double scale,
  ) {
    final regex = RegExp(r'\[(.+?)\]\((.+?)\)');
    final matches = regex.allMatches(paragraph);

    if (matches.isEmpty) {
      // No links, return plain text
      return Text(
        paragraph,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 18 * scale,
          height: 1.6,
          letterSpacing: 1.3 * scale,
          color: Color(0xFFB4B8C5),
        ),
      );
    }

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      // Add text before the link
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: paragraph.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 18 * scale,
              height: 1.6,
              letterSpacing: 1.3 * scale,
              color: Color(0xFFB4B8C5),
            ),
          ),
        );
      }

      // Add clickable link
      final linkText = match.group(1)!;
      final url = match.group(2)!;

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => _launchUrl(url),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                linkText,
                style: TextStyle(
                  fontSize: 18 * scale,
                  height: 1.6,
                  letterSpacing: 1.3 * scale,
                  color: Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).accentColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < paragraph.length) {
      spans.add(
        TextSpan(
          text: paragraph.substring(lastIndex),
          style: TextStyle(
            fontSize: 18 * scale,
            height: 1.6,
            letterSpacing: 1.3 * scale,
            color: Color(0xFFB4B8C5),
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
