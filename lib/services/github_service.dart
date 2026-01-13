import 'dart:convert';
import 'package:http/http.dart' as http;

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
}

class GitHubService {
  static const String _username = 'Broly-1';

  Future<List<GitHubCommit>> getRecentCommits({int count = 3}) async {
    try {
      print('🔍 BottomWidgets: Starting to fetch activity from GitHub...');
      final apiUrl = 'https://api.github.com/users/$_username/events/public';
      print('📡 BottomWidgets: Fetching from $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      print(
        '📊 BottomWidgets: GitHub API response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);
        print('📦 BottomWidgets: Received ${events.length} events');

        List<GitHubCommit> commits = [];

        // Find PushEvents and extract commit info
        for (var event in events) {
          if (event['type'] == 'PushEvent' && commits.length < count) {
            final repo = event['repo']['name'];
            final payload = event['payload'];
            final createdAt = event['created_at'];

            if (payload != null && payload['head'] != null) {
              final sha = payload['head'];
              final shortSha = sha.substring(0, 7);
              print('  📍 BottomWidgets: Found push event $shortSha in $repo');

              // Fetch the actual commit details from the commits API
              try {
                final commitUrl =
                    'https://api.github.com/repos/$repo/commits/$sha';
                final commitResponse = await http.get(
                  Uri.parse(commitUrl),
                  headers: {
                    'Authorization': 'Bearer $_token',
                    'Accept': 'application/vnd.github.v3+json',
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
                  print(
                    '  ✅ BottomWidgets: Added commit: ${commit.message.split('\n').first}',
                  );
                } else {
                  print(
                    '  ⚠️ BottomWidgets: Failed to fetch commit details: ${commitResponse.statusCode}',
                  );
                }
              } catch (e) {
                print('  ❌ BottomWidgets: Error fetching commit $sha: $e');
              }
            }
          }
        }

        print(
          '✨ BottomWidgets: Successfully fetched ${commits.length} commits with details',
        );
        return commits;
      } else {
        print(
          '❌ BottomWidgets: GitHub API returned status ${response.statusCode}',
        );
      }
      return [];
    } catch (e) {
      print('❌ BottomWidgets: Error fetching commits: $e');
      return [];
    }
  }
}
