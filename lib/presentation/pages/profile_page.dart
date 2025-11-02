import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

/// ProfilePage - Página de perfil/conta do usuário (autenticado)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: const [
          // Botão de usuário do Clerk (menu com opções, incluindo Sign out)
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(child: ClerkUserButton()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              final user = authState.user;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                child: Icon(Icons.person),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.username ?? user?.firstName ?? 'Usuário',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.emailAddresses?.firstOrNull?.emailAddress ?? 'email não disponível',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informações da Conta',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('ID: ${user?.id ?? '-'}'),
                              if ((user?.emailAddresses?.firstOrNull?.emailAddress ?? '').isNotEmpty)
                                Text('Email: ${user!.emailAddresses!.first.emailAddress}'),
                              if ((user?.username ?? '').isNotEmpty)
                                Text('Usuário: ${user!.username}'),
                              const SizedBox(height: 12),
                              const Text(
                                'Use o menu no canto superior direito para gerenciar sua conta ou sair.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            signedOutBuilder: (context, authState) {
              // Se não autenticado, mostrar UI de autenticação
              return const Center(
                child: ClerkAuthentication(),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Fim do arquivo
