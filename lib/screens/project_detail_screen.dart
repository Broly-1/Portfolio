import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../styles/theme_provider.dart';
import '../widgets/my_appbar.dart';
import '../widgets/footer.dart';
import '../Extensions/extensions.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';

    return Scaffold(
      backgroundColor: themeProvider.themeBackgroundColor,
      body: Column(
        children: [
          // AppBar
          MyAppbar(
            currentPath: 'projects/${project.name}',
            onNavigate: (path) {
              Navigator.pop(context);
            },
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Browser card with project info
                        _buildBrowserCard(context),

                        const SizedBox(height: 32),

                        // Date and links row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(project.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const Spacer(),
                            if (project.androidLink != null)
                              IconButton(
                                icon: const Icon(Icons.android),
                                onPressed: () =>
                                    _launchUrl(project.androidLink!),
                                tooltip: 'Get on Google Play',
                                color: Colors.green,
                              ),
                            if (project.iosLink != null)
                              IconButton(
                                icon: const Icon(Icons.apple),
                                onPressed: () => _launchUrl(project.iosLink!),
                                tooltip: 'Get on App Store',
                                color: Colors.blue,
                              ),
                            if (project.githubLink != null)
                              IconButton(
                                icon: const Icon(Icons.code),
                                onPressed: () =>
                                    _launchUrl(project.githubLink!),
                                tooltip: 'View on GitHub',
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tags
                        if (project.tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: project.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isLightTheme
                                      ? Colors.black.withOpacity(0.08)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getTagColor(tag),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Project title heading
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: themeProvider.accentColor,
                                letterSpacing: 2,
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Project content (rich text)
                        _buildProjectContent(context),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Footer(),
        ],
      ),
    );
  }

  Widget _buildBrowserCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final isMobile = context.isMobile;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Browser card
          Container(
            constraints: const BoxConstraints(minHeight: 500),
            decoration: BoxDecoration(
              color: isLightTheme ? Colors.grey[300] : const Color(0xFF313244),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(40),
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: isLightTheme
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Browser header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isLightTheme
                                  ? const Color(0xFF3D3D3D)
                                  : const Color(0xFF2D2D3D),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildDot(const Color(0xFFF38BA8)),
                                const SizedBox(width: 8),
                                _buildDot(const Color(0xFFF9E2AF)),
                                const SizedBox(width: 8),
                                _buildDot(const Color(0xFFA6E3A1)),
                              ],
                            ),
                          ),
                          // Browser content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Repo name
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Broly-1',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFF38BA8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' / ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                      TextSpan(
                                        text: project.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Description
                                Text(
                                  project.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // User info at bottom
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://avatars.githubusercontent.com/u/62743581?v=4',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Broly-1',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mobile screen preview
          Center(
            child: SizedBox(width: 200, child: _buildMobileScreen(context)),
          ),
        ],
      );
    }

    // Desktop layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Browser card (wider)
        Expanded(
          flex: 5,
          child: Container(
            constraints: const BoxConstraints(minHeight: 500),
            decoration: BoxDecoration(
              color: isLightTheme ? Colors.grey[300] : const Color(0xFF313244),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(40),
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: isLightTheme
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Browser header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isLightTheme
                                  ? const Color(0xFF3D3D3D)
                                  : const Color(0xFF2D2D3D),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildDot(const Color(0xFFF38BA8)),
                                const SizedBox(width: 8),
                                _buildDot(const Color(0xFFF9E2AF)),
                                const SizedBox(width: 8),
                                _buildDot(const Color(0xFFA6E3A1)),
                              ],
                            ),
                          ),
                          // Browser content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Repo name
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Broly-1',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFF38BA8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' / ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                      TextSpan(
                                        text: project.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Description
                                Text(
                                  project.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // User info at bottom
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://avatars.githubusercontent.com/u/62743581?v=4',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Broly-1',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Mobile screen preview
        Expanded(flex: 2, child: _MobileScreenPreview(project: project)),
      ],
    );
  }

  Widget _buildMobileScreen(BuildContext context) {
    return _MobileScreenPreview(project: project);
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getTagColor(String tag) {
    final colors = [
      const Color(0xFFF38BA8),
      const Color(0xFFF9E2AF),
      const Color(0xFFA6E3A1),
      const Color(0xFF89B4FA),
      const Color(0xFFCBA6F7),
      const Color(0xFFF5C2E7),
      const Color(0xFF94E2D5),
      const Color(0xFFFAB387),
    ];
    return colors[tag.hashCode.abs() % colors.length];
  }

  Widget _buildProjectContent(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MarkdownBody(
      data: project.content.isEmpty
          ? '_No detailed description available._'
          : project.content,
      styleSheet: MarkdownStyleSheet(
        h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: themeProvider.accentColor,
        ),
        h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: themeProvider.accentColor,
        ),
        h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: themeProvider.accentColor,
        ),
        p: Theme.of(context).textTheme.bodyLarge,
        strong: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        em: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
        code: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _MobileScreenPreview extends StatefulWidget {
  final Project project;

  const _MobileScreenPreview({required this.project});

  @override
  State<_MobileScreenPreview> createState() => _MobileScreenPreviewState();
}

class _MobileScreenPreviewState extends State<_MobileScreenPreview> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-0.2),
          alignment: Alignment.centerLeft,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).colorScheme.onSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovering ? 0.6 : 0.4),
                    blurRadius: _isHovering ? 40 : 30,
                    spreadRadius: _isHovering ? 3 : 2,
                    offset: Offset(-8, _isHovering ? 16 : 12),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    // Screen content
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: widget.project.thumbnailUrl != null
                            ? Image.network(
                                widget.project.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(context),
                              )
                            : _buildPlaceholder(context),
                      ),
                    ),

                    // Notch
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 100,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Shine effect
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final placeholderColor = isLightTheme
        ? Colors.grey[300]!
        : const Color(0xFF313244);

    return Container(
      color: placeholderColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: themeProvider.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
