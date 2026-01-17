import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cache_service.dart';
import 'firebase_service.dart';

class GitHubCommit {
  final String message;
  final String authorName;
  final DateTime date;
  final String sha;
  final int additions;
  final int deletions;
  final String repoName;

  GitHubCommit({
    required this.message,
    required this.authorName,
    required this.date,
    required this.sha,
    required this.additions,
    required this.deletions,
    required this.repoName,
  });

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    return GitHubCommit(
      message: json['commit']['message'] ?? '',
      authorName: json['commit']['author']['name'] ?? 'Unknown',
      date: DateTime.parse(json['commit']['author']['date']),
      sha: json['sha'] ?? '',
      additions: json['stats']?['additions'] ?? 0,
      deletions: json['stats']?['deletions'] ?? 0,
      repoName: json['repoName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'authorName': authorName,
      'date': date.toIso8601String(),
      'sha': sha,
      'additions': additions,
      'deletions': deletions,
      'repoName': repoName,
    };
  }
}

class GitHubService {
  static const String _username = 'Broly-1';
  final CacheService _cache = CacheService();
  final FirebaseService _firebaseService = FirebaseService();
  static const _cacheDuration = Duration(
    hours: 1,
  ); // Cache for 1 hour to reduce API calls

  Future<List<GitHubCommit>> getRecentCommits({int count = 3}) async {
    // Check cache first
    final cacheKey = 'github_commits_$count';
    final cached = _cache.get<List<GitHubCommit>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final apiUrl = 'https://api.github.com/users/$_username/events/public';

      // Get GitHub token from Firebase
      final token = await _firebaseService.getGitHubToken();

      // Build headers with optional authentication
      final headers = {
        'Accept': 'application/vnd.github.v3+json',
        if (token != null) 'Authorization': 'token $token',
      };

      final response = await http
          .get(Uri.parse(apiUrl), headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('GitHub API request timed out');
            },
          );

      // Check for rate limit
      if (response.statusCode == 403) {
        final rateLimitRemaining = response.headers['x-ratelimit-remaining'];
        if (rateLimitRemaining == '0') {
          // Return cached data even if expired, or empty list
          final expiredCache = _cache.get<List<GitHubCommit>>(cacheKey);
          return expiredCache ?? [];
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);

        List<GitHubCommit> commits = [];

        // Find PushEvents and extract commit info
        for (var event in events) {
          if (event['type'] == 'PushEvent' && commits.length < count) {
            final repo = event['repo']['name'];
            final payload = event['payload'];
            final createdAt = event['created_at'];

            if (payload != null && payload['head'] != null) {
              final sha = payload['head'];

              // Fetch the actual commit details from the commits API
              try {
                final commitUrl =
                    'https://api.github.com/repos/$repo/commits/$sha';
                final commitResponse = await http.get(
                  Uri.parse(commitUrl),
                  headers: {
                    'Accept': 'application/vnd.github.v3+json',
                    if (token != null) 'Authorization': 'token $token',
                  },
                );

                if (commitResponse.statusCode == 200) {
                  final commitData = json.decode(commitResponse.body);
                  final commit = GitHubCommit(
                    message: commitData['commit']['message'] ?? 'No message',
                    authorName:
                        commitData['commit']['author']['name'] ?? 'Unknown',
                    date: DateTime.parse(createdAt),
                    sha: sha,
                    additions: commitData['stats']?['additions'] ?? 0,
                    deletions: commitData['stats']?['deletions'] ?? 0,
                    repoName: repo.split('/').last,
                  );
                  commits.add(commit);
                }
              } catch (e) {}
            }
          }
        }

        // Cache the results for 1 hour
        _cache.set(cacheKey, commits, duration: _cacheDuration);

        return commits;
      }
      return [];
    } catch (e) {
      // Try to return stale cached data on error
      final staleCache = _cache.get<List<GitHubCommit>>(cacheKey);
      if (staleCache != null) {
        return staleCache;
      }

      return [];
    }
  }
}
