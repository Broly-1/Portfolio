import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/Extensions/extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final scale = context.responsiveScale;
    final isMobile = context.isMobile;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isLightTheme = themeProvider.selectedTheme != 'Mocha';
        final borderColor = isLightTheme
            ? Colors.black26
            : const Color(0xFF313244);
        final cardBackground = isLightTheme
            ? Color.lerp(
                themeProvider.themeBackgroundColor,
                Colors.black,
                0.05,
              )!
            : Color.lerp(
                themeProvider.themeBackgroundColor,
                Colors.black,
                0.2,
              )!;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(12 * scale),
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
              child: isMobile
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildContent(context, scale)),
                        SizedBox(width: 8 * scale),
                        SizedBox(
                          width: 120,
                          child: _buildMobileScreen(context, scale),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side - Content
                        Expanded(flex: 4, child: _buildContent(context, scale)),

                        SizedBox(width: 13 * scale),

                        // Right side - Phone mockup
                        Expanded(
                          flex: 2,
                          child: _buildMobileScreen(context, scale),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, double scale) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.grey[700]! : Colors.grey[300]!;
    final dateStr = DateFormat('MMM d, y').format(widget.project.createdAt);
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Browser window mockup
        Hero(
          tag: 'project_browser_${widget.project.id}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: isLightTheme
                    ? Colors.grey[300]
                    : const Color(0xFF313244),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              padding: EdgeInsets.all(10 * scale),
              child: Container(
                decoration: BoxDecoration(
                  color: isLightTheme
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(6 * scale),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Browser header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: isLightTheme
                            ? const Color(0xFF3D3D3D)
                            : const Color(0xFF2D2D3D),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6 * scale),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildDot(const Color(0xFFF38BA8), scale),
                          SizedBox(width: 5 * scale),
                          _buildDot(const Color(0xFFF9E2AF), scale),
                          SizedBox(width: 5 * scale),
                          _buildDot(const Color(0xFFA6E3A1), scale),
                        ],
                      ),
                    ),
                    // Browser content
                    Padding(
                      padding: EdgeInsets.all(10 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Repo name
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Broly-1',
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                        color: const Color(0xFFF38BA8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ',
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.project.name,
                                      style: TextStyle(
                                        fontSize: 14 * scale,
                                        color: themeProvider.accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 8 * scale),
                          // Description in browser - fixed height for consistency
                          SizedBox(
                            height:
                                60 *
                                scale, // Increased height for better visibility
                            child: Text(
                              widget.project.description,
                              style: TextStyle(
                                fontSize: 15 * scale,
                                color: Colors.grey[400],
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          // GitHub profile
                          Row(
                            children: [
                              Container(
                                width: 26 * scale,
                                height: 26 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2 * scale,
                                  ),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://avatars.githubusercontent.com/u/62743581?v=4',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6 * scale),
                              Text(
                                'Broly-1',
                                style: TextStyle(
                                  fontSize: 13 * scale,
                                  color: Colors.grey[400],
                                  letterSpacing: 1.3,
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
          ),
        ),

        SizedBox(height: 10 * scale),

        // Title and date
        Row(
          children: [
            Expanded(
              child: Text(
                widget.project.name,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.3,
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
                  size: 11 * scale,
                  color: textColor.withOpacity(0.5),
                ),
                SizedBox(width: 3 * scale),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    color: textColor.withOpacity(0.5),
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 6 * scale),

        // Main content text
        Text(
          _extractTextPreview(widget.project.content),
          style: TextStyle(
            fontSize: 14 * scale,
            color: textColor.withOpacity(0.7),
            height: 1.5,
            letterSpacing: 0.9,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 60 * scale),

        // Tags at bottom with random colors
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: isMobile ? 13 * scale : 24 * scale,
              color: textColor.withOpacity(0.5),
            ),
            SizedBox(width: isMobile ? 5 * scale : 8 * scale),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.project.tags.take(4).map((tag) {
                    final tagColor = _getTagColor(tag);
                    return Padding(
                      padding: EdgeInsets.only(
                        right: isMobile ? 6 * scale : 8 * scale,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 * scale : 12 * scale,
                          vertical: isMobile ? 4 * scale : 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: isLightTheme
                              ? Colors.grey[800]
                              : const Color(0xFF313244),
                          borderRadius: BorderRadius.circular(
                            isMobile ? 4 * scale : 6 * scale,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: isMobile ? 11 * scale : 13 * scale,
                            color: tagColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDot(Color color, double scale) {
    return Container(
      width: 10 * scale,
      height: 10 * scale,
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

  Widget _buildMobileScreen(BuildContext context, double scale) {
    return Hero(
      tag: 'project_phone_${widget.project.id}',
      child: Material(
        color: Colors.transparent,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-0.2),
          alignment: Alignment.centerLeft,
          child: AspectRatio(
            aspectRatio: 8 / 16,
            child: Container(
              padding: EdgeInsets.all(2 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22 * scale),
                color: Theme.of(context).colorScheme.onSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24 * scale,
                    spreadRadius: 2 * scale,
                    offset: Offset(-6 * scale, 10 * scale),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20 * scale),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    // Screen content
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20 * scale),
                        child: widget.project.thumbnailUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.project.thumbnailUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildPlaceholder(context, scale),
                              )
                            : _buildPlaceholder(context, scale),
                      ),
                    ),

                    // Notch
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 22 * scale,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20 * scale),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 3 * scale),
                            width: 80 * scale,
                            height: 19 * scale,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(13 * scale),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6 * scale,
                                  height: 6 * scale,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6 * scale),
                                Container(
                                  width: 32 * scale,
                                  height: 3 * scale,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(
                                      2 * scale,
                                    ),
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
                        borderRadius: BorderRadius.circular(20 * scale),
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

  Widget _buildPlaceholder(BuildContext context, double scale) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final placeholderColor = isLightTheme
        ? Colors.grey[300]!
        : const Color(0xFF313244);

    return Container(
      color: placeholderColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 38 * scale,
          color: themeProvider.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
