import 'package:flutter/material.dart';
import '../widgets/my_appbar.dart';
import 'about_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentScreen = '_';

  void navigateTo(String path) {
    setState(() {
      currentScreen = path;
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
    return const Center(
      child: Text('Welcome to my portfolio', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildAboutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 40),
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
    return const Center(child: Text('Projects - Coming Soon'));
  }

  Widget _buildResumeContent() {
    return const Center(child: Text('Resume - Coming Soon'));
  }

  Widget _buildMoreContent() {
    return const Center(child: Text('More - Coming Soon'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MyAppbar(currentPath: currentScreen, onNavigate: navigateTo),
          Expanded(child: _buildCurrentScreen()),
        ],
      ),
    );
  }
}
