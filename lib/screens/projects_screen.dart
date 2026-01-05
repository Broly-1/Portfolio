import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/services/firebase_service.dart';
import 'package:hassankamran/widgets/project_card.dart';
import 'package:hassankamran/screens/project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: _firebaseService.streamProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading projects',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add projects from the admin app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(context),
            vertical: 40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.folder_copy_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Projects Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = _getCrossAxisCount(
                        constraints.maxWidth,
                      );

                      final spacing = 20.0;

                      return Column(
                        children: [
                          for (
                            int i = 0;
                            i < projects.length;
                            i += crossAxisCount
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i + crossAxisCount < projects.length
                                    ? spacing
                                    : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (
                                    int j = 0;
                                    j < crossAxisCount &&
                                        i + j < projects.length;
                                    j++
                                  )
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: j < crossAxisCount - 1
                                              ? spacing
                                              : 0,
                                        ),
                                        child: ProjectCard(
                                          project: projects[i + j],
                                          onTap: () => _navigateToProjectDetail(
                                            context,
                                            projects[i + j],
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Fill remaining space if last row is incomplete
                                  for (
                                    int k = 0;
                                    k <
                                        crossAxisCount -
                                            ((projects.length - i).clamp(
                                              0,
                                              crossAxisCount,
                                            ));
                                    k++
                                  )
                                    Expanded(child: SizedBox()),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 40;
    if (width > 900) return 30;
    if (width > 600) return 20;
    return 16;
  }

  int _getCrossAxisCount(double width) {
    if (width > 1400) return 3;
    if (width > 700) return 2;
    return 1;
  }

  void _navigateToProjectDetail(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
  }
}
