import 'package:flutter/material.dart';
import 'package:hassankamran/services/github_service.dart';
import 'package:hassankamran/widgets/downloads_widget.dart';
import 'package:hassankamran/widgets/location_map_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/theme_provider.dart';

class BottomWidgets extends StatefulWidget {
  final double scale;
  final double maxWidth;

  const BottomWidgets({super.key, required this.scale, required this.maxWidth});

  @override
  State<BottomWidgets> createState() => _BottomWidgetsState();
}

class _BottomWidgetsState extends State<BottomWidgets>
    with AutomaticKeepAliveClientMixin {
  final GitHubService _githubService = GitHubService();
  List<GitHubCommit> _commits = [];
  bool _isLoadingCommits = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchCommits();
  }

  Future<void> _fetchCommits() async {
    if (!mounted) return;
    setState(() => _isLoadingCommits = true);
    final commits = await _githubService.getRecentCommits(count: 4);
    if (!mounted) return;
    setState(() {
      _commits = commits;
      _isLoadingCommits = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // Match featured projects card width calculation exactly
    final spacing = 20.0 * widget.scale;
    final projectCardWidth = widget.maxWidth.clamp(
      300.0 * widget.scale,
      600.0 * widget.scale,
    );

    // Small cards (Theme & Connect) together = one project card width
    final smallCardWidth = (projectCardWidth - spacing) / 2;

    // Downloads widget is square, same height as commits
    final downloadsSquareSize = 250.0 * widget.scale;

    if (isMobile) {
      // Mobile: stack vertically
      return Column(
        children: [
          _buildAccentCard(context, true, double.infinity),
          SizedBox(height: spacing),
          _buildConnectCard(context, true, double.infinity),
          SizedBox(height: spacing),
          _buildCommitsCard(context, true, double.infinity),
          SizedBox(height: spacing),
          LocationMapWidget(
            scale: widget.scale,
            cardWidth: double.infinity,
            isMobile: true,
          ),
          SizedBox(height: spacing),
          DownloadsWidget(
            scale: widget.scale,
            cardWidth: double.infinity,
            isMobile: true,
          ),
        ],
      );
    }

    // Desktop: Simple wrap layout with explicit widths
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAccentCard(context, false, smallCardWidth),
            SizedBox(width: spacing),
            _buildConnectCard(context, false, smallCardWidth),
          ],
        ),
        _buildCommitsCard(context, false, projectCardWidth),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocationMapWidget(
              scale: widget.scale,
              cardWidth: downloadsSquareSize,
              isMobile: false,
            ),
            SizedBox(width: spacing),
            DownloadsWidget(
              scale: widget.scale,
              cardWidth: downloadsSquareSize,
              isMobile: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccentCard(
    BuildContext context,
    bool isMobile,
    double cardWidth,
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: cardWidth,
          height: isMobile ? null : 250 * widget.scale,
          padding: EdgeInsets.all(24 * widget.scale),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(16 * widget.scale),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 20 * widget.scale,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  SizedBox(width: 10 * widget.scale),
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 18 * widget.scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * widget.scale),
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemSize = 36 * widget.scale;
                    final spacing = 10 * widget.scale;
                    final itemsPerRow =
                        ((constraints.maxWidth + spacing) /
                                (itemSize + spacing))
                            .floor();
                    final selectedIndex = ThemeProvider.accentColors.indexOf(
                      themeProvider.accentColor,
                    );
                    final totalItems = ThemeProvider.accentColors.length;

                    // Calculate position of selected item
                    final row = selectedIndex ~/ itemsPerRow;
                    final col = selectedIndex % itemsPerRow;

                    // Calculate if this is the last row and how many items it has
                    final itemsInLastRow = totalItems % itemsPerRow;
                    final isLastRow = row == (totalItems / itemsPerRow).floor();
                    final itemsInCurrentRow = isLastRow && itemsInLastRow > 0
                        ? itemsInLastRow
                        : itemsPerRow;

                    // Calculate centering offset for incomplete rows
                    final rowWidth =
                        itemsInCurrentRow * itemSize +
                        (itemsInCurrentRow - 1) * spacing;
                    final maxRowWidth =
                        itemsPerRow * itemSize + (itemsPerRow - 1) * spacing;
                    final rowOffset = (maxRowWidth - rowWidth) / 2;

                    final left = rowOffset + col * (itemSize + spacing);
                    final top = row * (itemSize + spacing);

                    return Stack(
                      children: [
                        // Animated border that travels between colors
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: left,
                          top: top,
                          child: Container(
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                8 * widget.scale,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: themeProvider.accentColor.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Color grid
                        Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.center,
                          children: ThemeProvider.accentColors.map((color) {
                            return GestureDetector(
                              onTap: () => themeProvider.setAccentColor(color),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(
                                      8 * widget.scale,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectCard(
    BuildContext context,
    bool isMobile,
    double cardWidth,
  ) {
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(24 * widget.scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B26),
        borderRadius: BorderRadius.circular(16 * widget.scale),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20 * widget.scale,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(width: 10 * widget.scale),
              Text(
                "Let's Connect",
                style: TextStyle(
                  fontSize: 18 * widget.scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * widget.scale),
          Text(
            'Always open to interesting projects and conversations.',
            style: TextStyle(
              fontSize: 14 * widget.scale,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          SizedBox(height: 20 * widget.scale),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return InkWell(
                onTap: () =>
                    _launchUrl('https://cal.com/hassan-kamran-uaea8u/30min'),
                borderRadius: BorderRadius.circular(8 * widget.scale),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12 * widget.scale),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8 * widget.scale),
                    border: Border.all(
                      color: themeProvider.accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18 * widget.scale,
                        color: themeProvider.accentColor,
                      ),
                      SizedBox(width: 8 * widget.scale),
                      Text(
                        'Book a Chat',
                        style: TextStyle(
                          fontSize: 15 * widget.scale,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommitsCard(
    BuildContext context,
    bool isMobile,
    double cardWidth,
  ) {
    return Container(
      width: cardWidth,
      height: isMobile ? null : 250 * widget.scale,
      padding: EdgeInsets.all(24 * widget.scale),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16 * widget.scale),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.commit,
                size: 20 * widget.scale,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(width: 10 * widget.scale),
              Text(
                'Recent Commits',
                style: TextStyle(
                  fontSize: 18 * widget.scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _launchUrl('https://github.com/Broly-1'),
                borderRadius: BorderRadius.circular(4 * widget.scale),
                child: Padding(
                  padding: EdgeInsets.all(4 * widget.scale),
                  child: Text(
                    '[info]',
                    style: TextStyle(
                      fontSize: 13 * widget.scale,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * widget.scale),
          if (_isLoadingCommits)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20 * widget.scale),
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        themeProvider.accentColor,
                      ),
                      strokeWidth: 2,
                    );
                  },
                ),
              ),
            )
          else if (_commits.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20 * widget.scale),
                child: Text(
                  'No recent commits found',
                  style: TextStyle(
                    fontSize: 14 * widget.scale,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            ...(isMobile
                ? [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _commits
                              .map(
                                (commit) =>
                                    _buildCommitRow(context, commit, isMobile),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _commits
                                .map(
                                  (commit) => _buildCommitRow(
                                    context,
                                    commit,
                                    isMobile,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ]),
          if (_commits.isNotEmpty) ...[
            SizedBox(height: 16 * widget.scale),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return InkWell(
                  onTap: () => _launchUrl('https://github.com/Broly-1'),
                  borderRadius: BorderRadius.circular(4 * widget.scale),
                  child: Row(
                    children: [
                      Text(
                        'View on GitHub',
                        style: TextStyle(
                          fontSize: 14 * widget.scale,
                          color: themeProvider.accentColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 6 * widget.scale),
                      Icon(
                        Icons.open_in_new,
                        size: 14 * widget.scale,
                        color: themeProvider.accentColor,
                      ),
                      const Spacer(),
                      _buildLanguageBar(themeProvider),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommitRow(
    BuildContext context,
    GitHubCommit commit,
    bool isMobile,
  ) {
    final message = commit.message.split('\n').first;
    final truncatedMessage = message.length > 50
        ? '${message.substring(0, 50)}...'
        : message;

    return Padding(
      padding: EdgeInsets.only(bottom: 8 * widget.scale),
      child: Row(
        children: [
          Text(
            '${commit.repoName}:',
            style: TextStyle(
              fontSize: 14 * widget.scale,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8 * widget.scale),
          Expanded(
            child: Text(
              truncatedMessage,
              style: TextStyle(
                fontSize: 14 * widget.scale,
                color: Colors.white.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12 * widget.scale),
          if (commit.additions > 0)
            Text(
              '+${commit.additions}',
              style: TextStyle(
                fontSize: 13 * widget.scale,
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
            ),
          if (commit.additions > 0 && commit.deletions > 0)
            Text(
              ' / ',
              style: TextStyle(
                fontSize: 13 * widget.scale,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          if (commit.deletions > 0)
            Text(
              '-${commit.deletions}',
              style: TextStyle(
                fontSize: 13 * widget.scale,
                color: const Color(0xFFF44336),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageBar(ThemeProvider themeProvider) {
    // Language distribution with colors
    final languages = [
      {'name': 'Dart', 'color': const Color(0xFF00D4FF), 'percent': 60},
      {'name': 'Kotlin', 'color': const Color(0xFFFF6B35), 'percent': 20},
      {'name': 'Swift', 'color': const Color(0xFF5B8DEE), 'percent': 15},
      {'name': 'C++', 'color': const Color(0xFFFF5722), 'percent': 3},
      {'name': 'CMake', 'color': const Color(0xFF8BC34A), 'percent': 1},
      {'name': 'HTML', 'color': const Color(0xFFFFC107), 'percent': 1},
    ];

    return MouseRegion(
      cursor: SystemMouseCursors.help,
      child: Container(
        height: 8 * widget.scale,
        width: 150 * widget.scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4 * widget.scale),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4 * widget.scale),
          child: Row(
            children: languages
                .map(
                  (lang) => Expanded(
                    flex: lang['percent'] as int,
                    child: Tooltip(
                      message: '${lang['name']} ${lang['percent']}%',
                      preferBelow: false,
                      textStyle: TextStyle(
                        fontSize: 12 * widget.scale,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(8 * widget.scale),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      padding: EdgeInsets.all(12 * widget.scale),
                      child: Container(color: lang['color'] as Color),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error silently
    }
  }
}
