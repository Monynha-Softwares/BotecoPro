class Company {
  const Company({
    required this.id,
    required this.name,
    this.currencyId,
    this.countryId,
  });

  final int id;
  final String name;
  final int? currencyId;
  final int? countryId;
}
