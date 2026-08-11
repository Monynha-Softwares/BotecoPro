import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pos_config.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/odoo_session_provider.dart';

class OdooPosPage extends StatelessWidget {
  const OdooPosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<OdooSessionProvider>();
    final catalog = context.watch<CatalogProvider>();
    final configs = session.diagnostic?.posConfigs ?? const [];
    final profile = session.posOperationalProfile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações POS'),
        actions: [
          IconButton(
            tooltip: 'Atualizar contexto read-only',
            onPressed: catalog.isLoading || session.isPosProfileLoading
                ? null
                : catalog.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: configs.isEmpty
          ? const Center(child: Text('Nenhuma configuração POS acessível.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (session.isPosProfileLoading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                ],
                for (final config in configs) ...[
                  _PosConfigTile(config: config, offline: catalog.isOffline),
                  const SizedBox(height: 8),
                ],
                if (session.selectedPosConfig?.restaurant == true)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.table_restaurant_outlined),
                      title: const Text('Contexto Restaurant'),
                      subtitle: Text(
                        '${catalog.restaurantFloors.length} piso(s) · '
                        '${catalog.restaurantTables.length} mesa(s) ativa(s) · '
                        'sessão: ${session.selectedPosConfig?.currentSessionState ?? 'não informada'}',
                      ),
                    ),
                  ),
                if (session.posProfileError != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_outlined),
                      title: const Text('Perfil operacional indisponível'),
                      subtitle: Text(session.posProfileError!.message),
                    ),
                  ),
                if (profile != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.manage_search_outlined),
                      title: const Text('Perfil operacional read-only'),
                      subtitle: Text([
                        'Moeda: ${profile.currency.name} (${profile.currency.symbol})',
                        !profile.pricelistReadable
                            ? 'Pricelist: sem permissão de leitura'
                            : profile.pricelist == null
                                ? 'Pricelist: desativada na POS'
                                : 'Pricelist: ${profile.pricelist!.name}',
                        if (catalog.isOffline)
                          'Sessões e pagamentos: estado dinâmico não armazenado offline'
                        else ...[
                          profile.sessionsReadable
                              ? 'Sessões não fechadas: ${profile.nonClosedSessions.length}'
                              : 'Sessões: sem permissão de leitura',
                          profile.paymentMethodsReadable
                              ? 'Métodos configurados: ${profile.paymentMethods.length}'
                              : 'Métodos de pagamento: sem permissão de leitura',
                        ],
                      ].join('\n')),
                    ),
                  ),
                if (!catalog.isOffline &&
                    profile != null &&
                    profile.nonClosedSessions.isNotEmpty)
                  for (final posSession in profile.nonClosedSessions)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: Text(posSession.name),
                        subtitle: Text(
                          'Estado: ${posSession.state} · responsável: ${posSession.userName}',
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _PosConfigTile extends StatelessWidget {
  const _PosConfigTile({required this.config, required this.offline});

  final PosConfig config;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooSessionProvider>();
    final selected = provider.selectedPosConfig?.id == config.id;
    return Card(
      child: ListTile(
        leading: Icon(selected ? Icons.check_circle : Icons.point_of_sale),
        title: Text(config.name),
        subtitle: Text(
          'Sessão: ${offline ? 'indisponível offline' : config.currentSessionState ?? 'não informada'} · '
          'catálogo: ${config.catalogProductCount ?? 'não verificado'} produto(s)',
        ),
        trailing: selected
            ? Chip(
                label: Text(
                    config.hasCatalogProducts ? 'Selecionado' : 'Sem produtos'),
              )
            : null,
        onTap: () => provider.selectPosConfig(config),
      ),
    );
  }
}
