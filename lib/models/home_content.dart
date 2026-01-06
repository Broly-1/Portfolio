class HomeContent {
  final String id;
  final String heading;
  final String paragraph;
  final String? githubUrl;
  final String? linkedinUrl;
  final List<String> featuredProjectIds;

  HomeContent({
    required this.id,
    required this.heading,
    required this.paragraph,
    this.githubUrl,
    this.linkedinUrl,
    required this.featuredProjectIds,
  });

  factory HomeContent.fromFirestore(Map<String, dynamic> data, String id) {
    return HomeContent(
      id: id,
      heading: data['heading'] ?? '',
      paragraph: data['paragraph'] ?? '',
      githubUrl: data['githubUrl'],
      linkedinUrl: data['linkedinUrl'],
      featuredProjectIds: List<String>.from(data['featuredProjectIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'heading': heading,
      'paragraph': paragraph,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'featuredProjectIds': featuredProjectIds,
    };
  }
}
