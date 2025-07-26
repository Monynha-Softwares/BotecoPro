import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart';
import 'services/user_provider.dart';
import 'services/service_provider.dart';
import 'services/sound_provider.dart';
import 'widgets/shared_widgets.dart';
import 'theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final soundProvider = Provider.of<SoundProvider>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configurações'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context: context,
            title: 'Perfil',
            icon: Icons.person,
            children: [
              _buildProfileCard(context, userProvider),
              const SizedBox(height: 16),
              ActionButton(
                icon: Icons.edit,
                label: 'Editar Perfil',
                onPressed: () => _showEditProfileDialog(context),
                backgroundColor: botecoWine,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            title: 'Aparência',
            icon: Icons.palette,
            children: [
              _buildThemeSettings(context, themeProvider),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            title: 'Sincronização',
            icon: Icons.sync,
            children: [
              _buildSyncSettings(context, serviceProvider),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            title: 'Notificações',
            icon: Icons.notifications,
            children: [
              SwitchListTile(
                title: const Text('Ativar notificações'),
                subtitle: const Text('Receber alertas de estoque e pedidos'),
                value: userProvider.notificationsEnabled,
                onChanged: (value) => userProvider.setNotificationsEnabled(value),
                activeColor: botecoWine,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            title: 'Idioma',
            icon: Icons.language,
            children: [
              ListTile(
                title: const Text('Idioma do aplicativo'),
                subtitle: Text(userProvider.language),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageSelector(context, userProvider),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            title: 'Sons e Efeitos',
            icon: Icons.music_note,
            children: [
              SwitchListTile(
                title: const Text('Efeitos sonoros'),
                subtitle: const Text('Sons temáticos de boteco'),
                value: soundProvider.isSoundEnabled,
                onChanged: (value) => soundProvider.toggleSound(value),
                activeColor: botecoWine,
              ),
              ListTile(
                title: const Text('Testar sons'),
                subtitle: const Text('Ouça os efeitos sonoros'),
                trailing: const Icon(Icons.volume_up),
                onTap: () => _showSoundTestDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            title: 'Sobre',
            icon: Icons.info_outline,
            children: [
              ListTile(
                title: const Text('Versão do aplicativo'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                title: const Text('Sobre o Boteco PRO'),
                subtitle: const Text('Informações e licenças'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutConfirmation(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sair do Sistema', 
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: botecoWine,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveY(begin: 20, duration: const Duration(milliseconds: 300));
  }

  Widget _buildProfileCard(BuildContext context, UserProvider userProvider) {
    final user = userProvider.userProfile;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: botecoWine.withOpacity(0.2),
            radius: 40,
            child: Icon(
              Icons.person,
              size: 40,
              color: botecoWine,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 8),
                Text(
                  '${user.establishment} - ${user.position}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Usar tema do sistema'),
          subtitle: const Text('Seguir configurações do dispositivo'),
          value: themeProvider.isSystemMode,
          onChanged: (value) {
            if (value) {
              themeProvider.setThemeMode(ThemeMode.system);
            } else {
              themeProvider.setThemeMode(
                  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light);
            }
          },
          activeColor: botecoWine,
        ),
        if (!themeProvider.isSystemMode) ...[  
          SwitchListTile(
            title: const Text('Modo escuro'),
            subtitle: const Text('Utilizar tema escuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            activeColor: botecoWine,
          ),
        ],
      ],
    );
  }

  Widget _buildSyncSettings(BuildContext context, ServiceProvider serviceProvider) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Modo online'),
          subtitle: Text(
            serviceProvider.isOnline 
                ? 'Conectado ao servidor'
                : 'Modo offline - usando dados locais',
          ),
          value: serviceProvider.isOnline,
          onChanged: (value) => serviceProvider.toggleOnlineMode(value),
          activeColor: botecoWine,
        ),
        if (serviceProvider.isOnline) ...[  
          ListTile(
            title: const Text('Última sincronização'),
            subtitle: Text(
              serviceProvider.lastSyncTime != null
                  ? formatDateTime(serviceProvider.lastSyncTime!)
                  : 'Nunca sincronizado',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: serviceProvider.isSyncing
                  ? null
                  : () => serviceProvider.syncData(),
            ),
          ),
          if (serviceProvider.isSyncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userProfile;
    
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final establishmentController = TextEditingController(text: user.establishment);
    final positionController = TextEditingController(text: user.position);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: establishmentController,
                decoration: const InputDecoration(
                  labelText: 'Estabelecimento',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user profile
              final newProfile = UserProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                establishment: establishmentController.text.trim(),
                position: positionController.text.trim(),
              );
              
              userProvider.updateUserProfile(newProfile);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil atualizado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Salvar',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Selecionar Idioma'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              userProvider.setLanguage('Português (Brasil)');
              Navigator.pop(context);
            },
            child: const Text('Português (Brasil)'),
          ),
          SimpleDialogOption(
            onPressed: () {
              userProvider.setLanguage('English (US)');
              Navigator.pop(context);
            },
            child: const Text('English (US)'),
          ),
          SimpleDialogOption(
            onPressed: () {
              userProvider.setLanguage('Español');
              Navigator.pop(context);
            },
            child: const Text('Español'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: botecoWine.withOpacity(0.2),
              radius: 50,
              child: Icon(
                Icons.sports_bar,
                size: 60,
                color: botecoWine,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Boteco PRO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Versão 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Boteco PRO é um sistema de gestão completo para bares e restaurantes. '
              'Gerencie mesas, produtos, fornecedores, estoques e muito mais.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2023 Boteco PRO\nTodos os direitos reservados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showSoundTestDialog(BuildContext context) {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teste de Sons'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Clique nos botões abaixo para testar os efeitos sonoros:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => soundProvider.playMesaAberta(),
                  child: const Text('Mesa Aberta'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playMesaFechada(),
                  child: const Text('Mesa Fechada'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playPedidoAdicionado(),
                  child: const Text('Pedido Adicionado'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playPedidoEntregue(),
                  child: const Text('Pedido Entregue'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playVendaFechada(),
                  child: const Text('Venda Fechada'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playProdutoAdicionado(),
                  child: const Text('Produto Adicionado'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playSucesso(),
                  child: const Text('Sucesso'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playErro(),
                  child: const Text('Erro'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playNotificacao(),
                  child: const Text('Notificação'),
                ),
                ElevatedButton(
                  onPressed: () => soundProvider.playNavegacao(),
                  child: const Text('Navegação'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Sistema'),
        content: const Text('Tem certeza que deseja sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Play sound effect
              soundProvider.playNavegacao();
              
              // Reset service provider to offline mode
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              serviceProvider.toggleOnlineMode(false);
              
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout realizado com sucesso!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}