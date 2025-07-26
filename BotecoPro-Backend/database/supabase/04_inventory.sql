CREATE SCHEMA IF NOT EXISTS inventory;

CREATE TABLE IF NOT EXISTS inventory.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric NOT NULL,
  qty integer NOT NULL DEFAULT 0,
  min_qty integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE inventory.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "inventory admin" ON inventory.products
  FOR ALL USING (core.is_admin());
