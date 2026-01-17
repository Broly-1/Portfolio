import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_stats.dart';
import '../services/firebase_service.dart';
import '../styles/theme_provider.dart';

class DownloadsWidget extends StatefulWidget {
  final double scale;
  final double cardWidth;
  final bool isMobile;

  const DownloadsWidget({
    super.key,
    required this.scale,
    required this.cardWidth,
    required this.isMobile,
  });

  @override
  State<DownloadsWidget> createState() => _DownloadsWidgetState();
}

class _DownloadsWidgetState extends State<DownloadsWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  AppStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firebaseService.getAppStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M+';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K+';
    }
    return '$number+';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: widget.cardWidth,
          height: widget.isMobile ? null : 250 * widget.scale,
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
                    Icons.download_rounded,
                    size: 20 * widget.scale,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  SizedBox(width: 10 * widget.scale),
                  Text(
                    'App Downloads',
                    style: TextStyle(
                      fontSize: 18 * widget.scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24 * widget.scale),
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40 * widget.scale),
                    child: CircularProgressIndicator(
                      color: themeProvider.accentColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_stats == null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40 * widget.scale),
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 14 * widget.scale,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPlatformStat(
                      context,
                      'iOS',
                      _stats!.iosDownloads,
                      Icons.apple,
                      themeProvider,
                    ),
                    SizedBox(height: 8 * widget.scale),
                    _buildPlatformStat(
                      context,
                      'Android',
                      _stats!.androidDownloads,
                      Icons.android,
                      themeProvider,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlatformStat(
    BuildContext context,
    String platform,
    int downloads,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * widget.scale,
        vertical: 10 * widget.scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10 * widget.scale),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * widget.scale),
            decoration: BoxDecoration(
              color: themeProvider.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10 * widget.scale),
            ),
            child: Icon(
              icon,
              size: 24 * widget.scale,
              color: themeProvider.accentColor,
            ),
          ),
          SizedBox(width: 12 * widget.scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  platform,
                  style: TextStyle(
                    fontSize: 11 * widget.scale,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2 * widget.scale),
                Text(
                  _formatNumber(downloads),
                  style: TextStyle(
                    fontSize: 26 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
