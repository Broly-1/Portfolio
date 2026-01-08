import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../styles/theme_provider.dart';
import '../Extensions/extensions.dart';
import 'package:intl/intl.dart';

class ProjectDetailContent extends StatefulWidget {
  final Project project;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const ProjectDetailContent({
    super.key,
    required this.project,
    this.onClose,
    this.showCloseButton = false,
  });

  @override
  State<ProjectDetailContent> createState() => _ProjectDetailContentState();
}

class _ProjectDetailContentState extends State<ProjectDetailContent> {
  bool _isHoveringMobile = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showCloseButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                color: themeProvider.accentColor,
                iconSize: 28,
                tooltip: 'Close',
              ),
            ],
          ),

        // Browser card with project info and mobile screen
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildBrowserCard(context)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildMobileScreen(context)),
            ],
          )
        else
          Column(
            children: [
              _buildBrowserCard(context),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 150, child: _buildMobileScreen(context)),
              ),
            ],
          ),

        const SizedBox(height: 32),

        // Date and links row
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(widget.project.createdAt),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (widget.project.androidLink != null)
              IconButton(
                icon: const Icon(Icons.android),
                onPressed: () => _launchUrl(widget.project.androidLink!),
                tooltip: 'Get on Google Play',
                color: Colors.green,
              ),
            if (widget.project.iosLink != null)
              IconButton(
                icon: const Icon(Icons.apple),
                onPressed: () => _launchUrl(widget.project.iosLink!),
                tooltip: 'Get on App Store',
                color: Colors.blue,
              ),
            if (widget.project.githubLink != null)
              IconButton(
                icon: const Icon(Icons.code),
                onPressed: () => _launchUrl(widget.project.githubLink!),
                tooltip: 'View on GitHub',
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Tags
        if (widget.project.tags.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Icon(
                  Icons.local_offer,
                  size: 16,
                  color: themeProvider.accentColor.withOpacity(0.7),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.project.tags.map((tag) {
                    final tagColor = _getTagColor(tag);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: tagColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 13,
                          color: tagColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],

        // Project title heading
        Text(
          widget.project.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 16),

        // Project content (rich text)
        _buildProjectContent(context),
      ],
    );
  }

  Widget _buildBrowserCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final isMobile = context.isMobile;

    return Container(
      constraints: BoxConstraints(
        minHeight: isMobile ? 150 : 250,
        maxHeight: isMobile ? 300 : 500,
      ),
      decoration: BoxDecoration(
        color: isLightTheme
            ? Colors.grey[200]
            : Color.lerp(
                themeProvider.themeBackgroundColor,
                Colors.white,
                0.05,
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 32),
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
                            ? Colors.grey[300]
                            : Color.lerp(
                                themeProvider.themeBackgroundColor,
                                Colors.black,
                                0.3,
                              ),
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
                                const TextSpan(
                                  text: 'Broly-1',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFF38BA8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        (isLightTheme
                                                ? Colors.white
                                                : Colors.white)
                                            .withOpacity(0.5),
                                  ),
                                ),
                                TextSpan(
                                  text: widget.project.name,
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
                            widget.project.description,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  (isLightTheme ? Colors.white : Colors.white)
                                      .withOpacity(0.8),
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
                            color: isLightTheme ? Colors.white : Colors.white,
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
                          color: (isLightTheme ? Colors.white : Colors.white)
                              .withOpacity(0.7),
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
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildMobileScreen(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringMobile = true),
      onExit: (_) => setState(() => _isHoveringMobile = false),
      child: AnimatedScale(
        scale: _isHoveringMobile ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-0.2),
          alignment: Alignment.centerLeft,
          child: AspectRatio(
            aspectRatio: 8 / 16,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).colorScheme.onSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      _isHoveringMobile ? 0.6 : 0.4,
                    ),
                    blurRadius: _isHoveringMobile ? 40 : 30,
                    spreadRadius: _isHoveringMobile ? 4 : 2,
                    offset: const Offset(-8, 12),
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

  Widget _buildProjectContent(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.grey[800]! : Colors.grey[300]!;
    final headingColor = isLightTheme ? Colors.grey[900]! : Colors.grey[100]!;

    return MarkdownBody(
      data: widget.project.content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          fontSize: 16,
          height: 1.6,
          letterSpacing: 0.3,
          color: textColor,
        ),
        h1: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.3,
          letterSpacing: 1.0,
          color: headingColor,
        ),
        h2: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
          letterSpacing: 0.8,
          color: headingColor,
        ),
        h3: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: 0.5,
          color: headingColor,
        ),
        h4: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: headingColor,
        ),
        strong: TextStyle(fontWeight: FontWeight.bold, color: headingColor),
        em: TextStyle(fontStyle: FontStyle.italic, color: textColor),
        a: TextStyle(
          color: themeProvider.accentColor,
          decoration: TextDecoration.underline,
        ),
        code: TextStyle(
          backgroundColor: isLightTheme ? Colors.grey[200] : Colors.grey[800],
          fontFamily: 'monospace',
          fontSize: 14,
          color: themeProvider.accentColor,
        ),
        listBullet: TextStyle(color: themeProvider.accentColor, fontSize: 16),
        listIndent: 24,
        blockquotePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        blockquoteDecoration: BoxDecoration(
          color: isLightTheme ? Colors.grey[100] : Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(color: themeProvider.accentColor, width: 4),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          _launchUrl(href);
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error silently or show a snackbar if context is available
    }
  }

  Color _getTagColor(String tag) {
    final colors = [
      const Color(0xFFF38BA8), // Pink
      const Color(0xFFF9E2AF), // Yellow
      const Color(0xFFA6E3A1), // Green
      const Color(0xFF89DCEB), // Sky blue (lighter)
      const Color(0xFFCBA6F7), // Purple
      const Color(0xFFF5C2E7), // Light pink
      const Color(0xFF94E2D5), // Teal
      const Color(0xFFFAB387), // Peach
    ];
    return colors[tag.hashCode.abs() % colors.length];
  }
}
