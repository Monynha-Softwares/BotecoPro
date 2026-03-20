import 'remote_backend_config.dart';

class RemoteSyncService {
  const RemoteSyncService(this.config);

  final RemoteBackendConfig config;

  bool get canSync => config.isRemoteEnabled;

  Future<void> enqueueBootstrapSync() async {
    if (!canSync) {
      return;
    }

    // Placeholder intencional para a futura sincronização real.
    // Esta camada existe para impedir acoplamento direto da UI com HTTP/Supabase.
  }
}
