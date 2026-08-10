import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/odoo_session_provider.dart';
import '../../widgets/odoo_sync_banner.dart';

class OdooHomePage extends StatelessWidget {
  const OdooHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooSessionProvider>();
    final diagnostic = provider.diagnostic;
    return Scaffold(
      appBar: AppBar(title: const Text('BotecoPRO · Odoo')),
      body: Column(
        children: [
          const OdooSyncBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(diagnostic?.identity.name ?? 'Sem identidade'),
                    subtitle: Text(diagnostic?.identity.login ?? ''),
                  ),
                ),
                if (diagnostic != null) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.business_outlined),
                      title: Text(diagnostic.currentCompany.name),
                      subtitle: Text(
                          '${diagnostic.companies.length} empresa(s) permitida(s)'),
                      trailing: diagnostic.companies.length > 1
                          ? DropdownButton<int>(
                              value: diagnostic.currentCompany.id,
                              underline: const SizedBox.shrink(),
                              onChanged: (companyId) {
                                if (companyId == null) return;
                                final company = diagnostic.companies.firstWhere(
                                  (candidate) => candidate.id == companyId,
                                );
                                context
                                    .read<OdooSessionProvider>()
                                    .selectCompany(company);
                              },
                              items: [
                                for (final company in diagnostic.companies)
                                  DropdownMenuItem<int>(
                                    value: company.id,
                                    child: Text(company.name),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.point_of_sale_outlined),
                      title: Text(
                          '${diagnostic.posConfigs.length} configuração(ões) POS'),
                      subtitle: Text(
                        'Odoo ${diagnostic.odooVersion} · '
                        '${provider.selectedPosConfig?.catalogProductCount ?? '—'} produto(s) no catálogo selecionado',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => provider.disconnect(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Desconectar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
