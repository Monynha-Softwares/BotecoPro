import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/odoo_session_provider.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _databaseController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final connection = context.read<OdooSessionProvider>().connection;
    _urlController.text = connection?.baseUrl ?? '';
    _usernameController.text = connection?.username ?? '';
    _databaseController.text = connection?.database ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _databaseController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<OdooSessionProvider>().connect(
          baseUrl: _urlController.text,
          username: _usernameController.text,
          database: _databaseController.text,
          apiKey: _apiKeyController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conectar ao Odoo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Consumer<OdooSessionProvider>(
              builder: (context, provider, _) {
                final connecting =
                    provider.state == OdooSessionState.connecting;
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.cloud_done_outlined, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Conexão direta com Odoo Online',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A API key será guardada apenas no armazenamento seguro do dispositivo.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Instância',
                          hintText: 'https://empresa.odoo.com',
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          final uri = Uri.tryParse(value?.trim() ?? '');
                          if (uri == null ||
                              uri.scheme != 'https' ||
                              uri.host.isEmpty) {
                            return 'Informe uma URL HTTPS válida.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Utilizador',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o utilizador do Odoo.'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _databaseController,
                        decoration: const InputDecoration(
                          labelText: 'Base de dados (opcional)',
                          prefixIcon: Icon(Icons.storage_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _apiKeyController,
                        obscureText: _obscureApiKey,
                        decoration: InputDecoration(
                          labelText: 'API key',
                          prefixIcon: const Icon(Icons.key_outlined),
                          suffixIcon: IconButton(
                            tooltip: _obscureApiKey ? 'Mostrar' : 'Ocultar',
                            onPressed: () => setState(
                                () => _obscureApiKey = !_obscureApiKey),
                            icon: Icon(_obscureApiKey
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe a API key do Odoo.'
                                : null,
                      ),
                      const SizedBox(height: 20),
                      if (provider.error != null) ...[
                        Text(
                          provider.error!.message,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton.icon(
                        onPressed: connecting ? null : _connect,
                        icon: connecting
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: Text(connecting
                            ? 'A testar conexão…'
                            : 'Testar conexão'),
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: connecting
                              ? null
                              : () => context
                                  .read<OdooSessionProvider>()
                                  .enterDemoMode(),
                          child: const Text('Abrir modo demo local (debug)'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
