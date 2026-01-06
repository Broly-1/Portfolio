import 'package:flutter/material.dart';
import 'package:hassankamran/models/home_content.dart';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/services/firebase_service.dart';
import 'package:hassankamran/widgets/project_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/theme_provider.dart';

class HomeContentScreen extends StatelessWidget {
  final Function(String, {String? projectId}) onNavigate;

  const HomeContentScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final firebaseService = FirebaseService();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

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
            horizontal: isMobile ? 20 : (isTablet ? 60 : 120),
            vertical: isMobile ? 24 : 60,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section with accent color support
                  _buildHeadingWithAccent(
                    context,
                    homeContent.heading,
                    themeProvider.accentColor,
                  ),
                  const SizedBox(height: 20),
                  _buildParagraphWithLinks(context, homeContent.paragraph),
                  const SizedBox(height: 32),

                  // Action buttons - minimalist icon-only style
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: [
                      if (homeContent.githubUrl != null)
                        _buildMinimalistIconButton(
                          context,
                          Icons.code,
                          'GitHub',
                          () => _launchUrl(homeContent.githubUrl!),
                        ),
                      if (homeContent.linkedinUrl != null)
                        _buildMinimalistIconButton(
                          context,
                          Icons.work_outline,
                          'LinkedIn',
                          () => _launchUrl(homeContent.linkedinUrl!),
                        ),
                      _buildMinimalistIconButton(
                        context,
                        Icons.arrow_forward,
                        'More about me',
                        () => onNavigate('about'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Featured Projects section - minimalist header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 18,
                            color: themeProvider.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Featured Projects',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => onNavigate('projects'),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: TextStyle(
                                color: themeProvider.accentColor,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: themeProvider.accentColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

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
                          final spacing = 20.0;
                          // Scale down cards on home screen - show single column
                          final cardWidth = constraints.maxWidth.clamp(
                            300.0,
                            600.0,
                          );

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: featuredProjects.map((project) {
                              return SizedBox(
                                width: cardWidth,
                                child: ProjectCard(
                                  project: project,
                                  onTap: () => onNavigate(
                                    'projects',
                                    projectId: project.id,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
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
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(tooltip, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  ) {
    final regex = RegExp(r'\{\{(.+?)\}\}');
    final matches = regex.allMatches(heading);

    if (matches.isEmpty) {
      // No accent markers, return plain text
      return Text(
        heading,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.5,
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
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        );
      }

      // Add accented text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: -0.5,
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
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  // Parse paragraph and make [text](url) clickable
  Widget _buildParagraphWithLinks(BuildContext context, String paragraph) {
    final regex = RegExp(r'\[(.+?)\]\((.+?)\)');
    final matches = regex.allMatches(paragraph);

    if (matches.isEmpty) {
      // No links, return plain text
      return Text(
        paragraph,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
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
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
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
                  fontSize: 16,
                  height: 1.5,
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
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFFB4B8C5),
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
