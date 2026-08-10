import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: configs.length,
              itemBuilder: (context, index) {
                final config = configs[index];
                final selected = provider.selectedPosConfig?.id == config.id;
                return Card(
                  child: ListTile(
                    leading: Icon(selected ? Icons.check_circle : Icons.point_of_sale),
                    title: Text(config.name),
                    subtitle: Text(
                      'Estado da sessão: ${config.currentSessionState ?? 'não informado'}',
                    ),
                    trailing: selected ? const Chip(label: Text('Selecionado')) : null,
                    onTap: () => provider.selectPosConfig(config),
                  ),
                );
              },
            ),
    );
  }
}
