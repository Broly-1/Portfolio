import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hassankamran/Extensions/extensions.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../widgets/my_appbar.dart';
import '../widgets/footer.dart';
import '../styles/theme_provider.dart';
import 'about_screen.dart';
import 'projects_screen.dart';
import 'home_content_screen.dart';

class HomePage extends StatefulWidget {
  final String initialScreen;
  final String? projectId;

  const HomePage({super.key, this.initialScreen = '_', this.projectId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentScreen;
  String? _expandProjectId;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBlurNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    currentScreen = widget.initialScreen;
    _expandProjectId = widget.projectId;

    _scrollController.addListener(() {
      final shouldShowBlur = _scrollController.offset > 10;
      if (shouldShowBlur != _showBlurNotifier.value) {
        _showBlurNotifier.value = shouldShowBlur;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBlurNotifier.dispose();
    super.dispose();
  }

  void navigateTo(String path, {String? projectId}) {
    setState(() {
      currentScreen = path;
      _expandProjectId = projectId;
    });

    // Update URL based on path
    switch (path) {
      case '_':
        context.go('/');
        break;
      case 'about':
        context.go('/about');
        break;
      case 'posts':
        context.go('/posts');
        break;
      case 'projects':
        if (projectId != null) {
          context.go('/projects?id=$projectId');
        } else {
          context.go('/projects');
        }
        break;
      case 'resume':
        context.go('/resume');
        break;
      case 'more':
        context.go('/more');
        break;
    }
  }

  Widget _buildCurrentScreen() {
    switch (currentScreen) {
      case 'about':
        return _buildAboutContent();
      case 'posts':
        return _buildPostsContent();
      case 'projects':
        return _buildProjectsContent();
      case 'resume':
        return _buildResumeContent();
      case 'more':
        return _buildMoreContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return HomeContentScreen(onNavigate: navigateTo);
  }

  Widget _buildAboutContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final scale = context.responsiveScale;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 * scale : 200 * scale),
        vertical: isMobile ? 20 : 40 * scale,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1400 * scale),
          child: const AboutContent(),
        ),
      ),
    );
  }

  Widget _buildPostsContent() {
    return const Center(child: Text('Posts - Coming Soon'));
  }

  Widget _buildProjectsContent() {
    return ProjectsScreen(initialExpandedProjectId: _expandProjectId);
  }

  Widget _buildResumeContent() {
    return const Center(child: Text('Resume - Coming Soon'));
  }

  Widget _buildMoreContent() {
    return const Center(child: Text('More - Coming Soon'));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: themeProvider.themeBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: context.isMobile ? 60 : 80),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [_buildCurrentScreen(), const Footer()],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Blurred app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showBlurNotifier,
              builder: (context, showBlur, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: showBlur
                        ? themeProvider.themeBackgroundColor.withOpacity(0.7)
                        : themeProvider.themeBackgroundColor,
                    backgroundBlendMode: showBlur ? BlendMode.srcOver : null,
                  ),
                  child: showBlur
                      ? ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.transparent,
                              child: MyAppbar(
                                currentPath: currentScreen,
                                onNavigate: navigateTo,
                              ),
                            ),
                          ),
                        )
                      : MyAppbar(
                          currentPath: currentScreen,
                          onNavigate: navigateTo,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
