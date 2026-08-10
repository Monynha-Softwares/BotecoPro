class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.name,
    required this.login,
    required this.companyId,
    required this.companyIds,
    this.language,
    this.timezone,
  });

  final int id;
  final String name;
  final String login;
  final int companyId;
  final List<int> companyIds;
  final String? language;
  final String? timezone;
}
