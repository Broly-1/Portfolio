import 'package:flutter/material.dart';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/services/firebase_service.dart';
import 'package:hassankamran/widgets/project_card.dart';
import 'package:hassankamran/widgets/project_detail_content.dart';

class ProjectsScreen extends StatefulWidget {
  final String? initialExpandedProjectId;

  const ProjectsScreen({super.key, this.initialExpandedProjectId});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _expandedProjectId;

  @override
  void initState() {
    super.initState();
    _expandedProjectId = widget.initialExpandedProjectId;
  }

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

                  // Projects Grid or Expanded Detail
                  if (_expandedProjectId != null)
                    Builder(
                      builder: (context) {
                        final expandedProject = projects
                            .cast<Project?>()
                            .firstWhere(
                              (p) => p?.id == _expandedProjectId,
                              orElse: () => null,
                            );
                        if (expandedProject != null) {
                          return _buildExpandedDetail(context, expandedProject);
                        }
                        return const SizedBox.shrink();
                      },
                    )
                  else
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
                                padding: EdgeInsets.only(bottom: spacing),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                              onTap: () =>
                                                  _toggleProjectExpansion(
                                                    projects[i + j].id,
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

  void _toggleProjectExpansion(String projectId) {
    setState(() {
      if (_expandedProjectId == projectId) {
        _expandedProjectId = null;
      } else {
        _expandedProjectId = projectId;
      }
    });
  }

  Widget _buildExpandedDetail(BuildContext context, Project project) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ProjectDetailContent(
          project: project,
          showCloseButton: true,
          onClose: () => _toggleProjectExpansion(project.id),
        ),
      ),
    );
  }
}
