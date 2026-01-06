import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/my_appbar.dart';
import '../widgets/footer.dart';
import '../styles/theme_provider.dart';
import 'about_screen.dart';
import 'projects_screen.dart';
import 'home_content_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentScreen = '_';
  String? _expandProjectId;

  void navigateTo(String path, {String? projectId}) {
    setState(() {
      currentScreen = path;
      _expandProjectId = projectId;
    });
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 200),
        vertical: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.themeBackgroundColor,
          body: Column(
            children: [
              MyAppbar(currentPath: currentScreen, onNavigate: navigateTo),
              Expanded(child: _buildCurrentScreen()),
              const Footer(),
            ],
          ),
        );
      },
    );
  }
}
