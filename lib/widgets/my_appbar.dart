import 'package:flutter/material.dart';
import 'package:hassankamran/Extensions/extensions.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 300.0, vertical: 16.0),
      child: Row(
        children: [
          NavigationIndicator(
            currentPath: currentPath,
            onHomePressed: () => onNavigate('_'),
          ),
          Spacer(),
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
              style: context.textStyle.titleLgBold.copyWith(letterSpacing: 3),
            ),
          ),
          Text(
            isHome ? '/' : '/${widget.currentPath}',
            style: context.textStyle.titleLgBold.copyWith(
              color: const Color.fromARGB(255, 128, 154, 175),
              letterSpacing: 3,
            ),
          ),
          if (isHome) ...[
            const SizedBox(width: 4),
            FadeTransition(
              opacity: _cursorController,
              child: Container(
                width: 10,
                height: 20,
                color: const Color.fromARGB(255, 128, 154, 175),
              ),
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

  @override
  Widget build(BuildContext context) {
    return context.isMobile
        ? IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Show drawer or menu
            },
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onNavigate('about'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'About',
                  style: context.textStyle.bodyLgMedium.copyWith(
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => onNavigate('projects'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Projects',
                  style: context.textStyle.bodyLgMedium.copyWith(
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => onNavigate('resume'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Resume',
                  style: context.textStyle.bodyLgMedium.copyWith(
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => onNavigate('more'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'More...',
                  style: context.textStyle.bodyLgMedium.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          );
  }
}
