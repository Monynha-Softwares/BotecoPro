import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/service_provider.dart';
import '../services/theme_provider.dart';
import '../services/user_provider.dart';
import '../services/sound_provider.dart';
import '../theme.dart';
import '../main.dart';
import '../reports_page.dart';
import '../settings_page.dart';

class AppDrawer extends StatelessWidget {
const AppDrawer({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
final serviceProvider = Provider.of<ServiceProvider>(context);

return Drawer(
child: Column(
children: [
_buildDrawerHeader(context),
Expanded(
child: ListView(
padding: EdgeInsets.zero,
children: [
_buildSyncTile(context, serviceProvider),
const Divider(),
_buildNavigationTile(
context: context,
title: 'Perfil do Usuário',
icon: Icons.person,
onTap: () {
Navigator.pop(context);
_showProfileDialog(context);
},
),
_buildNavigationTile(
context: context,
title: 'Configurações',
icon: Icons.settings,
onTap: () {
Navigator.pop(context);
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const SettingsPage(),
),
);
},
),
_buildThemeToggle(context),
const Divider(),
_buildNavigationTile(
context: context,
title: 'Relatórios',
icon: Icons.bar_chart,
onTap: () {
Navigator.pop(context);
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const ReportsPage(),
),
);
},
),
_buildNavigationTile(
context: context,
title: 'Sobre o App',
icon: Icons.info_outline,
onTap: () {
Navigator.pop(context);
_showAboutDialog(context);
},
),
_buildNavigationTile(
context: context,
title: 'Sair',
icon: Icons.exit_to_app,
onTap: () {
Navigator.pop(context);
_showLogoutConfirmation(context);
},
),
],
),
),
_buildVersionInfo(context),
],
),
);
}

Widget _buildDrawerHeader(BuildContext context) {
final userProvider = Provider.of<UserProvider>(context);
final user = userProvider.userProfile;

return DrawerHeader(
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
botecoWine,
botecoWine.withOpacity(0.8),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
CircleAvatar(
backgroundColor: Colors.white,
radius: 30,
child: Icon(
Icons.sports_bar,
size: 32,
color: botecoWine,
),
).animate()
.scale(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500)),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
Text(
'Boteco PRO',
style: Theme.of(context).textTheme.titleLarge!.copyWith(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
'Gestão completa para seu bar',
style: Theme.of(context).textTheme.bodyMedium!.copyWith(
color: Colors.white.withOpacity(0.9),
),
),
],
),
),
],
),
const Spacer(),
Text(
'Usuário: ${user.name}',
style: Theme.of(context).textTheme.bodyMedium!.copyWith(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
user.email,
style: Theme.of(context).textTheme.bodySmall!.copyWith(
color: Colors.white.withOpacity(0.9),
),
),
],
),
);
}

Widget _buildSyncTile(BuildContext context, ServiceProvider serviceProvider) {
return ListTile(
leading: Icon(
Icons.sync,
color: serviceProvider.isOnline ? Colors.green : Colors.grey,
),
title: Text('Sincronização'),
subtitle: Text(
serviceProvider.isOnline
? 'Modo Online'
: 'Modo Offline',
style: TextStyle(
color: serviceProvider.isOnline ? Colors.green : Colors.grey,
fontWeight: FontWeight.bold,
),
),
trailing: Switch(
value: serviceProvider.isOnline,
onChanged: (value) async {
await serviceProvider.toggleOnlineMode(value);
},
activeColor: Colors.green,
),
);
}

Widget _buildNavigationTile({
required BuildContext context,
required String title,
required IconData icon,
required VoidCallback onTap,
}) {
return ListTile(
leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
title: Text(title),
onTap: () {
// Play navigation sound
Provider.of<SoundProvider>(context, listen: false).playNavegacao();
onTap();
},
);
}

Widget _buildThemeToggle(BuildContext context) {
final themeProvider = Provider.of<ThemeProvider>(context);

return ListTile(
leading: Icon(
themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
color: Theme.of(context).colorScheme.primary,
),
title: Text('Modo Escuro'),
trailing: Switch(
value: themeProvider.isDarkMode,
onChanged: (value) {
themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
},
activeColor: botecoWine,
),
);
}

Widget _buildVersionInfo(BuildContext context) {
return Container(
padding: const EdgeInsets.symmetric(vertical: 16),
child: Text(
'Versão 1.0.0',
style: Theme.of(context).textTheme.bodySmall!.copyWith(
color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
),
textAlign: TextAlign.center,
),
);
}

void _showProfileDialog(BuildContext context) {
final userProvider = Provider.of<UserProvider>(context, listen: false);
final user = userProvider.userProfile;

showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Perfil do Usuário'),
content: SizedBox(
width: double.maxFinite,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
CircleAvatar(
backgroundColor: botecoWine.withOpacity(0.2),
radius: 50,
child: Icon(
Icons.person,
size: 60,
color: botecoWine,
),
),
const SizedBox(height: 16),
Text(
user.name,
style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
Text(user.email),
const SizedBox(height: 16),
const Divider(),
ListTile(
leading: const Icon(Icons.business),
title: const Text('Estabelecimento'),
subtitle: Text(user.establishment),
),
ListTile(
leading: const Icon(Icons.badge),
title: const Text('Cargo'),
subtitle: Text(user.position),
),
],
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Fechar'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(context);
_showEditProfileDialog(context);
},
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
),
child: Text(
'Editar Perfil',
style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
),
),
],
),
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
CircleAvatar(
backgroundColor: botecoWine.withOpacity(0.2),
radius: 50,
child: Stack(
children: [
Positioned.fill(
child: Icon(
Icons.person,
size: 60,
color: botecoWine,
),
),
Positioned(
right: 0,
bottom: 0,
child: CircleAvatar(
backgroundColor: botecoWine,
radius: 18,
child: IconButton(
icon: const Icon(
Icons.camera_alt,
size: 18,
color: Colors.white,
),
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Função em desenvolvimento')),
);
},
),
),
),
],
),
),
const SizedBox(height: 16),
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

void _showSettingsDialog(BuildContext context) {
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
final userProvider = Provider.of<UserProvider>(context, listen: false);

// Initialize with current settings
bool darkMode = themeProvider.isDarkMode;
bool systemTheme = themeProvider.isSystemMode;
bool notifications = userProvider.notificationsEnabled;
String language = userProvider.language;

showDialog(
context: context,
builder: (context) => StatefulBuilder(
builder: (context, setState) {
return AlertDialog(
title: const Text('Configurações'),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
ListTile(
leading: const Icon(Icons.brightness_auto),
title: const Text('Tema do Sistema'),
trailing: Switch(
value: systemTheme,
onChanged: (value) {
setState(() {
systemTheme = value;
if (systemTheme) {
// If system theme is enabled, disable manual dark mode
darkMode = false;
}
});
},
),
),
ListTile(
leading: const Icon(Icons.dark_mode),
title: const Text('Modo Escuro'),
trailing: Switch(
value: darkMode,
onChanged: systemTheme ? null : (value) {
setState(() {
darkMode = value;
});
},
),
),
ListTile(
leading: const Icon(Icons.notifications),
title: const Text('Notificações'),
trailing: Switch(
value: notifications,
onChanged: (value) {
setState(() {
notifications = value;
});
},
),
),
ListTile(
leading: const Icon(Icons.language),
title: const Text('Idioma'),
subtitle: Text(language),
trailing: const Icon(Icons.arrow_forward_ios, size: 16),
onTap: () {
// Mostrar diálogo de seleção de idioma
showDialog(
context: context,
builder: (context) => SimpleDialog(
title: const Text('Selecionar Idioma'),
children: [
SimpleDialogOption(
onPressed: () {
setState(() {
language = 'Português (Brasil)';
});
Navigator.pop(context);
},
child: const Text('Português (Brasil)'),
),
SimpleDialogOption(
onPressed: () {
setState(() {
language = 'English (US)';
});
Navigator.pop(context);
},
child: const Text('English (US)'),
),
SimpleDialogOption(
onPressed: () {
setState(() {
language = 'Español';
});
Navigator.pop(context);
},
child: const Text('Español'),
),
],
),
);
},
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancelar'),
),
ElevatedButton(
onPressed: () {
// Save theme settings
if (systemTheme) {
themeProvider.setThemeMode(ThemeMode.system);
} else {
themeProvider.setThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
}

// Save other settings
userProvider.setNotificationsEnabled(notifications);
userProvider.setLanguage(language);

Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Configurações salvas com sucesso!'),
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
);
},
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

void _showLogoutConfirmation(BuildContext context) {
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
// Reset service provider to offline mode
final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
serviceProvider.toggleOnlineMode(false);

Navigator.pop(context);

// Show success message and restart the app
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text('Logout realizado com sucesso!'),
backgroundColor: Colors.green,
duration: const Duration(seconds: 2),
action: SnackBarAction(
label: 'OK',
textColor: Colors.white,
onPressed: () {
// Restart app (go to splash screen)
Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(builder: (_) => const SplashScreen()),
(route) => false
);
},
),
),
);

// Navigate back to splash screen after a short delay
Future.delayed(const Duration(seconds: 2), () {
Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(builder: (_) => const SplashScreen()),
(route) => false
);
});
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