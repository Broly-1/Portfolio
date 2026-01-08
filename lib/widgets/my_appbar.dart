import 'package:flutter/material.dart';
import 'package:hassankamran/Extensions/extensions.dart';
import 'package:provider/provider.dart';
import '../styles/theme_provider.dart';

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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 300.0,
        vertical: isMobile ? 8.0 : 16.0,
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
    final textColor = isLightTheme ? Colors.black87 : Colors.white;
    final accentColor = themeProvider.accentColor;

    final isHome = widget.currentPath == '_';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onHomePressed,
            child: Text(
              '~',
              style: context.textStyle.titleLgBold.copyWith(
                letterSpacing: 3,
                color: textColor,
              ),
            ),
          ),
          Text(
            isHome ? '/' : '/${widget.currentPath}',
            style: context.textStyle.titleLgBold.copyWith(
              color: accentColor,
              letterSpacing: 3,
            ),
          ),
          if (!isHome)
            Text(
              '/',
              style: context.textStyle.titleLgBold.copyWith(
                color: accentColor,
                letterSpacing: 3,
              ),
            ),
          const SizedBox(width: 4),
          FadeTransition(
            opacity: _cursorController,
            child: Container(width: 10, height: 20, color: accentColor),
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
                  width:
                      MediaQuery.of(context).size.width *
                      (isMobile ? 0.6 : 0.18),
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
                                fontSize: 24,
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.palette, color: iconColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Accent Color',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: ThemeProvider.accentColors
                                      .map(
                                        (color) => _buildColorButton(
                                          context,
                                          color,
                                          themeProvider,
                                        ),
                                      )
                                      .toList(),
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

  Widget _buildColorButton(
    BuildContext context,
    Color color,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.accentColor == color;
    return InkWell(
      onTap: () => themeProvider.setAccentColor(color),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 22)
            : null,
      ),
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
        style: TextStyle(color: textColor, fontSize: 18, letterSpacing: 1),
      ),
      onTap: () {
        Navigator.pop(context);
        onNavigate(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightTheme = themeProvider.selectedTheme != 'Mocha';
    final textColor = isLightTheme ? Colors.black87 : Colors.white;

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
              const SizedBox(width: 16),
              _HoverTextButton(
                label: 'Projects',
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onPressed: () => onNavigate('projects'),
              ),
              const SizedBox(width: 16),
              _HoverTextButton(
                label: 'Resume',
                textColor: textColor,
                hoverColor: themeProvider.accentColor,
                onPressed: () => onNavigate('resume'),
              ),
              const SizedBox(width: 16),
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: Text(
          widget.label,
          style: context.textStyle.bodyLgMedium.copyWith(
            letterSpacing: widget.letterSpacing,
            color: _isHovering ? widget.hoverColor : widget.textColor,
          ),
        ),
      ),
    );
  }
}
