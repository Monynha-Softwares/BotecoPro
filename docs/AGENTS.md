# Codex Agents Guide for BotecoPro-Monorepo

Este arquivo orienta as contribuições automatizadas do Codex neste repositório.

- Priorize sempre os arquivos dentro de `BotecoPro-Backend`.
- Siga o backlog de issues abaixo para evoluir o backend.
- Todas as tasks devem ser implementadas de forma incremental e commitadas com mensagens claras.
- Sempre que possível rode os testes ou validações indicadas em cada issue antes de abrir um PR.

## Backlog de Implementação do BotecoPro-Backend

A tabela a seguir lista as tarefas sugeridas, em ordem de prioridade. Utilize as tags de prioridade para planejar cada fase.

| # | Título | Descrição resumida | Prioridade | Estimativa | Responsável | Dependências |
|---|--------|-------------------|-----------|-----------|-------------|--------------|
| 1 | **DB | schemas base + RLS** | Criar ou revisar schemas `core`, `order`, `invoice`, `inventory`, `client` e `staff`. Definir tabelas principais e políticas RLS usando helper `is_admin()`. | MVP | 8h | TBD | - |
| 2 | **DB | create_order()** | Implementar função `create_order()` que insere pedido e itens. Verificar permissões de acordo com papel do usuário. | MVP | 5h | TBD | 1 |
| 3 | **DB | confirm_order()** | Completar função `confirm_order()` que desconta estoque via trigger e marca pedido como confirmado. | MVP | 5h | TBD | 2 |
| 4 | **DB | generate_invoice()** | Criar RPC `generate_invoice(order_id)` para gerar fatura após confirmação do pedido. | MVP | 5h | TBD | 3 |
| 5 | **View | vw_low_stock** | Criar view `vw_low_stock` para exibir produtos abaixo do estoque mínimo. | MVP | 3h | TBD | 1 |
| 6 | **EdgeFn | agendamento invoice** | Agendar execução diária de `generate_invoice()` usando Edge Function cron. | Next | 4h | TBD | 4 |
| 7 | **Notif | alerta baixo estoque** | Função periódica que consulta `vw_low_stock` e envia e-mail/push para administradores. | Next | 4h | TBD | 5 |
| 8 | **API | OpenAPI atualizado** | Atualizar `openapi.yaml` com todas RPCs e tabelas e gerar cliente Flutter. | Next | 6h | TBD | 2,4 |
| 9 | **DB | ponto eletrônico** | Criar tabelas e RPCs para controle de ponto e folha de pagamento. | Future | 8h | TBD | 1 |
|10 | **Infra | auditing & logs** | Implementar tabelas de auditoria e triggers para registrar alterações críticas. | Future | 6h | TBD | 1 |
|11 | **Integr | webhooks pagamento** | Preparar endpoints ou funções para processar webhooks de pagamento (ex.: adquirentes). | Future | 6h | TBD | 4 |

### Detalhamento das Principais Funções

Abaixo seguem passos em alto nível/pseudocódigo para algumas funções chave. Ajuste os nomes dos schemas conforme definido na Fase 1.

#### create_order()
```sql
CREATE OR REPLACE FUNCTION order.create_order(
    p_client_id uuid,
    p_items jsonb
) RETURNS uuid AS $$
DECLARE
    v_order_id uuid := gen_random_uuid();
BEGIN
    INSERT INTO order.orders(id, client_id, status, created_at)
    VALUES (v_order_id, p_client_id, 'pending', now());

    INSERT INTO order.order_items(order_id, product_id, qty)
    SELECT v_order_id, (item->>'product_id')::uuid, (item->>'qty')::int
    FROM jsonb_array_elements(p_items) AS item;

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### confirm_order()
```sql
CREATE OR REPLACE FUNCTION order.confirm_order(p_order_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE order.orders SET status = 'confirmed', confirmed_at = now()
    WHERE id = p_order_id;
    -- Descontar estoque via trigger em order_items
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### generate_invoice()
```sql
CREATE OR REPLACE FUNCTION invoice.generate_invoice(p_order_id uuid)
RETURNS uuid AS $$
DECLARE
    v_invoice_id uuid := gen_random_uuid();
BEGIN
    INSERT INTO invoice.invoices(id, order_id, total, created_at)
    SELECT v_invoice_id, o.id, SUM(i.price * i.qty), now()
    FROM order.orders o
    JOIN order.order_items i ON i.order_id = o.id
    WHERE o.id = p_order_id
    GROUP BY o.id;
    RETURN v_invoice_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### vw_low_stock
```sql
CREATE OR REPLACE VIEW inventory.vw_low_stock AS
SELECT id, name, qty, min_qty
FROM inventory.products
WHERE qty < min_qty;
```

Use essas referências como ponto de partida para preenchimento dos scripts em `BotecoPro-Backend/database/supabase`.

