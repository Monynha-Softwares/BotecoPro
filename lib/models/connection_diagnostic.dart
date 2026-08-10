import 'company.dart';
import 'identity.dart';
import 'pos_config.dart';

class ConnectionDiagnostic {
  const ConnectionDiagnostic({
    required this.odooVersion,
    required this.identity,
    required this.currentCompany,
    required this.companies,
    required this.posConfigs,
    required this.modelAccess,
  });

  final String odooVersion;
  final AuthenticatedUser identity;
  final Company currentCompany;
  final List<Company> companies;
  final List<PosConfig> posConfigs;
  final Map<String, bool> modelAccess;

  ConnectionDiagnostic copyWith({
    Company? currentCompany,
    List<PosConfig>? posConfigs,
  }) =>
      ConnectionDiagnostic(
        odooVersion: odooVersion,
        identity: identity,
        currentCompany: currentCompany ?? this.currentCompany,
        companies: companies,
        posConfigs: posConfigs ?? this.posConfigs,
        modelAccess: modelAccess,
      );
}
