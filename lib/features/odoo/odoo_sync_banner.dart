import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/odoo/odoo_provider.dart';

class OdooSyncBanner extends StatelessWidget {
  const OdooSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();
    return OdooSyncStatus(
      isOffline: provider.isOffline,
      synchronizedAt: provider.lastSynchronizedAt,
      onRetry: provider.reconnect,
    );
  }
}

class OdooSyncStatus extends StatelessWidget {
  const OdooSyncStatus({
    required this.isOffline,
    required this.synchronizedAt,
    this.onRetry,
    super.key,
  });

  final bool isOffline;
  final DateTime? synchronizedAt;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (!isOffline && synchronizedAt == null) {
      return const SizedBox.shrink();
    }
    final date = synchronizedAt == null
        ? null
        : DateFormat('dd/MM/yyyy HH:mm').format(synchronizedAt!.toLocal());
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isOffline ? colors.errorContainer : colors.secondaryContainer,
      child: ListTile(
        dense: true,
        leading: Icon(isOffline ? Icons.cloud_off : Icons.cloud_done),
        title: Text(isOffline ? 'Offline · Dados locais' : 'Online'),
        subtitle: date == null ? null : Text('Última sincronização: $date'),
        trailing: isOffline
            ? TextButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              )
            : null,
      ),
    );
  }
}
