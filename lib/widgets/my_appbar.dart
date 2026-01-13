import 'package:flutter/material.dart';
import 'package:hassankamran/Extensions/extensions.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/theme_provider.dart';
import '../services/firebase_service.dart';

class MyAppbar extends StatelessWidget {
  final String currentPath;
  final Function(String) onNavigate;

  const MyAppbar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final scale = context.responsiveScale;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 300.0 * scale,
        vertical: isMobile ? 8.0 : 16.0 * scale,
      ),
      child: Row(
        children: [
          NavigationIndicator(
            currentPath: currentPath,
            onHomePressed: () => onNavigate('_'),
          ),
          const Spacer(),
          AppMenus(onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class NavigationIndicator extends StatefulWidget {
  final String currentPath;
  final VoidCallback onHomePressed;

  const NavigationIndicator({
    super.key,
    required this.currentPath,
    required this.onHomePressed,
  });

  @override
  State<NavigationIndicator> createState() => _NavigationIndicatorState();
}

class _NavigationIndicatorState extends State<NavigationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.black87 : Colors.grey[400]!;
    final accentColor = themeProvider.accentColor;
    final scale = context.responsiveScale;
    final isMobile = context.isMobile;

    final isHome = widget.currentPath == '_';

    // Use smaller font size on mobile to prevent overflow
    final fontSize = isMobile ? 14.0 : 18.0;
    final letterSpacing = isMobile ? 1.5 : 3.0;

    return Padding(
      padding: EdgeInsets.all(16.0 * scale),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onHomePressed,
            child: Text(
              '~',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: letterSpacing,
                color: textColor,
              ),
            ),
          ),
          Text(
            isHome ? '/' : '/${widget.currentPath}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: accentColor,
              letterSpacing: letterSpacing,
            ),
          ),
          if (!isHome)
            Text(
              '/',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: letterSpacing,
              ),
            ),
          const SizedBox(width: 4),
          FadeTransition(
            opacity: _cursorController,
            child: Container(
              width: isMobile ? 8 : 10 * scale,
              height: isMobile ? 16 : 20 * scale,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class AppMenus extends StatelessWidget {
  final Function(String) onNavigate;

  const AppMenus({super.key, required this.onNavigate});

  void _showMobileMenu(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            // Check if background is light based on luminance
            final bgColor = themeProvider.themeBackgroundColor;
            final isLightTheme = bgColor.computeLuminance() > 0.5;

            final textColor = isLightTheme ? Colors.black87 : Colors.white;
            final iconColor = isLightTheme ? Colors.black87 : Colors.white;
            final dividerColor = isLightTheme
                ? Colors.grey[300]!
                : const Color(0xFF313244);

            // Make drawer darker than theme background
            final baseColor = themeProvider.themeBackgroundColor;
            final drawerColor = Color.lerp(
              baseColor,
              Colors.black,
              isLightTheme ? 0.1 : 0.2,
            )!;

            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: drawerColor,
                child: Container(
                  width: isMobile
                      ? MediaQuery.of(context).size.width * 0.6
                      : 280,
                  height: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Navigation',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: iconColor),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: dividerColor),

                      // Accent colors
                      Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.palette, color: iconColor, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Accent Color',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    const itemSize = 35.0;
                                    const spacing = 6.0;
                                    final itemsPerRow =
                                        ((constraints.maxWidth + spacing) /
                                                (itemSize + spacing))
                                            .floor();
                                    final selectedIndex = ThemeProvider
                                        .accentColors
                                        .indexOf(themeProvider.accentColor);
                                    final totalItems =
                                        ThemeProvider.accentColors.length;

                                    // Calculate position of selected item
                                    final row = selectedIndex ~/ itemsPerRow;
                                    final col = selectedIndex % itemsPerRow;

                                    // Calculate if this is the last row and how many items it has
                                    final itemsInLastRow =
                                        totalItems % itemsPerRow;
                                    final isLastRow =
                                        row ==
                                        (totalItems / itemsPerRow).floor();
                                    final itemsInCurrentRow =
                                        isLastRow && itemsInLastRow > 0
                                        ? itemsInLastRow
                                        : itemsPerRow;

                                    // Calculate centering offset for incomplete rows
                                    final rowWidth =
                                        itemsInCurrentRow * itemSize +
                                        (itemsInCurrentRow - 1) * spacing;
                                    final maxRowWidth =
                                        itemsPerRow * itemSize +
                                        (itemsPerRow - 1) * spacing;
                                    final rowOffset =
                                        (maxRowWidth - rowWidth) / 2;

                                    final left =
                                        rowOffset + col * (itemSize + spacing);
                                    final top = row * (itemSize + spacing);

                                    return Stack(
                                      children: [
                                        // Animated border that travels between colors
                                        AnimatedPositioned(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          left: left,
                                          top: top,
                                          child: Container(
                                            width: itemSize,
                                            height: itemSize,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: themeProvider
                                                      .accentColor
                                                      .withOpacity(0.5),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Color grid
                                        Wrap(
                                          spacing: spacing,
                                          runSpacing: spacing,
                                          children: ThemeProvider.accentColors
                                              .map((color) {
                                                return InkWell(
                                                  onTap: () => themeProvider
                                                      .setAccentColor(color),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    width: itemSize,
                                                    height: itemSize,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(color: dividerColor),

                      // Navigation menu items
                      _buildMenuItem(context, 'About', 'about', textColor),
                      _buildMenuItem(
                        context,
                        'Projects',
                        'projects',
                        textColor,
                      ),
                      _buildMenuItem(context, 'Resume', 'resume', textColor),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String label,
    String route,
    Color textColor,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 14, letterSpacing: 0.8),
      ),
      onTap: () async {
        Navigator.pop(context);

        if (route == 'resume') {
          // Download resume instead of navigating
          await _downloadResume(context);
        } else {
          onNavigate(route);
        }
      },
    );
  }

  Future<void> _downloadResume(BuildContext context) async {
    try {
      final firebaseService = FirebaseService();
      final resumeUrl = await firebaseService.getResumeUrl();

      if (resumeUrl != null) {
        final uri = Uri.parse(resumeUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not open resume');
        }
      } else {
        throw Exception('Resume not available');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.black87 : Colors.white;
    final scale = context.responsiveScale;

    return context.isMobile
        ? IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () => _showMobileMenu(context),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HoverTextButton(
                label: 'About',
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onPressed: () => onNavigate('about'),
              ),
              SizedBox(width: 16 * scale),
              _HoverTextButton(
                label: 'Projects',
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onPressed: () => onNavigate('projects'),
              ),
              SizedBox(width: 16 * scale),
              _HoverTextButton(
                label: 'Resume',
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onPressed: () => _downloadResume(context),
              ),
              SizedBox(width: 16 * scale),
              _HoverTextButton(
                label: 'More...',
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                letterSpacing: 1.2,
                onPressed: () => _showMobileMenu(context),
              ),
            ],
          );
  }
}

class _HoverTextButton extends StatefulWidget {
  final String label;
  final Color textColor;
  final Color hoverColor;
  final VoidCallback onPressed;
  final double letterSpacing;

  const _HoverTextButton({
    required this.label,
    required this.textColor,
    required this.hoverColor,
    required this.onPressed,
    this.letterSpacing = 3,
  });

  @override
  State<_HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<_HoverTextButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = context.responsiveScale;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 16 * scale,
          ),
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: Text(
          widget.label,
          style: context.textStyle.bodyLgMedium.copyWith(
            letterSpacing: widget.letterSpacing * scale,
            color: _isHovering ? widget.hoverColor : widget.textColor,
          ),
        ),
      ),
    );
  }
}
