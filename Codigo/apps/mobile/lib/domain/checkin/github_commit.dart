class GithubCommit {
  GithubCommit({
    required this.sha,
    required this.message,
    required this.repository,
    this.url,
    this.committedAt,
  });

  final String sha;
  final String message;
  final String repository;
  final String? url;
  final DateTime? committedAt;

  factory GithubCommit.fromJson(Map<String, dynamic> json) {
    return GithubCommit(
      sha: json['sha'] as String? ?? '',
      message: (json['message'] as String? ?? '').trim(),
      repository: json['repository'] as String? ?? '',
      url: json['url'] as String?,
      committedAt: json['committedAt'] != null
          ? DateTime.tryParse(json['committedAt'] as String)
          : null,
    );
  }
}
