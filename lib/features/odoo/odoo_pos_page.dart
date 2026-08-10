import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/odoo/odoo_connection.dart';
import '../../core/odoo/odoo_provider.dart';

class OdooPosPage extends StatelessWidget {
  const OdooPosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();
    final configs = provider.diagnostic?.posConfigs ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações POS')),
      body: configs.isEmpty
          ? const Center(child: Text('Nenhuma configuração POS acessível.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final config in configs) ...[
                  _PosConfigTile(config: config),
                  const SizedBox(height: 8),
                ],
                if (provider.selectedPosConfig?.restaurant == true)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.table_restaurant_outlined),
                      title: const Text('Contexto Restaurant'),
                      subtitle: Text(
                        '${provider.restaurantFloors.length} piso(s) · '
                        '${provider.restaurantTables.length} mesa(s) ativa(s) · '
                        'sessão: ${provider.selectedPosConfig?.currentSessionState ?? 'não informada'}',
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PosConfigTile extends StatelessWidget {
  const _PosConfigTile({required this.config});

  final OdooPosConfig config;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();
    final selected = provider.selectedPosConfig?.id == config.id;
    return Card(
      child: ListTile(
        leading: Icon(selected ? Icons.check_circle : Icons.point_of_sale),
        title: Text(config.name),
        subtitle: Text(
          'Sessão: ${config.currentSessionState ?? 'não informado'} · '
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
