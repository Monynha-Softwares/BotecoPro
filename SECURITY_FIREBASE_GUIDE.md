# 🔐 GUIA DE SEGURANÇA - FIREBASE API KEYS

## ⚠️ ATENÇÃO: API Keys Expostas

As credenciais do Firebase estavam expostas no arquivo `lib/firebase_options.dart`. 
Este guia mostra como protegê-las corretamente.

---

## 🛡️ CORREÇÃO IMPLEMENTADA

### 1. Arquivo `.env.example` Criado
- Template para configuração de credenciais
- Contém todas as variáveis necessárias
- Deve ser copiado para `.env` com valores reais

### 2. `.gitignore` Atualizado
- Adicionadas entradas para `.env*`
- Previne commit acidental de credenciais
- Protege ambiente local e CI/CD

---

## 📋 PRÓXIMOS PASSOS

### PASSO 1: Criar arquivo .env local

```bash
# Windows PowerShell
Copy-Item .env.example .env

# Linux/Mac
cp .env.example .env
```

### PASSO 2: Preencher credenciais reais

Edite `.env` e substitua os valores do Firebase Console:

```env
FIREBASE_API_KEY_WEB=AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw
FIREBASE_APP_ID_WEB=1:431701294282:web:781a5858396ff158ffc833
FIREBASE_PROJECT_ID=boteco-pro
# ... etc
```

### PASSO 3: Instalar flutter_dotenv

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Execute:
```bash
flutter pub get
```

### PASSO 4: Atualizar firebase_options.dart

Substitua o arquivo atual por:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ... resto do código
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY_WEB']!,
    appId: dotenv.env['FIREBASE_APP_ID_WEB']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
    measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
  );
  
  // ... resto das plataformas
}
```

### PASSO 5: Carregar .env no main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  // Resto do código...
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AppProviders());
}
```

### PASSO 6: Adicionar .env aos assets no pubspec.yaml

```yaml
flutter:
  assets:
    - .env
```

---

## 🔒 SEGURANÇA ADICIONAL RECOMENDADA

### Para Web (Obrigatório)

1. **Firebase App Check**
   - Acesse Firebase Console > App Check
   - Ative reCAPTCHA v3 para web
   - Configure tokens para Android/iOS

2. **Restricões de API Key**
   - No Google Cloud Console
   - Restrinja API key por domínio
   - Apenas `seu-dominio.com` autorizado

3. **Firebase Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### Para CI/CD

Configure secrets no GitHub Actions:

```yaml
# .github/workflows/deploy.yml
- name: Create .env
  run: |
    echo "FIREBASE_API_KEY_WEB=${{ secrets.FIREBASE_API_KEY_WEB }}" >> .env
    echo "FIREBASE_APP_ID_WEB=${{ secrets.FIREBASE_APP_ID_WEB }}" >> .env
    # ... outros secrets
```

---

## ✅ CHECKLIST DE VALIDAÇÃO

- [ ] `.env.example` criado
- [ ] `.env` no `.gitignore`
- [ ] `.env` criado localmente com credenciais reais
- [ ] `flutter_dotenv` instalado
- [ ] `firebase_options.dart` atualizado para usar dotenv
- [ ] `main.dart` carrega `.env`
- [ ] `.env` adicionado aos assets
- [ ] Testado em desenvolvimento
- [ ] Firebase App Check configurado
- [ ] Security Rules configuradas
- [ ] Secrets configurados no CI/CD
- [ ] Credenciais antigas revogadas (se já commitadas)

---

## 🚨 SE CREDENCIAIS JÁ FORAM COMMITADAS

1. **Revogue as API Keys antigas:**
   - Firebase Console > Project Settings
   - Delete as API keys comprometidas
   - Gere novas

2. **Limpe o histórico do Git (se necessário):**
   ```bash
   # CUIDADO: Reescreve histórico!
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch lib/firebase_options.dart" \
     --prune-empty --tag-name-filter cat -- --all
   
   git push origin --force --all
   ```

3. **Notifique a equipe:**
   - Informe sobre revogação de credenciais
   - Peça para todos atualizarem `.env` local

---

## 📚 RECURSOS

- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/best-practices)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

---

**Criado em:** 26/10/2025  
**Status:** ⚠️ Implementação parcial - requer passos manuais  
**Prioridade:** 🔴 CRÍTICA
