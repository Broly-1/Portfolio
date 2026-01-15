import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/edit_about_screen.dart';
import 'screens/manage_projects_screen.dart';
import 'screens/edit_home_screen.dart';
import 'screens/edit_resume_screen.dart';
import 'screens/edit_stats_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      // AuthWrapper will automatically redirect to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                user?.email ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.5,
          children: [
            _buildAdminCard(
              context,
              title: 'Edit Home Screen',
              icon: Icons.home,
              description:
                  'Update home heading, paragraph, and featured projects',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditHomeScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Edit About Section',
              icon: Icons.person,
              description: 'Update profile image and about content',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditAboutScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Projects',
              icon: Icons.work,
              description: 'Manage portfolio projects',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageProjectsScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Resume',
              icon: Icons.picture_as_pdf,
              description: 'Upload and manage resume PDF',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditResumeScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Skills',
              icon: Icons.code,
              description: 'Update skills and technologies',
              onTap: () {
                // TODO: Navigate to skills management
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
              },
            ),
            _buildAdminCard(
              context,
              title: 'App Downloads',
              icon: Icons.download,
              description: 'Update iOS and Android download counts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditStatsScreen(),
                  ),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Contact',
              icon: Icons.email,
              description: 'Manage contact information',
              onTap: () {
                // TODO: Navigate to contact management
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
