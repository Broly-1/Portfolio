import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../styles/theme_provider.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final borderColor = isLightTheme ? Colors.black26 : const Color(0xFF313244);

    final cardBackground = isLightTheme
        ? Color.lerp(themeProvider.themeBackgroundColor, Colors.black, 0.05)!
        : Color.lerp(themeProvider.themeBackgroundColor, Colors.black, 0.2)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? themeProvider.accentColor : borderColor,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.accentColor.withOpacity(
                  _isHovered ? 0.15 : 0,
                ),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Content
              Expanded(flex: 4, child: _buildContent(context)),

              const SizedBox(width: 16),

              // Right side - Phone mockup
              Expanded(flex: 2, child: _buildMobileScreen(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.grey[700]! : Colors.grey[300]!;
    final dateStr = DateFormat('MMM d, y').format(widget.project.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Browser window mockup
        Container(
          decoration: BoxDecoration(
            color: isLightTheme ? Colors.grey[300] : const Color(0xFF313244),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: isLightTheme
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Browser header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isLightTheme
                        ? const Color(0xFF3D3D3D)
                        : const Color(0xFF2D2D3D),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildDot(const Color(0xFFF38BA8)),
                      const SizedBox(width: 6),
                      _buildDot(const Color(0xFFF9E2AF)),
                      const SizedBox(width: 6),
                      _buildDot(const Color(0xFFA6E3A1)),
                    ],
                  ),
                ),
                // Browser content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Repo name
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Broly-1',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFFF38BA8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' / ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            TextSpan(
                              text: widget.project.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: themeProvider.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description in browser - fixed height for consistency
                      SizedBox(
                        height:
                            33, // Fixed height for exactly 2 lines (11px font * 1.5 line height * 2 lines)
                        child: Text(
                          widget.project.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // GitHub profile
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://avatars.githubusercontent.com/u/62743581?v=4',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Broly-1',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Title and date
        Row(
          children: [
            Expanded(
              child: Text(
                widget.project.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.6,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 11,
                  color: textColor.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.5),
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Main content text
        Text(
          _extractTextPreview(widget.project.content),
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.7),
            height: 1.5,
            letterSpacing: 1.1,
          ),
          maxLines: 4,

          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 60),

        // Tags at bottom with random colors
        Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 14,
              color: textColor.withOpacity(0.5),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.project.tags.map((tag) {
                  return Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getTagColor(tag),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _extractTextPreview(String markdown) {
    String text = markdown
        .replaceAll(RegExp(r'#+ '), '')
        .replaceAll(RegExp(r'\*\*|__'), '')
        .replaceAll(RegExp(r'\*|_'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'```[^`]*```'), '')
        .replaceAll(RegExp(r'`[^`]+`'), '')
        .trim();

    int endIndex = text.indexOf('\n\n');
    if (endIndex == -1 || endIndex > 250) endIndex = 250;
    return text.substring(0, endIndex.clamp(0, text.length)).trim();
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

  Widget _buildMobileScreen(BuildContext context) {
    return Transform(
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
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 2,
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
