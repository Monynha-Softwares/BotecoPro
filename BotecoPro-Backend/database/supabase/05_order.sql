CREATE SCHEMA IF NOT EXISTS "order";

CREATE TABLE IF NOT EXISTS "order".orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid NOT NULL REFERENCES client.clients(id),
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  confirmed_at timestamptz
);

CREATE TABLE IF NOT EXISTS "order".order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES "order".orders(id),
  product_id uuid NOT NULL REFERENCES inventory.products(id),
  qty integer NOT NULL,
  price numeric NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "order".orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE "order".order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "order admin" ON "order".orders
  FOR ALL USING (core.is_admin());
CREATE POLICY "order items admin" ON "order".order_items
  FOR ALL USING (core.is_admin());

-- RPC to create an order and its items
CREATE OR REPLACE FUNCTION "order".create_order(
  p_client_id uuid,
  p_items jsonb
) RETURNS uuid AS $$
DECLARE
  v_order_id uuid := gen_random_uuid();
BEGIN
  IF NOT (
    core.is_admin() OR
    EXISTS (
      SELECT 1 FROM client.clients c
      WHERE c.id = p_client_id AND c.user_id = auth.uid()
    )
  ) THEN
    RAISE EXCEPTION 'insufficient_privilege';
  END IF;

  INSERT INTO "order".orders(id, client_id, status, created_at)
  VALUES (v_order_id, p_client_id, 'pending', now());

  INSERT INTO "order".order_items(order_id, product_id, qty, price)
  SELECT
    v_order_id,
    (item->>'product_id')::uuid,
    (item->>'qty')::int,
    (item->>'price')::numeric
  FROM jsonb_array_elements(p_items) AS item;

  RETURN v_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
