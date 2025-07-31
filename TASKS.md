Objetivo:
Corrigir e atualizar o código base do aplicativo Flutter BotecoPro, utilizando exclusivamente a API provida pelo Supabase, conforme a nova estrutura de banco de dados.

Contexto:
- Todos os scripts SQL da pasta `supabase/` já foram executados com sucesso.
- A base de dados está atualizada com os domínios `core`, `client`, `order`, `invoice`, `staff` e `inventory`.
- A comunicação com o Supabase deve ser feita exclusivamente por meio das views, funções e policies definidas no backend.
- As credenciais de acesso estão disponíveis no arquivo `.env` do projeto.

### 🔒 Antes de modificar qualquer código:
1. Carregue as variáveis do arquivo `.env` e teste a conectividade com o Supabase como cliente (usando `supabase_flutter`).
2. Verifique se é possível autenticar, fazer um `select` simples e uma `rpc()` com sucesso.

### 🔧 Etapas para corrigir o código base:

**Etapa 1 – Inicialização do Supabase:**
- Substitua credenciais hardcoded pela leitura via `.env`.
- Garanta que `Supabase.initialize` seja feito corretamente no `main.dart`.

**Etapa 2 – Refatorar autenticação:**
- Certifique-se de que login, registro e persistência de sessão usam `supabase.auth`.
- Remova serviços antigos (`DatabaseService`, `ApiService`, `SharedPreferences`, etc.) que não são mais usados.

**Etapa 3 – Refatorar a camada de dados:**
- Para cada domínio (ex: mesas, pedidos, vendas, produtos), crie serviços ou providers que consumam exclusivamente:
  - `supabase.from('tabela').select()`
  - `supabase.rpc('minha_funcao', params)`
- Utilize as views e functions criadas para abstrair a lógica do app.

**Etapa 4 – Atualizações em tempo real:**
- Implemente escuta via `supabase.channel().on(PostgresChange)` para pedidos e vendas.
- Use `StreamBuilder` para refletir atualizações automáticas no app.

**Etapa 5 – Sincronização e controle offline (opcional se brick for ativado depois):**
- Planeje persistência local (com Hive, Isar ou Brick) se necessário.
- Assegure que dados possam ser sincronizados via `stream()` ou manualmente.

**Etapa 6 – Remoção de código legado:**
- Elimine qualquer chamada HTTP direta, classes mock, ou serviços desatualizados.
- Mantenha o código limpo, modular e testável.

**Etapa 7 – Testes manuais e UI:**
- Teste os fluxos principais (login, listar mesas, abrir pedidos, pagar, etc.).
- Verifique se as alterações em tempo real estão funcionando.
- Adicione mensagens de erro e indicadores de carregamento onde necessário.

---

⚠️ Atenção: Nenhum dado deve ser salvo localmente fora dos providers, a menos que seja para cache offline com controle de sincronização.

📦 Pacotes recomendados: `supabase_flutter`, `flutter_dotenv`, `riverpod`, `freezed`, `json_serializable`.

🎯 Resultado esperado: um app funcional conectado exclusivamente ao Supabase, refletindo a nova estrutura de dados, com código limpo, modular e alinhado ao backend.

