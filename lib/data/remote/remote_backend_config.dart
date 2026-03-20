enum BackendProvider { mocked, supabase, fastApi }

class RemoteBackendConfig {
  const RemoteBackendConfig({
    required this.provider,
    this.baseUrl,
    this.projectId,
    this.enableSync = false,
  });

  final BackendProvider provider;
  final String? baseUrl;
  final String? projectId;
  final bool enableSync;

  static const mocked = RemoteBackendConfig(provider: BackendProvider.mocked);

  bool get isRemoteEnabled =>
      enableSync && provider != BackendProvider.mocked && (baseUrl?.isNotEmpty ?? false);
}
