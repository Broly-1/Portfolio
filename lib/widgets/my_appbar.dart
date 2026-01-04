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
        vertical: 30.0,
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
    final accentColor = isLightTheme
        ? const Color.fromARGB(255, 70, 100, 120)
        : const Color.fromARGB(255, 128, 154, 175);

    // Show cursor only when on home (currentPath is '_')
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
          if (isHome) ...[
            const SizedBox(width: 4),
            FadeTransition(
              opacity: _cursorController,
              child: Container(width: 10, height: 20, color: accentColor),
            ),
          ],
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
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: const Color(0xFF1E1E2E),
            child: Container(
              width:
                  MediaQuery.of(context).size.width * (isMobile ? 0.6 : 0.25),
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
                        const Text(
                          'Navigation',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF313244)),

                  // Theme Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.palette, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Theme',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Theme buttons
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Row(
                              children: [
                                _buildThemeButton(
                                  context,
                                  'Latte',
                                  themeProvider,
                                ),
                                const SizedBox(width: 8),
                                _buildThemeButton(
                                  context,
                                  'Frappe',
                                  themeProvider,
                                ),
                                const SizedBox(width: 8),
                                _buildThemeButton(
                                  context,
                                  'Macchiato',
                                  themeProvider,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return _buildThemeButton(
                              context,
                              'Mocha',
                              themeProvider,
                              fullWidth: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Accent colors
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
                  const Divider(color: Color(0xFF313244)),

                  // Navigation menu items
                  _buildMenuItem(context, 'About', 'about'),
                  _buildMenuItem(context, 'Posts', 'posts'),
                  _buildMenuItem(context, 'Projects', 'projects'),
                  _buildMenuItem(context, 'Resume', 'resume'),
                ],
              ),
            ),
          ),
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

  Widget _buildThemeButton(
    BuildContext context,
    String theme,
    ThemeProvider themeProvider, {
    bool fullWidth = false,
  }) {
    final isSelected = themeProvider.selectedTheme == theme;
    final child = InkWell(
      onTap: () => themeProvider.setTheme(theme),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF313244) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? themeProvider.accentColor
                : const Color(0xFF313244),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            theme,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );

    return fullWidth ? child : Expanded(child: child);
  }

  Widget _buildColorButton(
    BuildContext context,
    Color color,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.accentColor == color;
    return InkWell(
      onTap: () => themeProvider.setAccentColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String label, String route) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          title: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onNavigate(route);
          },
        );
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
