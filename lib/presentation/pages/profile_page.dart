// lib/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'account_page.dart';

/// ProfilePage - Wrapper that redirects to AccountPage
/// 
/// This maintains backward compatibility with existing navigation structure
/// while using the new Supabase-powered AccountPage
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountPage();
  }
}

            },
          ),
        ),
      ),
    );
  }
}

// Fim do arquivo
