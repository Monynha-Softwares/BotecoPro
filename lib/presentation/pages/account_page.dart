// lib/presentation/pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import 'login_page.dart';

/// AccountPage - User Profile Management
/// 
/// Features:
/// - Display user email (from auth.currentUser)
/// - Edit username and website (from profiles table)
/// - Update profile in Supabase
/// - Sign out functionality
/// 
/// Connected to profiles table via RLS policies
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;
  var _loading = true;

  /// Load user profile from profiles table
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });
    
    try {
      final userId = supabase.auth.currentSession!.user.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      _usernameController.text = (data['username'] ?? '') as String;
      _websiteController.text = (data['website'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Erro ao carregar perfil', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Update user profile in profiles table
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    
    final userName = _usernameController.text.trim();
    final website = _websiteController.text.trim();
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) context.showSnackBar('Perfil atualizado com sucesso!');
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Erro ao atualizar perfil', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Sign out user
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Erro ao sair', isError: true);
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // User Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                (user?.email ?? 'U').substring(0, 1).toUpperCase(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  Text(
                                    user?.email ?? 'Não disponível',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Profile Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Informações do Perfil',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome de Usuário',
                            hintText: 'Digite seu nome de usuário',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_loading,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Website Field
                        TextField(
                          controller: _websiteController,
                          decoration: const InputDecoration(
                            labelText: 'Website',
                            hintText: 'https://exemplo.com',
                            prefixIcon: Icon(Icons.language),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                          enabled: !_loading,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Update Button
                        FilledButton.icon(
                          onPressed: _loading ? null : _updateProfile,
                          icon: const Icon(Icons.save),
                          label: Text(_loading ? 'Salvando...' : 'Atualizar Perfil'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sign Out Button
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da Conta'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
    );
  }
}
